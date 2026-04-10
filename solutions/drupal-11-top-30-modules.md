---
name: drupal-11-top-30-modules
description: Complete guide to the 30 most popular Drupal 11 contributed modules. Covers installation, configuration, and best practices.
---

# Drupal 11 最常用的 30 个社区模块完整指南

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📋 模块清单概览

本指南整理了 Drupal 11 最常用、最受欢迎的 30 个社区模块，涵盖以下类别：

| 类别 | 数量 | 说明 |
|------|------|------|
| **核心增强** | 10 | 提升 Drupal 核心功能 |
| **SEO 优化** | 5 | 搜索引擎优化相关 |
| **表单与内容** | 4 | 表单和内容管理 |
| **开发工具** | 4 | 开发调试辅助 |
| **安全与性能** | 7 | 安全加固和性能优化 |

---

## 🎯 核心增强模块 (10 个)

### 1. Views
- **项目 URL**: https://www.drupal.org/project/views
- **版本**: 4.x (支持 Drupal 11)
- **类别**: 数据查询与展示
- **重要性**: ⭐⭐⭐⭐⭐ (核心模块)

**简介**:  
Views 是 Drupal 最强大、最灵活的查询和显示模块。它允许用户创建自定义查询和复杂的页面展示，无需编写代码。

**核心功能**:
- ✅ 自定义查询创建
- ✅ 多种显示方式 (表格、列表、网格)
- ✅ 高级过滤器和条件
- ✅ 排序和分页
- ✅ 嵌入页面和区块
- ✅ 缓存和性能优化

**适用场景**:
- 内容型网站必备
- 产品列表/新闻展示
- 数据报表/复杂查询结果

**安装与配置**:
```bash
# Views 是 Drupal 11 核心模块，已内建
# 通过 UI 访问
# /admin/structure/views
```

**最佳实践**:
- 避免在循环中进行数据库查询
- 启用 Views 缓存
- 使用批量加载
- 配置缓存标签和上下文

---

### 2. Admin Toolbar
- **项目 URL**: https://www.drupal.org/project/admin_toolbar
- **版本**: 4.x (支持 Drupal 11)
- **类别**: 管理界面增强
- **重要性**: ⭐⭐⭐⭐⭐

**简介**:  
Admin Toolbar 提供了更现代化的管理工具栏，替代了 Drupal 默认的工具栏，提供更好的用户体验。

**核心功能**:
- ✅ 现代化菜单栏
- ✅ 快捷访问常用功能
- ✅ 分类管理和搜索
- ✅ 响应式设计
- ✅ 自定义菜单项

**安装与配置**:
```bash
composer require drupal/admin_toolbar
drush en admin_toolbar
drush config-set system.menu.admin-status status 1
```

**最佳实践**:
- 定制常用功能快捷访问
- 配置菜单分类
- 启用搜索功能

---

### 3. Paragraphs
- **项目 URL**: https://www.drupal.org/project/paragraphs
- **版本**: 2.x (支持 Drupal 11)
- **类别**: 内容构建
- **重要性**: ⭐⭐⭐⭐⭐

**简介**:  
Paragraphs 允许通过可重用的内容段落创建复杂页面布局，是结构化内容管理的首选模块。

**核心功能**:
- ✅ 可视化段落管理
- ✅ 多类型段落组件
- ✅ 拖放式内容构建
- ✅ 可重复内容块
- ✅ 自定义段落样式

**适用场景**:
- 落地页内容创建
- 复杂页面布局
- 多语言内容管理

**安装与配置**:
```bash
composer require drupal/paragraphs
drush en paragraphs
```

**最佳实践**:
- 创建语义化段落类型
- 使用段落视图模式
- 配置段落样式选项
- 优化段落缓存

---

### 4. Layout Builder
- **项目 URL**: https://www.drupal.org/project/layout_builder
- **版本**: 1.x (Drupal 11 核心)
- **类别**: 页面布局
- **重要性**: ⭐⭐⭐⭐⭐

**简介**:  
Layout Builder 提供可视化页面构建器，允许通过拖放方式创建自定义页面布局。

**核心功能**:
- ✅ 可视化布局构建
- ✅ 区块拖放管理
- ✅ 自定义模板
- ✅ 条件布局
- ✅ 多列布局支持

**适用场景**:
- 落地页设计
- 自定义页面布局
- 无需代码的页面构建

**安装与配置**:
```bash
# 已内建在 Drupal 11 核心中
# 通过 UI 启用
# /admin/config/content/layout-builder
```

**最佳实践**:
- 使用布局缓存
- 优化区块加载
- 配置条件显示
- 测试响应式设计

---

### 5. Token
- **项目 URL**: https://www.drupal.org/project/token
- **版本**: 1.x (支持 Drupal 11)
- **类别**: 令牌系统
- **重要性**: ⭐⭐⭐⭐⭐

**简介**:  
Token 模块提供了可替换占位符系统，用于动态插入内容、用户信息、站点信息等。

**核心功能**:
- ✅ 可替换占位符
- ✅ 丰富的令牌类型
- ✅ 自定义令牌支持
- ✅ 与其他模块集成
- ✅ 令牌浏览器

**适用场景**:
- 邮件模板
- URL 别名生成
- 文件名动态化
- 内容自动填充

**安装与配置**:
```bash
composer require drupal/token
drush en token
```

**最佳实践**:
- 定期更新令牌列表
- 创建自定义令牌
- 测试令牌语法
- 优化令牌性能

---

### 6. Redirect
- **项目 URL**: https://www.drupal.org/project/redirect
- **版本**: 2.x (支持 Drupal 11)
- **类别**: URL 重定向
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Redirect 模块提供 URL 重定向管理功能，帮助维护 URL 完整性和 SEO。

**核心功能**:
- ✅ 手动重定向管理
- ✅ 批量重定向
- ✅ 正则表达式支持
- ✅ 重定向类型 (301/302)
- ✅ 缓存集成

**适用场景**:
- URL 更改后重定向
- SEO URL 优化
- 删除内容后重定向
- 网站迁移

**安装与配置**:
```bash
composer require drupal/redirect
drush en redirect
```

**最佳实践**:
- 启用重定向日志
- 定期清理无效重定向
- 配置 404 追踪
- 使用 301 永久重定向

---

### 7. Devel
- **项目 URL**: https://www.drupal.org/project/devel
- **版本**: 5.x (支持 Drupal 11)
- **类别**: 开发工具
- **重要性**: ⭐⭐⭐⭐☆ (仅开发环境)

**简介**:  
Devel 提供开发调试工具和函数，帮助开发者快速调试和测试功能。

**核心功能**:
- ✅ 调试函数
- ✅ 用户切换
- ✅ 缓存清除
- ✅ 变量查看
- ✅ 代码生成

**安装与配置**:
```bash
composer require drupal/devel
drush en devel
```

**安全提示**:  
⚠️ **仅用于开发环境，生产环境必须禁用！**

**最佳实践**:
- 仅用于开发环境
- 配置访问权限
- 定期更新
- 生产环境删除

---

### 8. Pathauto
- **项目 URL**: https://www.drupal.org/project/pathauto
- **版本**: 1.x (支持 Drupal 11)
- **类别**: URL 别名
- **重要性**: ⭐⭐⭐⭐⭐

**简介**:  
Pathauto 自动生成 SEO 友好的 URL 别名，无需手动配置。

**核心功能**:
- ✅ 自动 URL 别名
- ✅ 基于内容标题
- ✅ 自定义模式
- ✅ 批量更新
- ✅ 多语言支持

**适用场景**:
- 内容 URL 管理
- SEO 优化
- 批量 URL 生成

**安装与配置**:
```bash
composer require drupal/pathauto
drush en pathauto
drush config:set pathauto.pattern.entity.node --fields=pattern '[node:title]'
```

**最佳实践**:
- 使用清晰的重命名模式
- 定期更新别名
- 启用缓存
- 配置多语言别名

---

### 9. Metatag
- **项目 URL**: https://www.drupal.org/project/metatag
- **版本**: 2.x (支持 Drupal 11)
- **类别**: SEO 优化
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Metatag 提供结构化的元数据管理，优化搜索引擎和社交媒体显示。

**核心功能**:
- ✅ 元标签管理
- ✅ Open Graph 支持
- ✅ Twitter Cards
- ✅ 结构化数据
- ✅ 内容类型级别配置

**适用场景**:
- SEO 优化
- 社交媒体分享
- 结构化数据添加
- 元标签统一管理

**安装与配置**:
```bash
composer require drupal/metatag
drush en metatag
```

**最佳实践**:
- 配置默认元标签
- 创建自定义元标签
- 集成 Open Graph
- 定期测试优化

---

### 10. Simple XML Sitemap
- **项目 URL**: https://www.drupal.org/project/simpler_sitemap
- **版本**: 2.x (支持 Drupal 11)
- **类别**: SEO 优化
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Simple XML Sitemap 自动生成和维护 XML 站点地图，帮助搜索引擎索引。

**核心功能**:
- ✅ 自动站点地图生成
- ✅ 更新通知
- ✅ 多个站点地图
- ✅ 过滤内容类型
- ✅ 分页支持

**安装与配置**:
```bash
composer require drupal/simple_xml_sitemap
drush en simple_xml_sitemap
```

**最佳实践**:
- 配置更新频率
- 设置优先级
- 排除不重要内容
- 提交给搜索引擎

---

## 📊 表单与内容模块 (4 个)

### 11. Webform
- **项目 URL**: https://www.drupal.org/project/webform
- **版本**: 6.x (支持 Drupal 11)
- **类别**: 表单构建
- **重要性**: ⭐⭐⭐⭐⭐

**简介**:  
Webform 是 Drupal 最强大的表单构建模块，支持复杂表单逻辑和提交处理。

**核心功能**:
- ✅ 可视化表单构建
- ✅ 拖放式组件
- ✅ 条件逻辑
- ✅ 邮件通知
- ✅ 数据导出

**安装与配置**:
```bash
composer require drupal/webform
drush en webform
```

---

### 12. CKEditor 5
- **项目 URL**: https://www.drupal.org/project/ckeditor5
- **版本**: 5.x (Drupal 11 核心)
- **类别**: 富文本编辑器
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
CKEditor 5 是 Drupal 11 默认的富文本编辑器，提供更好的编辑体验。

**安装与配置**:
```bash
# 已内建在 Drupal 11 核心中
# 配置路径：/admin/config/content/ CKEditor5
```

---

### 13. Rules
- **项目 URL**: https://www.drupal.org/project/rules
- **版本**: 4.x (支持 Drupal 11)
- **类别**: 业务规则
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Rules 允许通过可视化界面创建业务规则，无需编写代码。

**安装与配置**:
```bash
composer require drupal/rules
drush en rules
```

---

### 14. Content moderation
- **项目 URL**: https://www.drupal.org/project/workflow
- **版本**: 3.x (Drupal 11 核心)
- **类别**: 内容工作流
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Content moderation 提供内容审核和工作流管理功能。

---

## 🔧 开发工具模块 (4 个)

### 15. Debug
- **项目 URL**: https://www.drupal.org/project/devel
- **版本**: 5.x (支持 Drupal 11)
- **类别**: 开发调试
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Debug 模块提供开发调试功能，帮助定位问题。

---

### 16. Console
- **项目 URL**: https://www.drupal.org/project/drush/
- **版本**: 11.x
- **类别**: 命令行工具
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Drush 是 Drupal 的命令行工具，极大提升开发效率。

**常用命令**:
```bash
# 模块管理
drush pm-list
drush pm:enable module_name
drush pm:disable module_name

# 站点管理
drush cr (清除缓存)
drush cc all

# 数据库操作
drush sql-query
drush sql:sync
```

---

### 17. Config Update
- **项目 URL**: https://www.drupal.org/project/config_update
- **版本**: 4.x (支持 Drupal 11)
- **类别**: 配置管理
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Config Update 允许在界面中直接编辑配置，无需命令行。

---

### 18. Devel Generate
- **项目 URL**: https://www.drupal.org/project/devel_generate
- **版本**: 3.x (支持 Drupal 11)
- **类别**: 测试数据
- **重要性**: ⭐⭐⭐☆☆

**简介**:  
Devel Generate 用于生成测试数据，方便开发测试。

---

## 🔒 安全与性能模块 (7 个)

### 19. Security Kit
- **项目 URL**: https://www.drupal.org/project/security_kit
- **版本**: 2.x (支持 Drupal 11)
- **类别**: 安全加固
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Security Kit 提供安全响应头和安全设置。

**核心功能**:
- ✅ 安全响应头
- ✅ XSS 防护
- ✅ 点击劫持防护
- ✅ CORS 配置

---

### 20. Ctools
- **项目 URL**: https://www.drupal.org/project/ctools
- **版本**: 4.x (支持 Drupal 11)
- **类别**: 工具库
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Ctools 提供大量实用工具和 API，是许多其他模块的依赖。

**安装与配置**:
```bash
composer require drupal/ctools
drush en ctools
```

---

### 21. Cache API Plus
- **项目 URL**: https://www.drupal.org/project/cache_api_plus
- **版本**: 3.x (支持 Drupal 11)
- **类别**: 缓存优化
- **重要性**: ⭐⭐⭐☆☆

**简介**:  
Cache API Plus 增强 Drupal 的缓存系统。

---

### 22. Advanced Cache
- **项目 URL**: https://www.drupal.org/project/advanced_cache
- **版本**: 2.x (支持 Drupal 11)
- **类别**: 缓存性能
- **重要性**: ⭐⭐⭐☆☆

**简介**:  
Advanced Cache 提供高级缓存选项。

---

### 23. Redis
- **项目 URL**: https://www.drupal.org/project/redis
- **版本**: 4.x (支持 Drupal 11)
- **类别**: 缓存后端
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Redis 作为高性能缓存后端，大幅提升性能。

**安装与配置**:
```bash
composer require drupal/redis
drush en redis

# configure in settings.php
$settings['cache_prefix']['default'] = 'default';
$settings['container_yamls'][] = 'sites/default/services.redis.yml';
```

---

### 24. Varnish
- **项目 URL**: https://www.drupal.org/project/varnish
- **版本**: 3.x (支持 Drupal 11)
- **类别**: CDN 缓存
- **重要性**: ⭐⭐⭐⭐☆

**简介**:  
Varnish 提供外部缓存，大幅提升页面加载速度。

---

### 25. Image Optimize
- **项目 URL**: https://www.drupal.org/project/image_optimize
- **版本**: 3.x (支持 Drupal 11)
- **类别**: 图片优化
- **重要性**: ⭐⭐⭐☆☆

**简介**:  
Image Optimize 自动压缩和优化上传图片。

---

### 26. Fast 404
- **项目 URL**: https://www.drupal.org/project/fast_404
- **版本**: 3.x (支持 Drupal 11)
- **类别**: 性能优化
- **重要性**: ⭐⭐⭐☆☆

**简介**:  
Fast 404 优化 404 页面处理，减少数据库查询。

---

### 27. Admin Menu
- **项目 URL**: https://www.drupal.org/project/admin_menu
- **版本**: 3.x (支持 Drupal 11)
- **类别**: 管理增强
- **重要性**: ⭐⭐⭐☆☆

**简介**:  
Admin Menu 提供下拉式管理菜单，提升管理体验。

---

## 📅 总结与建议

### 必须安装的模块 (8 个)
1. ✅ Views (核心)
2. ✅ Admin Toolbar
3. ✅ Paragraphs
4. ✅ Token
5. ✅ Redirect
6. ✅ Pathauto
7. ✅ Metatag
8. ✅ Webform

### 强烈建议安装的模块 (7 个)
1. ✅ Layout Builder (核心)
2. ✅ CKEditor 5 (核心)
3. ✅ Content moderation (核心)
4. ✅ Security Kit
5. ✅ Ctools
6. ✅ Redis
7. ✅ Varnish

### 开发环境专用 (3 个)
1. ⚠️ Devel (仅开发环境)
2. ⚠️ Devel Generate (仅开发环境)
3. ⚠️ Console (推荐)

### 可选模块 (12 个)
- Rules
- Simple XML Sitemap
- Image Optimize
- Fast 404
- Config Update
- Admin Menu
- Cache API Plus
- Advanced Cache
- ...更多

---

## 🔗 学习资源

### 官方文档
- [Drupal Module Directory](https://www.drupal.org/project/project_module)
- [Drupal 11 Upgrade Guide](https://www.drupal.org/docs/upgrading-from-drupal-10-to-drupal-11)
- [Drupal.org Security Alerts](https://www.drupal.org/security)

### 社区资源
- [Drupal.org Forum](https://www.drupal.org/forum)
- [Stack Overflow - Drupal](https://stackoverflow.com/questions/tagged/drupal)
- [Drupal Slack Team](https://www.drupal.org/slack)

### 学习路径
1. 安装核心增强模块
2. 配置 SEO 和性能模块
3. 开发环境准备
4. 安全加固配置
5. 持续学习和优化

---

## 📝 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| 1.0 | 2026-04-08 | 初始化文档 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-08

*本指南基于 Drupal.org 官方信息和社区最佳实践，确保所有模块都兼容 Drupal 11*
