# 🛠️ Drush 自动化部署命令

**版本**: v1.0  
**Drupal**: 11.x  
**目标**: 部署脚本中 Drush 命令的正确使用

---

## 📋 命令顺序原则

### ✅ 正确的部署顺序

```bash
# 1. 数据库更新（必须在任何配置导入之前）
drush updatedb --strict=0

# 2. 清除缓存（让数据库更新生效）
drush cache:rebuild

# 3. 导入配置（从文件同步到数据库）
drush config:import

# 4. 再次清除缓存（让配置生效）
drush cache:rebuild
```

### ❌ 错误示例

```bash
# 错误 1: 在 updatedb 之前导入配置
drush config:import  # ❌ 配置可能引用了新的数据库结构

# 错误 2: 不清除缓存
drush updatedb
drush config:import
# ❌ 缓存仍然使用旧的 schema 和配置
```

---

## 🔧 核心部署命令详解

### 1. drush updatedb

**用途**: 运行数据库更新钩子

```bash
# 基本用法
drush updatedb --strict=0

# 模拟运行（测试）
drush updatedb --simulate --strict=0

# 静默模式
drush updatedb --quiet

# 详细日志
drush updatedb --verbose
```

**参数说明**:
- `--strict=0`: 允许跳过一些警告
- `--simulate`: 模拟运行，不实际执行
- `--force`: 强制更新（不推荐）

### 2. drush config:import

**用途**: 从配置同步目录导入配置

```bash
# 基本用法
drush config:import --all

# 预览变化（模拟）
drush config:import --preview

# 强制导入（覆盖本地配置）
drush config:import --force
```

### 3. drush cache:rebuild

**用途**: 重构各种缓存表

```bash
# 基本用法
drush cache:rebuild

# 静默模式
drush cache:rebuild --quiet
```

---

## 🧪 测试和验证命令

### 1. 环境状态检查

```bash
# JSON 格式（便于 Agent 解析）
drush status --format=json

# 仅数据库状态
drush status --db-status

# 仅核心版本
drush status --fields=version
```

### 2. 配置状态检查

```bash
# 查看配置状态
drush config:status

# JSON 格式
drush config:status --format=json

# 仅显示有差异的配置
drush config:status --format=json | jq 'map(select(.value.status != "identical"))'
```

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**维护者**: Gates (OpenClaw)
