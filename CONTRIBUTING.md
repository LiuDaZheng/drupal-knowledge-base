# 贡献指南

欢迎贡献 Drupal Knowledge Base 项目！本指南帮助你快速上手。

## 如何提交代码

1. **Fork 项目**
   - 在 GitHub 上点击 Fork 按钮

2. **创建功能分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **提交更改**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

4. **推送到分支**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **开启 Pull Request**
   - 在 GitHub 上创建 PR，描述你的更改

## 代码规范

### Skill 开发规范

- **行数限制**: Skill 文件 < 500 行
- **YAML frontmatter**: 必须完整包含 name、description、metadata
- **使用示例**: 至少提供 3 个使用示例
- **提交规范**: 遵循 Conventional Commits

### Drupal 知识规范

- **准确性**: 确保所有 Drupal 相关信息准确无误
- **版本标注**: 明确标注适用的 Drupal 版本
- **代码示例**: 提供可运行的代码示例
- **引用来源**: 引用官方文档和可靠来源

### Conventional Commits 格式

```
<type>: <description>

[optional body]

[optional footer]
```

### 提交类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: add Drupal module guide` |
| `fix` | Bug 修复 | `fix: correct configuration steps` |
| `docs` | 文档更新 | `docs: update API reference` |
| `style` | 代码格式 | `style: format markdown` |
| `refactor` | 重构 | `refactor: reorganize knowledge base` |
| `test` | 测试 | `test: add validation tests` |
| `chore` | 构建/工具 | `chore: update dependencies` |

## 开发环境

### 前置要求

- Node.js >= 18
- OpenClaw >= 1.0
- Drupal 环境（用于测试）

### 本地测试

```bash
# 安装依赖
npm install

# 运行测试
npm test

# 代码检查
npm run lint

# 验证知识库结构
npm run validate:knowledge
```

## 知识贡献流程

1. 创建或更新知识条目
2. 运行本地验证
3. 提交 PR
4. 维护者审查
5. 合并到主分支

## 代码审查流程

1. PR 创建后自动触发 CI 检查
2. 维护者进行代码审查
3. 根据反馈进行修改
4. 审查通过后合并

## 问题反馈

- 使用 GitHub Issues 报告 Bug
- 使用 Discussions 讨论新功能
- 紧急问题联系维护者

## 许可证

本项目采用 MIT 许可证。
