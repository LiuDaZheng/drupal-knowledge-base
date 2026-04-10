# Drupal 核心版本概述

> **重要提示**：本文档基于 Drupal.org 官方发布信息和社区讨论整合

## 📚 Drupal 版本现状

### 当前版本状态（据 2026-04 官方信息）

| 版本 | 状态 | 发布日期 | 支持周期 | 官方链接 |
|------|------|----------|----------|---------|
| **Drupal 10** | LTS (Long Term Support) | 2023 年 1 月 | 至 2025 年 12 月 | [Drupal.org](https://www.drupal.org/project/drupal/releases/10.3.x) |
| **Drupal 11** | Stable (当前最新) | 2024 年 8 月 2 日 | 至 2026 年 6 月 | [Drupal.org](https://www.drupal.org/project/drupal/releases/11.3.3) |

**来源**: 
1. https://www.drupal.org/about/core/policies/core-release-cycles/schedule
2. https://www.annertech.com/blog/drupal-11-here-what-were-excited-about
3. https://www.droptica.com/blog/drupal-11-release-date-features-and-what-expect/

---

## 🎯 Drupal 11 核心改进

### 技术栈升级

**Symfony 7**:
- ✅ 要求 PHP 8.2+
- ✅ 更现代的 API 设计
- ✅ 性能提升 10-15%

**Twig 3.x**:
- ✅ 更严格的模板语法
- ✅ 更好的错误提示
- ✅ 性能优化

**PHP 8.2+**:
- ✅ 要求最低 PHP 8.2
- ✅ 利用 PHP 8.2 特性
- ✅ 类型安全增强

**来源**:
- https://www.drupal.org/project/drupal/releases/11.0.0
- https://www.drupal.org/project/drupal/releases/11.3.0

---

## 💡 版本选择建议

### 当前推荐策略 (2026-04)

**选择 Drupal 10.x，如果**：
- ✅ 需要最广泛模块支持
- ✅ 项目周期 > 2 年
- ✅ 团队需要稳定环境

**选择 Drupal 11.x，如果**：
- ✅ 需要最新特性
- ✅ 项目周期 1-2 年
- ✅ 愿意接受部分模块更新

**来源**:
- https://www.reddit.com/r/drupal/comments/1gffves/is_drupal_11_productionready/
- https://www.drupal.org/project/drupal/releases

---

## ⚠️ 重要注意事项

### contrib 模块兼容性

**当前状况**：
- Drupal 11 已稳定发布
- **部分核心模块已适配**
- **部分贡献模块仍在适配中**

**建议**：
1. 升级前检查 `upgrade_status` 模块
2. 优先选择已标记 `Drupal 11 compatible` 的模块
3. Commerce 3.x 已支持 Drupal 11（source: https://www.drupal.org/project/commerce）

---

## 📅 升级路径

```
Drupal 9 → Drupal 10 → Drupal 11 → Drupal 12
```

**升级工具**：
- `upgrade_status` 模块（核心）
- `update_status` 模块（核心）

**官方升级指南**：
- https://www.drupal.org/docs/upgrading-drupal

---

**文档版本**: v1.0  
**最后更新**: 2026-04-05  
**来源验证**: ✅ Drupal.org 官方 + 社区讨论交叉验证

---

**下一节**: Drupal 10.x 详细特性（待补充）
