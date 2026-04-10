# AI Agent 死循环防护最佳实践

**版本**: v1.0  
**更新日期**: 2026-04-08  
**来源**: 基于行业标准和 Agent Patterns 研究

---

## 🎯 核心发现

**关键结论**: 死循环防护应该由 **Agent Runtime（运行时）** 实现，而不是 Agent Prompt 或技能文档。

> "Loop control should live not in the agent itself, but in separate architecture layers." - Agent Patterns

---

## 📚 行业标准实践

### 1. **AI SDK** (ai-sdk.dev)

**实现方式**:
```typescript
// 使用内置的 loop control 参数
const agent = new Agent({
  instructions: "...",
  tools: [...],
  stopWhen: stepCountIs(20),  // 硬编码的步数限制
  prepareStep: (context) => {
    // 在每步之间调整配置
    return context;
  }
});
```

**默认配置**:
- `max_steps: 20` (默认)
- `timeout: 300s` (默认)
- `max_tokens_per_step: 2000`

### 2. **Agent Patterns** (agentpatterns.tech)

**四层防护架构**:

```
┌─────────────────────────────────────┐
│  Agent Runtime                       │
│  - max_steps (硬限制)                │
│  - timeout (超时控制)                │
│  - max_tokens (流量控制)             │
│  - stop_reason (终止原因)            │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Tool Execution Layer                │
│  - call deduplication (防重复调用)   │
│  - retry policy (重试策略)           │
│  - error normalization (错误标准化)  │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Agent Prompt                        │
│  - 理解停止条件                      │
│  - 给出有意义的反馈                  │
└─────────────────────────────────────┘
```

**检测指标**:

| 指标 | 描述 | 阈值建议 |
|------|------|---------|
| `steps_per_task` | 每个任务的步数 | > 30 告警 |
| `repeated_tool_calls` | 重复工具调用 | > 3 次告警 |
| `no_progress_steps` | 无进展步数 | > 5 步停止 |
| `tokens_per_task` | 每个任务的 token | > 10k 告警 |
| `timeout_rate` | 超时率 | > 5% 告警 |

### 3. **Dev.to 研究** (2026-01)

**7 项基础最佳实践**:

1. **Hard Turn Limits (TTL/Max Hop Count)**
   - 设置最大对话轮次
   - 框架支持：AutoGen, LangChain, CrewAI

2. **Clear Termination Functions**
   - 定义明确的完成任务条件
   - 使用明确信号如 `TASK_COMPLETED`

3. **Mandatory Final States**
   - 定义最终状态：`completed`, `failed`, `needs_human`
   - 每个任务必须有明确的终点

4. **Circuit Breakers on Retry/Handoff**
   - 如果重试 N 次失败，触发断路器
   - 防止循环传递

5. **Task ID Idempotency and Deduplication**
   - 为每个任务分配唯一 ID
   - 防止重复处理

6. **Rules for Anti-Recursion**
   - 限制同一任务传递给同一 agent 的次数

7. **Tracing and Monitoring**
   - 记录完整的 agent 交互链
   - 自动化异常检测

---

## 🛠️ OpenClaw 实现建议

### 1. **Runtime 层面 (必须实现)**

```python
class LoopGuard:
    def __init__(self):
        self.max_steps = 20
        self.file_read_limit = 5  # 每个文件最多读取 5 次
        self.token_limit = 50000  # 每任务 token 限制
        self.timeout = 300  # 5 分钟超时
        
    def on_step(self, step_data):
        # 检查硬限制
        if step_data.steps >= self.max_steps:
            return "max_steps_reached"
        
        # 检查文件读取限制
        if step_data.file_reads[step_data.current_file] >= self.file_read_limit:
            return "file_read_limit_reached"
        
        # 检查 token 使用
        if step_data.total_tokens >= self.token_limit:
            return "token_limit_reached"
        
        # 检查重复调用
        if self.check_repeated_calls(step_data):
            return "repeated_calls_detected"
        
        # 检查无进展
        if self.check_no_progress(step_data):
            return "no_progress"
        
        return None
    
    def check_repeated_calls(self, data):
        """检测重复的工具调用"""
        recent_calls = data.recent_tool_calls[-10:]
        unique_calls = set(recent_calls)
        if len(recent_calls) - len(unique_calls) > 3:
            return True
        return False
    
    def check_no_progress(self, data):
        """检测连续 N 步无进展"""
        recent_outputs = data.recent_outputs[-5:]
        # 检查语义相似度
        if self.calculate_similarity(recent_outputs) > 0.8:
            return True
        return False
```

### 2. **Agent Prompt 层面 (推荐实现)**

在 `AGENTS.md` 中保留行为指南（已实现）：

```markdown
### 🛡️ 死循环防护指南

当 Agent 需要读取大型文件时，必须：
1. 估算文件大小，设置读取次数上限
2. 每次读取后检查是否应该停止
3. 检测到重复内容时立即停止
4. 即使没找到也要给出有意义的结论
```

### 3. **Skill 层面 (可选)**

简短提示即可（已简化 SKILL.md）：

```markdown
**文件读取建议**: 
- 优先使用搜索功能
- 注意检测内容重复
- 参考 AGENTS.md 中的防护指南
```

---

## 📊 检测机制实现

### 1. **硬限制检测**

```python
def detect_hard_loop(data):
    """检测硬循环：同样的工具调用重复多次"""
    call_history = data.recent_tool_calls
    if len(call_history) < 10:
        return False
    
    # 检查最近 10 次调用是否重复
    recent = call_history[-10:]
    unique = set(recent)
    
    if len(recent) - len(unique) > 3:
        return True
    return False
```

### 2. **软循环检测**

```python
def detect_soft_loop(data):
    """检测软循环：参数微小变化的重复调用"""
    recent_calls = data.recent_tool_calls[-10:]
    
    for i in range(len(recent_calls) - 1):
        if is_similar_call(recent_calls[i], recent_calls[i+1]):
            return True
    return False

def is_similar_call(call1, call2):
    """检测两个调用是否相似"""
    if call1['tool'] != call2['tool']:
        return False
    
    # 检查参数相似度
    similarity = calculate_semantic_similarity(
        call1['args'], call2['args']
    )
    return similarity > 0.9
```

### 3. **语义循环检测**

```python
def detect_semantic_loop(data):
    """检测语义循环：内容重复但表述不同"""
    recent_outputs = data.recent_outputs[-5:]
    
    if len(recent_outputs) < 3:
        return False
    
    # 检查最近 3 次输出的语义相似度
    similarities = []
    for i in range(len(recent_outputs) - 1):
        sim = calculate_semantic_similarity(
            recent_outputs[i], recent_outputs[i+1]
        )
        similarities.append(sim)
    
    avg_similarity = sum(similarities) / len(similarities)
    return avg_similarity > 0.85
```

---

## 🔍 测试用例

### 测试 1: Hard Loop

```python
def test_hard_loop_detection():
    data = MockStepData(tool_calls=[
        "read:file.md",
        "read:file.md",
        "read:file.md",
        "read:file.md",
        "read:file.md"
    ])
    
    assert detect_hard_loop(data) == True
```

### 测试 2: Soft Loop

```python
def test_soft_loop_detection():
    data = MockStepData(tool_calls=[
        "search:"query A",
        "search:"query A more",
        "search:"query A more please"
    ])
    
    assert detect_soft_loop(data) == True
```

### 测试 3: Semantic Loop

```python
def test_semantic_loop_detection():
    data = MockStepData(outputs=[
        "Looking for运维工具... not found yet.\nContinue scanning...",
        "Looking for运维工具... still not found.\nContinuing...",
        "Looking for运维工具... no results yet.\nScanning more..."
    ])
    
    assert detect_semantic_loop(data) == True
```

---

## 📈 监控指标

### 运行时指标

| 指标 | 说明 | 告警阈值 |
|------|------|---------|
| `loop_prevention_triggered` | 循环防护触发次数 | > 0/小时 |
| `max_steps_reached` | 达到最大步数 | > 1/任务 |
| `repeated_calls_detected` | 检测到重复调用 | > 5/小时 |
| `avg_steps_per_task` | 平均任务步数 | > 25 |
| `avg_tokens_per_task` | 平均任务 token | > 60k |

### 用户体验指标

| 指标 | 说明 | 目标 |
|------|------|------|
| `task_completion_rate` | 任务完成率 | > 95% |
| `avg_task_duration` | 平均任务时长 | < 120s |
| `user_intervention_rate` | 用户干预率 | < 5% |

---

## 🎓 参考资源

1. **AI SDK Loop Control**
   - URL: https://ai-sdk.dev/docs/agents/loop-control
   - 内容：内置 loop control 参数实现

2. **Agent Patterns - Infinite Loop**
   - URL: https://www.agentpatterns.tech/en/failures/infinite-loop
   - 内容：生产环境中的无限循环案例和解决方案

3. **Dev.to - Stop the Loop**
   - URL: https://dev.to/alessandro_pignati/stop-the-loop-how-to-prevent-infinite-conversations-in-your-ai-agents-ekj
   - 内容：7 项基础最佳实践

4. **OpenAI Cookbook**
   - URL: https://cookbook.openai.com/examples/loop_control
   - 内容：实际代码示例

---

## 💡 总结

1. **Runtime 优先**: 死循环防护应该由 OpenClaw 的 runtime 层实现
2. **多层次防护**: 结合硬限制、软检测、语义分析
3. **监控告警**: 建立完善的检测指标和告警机制
4. **Prompt 补充**: AGENTS.md 中的指南作为补充，不是核心
5. **持续改进**: 定期回顾和调整防护策略

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**维护者**: OpenClaw Team  
**最后更新**: 2026-04-08
