---
name: drupal-knowledge-base
description: |
  Complete Drupal knowledge base covering versions 10, 11, 12,
  core/contrib modules, solutions, development, and maintenance.
  Designed for product managers, project managers, developers,
  and designers working with Drupal-based projects.
homepage: https://www.drupal.org/docs
metadata:
  openclaw:
    emoji: "🎨"
    version: "1.0"
    os: ["darwin", "linux"]
    requires:
      bins: ["wc"]
---

# 📚 Drupal Knowledge Base

**版本**: v2.1  
**构建标准**: Agent Skills Specification  
**维护**: OpenClaw Marvin  
**更新时间**: 2026-04-10  

> 完整的 Drupal 知识体系，支持 Drupal 10, 11, 12 多版本扩展

---

## 🎯 When to Use This Skill

✅ **USE when:**
- Building Drupal-based websites (10.x, 11.x, 12.x)
- Need reference for core modules (Node, User, Entity, Views, Config, etc.)
- Implementing Commerce e-commerce features
- Setting up booking/availability systems (BAT module)
- Developing custom Drupal modules
- Configuring multi-language sites
- Performance optimization and security hardening
- Creating SEO-friendly URLs (Metatag, Pathauto)
- Building JSON:API integration (Headless architecture)

❌ **DON'T USE when:**
- Building non-Drupal sites
- Needing WordPress/Shopify solutions
- Looking for CMS-agnostic solutions
- Needing real-time data processing without Drupal

---

## 📋 Quick Navigation

### 🚀 Getting Started
- [Drupal Overview](drupal-core/00-overview.md) - 了解 Drupal
- [Environment Setup](dev/environment-setup/) - 搭建环境
- [Core Modules Index](core-modules/00-index.md) - 核心模块完整索引

### 🛒 E-commerce Development
- [Commerce Module](contrib-modules/commerce/) - 电商核心
- [Payment Module](contrib-modules/payment/) - 支付网关
- [E-commerce Solution](solutions/ecommerce/) - 完整方案

### 🏢 Event Booking System
- [BAT Module](contrib-modules/bat/) - 预订管理框架
- [Booth Booking Solution](solutions/booth-booking/) - 展位预定方案

### 🌍 Multi-language Sites
- [Core Multilingual](core-modules/multilingual/) - 多语言核心
- [Solution](solutions/multilingual/) - 多语言解决方案

### 🔌 Headless Architecture
- [JSON:API](contrib-modules/jsonapi/) - REST API
- [Headless Solution](solutions/headless/) - 无头架构

---

## 📚 Document Indexes

### 📦 Core Modules

完整的核心模块文档索引，包含 ER 图、工作流程和最佳实践。

👉 **查看完整索引**: [`core-modules/00-index.md`](core-modules/00-index.md)

**已完成的模块** (15 个):
- System Core, Node, User, Field, Entity, Views, Config
- Layout Builder, Media, Webform, Menu, Multilingual
- Statistics, Search, Path

**总成就**: 215KB+ 文档 | 13 个 ER 图 | 45 个业务场景 | 183+ 代码示例

---

### 🔧 Contributed Modules

完整的贡献模块索引，包含优先级和使用场景。

👉 **查看完整索引**: [`contrib/modules/00-index.md`](contrib/modules/00-index.md)

**TOP 10 推荐**:
| 模块 | 优先级 | 用途 |
|------|--------|------|
| Commerce | ⭐⭐⭐⭐⭐ | 电商核心 |
| Payment | ⭐⭐⭐⭐⭐ | 支付网关 |
| BAT | ⭐⭐⭐⭐⭐ | 展位预订 |
| Metatag | ⭐⭐⭐⭐ | SEO 优化 |
| Pathauto | ⭐⭐⭐⭐ | URL 别名 |
| Redirect | ⭐⭐⭐⭐ | 重定向管理 |
| JSON:API | ⭐⭐⭐⭐ | REST API |
| Workflow | ⭐⭐⭐⭐ | 内容工作流 |
| Search API | ⭐⭐⭐ | 高级搜索 |
| Token | ⭐⭐⭐ | 令牌替换 |

---

### 🏗️ Solutions

完整解决方案，包含架构设计和实施指南。

👉 **查看完整索引**: [`solutions/00-index.md`](solutions/00-index.md)

---

### 💻 Development Guides

开发指南，涵盖环境搭建到测试。

👉 **查看完整索引**: [`dev/00-index.md`](dev/00-index.md)

---

### 🔧 Operations & Best Practices

运维文档和最佳实践。

👉 **查看完整索引**: [`ops/00-index.md`](ops/00-index.md) | [`best-practices/00-index.md`](best-practices/00-index.md)

---

### 🔗 Reference Resources

参考资源和官方链接。

👉 **查看完整索引**: [`references/00-index.md`](references/00-index.md)

---

## 🎓 Version Documentation

| 文档 | 说明 | 版本 | 状态 |
|------|------|------|------|
| [Drupal Core Overview](drupal-core/00-overview.md) | Drupal 核心介绍 | All | ✅ |
| [Drupal 11 Features](drupal-core/11-overview.md) | Drupal 11 特性 | 11.x | ✅ |
| [Drupal 12 Beta](drupal-core/12-beta.md) | Drupal 12 预览版本 | 12.x (Beta) | 🔄 |
| [Migration Guide](drupal-core/migration.md) | 迁移指南 | 10.x, 11.x | ✅ |

---

## 📅 Changelog

### v2.1 (2026-04-10) - Optimization
- ✅ SKILL.md optimized (< 500 lines)
- ✅ YAML frontmatter enhanced (os, bins)
- ✅ Document indexes reorganized

### v2.0 (2026-04-07) - Major Update
**🎉 Core Achievement: 13 Core Modules 100% Complete**

- ✅ **Core Module Documentation**: 13 core modules completed (215KB+)
- ✅ **Agent Best Practices Guide** (v1.0): 18KB comprehensive guide
- ✅ **Drupal 11 Extension Modules Research**: 15KB detailed report
- ✅ **Quality Achievements**: 13 ER diagrams, 45 business scenarios, 183+ code examples

### v1.9 (2026-04-07)
- ✅ Created official links documentation
- ✅ Created structure documentation

### v1.8 (2026-04-07)
- ✅ Created BAT module documentation
- ✅ Established directory structure

### v1.0 (2026-04-04)
- ✅ Initialized knowledge base structure

---

## 🔄 Maintenance Notes

### Documentation Strategy
1. **Core Modules**: Real-time updates, following Drupal releases
2. **Solutions**: Updated each version for compatibility
3. **Best Practices**: Quarterly updates with community feedback
4. **Reference Links**: Monthly checks, update broken links

### Update Frequency
- **Core Documentation**: Weekly review
- **Solutions**: Monthly updates
- **Reference Links**: Bi-weekly verification

### Quality Standards
- ✅ All content based on Drupal.org official documentation
- ✅ Modules with entities include ER diagrams (triple Mermaid syntax check)
- ✅ Business workflows and object sequences included
- ✅ Common business scenario cases provided
- ✅ Best practice recommendations (based on actual experience)

---

## 💡 Usage Guidelines

### For Product Managers
- Focus on **Solutions** section for business scenarios
- Reference **Best Practices** for project planning
- Use **Core Modules** for technical feasibility analysis

### For Project Managers
- Start with **Development Guides** for team onboarding
- Use **Operations** for deployment planning
- Reference **Changelog** for project timeline

### For Developers
- Deep dive into **Core Modules** for implementation
- Follow **Best Practices** for code quality
- Check **API Reference** in official links
- Use **Agent Best Practices** for AI-assisted development

### For Designers
- Review **Layout Builder** for visualization
- Check **Media** module for asset management
- Reference **Business Scenarios** for UI requirements

---

**Document Version**: v2.1  
**Status**: Active Maintenance  
**Maintainer**: OpenClaw Marvin  
**Last Updated**: 2026-04-10  

*All technical information based on Drupal.org official documentation and actual project experience*
*All ER diagrams triple-checked with Mermaid syntax validation*

**🎯 Current Project Status**: Core modules 100% complete ✅ | Contributed modules in progress ⏳
