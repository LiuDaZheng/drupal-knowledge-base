# Drupal Knowledge Base - 目录结构说明

> **核心原则**: 清晰的目录结构便于维护和扩展

**更新时间**: 2026-04-08
**维护**: OpenClaw Marvin

---

## 📁 目录结构总览（v4.0 最新）

```
drupal-knowledge-base/
├── SKILL.md                      # 主技能文档（入口点）
├── STRUCTURE.md                  # ← 本文件（目录说明）
├── 00-INDEX.md                   # ← 完整索引 v4.0
│
├── contrib/
│   ├── ecommerce/               # ← 电商模块组 (19 个)
│   │   ├── commerce-stripe.md
│   │   ├── commerce-paypal.md
│   │   ├── commerce-shipping.md
│   │   ├── commerce-license.md  # ← NEW! 许可证管理
│   │   └── license/             # ← License 子目录 (7 个详细文档)
│   │       ├── README.md
│   │       ├── license-api-reference.md
│   │       ├── license-activation-guide.md
│   │       ├── subscription-plans-config.md
│   │       ├── license-validation-best-practices.md
│   │       ├── saas-integration-examples.md
│   │       └── enterprise-deployment.md
│   │
│   └── modules/                 # 其他贡献模块 (2 个)
│       ├── drupal-11-extended-modules-study.md
│       └── metatag.md
│
├── core-modules/                # 核心模块 (17 个) ✅
│   ├── 00-index.md
│   ├── 01-system-core.md
│   ├── 02-node.md
│   ├── ... (共 17 个核心模块)
│   └── commerce.md              # Commerce 核心
│
├── solutions/                   # 解决方案 (7 个) ✅
│   ├── drupal-11-ecommerce-20-modules.md
│   └── ... (共 7 个方案)
│
├── ops/                         # 运维文档 (5 个) ✅
│   ├── cicd-*.md
│   └── ... 
│
└── best-practices/              # 最佳实践 (2 个) ✅
    ├── cicd-security.md
    └── code-style.md
```

```
drupal-knowledge-base/
├── SKILL.md                      # 主技能文档（入口点）
├── STRUCTURE.md                  # 本文件（目录说明）
│
├── drupal-core/                  # 核心版本文档
│   ├── 00-overview.md           # Drupal 核心介绍
│   ├── migration.md             # 迁移指南
│   ├── 11-overview.md           # Drupal 11 特性
│   └── 12-beta.md               # Drupal 12 Beta
│
├── core-modules/                 # 核心模块（每个模块独立目录）
│   ├── system-core/
│   │   └── index.md
│   ├── node/
│   │   └── index.md
│   ├── user/
│   │   └── index.md
│   ├── field/
│   │   └── index.md
│   ├── views/
│   │   └── index.md
│   ├── config/
│   │   └── index.md
│   ├── entity/
│   │   └── index.md
│   ├── layout-builder/
│   │   └── index.md
│   ├── media/
│   │   └── index.md
│   └── webform/
│       └── index.md
│
├── contrib-modules/              # 扩展模块（每个模块独立目录）
│   ├── commerce/
│   │   ├── index.md
│   │   ├── dependencies/
│   │   │   └── list.md
│   │   ├── api/
│   │   │   └── reference.md
│   │   └── examples/
│   │       └── ecommerce.md
│   ├── bat/
│   │   ├── index.md
│   │   ├── dependencies/
│   │   │   └── list.md
│   │   ├── api/
│   │   │   └── reference.md
│   │   └── examples/
│   │       └── booking.md
│   ├── jsonapi/
│   │   ├── index.md
│   │   ├── dependencies/
│   │   │   └── list.md
│   │   ├── api/
│   │   │   └── reference.md
│   │   └── examples/
│   │       └── rest_api.md
│   ├── workflow/
│   │   ├── index.md
│   │   ├── dependencies/
│   │   │   └── list.md
│   │   └── api/
│   │       └── reference.md
│   ├── metatag/
│   │   ├── index.md
│   │   ├── dependencies/
│   │   │   └── list.md
│   │   └── api/
│   │       └── reference.md
│   ├── pathauto/
│   │   ├── index.md
│   │   ├── dependencies/
│   │   │   └── list.md
│   │   └── api/
│   │       └── reference.md
│   ├── redirect/
│   │   ├── index.md
│   │   ├── dependencies/
│   │   │   └── list.md
│   │   └── api/
│   │       └── reference.md
│   └── paragraphs/
│       ├── index.md
│       ├── dependencies/
│       │   └── list.md
│       └── api/
│           └── reference.md
│
├── solutions/                    # 解决方案
│   ├── ecommerce/
│   │   └── index.md
│   ├── booth-booking/
│   │   └── index.md
│   ├── multilingual/
│   │   └── index.md
│   ├── headless/
│   │   └── index.md
│   └── enterprise/
│       └── index.md
│
├── dev/                          # 开发指南
│   ├── environment-setup/
│   │   └── index.md
│   ├── module-development/
│   │   ├── index.md
│   │   ├── api/
│   │   │   └── reference.md
│   │   └── examples/
│   │       └── sample_module.md
│   ├── custom-themes/
│   │   ├── index.md
│   │   ├── templates/
│   │   │   └── sample.html.twig
│   │   └── assets/
│   │       └── styles.scss
│   ├── api-usage/
│   │   └── index.md
│   └── testing/
│       ├── unit-testing.md
│       ├── functional-testing.md
│       └── best-practices.md
│
├── ops/                          # 运维文档
│   ├── security.md              # 安全配置
│   ├── performance.md           # 性能优化
│   ├── backup-restore.md        # 备份与恢复
│   └── deployment.md            # 部署流程
│
├── best-practices/               # 最佳实践
│   ├── code-style.md           # 编码规范
│   ├── standards.md            # 行业标准
│   ├── scaling.md              # 扩展性设计
│   └── api-design.md           # API 设计
│
└── references/                   # 参考资源
    ├── official-links.md       # 官方文档链接
    ├── community-tools.md      # 社区工具
    └── vendor-resources.md     # 供应商资源
```

---

## 📝 文件规范

### 命名规范

**目录命名**:
- 使用小写字母
- 单词用连字符分隔（snake-case 或 kebab-case）
- 示例：`user-management`, `payment-gateway`

**文件命名**:
- `index.md` - 主文档
- `dependencies.md` - 依赖关系
- `api.md` - API 参考
- `examples.md` - 示例代码
- `best-practices.md` - 最佳实践

### 文件内容规范

**每个模块文档必须包含**:

1. **模块概述** - 功能介绍
2. **核心概念** - 基本概念说明
3. **版本兼容性** - 支持的 Drupal 版本
4. **依赖模块** - 依赖关系（新增章节）
5. **安装配置** - 安装步骤和配置
6. **核心架构** - 模块结构和技术架构
7. **数据模型** - ER 图（如有实体关系）
8. **开发指南** - API 和使用方法
9. **使用场景** - 实际应用场景
10. **常见问题** - FAQ
11. **参考资源** - 官方链接

**特殊模块文件**:

| 文件类型 | 用途 | 必须 | 可选 |
|---------|------|------|------|
| `index.md` | 主文档 | ✅ | - |
| `dependencies.md` | 依赖关系 | ❌ | 复杂模块 |
| `api.md` | API 参考 | ❌ | 开发密集型模块 |
| `examples.md` | 使用示例 | ❌ | 应用密集型模块 |

---

## 🗂️ 文件组织原则

### 1. 模块化

- 每个模块独立目录
- 子模块独立子目录
- 避免文件过长（目标 < 5000 行）

### 2. 相关性

- 相关文件放在同一目录
- 代码、配置、示例分开
- 便于维护和理解

### 3. 可发现性

- 清晰的命名
- 统一的文件类型
- 方便搜索和定位

### 4. 可扩展性

- 预留扩展空间
- 模块化设计
- 便于添加新内容

---

## 🔄 目录迁移计划

### 当前状态

**已有目录**:
```
✅ core-modules/ - 已有旧格式文件
✅ contrib/modules/ - 已有旧格式文件
✅ dev/ - 已有部分文件
✅ ops/ - 已创建新文件
✅ best-practices/ - 已创建文件
✅ references/ - 已创建文件
```

### 迁移步骤

**Phase 1: 核心模块迁移**

1. `system-core/01-system-core/` - 已迁移 ✅
2. `node/02-node/` - 待迁移 ⏳
3. `user/03-user/` - 待迁移 ⏳
4. `field/04-field/` - 待迁移 ⏳
5. `entity/05-entity/` - 待迁移 ⏳
6. `views/06-views/` - 待迁移 ⏳
7. `config/07-config/` - 待迁移 ⏳
8. `layout-builder/08-layout-builder/` - 待迁移 ⏳
9. `media/09-media/` - 待迁移 ⏳
10. `webform/10-webform/` - 待迁移 ⏳

**Phase 2: 扩展模块迁移**

1. `commerce/` - 待迁移 ✅ (已有 bat/)
2. `bat/` - 待迁移 ✅ (已创建)
3. `jsonapi/` - 待迁移 ⏳
4. `workflow/` - 待迁移 ⏳
5. `metatag/` - 待迁移 ⏳
6. `pathauto/` - 待迁移 ⏳
7. `redirect/` - 待迁移 ⏳
8. `paragraphs/` - 待迁移 ⏳

**Phase 3: 解决方案迁移**

1. `ecommerce/` - 待迁移 ⏳
2. `booth-booking/` - 待迁移 ✅ (已有 booth-booking)
3. `multilingual/` - 待迁移 ⏳
4. `headless/` - 待迁移 ⏳
5. `enterprise/` - 待迁移 ⏳

---

## 📊 统计信息

| 类别 | 数量 | 完成率 |
|------|------|--------|
| 核心模块 | 10 | 10% |
| 扩展模块 | 8 | 12.5% |
| 解决方案 | 5 | 20% |
| 运维文档 | 4 | 100% |
| 最佳实践 | 4 | 25% |
| 参考资源 | 3 | 33% |
| **总计** | **34** | **23.5%** |

**当前文档总数**: 34 个  
**已完成**: 8 个  
**进行中**: 4 个（bat, security, performance, code-style）  
**待创建**: 22 个

---

## 🗺️ 文件关系图

```
SKILL.md (索引入口)
├─→ 快速导航
│   ├─→ 新手入门 (dev/environment-setup)
│   ├─→ 电商开发 (solutions/ecommerce, contrib-modules/commerce)
│   ├─→ 多语言站点 (solutions/multilingual, core-modules/multilingual)
│   └─→ Headless 架构 (solutions/headless, contrib-modules/jsonapi)
│
├─→ 核心模块
│   ├─→ system-core
│   ├─→ node
│   ├─→ user
│   ├─→ field
│   ├─→ views
│   ├─→ config
│   ├─→ entity
│   ├─→ layout-builder
│   ├─→ media
│   └─→ webform
│
├─→ 扩展模块
│   ├─→ commerce (电商)
│   ├─→ bat (预订管理)
│   ├─→ jsonapi (REST API)
│   ├─→ workflow (工作流)
│   ├─→ metatag (SEO)
│   ├─→ pathauto (URL 别名)
│   ├─→ redirect (重定向)
│   └─→ paragraphs (内容组件)
│
├─→ 运维
│   ├─→ security
│   ├─→ performance
│   ├─→ backup-restore
│   └─→ deployment
│
├─→ 最佳实践
│   ├─→ code-style
│   ├─→ standards
│   ├─→ scaling
│   └─→ api-design
│
└─→ 参考
    ├─→ official-links
    ├─→ community-tools
    └─→ vendor-resources
```

---

## 🛠️ 维护指南

### 更新流程

1. **发现需求** - 识别需要更新或新增的内容
2. **确定位置** - 找到对应的模块/解决方案
3. **编写内容** - 按照模板创建文档
4. **验证链接** - 确保所有外部链接有效
5. **更新索引** - 更新 SKILL.md 中的 Table of Contents
6. **测试检查** - 检查文档格式和引用

### 质量标准

**每个文档必须**:
- ✅ 使用一致的模板格式
- ✅ 包含完整的信息章节
- ✅ 有明确的适用范围说明
- ✅ 提供有效的外部引用
- ✅ 包含代码示例（如适用）
- ✅ 有 ER 图（如有实体关系）
- ✅ 列出依赖模块

**文件质量规范**:
- 长度：200-5000 行（最佳 1000-2000 行）
- 格式：Markdown
- 语言：中英文混合（技术术语用英文）
- 版本：Drupal 11 为主，兼容 10.x

---

## 📝 更新日志

| 日期 | 操作 | 说明 |
|------|------|------|
| 2026-04-07 | 创建 | 新目录结构规划 |
| 2026-04-07 | 迁移 | bat 模块文档创建 |
| 2026-04-07 | 迁移 | security 文档创建 |
| 2026-04-07 | 迁移 | performance 文档创建 |
| 2026-04-07 | 迁移 | code-style 文档创建 |
| 2026-04-07 | 迁移 | official-links 文档创建 |

---

**最后更新**: 2026-04-07  
**维护**: OpenClaw Marvin  
**状态**: 活跃维护

*目录结构设计遵循模块化、可扩展和易维护原则*
