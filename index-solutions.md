# 💼 解决方案索引 (Solutions Index)

**版本**: v1.0  
**最后更新**: 2026-04-10  
**分类**: 场景化解决方案  
**总文档数**: 11 个

---

## 🛒 电商解决方案

### 核心电商方案

| # | 文档 | 适用场景 | 优先级 | 大小 |
|---|------|---------|--------|------|
| 1 | [drupal-11-ecommerce-20-modules.md](solutions/drupal-11-ecommerce-20-modules.md) | 20 个核心电商模块详解 | ⭐⭐⭐⭐⭐ | ~21KB |
| 2 | [drupal-11-ecommerce-20-modules-quick.md](solutions/drupal-11-ecommerce-20-modules-quick.md) | 快速参考版 | ⭐⭐⭐⭐☆ | ~4KB |
| 3 | [drupal-11-10-ecommerce-modules.md](solutions/drupal-11-10-ecommerce-modules.md) | D10/D11 电商模块推荐 | ⭐⭐⭐⭐☆ | ~19KB |
| 4 | [ecommerce-commerce-3x.md](solutions/ecommerce-commerce-3x.md) | Commerce 3.x 完整方案 | ⭐⭐⭐⭐⭐ | ~6KB |

### 模块精选

| # | 文档 | 适用场景 | 优先级 | 大小 |
|---|------|---------|--------|------|
| 5 | [drupal-11-top-30-modules.md](solutions/drupal-11-top-30-modules.md) | 热门模块精选 Top 30 | ⭐⭐⭐⭐⭐ | ~15KB |
| 6 | [drupal-11-modules-quick-reference.md](solutions/drupal-11-modules-quick-reference.md) | 模块快速指南 | ⭐⭐⭐⭐☆ | ~7KB |

---

## 🎨 主题定制方案

| # | 文档 | 适用场景 | 优先级 | 大小 |
|---|------|---------|--------|------|
| 7 | [theme-customizations.md](solutions/theme-customizations.md) | 主题定制大全 | ⭐⭐⭐⭐⭐ | ~20KB |

---

## 🚀 CI/CD 解决方案 (solutions/cicd/)

| 文档 | 适用场景 | 优先级 |
|------|---------|--------|
| [full-stack-cicd.md](solutions/cicd/full-stack-cicd.md) | 全栈 CI/CD 流程 | ⭐⭐⭐⭐⭐ |

---

## 📋 使用案例

### 案例 1: 快速搭建电商网站

**适用文档组合**:
1. [drupal-11-ecommerce-20-modules-quick.md](solutions/drupal-11-ecommerce-20-modules-quick.md) - 快速了解核心模块
2. [ecommerce-commerce-3x.md](solutions/ecommerce-commerce-3x.md) - Commerce 3.x 配置
3. [theme-customizations.md](solutions/theme-customizations.md) - 主题定制

**预计工时**: 2-4 周

---

### 案例 2: 企业级电商部署

**适用文档组合**:
1. [drupal-11-ecommerce-20-modules.md](solutions/drupal-11-ecommerce-20-modules.md) - 详细模块文档
2. [drupal-11-top-30-modules.md](solutions/drupal-11-top-30-modules.md) - 扩展模块参考
3. [full-stack-cicd.md](solutions/cicd/full-stack-cicd.md) - CI/CD 部署

**预计工时**: 4-8 周

---

### 案例 3: 模块选型评估

**适用文档组合**:
1. [drupal-11-modules-quick-reference.md](solutions/drupal-11-modules-quick-reference.md) - 快速对比
2. [drupal-11-10-ecommerce-modules.md](solutions/drupal-11-10-ecommerce-modules.md) - 版本兼容性
3. [drupal-11-top-30-modules.md](solutions/drupal-11-top-30-modules.md) - 社区推荐

**预计工时**: 1-2 天

---

### 案例 4: 主题定制开发

**适用文档组合**:
1. [theme-customizations.md](solutions/theme-customizations.md) - 完整定制指南
2. [index-core.md](index-core.md) → theming/ - 核心主题开发文档

**预计工时**: 1-3 周

---

## 📊 统计

| 类别 | 文档数 | 总大小 |
|------|--------|--------|
| 电商解决方案 | 6 | ~72KB |
| 主题定制 | 1 | ~20KB |
| CI/CD 方案 | 1 | ~10KB (估计) |
| **总计** | **8** | **~102KB** |

---

## 🎯 方案选择指南

### 按项目规模

| 规模 | 推荐方案 | 核心文档 |
|------|---------|----------|
| **小型电商** | 快速搭建 | drupal-11-ecommerce-20-modules-quick.md |
| **中型电商** | 标准方案 | drupal-11-ecommerce-20-modules.md + theme-customizations.md |
| **大型电商** | 企业方案 | 全部电商文档 + cicd/full-stack-cicd.md |
| **模块评估** | 选型参考 | drupal-11-top-30-modules.md + quick-reference.md |

### 按开发阶段

| 阶段 | 推荐文档 |
|------|---------|
| **需求分析** | drupal-11-top-30-modules.md |
| **技术选型** | drupal-11-10-ecommerce-modules.md |
| **开发实施** | drupal-11-ecommerce-20-modules.md |
| **部署上线** | cicd/full-stack-cicd.md |
| **运维优化** | 参考 ops/ 和 best-practices/ |

---

## 🔗 相关索引

- [核心模块索引](index-core.md) - Drupal 核心功能
- [贡献模块索引](index-contrib.md) - 第三方模块
- [总索引](00-INDEX.md) - 完整导航

---

## 📁 完整目录结构

```
solutions/
├── drupal-11-10-ecommerce-modules.md
├── drupal-11-ecommerce-20-modules.md
├── drupal-11-ecommerce-20-modules-quick.md
├── drupal-11-modules-quick-reference.md
├── drupal-11-top-30-modules.md
├── ecommerce-commerce-3x.md
├── theme-customizations.md
└── cicd/
    └── full-stack-cicd.md
```

---

*文件大小: ~4.8KB | 符合 < 5KB 要求*
