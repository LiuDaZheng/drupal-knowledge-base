---
name: drupal-theming-introduction
description: Introduction to Drupal 11 Theming. Overview of theme system, Twig, preprocess, and development workflow.
---

# Drupal 主题开发入门指南

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 主题开发基础

### 什么是 Drupal 主题？

Drupal 主题是一套文件、代码和配置，用于完全控制站点的外观看起来和感觉。它包括：

- **HTML 模板** - 使用 Twig 定义页面结构
- **CSS 样式表** - 定义外观和响应式设计
- **JavaScript** - 添加交互和动态效果
- **预处理函数** - 在模板渲染前转换变量
- **图标和图像** - 视觉元素
- **配置文件** - 主题设置和依赖

### 为什么需要主题开发？

1. **品牌一致性** - 符合企业品牌形象
2. **用户体验优化** - 根据用户需求定制
3. **功能性扩展** - 添加特殊功能和布局
4. **性能优化** - 针对特定场景优化加载
5. **无障碍访问** - 确保符合 WCAG 标准

---

## 🏗️ Drupal 主题系统架构

### 主题层级结构

```
Drupal Core (核心层)
  ↓
Base Themes (基础主题层)
  ↓
Stable Theme (Stable 基础主题)
  ↓
Custom Theme (自定义主题层)
  ↓
Sub-theme (子主题层)
```

### 主题类型

| 类型 | 说明 | 使用场景 |
|------|------|---------|
| **核心主题** | Drupal 默认主题 (Bartik, Seven) | 学习参考 |
| **基础主题** | Stable, Classy, Olivia | 快速开发起点 |
| **自定义主题** | 完全自定义开发 | 特殊需求 |
| **子主题** | 继承自其他主题 | 轻量级定制 |

### 主题引擎

Drupal 11 使用 **Twig** 作为唯一的主题引擎：
- 模板渲染速度快
- 安全性高（自动转义）
- 模板继承和包含
- 强大的模板函数

---

## 🚀 快速开始

### 1. 创建主题文件夹

```bash
# 在 sites/all/themes/ 或 themes/custom/ 目录下创建
mkdir -p themes/custom/mytheme
cd themes/custom/mytheme
```

### 2. 创建 .info.yml 文件

```yaml
# mytheme.info.yml
name: 'My Custom Theme'
type: theme
description: 'My first custom Drupal 11 theme'
core_version_requirement: ^11
base theme: stable

stylesheets:
  - css/style.css
scripts:
  - js/scripts.js
```

### 3. 创建基本目录结构

```
mytheme/
├── mytheme.info.yml
├── mytheme.theme
├── mytheme.libraries.yml
├── css/
│   └── style.css
├── js/
│   └── scripts.js
└── templates/
    ├── page.html.twig
    └── node.html.twig
```

### 4. 创建 page.html.twig 模板

```twig
{# mytheme/templates/page.html.twig #}
<!DOCTYPE html>
<html{{ html_attributes }}>
<head>
  <head>
    <title>{{ head_title }}</title>
    {{ head_resources }}
  </head>
<body{{ attributes }}>
  {{ page.top }}
  
  <div class="page-wrapper">
    <header>
      {{ page.header }}
    </header>
    
    <main role="main" id="main-content">
      {{ page.content }}
    </main>
    
    {{ page.bottom }}
  </div>
  
  {{ page.footer }}
  {{ page.below }}
</body>
</html>
```

### 5. 启用主题

```bash
# 通过 drush 启用主题
drush theme:install mytheme

# 设置为主题
drush config-set system.theme.default mytheme

# 清除缓存
drush cr
```

---

## 📊 核心文件说明

### 1. .info.yml - 主题描述文件

```yaml
name: 'My Theme'
type: theme
description: 'Custom theme for enterprise application'
core_version_requirement: ^11

# 继承的基础主题
base theme: stable

# 依赖的模块
dependencies:
  - drupal:node
  - drupal:system
  - paragraphs:paragraphs

# CSS 文件
stylesheets:
  - css/style.css

# JavaScript 文件
scripts:
  - js/scripts.js

# 功能支持
features:
  - node_styling
  - comment_styling
  - block_styling

# 版本信息
version: '1.0.0'
package: Custom Themes
```

### 2. .libraries.yml - 资源库配置文件

```yaml
# 全局样式
global-styling:
  version: 1.0.0
  css:
    theme:
      css/style.css: { weight: -10, type: theme }

# 全局脚本
global-scripts:
  version: 1.0.0
  js:
    js/scripts.js: { type: file, weight: 10 }

# 特定页面使用
homepage-styling:
  version: 1.0.0
  css:
    theme:
      css/homepage.css: { weight: 0 }
```

### 3. .theme 文件 - 预处理函数

```php
<?php

/**
 * @file
 * Theme functionality.
 */

/**
 * 实现 hook_preprocess_page()
 */
function mytheme_preprocess_page(&$variables) {
  $variables['site_name'] = '我的企业网站';
  $variables['year'] = date('Y');
  
  // 条件添加 CSS 类
  $user = \Drupal::currentUser();
  if ($user->isAuthenticated()) {
    $variables['attributes']->addClass('logged-in');
  }
}

/**
 * 实现 hook_preprocess_node()
 */
function mytheme_preprocess_node(&$variables) {
  $node = $variables['node'];
  $variables['author_name'] = $node->getOwner()->getDisplayName();
  $variables['author_picture'] = $node->getOwner()->getPicture()->uri->value;
}

/**
 * 实现 hook_css_alter()
 */
function mytheme_css_alter(&$css) {
  // 修改 CSS 文件路径
  if (isset($css['modules/core/assets/css/drupal-styles.css'])) {
    $css['modules/core/assets/css/drupal-styles.css']['attributes']['media'] = 'print';
  }
}
```

### 4. .routing.yml - 路由定义

```yaml
# mytheme.routing.yml
mytheme.custom_page:
  path: '/custom-page'
  defaults:
    _controller: '\Drupal\mytheme\Controller\CustomController::mainPage'
    _title: 'Custom Page'
  requirements:
    _access: 'TRUE'
```

---

## 🎨 模板命名约定

### 页面模板优先级

```
1. page.html.twig                    # 通用页面模板
2. page--[node-type].html.twig       # 特定内容类型页面
3. page--[view-mode].html.twig       # 特定显示模式页面
4. page--[region].html.twig          # 特定区域页面
```

### 节点模板优先级

```
1. node--[node-type]--[view-mode].html.twig  # 最具体
2. node--[node-type].html.twig               # 特定内容类型
3. node--[view-mode].html.twig               # 特定显示模式
4. node.html.twig                            # 通用节点模板
```

### 区块模板优先级

```
1. block--[block-plugin-id].html.twig  # 特定区块插件
2. block.html.twig                     # 通用区块模板
```

### Paragraph 模板优先级

```
1. paragraph--[type]--[view-mode].html.twig
2. paragraph--[type].html.twig
3. paragraph--[view-mode].html.twig
4. paragraph.html.twig
```

---

## 🔧 开发环境配置

### Twig 调试配置

```yaml
# sites/default/services.yml
twig.config:
  debug: true              # 启用 Twig 调试
  auto_reload: true        # 自动重载模板
  cache: false             # 禁用缓存
```

### 开发模式配置

```yaml
# sites/default/settings.php
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/default/development.services.yml';

// 禁用缓存
$config['system.site']['status'] = TRUE;
$config['system.performance']['cache']['page']['maximum_age'] = 0;

// 显示错误
$config['system.logging']['error_level'] = 'verbose';
```

### 使用 Mix 模块 (推荐)

```bash
# 安装 Mix 模块
composer require drupal/mix

# 启用 Mix
drush mix:enable

# 禁用 Cache 聚合
drush css:aggregation:off
drush js:aggregation:off

# 启用 Twig 调试
drush twig:debug:on
```

---

## 🎯 最佳实践

### 1. 模板组织

```
✓ 将所有模板放在 templates/ 目录下
✓ 使用有意义的模板文件名
✓ 避免在模板中编写复杂的 PHP 逻辑
✓ 使用模板变量而非直接函数调用
```

### 2. 资源管理

```
✓ 使用 libraries.yml 管理 CSS/JS
✓ 将资源文件按功能分组
✓ 使用资源库版本控制
✓ 避免硬编码资源路径
```

### 3. 性能优化

```
✓ 启用资源聚合
✓ 使用 CDN 托管静态资源
✓ 延迟加载非关键资源
✓ 优化图片和字体
```

### 4. 代码质量

```
✓ 遵循 Drupal 编码规范
✓ 添加清晰的注释和文档
✓ 单元测试关键功能
✓ 使用版本控制管理代码
```

---

## 📊 调试技巧

### 查看模板建议

```php
// 启用 Twig 调试后，查看页面源码
// 会显示所有可用的模板建议
```

### 使用 drush 命令

```bash
# 查看所有模板文件
drush php-eval "print_r(drupal_get_theme()->getTemplateFiles());"

# 查看当前主题
drush config-get system.theme default

# 查看主题依赖
drush php-eval "print_r(\Drupal::service('theme.registry')->getInfo());"
```

### 检查变量

```php
// 在模板中添加调试信息
{{ dump(variables) }}

// 或者使用 Kint
{{ dump(variables.author) }}
```

---

## 🔗 学习资源

### 官方文档
- [Twig in Drupal](https://www.drupal.org/docs/develop/theming-drupal/twig-in-drupal)
- [Defining a theme](https://www.drupal.org/docs/develop/theming-drupal/defining-a-theme-with-an-infoyml-file)
- [Theme API](https://www.drupal.org/docs/develop/theming-drupal)

### 在线课程
- [Drupalize.me Theming Course](https://drupalize.me/topic/theming-drupal)
- [Acquia Learn Theming](https://www.acquia.com/learn/drupal/theming)

### 社区
- [Drupal.org Theming Forum](https://www.drupal.org/forum/section/6)
- [Stack Overflow - Theming](https://stackoverflow.com/questions/tagged/drupal-theming)

---

## 📝 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| 1.0 | 2026-04-08 | 初始化文档 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-08

*此文档作为主题开发的入门指南，后续将补充更多详细主题开发技巧*
