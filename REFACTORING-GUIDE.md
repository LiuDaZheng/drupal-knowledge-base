# 重构指南 - Renew Branch

## 🎯 核心原则

### 铁律：禁止直接精简，只进行合理拆分

**❌ 错误做法：**
- 直接删除内容以减小文件大小
- 简化文档内容
- 移除"不重要"的信息

**✅ 正确做法：**
- 按照文档板块进行逻辑拆分
- 将大文件分解为更小、更专注的文件
- 保持内容完整性，只改变组织结构

## 📋 文件拆分最佳实践

### 1. 按知识领域拆分

```
drupal-knowledge-base/
├── README.md                    # 项目说明
├── docs/
│   ├── drupal-basics/           # Drupal 基础
│   │   ├── architecture.md
│   │   ├── modules.md
│   │   └── themes.md
│   ├── development/             # 开发指南
│   │   ├── custom-modules.md
│   │   ├── hooks.md
│   │   └── services.md
│   ├── site-building/           # 站点构建
│   │   ├── content-types.md
│   │   ├── views.md
│   │   └── permissions.md
│   └── deployment/              # 部署指南
│       ├── ci-cd.md
│       └── hosting.md
├── src/                         # 源代码/脚本
└── tests/                       # 测试
```

### 2. 按内容类型拆分

**README.md 拆分策略：**
- 保留项目概述和快速开始
- 将详细教程移到 `docs/` 目录
- 将参考文档移到 `docs/reference/` 目录
- 将示例移到 `examples/` 目录

### 3. 文档拆分标准

| 文件类型 | 建议大小 | 拆分触发点 |
|---------|---------|-----------|
| README.md | < 1000 行 | 超过 1000 行时拆分 |
| 教程文档 | < 800 行 | 超过 800 行时拆分 |
| 参考文档 | < 600 行 | 超过 600 行时拆分 |
| 配置文件 | < 200 行 | 超过 200 行时拆分 |

## 🔧 拆分步骤

### 步骤 1: 分析现有内容

```bash
# 检查文件大小
wc -l README.md

# 识别主要板块
grep "^## " README.md
```

### 步骤 2: 创建新文件结构

```bash
# 创建目录结构
mkdir -p docs/drupal-basics docs/development docs/site-building

# 移动内容到对应文件
# (保持内容完整，只改变位置)
```

### 步骤 3: 更新引用

- 更新所有内部链接
- 确保路径正确
- 测试链接有效性

### 步骤 4: 验证

```bash
# 运行 CI/CD 验证
git add .
git commit -m "docs: 拆分知识库内容"
git push origin renew
```

## 📊 拆分检查清单

### 拆分前
- [ ] 已分析文件内容结构
- [ ] 已识别逻辑板块
- [ ] 已规划新文件结构
- [ ] 已备份原始文件

### 拆分后
- [ ] 所有文件 < 建议大小限制
- [ ] 内容完整性已验证
- [ ] 内部链接已更新
- [ ] CI/CD 验证通过
- [ ] 文档可读性提升

## 🚀 CI/CD 验证要求

### 必须通过的检查
1. ✅ YAML Lint 验证
2. ✅ Markdown Lint 验证
3. ✅ 文档结构验证
4. ✅ 安全检查
5. ✅ 文档完整性检查

### 提交要求
- 所有自动化测试必须通过
- 代码审查必须完成
- 文档更新必须完整

## 📝 示例：知识库拆分

### 拆分前
```
README.md (2500 行)
├── 项目介绍
├── Drupal 基础
├── 模块开发
├── 主题定制
├── 站点构建
├── 部署指南
└── 常见问题
```

### 拆分后
```
README.md (300 行)              # 项目概述和快速开始
docs/
├── drupal-basics/ (500 行)     # Drupal 基础
├── development/ (800 行)       # 开发指南
├── site-building/ (600 行)     # 站点构建
└── deployment/ (300 行)        # 部署指南
```

## ⚠️ 注意事项

1. **保持内容完整**: 拆分不删除，只重组
2. **更新所有链接**: 确保内部和外部链接都指向正确位置
3. **测试验证**: 每次拆分后运行完整的 CI/CD 流程
4. **文档同步**: 确保所有相关文档都更新

## 📚 参考资源

- [Drupal 官方文档](https://www.drupal.org/docs)
- [Git 分支管理最佳实践](https://git-scm.com/book/en/v2/Git-Branching)
- [技术文档组织指南](https://documentation.divio.com/)

---

*最后更新：2026-04-12*
*分支：renew*
*状态：活跃开发中*
