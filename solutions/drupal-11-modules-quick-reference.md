# Drupal 11 模块快速速查表

**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  
**维护**: OpenClaw Marvin  

---

## 📊 30 个常用模块速查表

### 核心增强 (10 个) ⭐⭐⭐⭐⭐

| # | 模块名 | 功能 | 安装命令 | 优先级 |
|---|--------|------|---------|--------|
| 1 | Views | 数据查询与展示 | (核心已内置) | ⭐⭐⭐⭐⭐ |
| 2 | Admin Toolbar | 现代化菜单 | `composer drupal/admin_toolbar` | ⭐⭐⭐⭐⭐ |
| 3 | Paragraphs | 段落式内容 | `composer drupal/paragraphs` | ⭐⭐⭐⭐⭐ |
| 4 | Layout Builder | 可视化布局 | (核心已内置) | ⭐⭐⭐⭐⭐ |
| 5 | Token | 令牌替换系统 | `composer drupal/token` | ⭐⭐⭐⭐⭐ |
| 6 | Redirect | URL 重定向 | `composer drupal/redirect` | ⭐⭐⭐⭐☆ |
| 7 | Devel *(开发)* | 开发调试工具 | `composer drupal/devel` | ⚠️ 仅开发 |
| 8 | Pathauto | 自动 URL 别名 | `composer drupal/pathauto` | ⭐⭐⭐⭐⭐ |
| 9 | Metatag | 元标签管理 | `composer drupal/metatag` | ⭐⭐⭐⭐☆ |
| 10 | Simple XML Sitemap | 站点地图 | `composer drupal/simple_xml_sitemap` | ⭐⭐⭐⭐☆ |

### 表单与内容 (4 个) ⭐⭐⭐⭐☆

| # | 模块名 | 功能 | 安装命令 | 优先级 |
|---|--------|------|---------|--------|
| 11 | Webform | 表单构建 | `composer drupal/webform` | ⭐⭐⭐⭐⭐ |
| 12 | CKEditor 5 | 富文本编辑器 | (核心已内置) | ⭐⭐⭐⭐☆ |
| 13 | Rules | 业务规则引擎 | `composer drupal/rules` | ⭐⭐⭐⭐☆ |
| 14 | Content moderation | 内容审核 | (核心已内置) | ⭐⭐⭐⭐☆ |

### 开发工具 (4 个) ⭐⭐⭐⭐☆

| # | 模块名 | 功能 | 安装命令 | 优先级 |
|---|--------|------|---------|--------|
| 15 | Debug | 调试信息 | `composer drupal/devel` | ⚠️ 仅开发 |
| 16 | Drush | 命令行工具 | (独立安装) | ⭐⭐⭐⭐⭐ |
| 17 | Config Update | 配置在线编辑 | `composer drupal/config_update` | ⭐⭐⭐⭐☆ |
| 18 | Devel Generate | 测试数据生成 | `composer drupal/devel_generate` | ⚠️ 仅开发 |

### 安全与性能 (7 个) ⭐⭐⭐⭐☆

| # | 模块名 | 功能 | 安装命令 | 优先级 |
|---|--------|------|---------|--------|
| 19 | Security Kit | 安全加固 | `composer drupal/security_kit` | ⭐⭐⭐⭐☆ |
| 20 | Ctools | 工具库 | `composer drupal/ctools` | ⭐⭐⭐⭐☆ |
| 21 | Cache API Plus | 缓存增强 | `composer drupal/cache_api_plus` | ⭐⭐⭐☆☆ |
| 22 | Advanced Cache | 高级缓存 | `composer drupal/advanced_cache` | ⭐⭐⭐☆☆ |
| 23 | Redis | 高性能缓存 | `composer drupal/redis` | ⭐⭐⭐⭐☆ |
| 24 | Varnish | CDN 缓存 | `composer drupal/varnish` | ⭐⭐⭐⭐☆ |
| 25 | Image Optimize | 图片压缩 | `composer drupal/image_optimize` | ⭐⭐⭐☆☆ |

### 管理增强 (5 个) ⭐⭐⭐☆☆

| # | 模块名 | 功能 | 安装命令 | 优先级 |
|---|--------|------|---------|--------|
| 26 | Fast 404 | 404 优化 | `composer drupal/fast_404` | ⭐⭐⭐☆☆ |
| 27 | Admin Menu | 管理菜单下拉 | `composer drupal/admin_menu` | ⭐⭐⭐☆☆ |
| 28 | Better Exposed Filters | 高级过滤器 | `composer drupal/better_exposed_filters` | ⭐⭐⭐☆☆ |
| 29 | Token Browser | 令牌浏览器 | `composer drupal/token_browser` | ⭐⭐⭐☆☆ |
| 30 | Entity Queue | 实体队列 | `composer drupal/entity_queue` | ⭐⭐⭐☆☆ |

---

## 🎯 必装模块清单 (8 个)

```bash
# 核心功能增强
composer require drupal/toolbar
composer require drupal/admin_toolbar
composer require drupal/paragraphs
composer require drupal/token
composer require drupal/pathauto
composer require drupal/redirect
composer require drupal/metatag
composer require drupal/webform
```

---

## 🔧 常用 Drush 命令

### 模块管理
```bash
drush pm-list              # 列出所有模块
drush pm:enable module     # 启用模块
drush pm:enable module1 module2  # 启用多个
drush pm:disable module    # 禁用模块
drush pm:uninstall module  # 卸载模块
```

### 缓存管理
```bash
drush cr                   # 清除所有缓存
drush cache:clear          # 清除缓存
drush cache:rebuild        # 重建缓存
drush cache:clear twig     # 清除 Twig 缓存
```

### 站点管理
```bash
drush status               # 站点状态
drush cc all              # 清除所有缓存和编译
drush php:eval 'print_r(...)' # 执行 PHP 代码
```

### 调试命令
```bash
# 开发环境
drush php:eval 'print_r(\Drupal::moduleHandler()->getModuleList());'

# 清除缓存后查看
drush cr && drush php:eval 'print_r("Cache cleared");'
```

---

## 📚 模块安装最佳实践

### 1. 使用 Composer (推荐)
```bash
# 安装模块
composer require drupal/module_name

# 安装多个模块
composer require drupal/module1 drupal/module2

# 启用模块
drush en module_name
```

### 2. 批量安装脚本
```bash
#!/bin/bash
# install-drupal-modules.sh

MODULES="admin_toolbar paragraphs token pathauto redirect metatag webform"

for module in $MODULES; do
  echo "Installing $module..."
  composer require drupal/$module
  drush en $module
done

echo "All modules installed!"
drush cr
```

### 3. 生产环境检查
```bash
# 检查模块版本
drush pm-info admin_toolbar
drush pm-info paragraphs

# 检查依赖关系
drush pm:dependencies webform

# 检查更新
drush pm:status
```

---

## 🔐 安全配置

### 必须配置的安全模块
1. Security Kit - 安全响应头
2. Admin Toolbar - 安全的菜单
3. Content moderation - 内容审核

### 安全配置步骤
```bash
# 安装 Security Kit
composer require drupal/security_kit
drush en security_kit

# 启用安全响应头
drush config-set security_kit.settings strict_transport_security true
drush config-set security_kit.settings xss_protection true
```

---

## 🚀 性能优化配置

### Redis 缓存配置
```bash
# 安装 Redis
composer require drupal/redis
drush en redis

# 配置在 settings.php
$settings['cache_prefix']['default'] = 'default';
$settings['container_yamls'][] = 'sites/default/services.redis.yml';
```

### Varnish 缓存
```bash
# 安装 Varnish
composer require drupal/varnish
drush en varnish

# 配置缓存
drush config:set varnish.settings enabled true
```

---

## 📝 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| 1.0 | 2026-04-08 | 初始化文档 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-08

---

## 🔗 快速链接

- [Drupal.org Modules](https://www.drupal.org/project/project_module)
- [Drupal 11 Upgrade Guide](https://www.drupal.org/docs/upgrading-from-drupal-10-to-drupal-11)
- [Drupal Security](https://www.drupal.org/security)
- [Coders Drupal](https://www.drupal.org/project/project_module)
- [Drush Commands](https://drush.org/commands/)

---

*使用 Ctrl+F 快速搜索模块*  
*定期更新以反映最新 Drupal 11 模块状态*
