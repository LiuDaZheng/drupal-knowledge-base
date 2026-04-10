---
name: drupal-base-themes
description: Comprehensive guide to Drupal 11 Base Themes and Sub-themes. Covers creation, customization, and best practices.
---

# Drupal 基础主题和子主题开发指南

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 主题层级结构

### 主题类型概述

| 类型 | 说明 | 创建难度 | 使用场景 |
|------|------|---------|---------|
| **核心主题** | Drupal 默认主题 | - | 学习参考 |
| **基础主题** | 提供基础样式 | ⭐⭐⭐ | 快速开发起点 |
| **自定义主题** | 完全自定义 | ⭐⭐⭐⭐⭐ | 特殊需求 |
| **子主题** | 继承基础主题 | ⭐⭐ | 轻量级定制 |

### 主题继承关系

```
Stable/Classy/Olivia (核心基础主题)
  ↓ (继承)
MyBaseTheme (自定义基础主题)
  ↓ (继承)
MySubTheme (子主题)
  ↓ (继承)
MySubSubTheme (二级子主题)
```

---

## 🏗️ 基础主题开发

### 什么是基础主题？

基础主题 (Base Theme) 是一个完整的主题实现，提供：
- 完整的模板文件
- CSS 和 JavaScript 资源
- 预处理函数
- 主题功能

### Stable 主题 - 官方基础主题

**Stable** 是 Drupal 11 推荐的基础主题：

```yaml
# stable.info.yml
name: 'Stable'
type: theme
description: 'The default base theme for Drupal 11'
core_version_requirement: ^11
base theme: ''  # 不继承任何其他主题
```

**主要特点**:
- 提供基本的主题样式
- 不包含具体设计
- 是其他主题的基础
- 轻量级、高性能

### 创建自定义基础主题

#### 1. 主题结构

```
mybase/
├── mybase.info.yml
├── mybase.theme
├── mybase.libraries.yml
├── css/
│   ├── style.css
│   └── style.print.css
├── js/
│   └── scripts.js
├── templates/
│   ├── page.html.twig
│   ├── node.html.twig
│   ├── block.html.twig
│   ├── region.html.twig
│   └── ...
├── assets/
│   ├── fonts/
│   ├── images/
│   └── css/
└── config/
    └── optional/
        └── settings.local.yml
```

#### 2. .info.yml 文件

```yaml
# mybase.info.yml
name: 'My Base Theme'
type: theme
description: 'Custom base theme for enterprise applications'
core_version_requirement: ^11

# 继承 Stable 主题 (可选)
base theme: stable

# 功能支持
features:
  - node_styling
  - community_block
  - breadcrumb

# 依赖模块
dependencies:
  - drupal:node
  - drupal:system
  - drupal:block

# 样式文件
stylesheets:
  - css/style.css
  - css/responsive.css
  - css/print.css

# JavaScript 文件
scripts:
  - js/scripts.js

# 版本信息
version: '1.0.0'
package: Base Themes

# 兼容性
core_version_requirement: ^11 || ^12
```

#### 3. 创建基础模板

##### page.html.twig (最小化页面模板)
```twig
{#
 * Stable 风格的页面模板
 * 提供基本的页面结构，不包含具体样式
 *
 * 子主题可以覆盖此模板添加自定义样式
 *
 * @file
 * Default theme implementation for pages.
 *
 * Variables:
 * - title: Page title.
 * - page_top: Initial markup from other modules.
 * - page_bottom: Closing markup from other modules.
 * - primary_menu: Primary menu rendering.
 * - secondary_menu: Secondary menu rendering.
 * - breadcrumbs: Breadcrumbs.
 * - node: Fully loaded node, if there is an automatically-loaded node.
 * - profile: The profile of a fully loaded node, if there is one.
 * - description: The node description.
 * - actions: Node actions.
 * - content: Page content.
 * - sidebar_primary: Sidebar content.
 * - sidebar_secondary: Additional sidebar content.
 * - footer: Footer content.
 */
#}

{{ attach_library('mybase/global') }}

{{ page.top }}

{# Skip link - 无障碍访问 #}
<a href="#main-content" class="visually-hidden focusable skip-link">
  {{ 'Skip to main content'|t }}
</a>

{% set page_header %}
  {% if user_menu %}
    <div class="user-menu">{{ user_menu }}</div>
  {% endif %}
  {% if language_menu %}
    <div class="language-switcher-language-url">{{ language_menu }}</div>
  {% endif %}
{% endset %}
{{ page.header|without(primary_menu, secondary_menu, social_links) }}

<nav class="menu primary-menu" role="navigation" aria-labelledby="system-primary-menu-heading">
  <h2 id="system-primary-menu-heading" class="visually-hidden">{{ 'Primary menu'|t }}</h2>
  {{ primary_menu }}
</nav>

{% if secondary_menu %}
<nav class="menu secondary-menu" role="navigation" aria-labelledby="system-secondary-menu-heading">
  <h2 id="system-secondary-menu-heading" class="visually-hidden">{{ 'Secondary menu'|t }}</h2>
  {{ secondary_menu }}
</nav>
{% endif %}

{% if breadcrumbs %}
<nav class="breadcrumbs" role="navigation" aria-labelledby="breadcrumbs-heading">
  <h2 id="breadcrumbs-heading" class="visually-hidden">{{ 'Breadcrumb'|t }}</h2>
  {{ breadcrumbs }}
</nav>
{% endif %}

<div class="page-layout{{ page_layout }}">
  
  {% if sidebar_primary %}
  <aside class="layout-column layout-column--left">{{ sidebar_primary }}</aside>
  {% endif %}
  
  <main id="main-content" class="page-content" role="main">
    {% if title %}<h1 class="page-title">{{ title }}</h1>{% endif %}
    {{ page.content }}
    {{ page.sidebar_secondary }}
  </main>
  
  {% if sidebar_secondary %}
  <aside class="layout-column layout-column--right">{{ sidebar_secondary }}</aside>
  {% endif %}
  
</div>

<div class="page-footer">
  {{ page.footer }}
</div>

{{ page_bottom }}
```

##### node.html.twig (基础节点模板)
```twig
{#
 * @file
 * Basic node template for base theme.
 * 子主题可以覆盖此模板添加自定义样式
 *
 * Variables:
 * - title: Node title.
 * - content: All node items.
 * - name: Node author name.
 * - author_picture: Node author picture.
 * - date: Created date.
 * - tags: Array of taxonomy terms.
 */
#}

<article{{ attributes }}>
  
  {% if title_prefix %}<div class="title-prefix">{{ title_prefix }}</div>{% endif %}
  {% if title %}<h2{{ title_attributes }}><a href="{{ url }}">{{ title }}</a></h2>{% endif %}
  {% if title_suffix %}<div class="title-suffix">{{ title_suffix }}</div>{% endif %}
  
  {% if user_picture and node.type != 'comment' %}
  <div class="node-picture">
    {{ user_picture }}
  </div>
  {% endif %}
  
  {% if not page and label %}
  <h2{{ title_attributes }}>{{ label }}</h2>
  {% endif %}
  
  <div{{ content_attributes }}>
    {{ content }}
  </div>
  
  {% if not page and view_mode %}
  <ul class="links inline">
    <li class="node-link">{{ link('Read more', node_url) }}</li>
    {% endif %}
  </ul>
</article>
```

#### 4. libraries.yml 文件

```yaml
# mybase.libraries.yml
global:
  version: 1.0.0
  css:
    theme:
      css/style.css: {}
  js:
    js/scripts.js: {}

# 响应式样式
responsive:
  version: 1.0.0
  css:
    theme:
      css/responsive.css: { media: 'all' }

# 打印样式
print:
  version: 1.0.0
  css:
    theme:
      css/print.css: { media: print }
```

#### 5. .theme 文件

```php
<?php

/**
 * @file
 * MyBase Theme functionality.
 */

/**
 * 实现 hook_base_theme_info()
 * 返回基础主题的样式表路径
 */
function mybase_base_theme_info() {
  return [
    'settings' => [
      'assetsPath' => drupal_get_path('theme', 'mybase') . '/assets',
    ],
  ];
}

/**
 * 实现 hook_preprocess_HOOK() 的通用实现
 */
function mybase_preprocess_page(&$variables) {
  // 添加通用页面变量
  $variables['mybase_site_name'] = \Drupal::service('system.site')->getVariable('name');
  $variables['mybase_year'] = date('Y');
  
  // 添加 CSS 类
  $variables['attributes']->addClass('theme-mybase');
  
  // 设置区域类
  $regions = [
    'header' => 'region header',
    'primary_menu' => 'region primary-menu',
    'footer' => 'region footer',
  ];
  
  foreach ($regions as $region => $class) {
    if (!empty($variables['page'][$region])) {
      $variables['page'][$region]['#attributes']->addClass($class);
    }
  }
}

/**
 * 实现 hook_form_FORM_ID_alter()
 * 修改表单样式
 */
function mybase_form_alter(&$form, \Drupal\Core\Form\FormStateInterface $form_state, $form_id) {
  // 为所有表单添加基础样式类
  if (isset($form['#attributes'])) {
    $form['#attributes']['class'][] = 'mybase-form';
  }
}

/**
 * 实现 hook_css_alter()
 * 修改 CSS 文件属性
 */
function mybase_css_alter(&$css) {
  // 将所有 CSS 文件移动到同一目录
  foreach ($css as &$item) {
    if (is_string($item)) {
      // 修改 CSS 路径
    }
  }
}

/**
 * 实现 hook_js_alter()
 * 修改 JavaScript 文件属性
 */
function mybase_js_alter(&$javascript) {
  // 修改 JS 文件路径或属性
  foreach ($javascript as &$item) {
    if (is_string($item)) {
      // 修改 JS 链接
    }
  }
}

/**
 * 辅助函数：获取主题设置
 */
function mybase_get_setting($setting_name, $default = NULL) {
  return \Drupal::config('mybase.settings')->get($setting_name, $default);
}
```

---

## 🎨 子主题开发

### 什么是子主题？

子主题 (Sub-theme) 继承自基础主题，只包含：
- 覆盖的模板文件
- 额外的 CSS/JS 文件
- 自定义的预处理函数
- 主题设置

**优势**:
- 快速开发
- 轻量级
- 易于维护
- 不修改父主题

### 创建子主题

#### 1. 主题结构

```
mysubtheme/
├── mysubtheme.info.yml
├── mysubtheme.theme
├── mysubtheme.libraries.yml
├── css/
│   └── custom.css          # 自定义样式 (覆盖基础主题)
├── js/
│   └── custom.js           # 自定义 JavaScript
└── templates/              # 覆盖的模板
    ├── page.html.twig
    └── node.html.twig
```

#### 2. .info.yml 文件

```yaml
# mysubtheme.info.yml
name: 'My Sub Theme'
type: theme
description: 'Sub-theme of My Base Theme'
core_version_requirement: ^11

# 继承的基础主题
base theme: mybase

# 只定义新增的资源
stylesheets:
  - css/custom.css

# 只定义新增的脚本
scripts:
  - js/custom.js

# 版本信息
version: '1.0.0'
package: Sub Themes
```

#### 3. libraries.yml 文件

```yaml
# mysubtheme.libraries.yml
# 定义子主题特有的资源
custom-style:
  version: 1.0.0
  css:
    theme:
      css/custom.css: { weight: -5 }

custom-scripts:
  version: 1.0.0
  js:
    js/custom.js: { type: file, attribute: defer }
```

#### 4. .theme 文件

```php
<?php

/**
 * @file
 * My Sub Theme functionality.
 */

/**
 * 实现 hook_preprocess_page()
 * 添加子主题特有的变数
 */
function mysubtheme_preprocess_page(&$variables) {
  // 继承父主题的预处理
  mybase_preprocess_page($variables);
  
  // 添加子主题特有的变数
  $variables['custom_footer_text'] = '© 2026 My Company';
  
  // 根据页面添加特殊 CSS 类
  $path = \Drupal::service('current_route_match')->getCurrentRouteName();
  $variables['attributes']->addClass('page-' . $path);
}

/**
 * 实现 hook_preprocess_node()
 * 添加子主题节点特有的变数
 */
function mysubtheme_preprocess_node(&$variables) {
  // 确保继承父主题的预处理
  mybase_preprocess_node($variables);
  
  // 添加子主题特有的信息
  if ($variables['node']->getType() == 'article') {
    $variables['show_author_bio'] = TRUE;
  }
}
```

#### 5. 覆盖模板文件

##### page.html.twig
```twig
{#
 * mysubtheme/templates/page.html.twig
 * 覆盖 mybase/page.html.twig
 * 只添加子主题特有的样式
 *
 * 使用 parent 变量继承父主题的模板
 * 使用 {{ content|without() }} 过滤内容
 */
#}

{{ attach_library('mysubtheme/custom-style') }}

<header class="site-header my-sub-header">
  {{ page.header }}
</header>

<div class="site-nav my-sub-nav">
  {{ page.primary_menu }}
</div>

<main id="main-content" class="site-main">
  {{ page.content }}
</main>

<footer class="site-footer my-sub-footer">
  <div class="footer-custom">
    {{ custom_footer_text }}
  </div>
  {{ page.footer }}
</footer>
```

---

## 🏗️ 创建子主题的步骤

### Step 1: 创建主题文件夹

```bash
mkdir -p themes/custom/mysubtheme
cd themes/custom/mysubtheme
```

### Step 2: 创建 .info.yml 文件

```yaml
name: 'My Sub Theme'
base theme: mybase  # 继承基础主题
```

### Step 3: 复制基础主题的 templates 目录

```bash
# 从基础主题复制模板
cp -r themes/custom/mybase/templates templates/

# 现在可以修改需要的模板
```

### Step 4: 创建自定义资源

```bash
# CSS 文件
touch css/custom.css

# JavaScript 文件
touch js/custom.js

# 更新 libraries.yml
vi mysubtheme.libraries.yml
```

### Step 5: 创建 .theme 文件

```bash
# 添加预处理函数
touch mysubtheme.theme
```

### Step 6: 清除缓存并启用

```bash
# 清除缓存
drush cr

# 安装主题
drush theme:install mysubtheme

# 设置为主题
drush config-set system.theme.default mysubtheme
```

---

## 🎯 主题开发最佳实践

### 1. 主题命名规范

```yaml
# ✅ 正确的命名
- my_theme_name: 'My Theme Name'
- my_sub_theme: 'My Sub Theme'

# ❌ 错误的命名
- my-theme: 'My-Theme'        # 使用下划线而非连字符
- MY_THEME: 'My Theme'        # 使用小写
- theme_one: 'Theme One'      # 不要在词尾加 underscore
```

### 2. 资源管理

```yaml
libraries:
  # ✅ 正确的做法
  global-style:
    css:
      theme:
        css/style.css: { weight: -10 }
  
  # ❌ 避免硬编码权重
  custom:
    css:
      theme:
        css/custom.css: { }  # 不指定权重，使用默认
```

### 3. 模板组织

```
# ✅ 正确的组织
templates/
├── page.html.twig
├── node.html.twig
├── block.html.twig
└── region.html.twig

# ❌ 避免
- 不要在模板中写复杂 PHP 代码
- 不要在模板中调用 API
```

### 4. 预处理函数

```php
// ✅ 正确的做法
function mytheme_preprocess_page(&$variables) {
  // 只添加简单变量
  $variables['site_name'] = 'My Site';
}

// ❌ 避免
function mytheme_preprocess_page(&$variables) {
  // 不要在预处理中执行复杂操作
  $complex_data = do_complex_operation();
}
```

---

## 📊 Sub-theme vs Custom Theme

### Sub-theme 适用场景
- ✅ 只需要修改样式
- ✅ 需要快速开发
- ✅ 希望易于维护
- ✅ 只需要覆盖模板

### Custom Theme 适用场景
- ✅ 需要完全控制
- ✅ 有特殊功能需求
- ✅ 性能优化要求高
- ✅ 需要深度定制

---

## 📚 参考资源和主题

### Drupal 11 官方基础主题

1. **Stable** - 官方推荐的基础主题
2. **Olivia** - 现代化基础主题
3. **Classy** - 提供完整样式的基础主题 (Drupal 10)

### 第三方基础主题

| 主题 | 说明 | 链接 |
|------|------|------|
| **Solo** | 现代化、轻量级 | https://www.drupal.org/project/solo |
| **Base Zymphonies** | 响应式基础主题 | https://www.drupal.org/project/base_zymphonies_theme |
| **Omega** | 经典基础主题 | https://www.drupal.org/project/omega |

### 常用子主题

| 子主题 | 基础主题 | 说明 |
|------|---------|------|
| **Classy Sub** | Classy | 轻量级子主题 |
| **Bartik Sub** | Bartik | 经典风格的子主题 |

---

## 📋 主题开发检查清单

### 创建基础主题检查清单

- [ ] 创建 .info.yml 文件
- [ ] 创建 .libraries.yml 文件  
- [ ] 创建 templates 目录和基础模板
- [ ] 创建 .theme 文件实现钩子
- [ ] 创建 CSS/JS 资源文件
- [ ] 添加 screenshot.png 截图
- [ ] 测试主题功能
- [ ] 编写文档和说明

### 创建子主题检查清单

- [ ] 创建 .info.yml 指定 base theme
- [ ] 创建子主题特有的 CSS/JS
- [ ] 覆盖需要的模板文件
- [ ] 添加子主题预处理函数
- [ ] 测试主题继承关系
- [ ] 确保父主题功能正常

---

## 🔗 学习资源

### 官方文档
- [Defining a theme](https://www.drupal.org/docs/develop/theming-drupal/defining-a-theme-with-an-infoyml-file)
- [Creating sub-themes](https://www.drupal.org/docs/develop/theming-drupal/creating-sub-themes)
- [Adding resources](https://www.drupal.org/docs/develop/theming-drupal/adding-assets-css-js-to-a-drupal-theme-via-librariesyml)

### 社区资源
- [Drupal.org Theming Forum](https://www.drupal.org/forum/section/6)
- [Stack Overflow - Theming](https://stackoverflow.com/questions/tagged/drupal-theming)
- [Base Theme Examples](https://github.com/drupal/base-theme)

---

## 📅 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| 1.0 | 2026-04-08 | 初始化文档 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-08

*基础主题和子主题是 Drupal 主题开发的重要组成部分，选择合适的主题策略可以大大提高开发效率*
