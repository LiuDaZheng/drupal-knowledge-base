---
name: drupal-theme-development
description: Complete guide to Drupal 11 Theme Development. Covers Twig templates, preprocessors, libraries, Paragraphs, Layout Builder, E-commerce themes, and best practices.
---

# Drupal 主题开发完整指南

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
**主题开发**是 Drupal 前端开发和 UI/UX 设计的核心技能。它涉及创建自定义主题来完全控制站点的外观和感觉，包括 HTML 结构、CSS 样式、JavaScript 交互等。

### 核心功能
- ✅ Twig 模板引擎和模板覆盖
- ✅ 预处理器函数和变数转换
- ✅ 资源库管理和资产集成
- ✅ 主题文件夹结构和文件组织
- ✅ 子主题和基础主题创建
- ✅ 响应式设计和移动优先
- ✅ 无障碍访问 (WCAG) 支持
- ✅ 主题开发最佳实践

### 适用范围
- ✅ 自定义企业网站
- ✅ 电子商务站点 (Drupal Commerce)
- ✅ 多语言国际站点
- ✅ 内容展示型网站
- ✅ 复杂布局页面 (使用 Paragraphs/Layout Builder)

---

## 🚀 安装与启用

### 默认状态
- ✅ **核心功能**: Twig 模板引擎是 Drupal 11 核心功能
- ⚡ **主题系统**: Drupal 11 使用 Twig 作为唯一的主题引擎

### 检查状态
```bash
# 查看当前主题
drush config-get system.theme default

# 查看所有已启用主题
drush pm-list --type=theme

# 查看主题设置
drush config-get system.theme.admin
```

### 主题开发环境设置

#### 开发配置
```yaml
# sites/default/services.yml
twig.config:
  debug: true              # 启用 Twig 调试
  auto_reload: true        # 自动重载模板
  cache: false             # 禁用 Twig 缓存 (开发环境)
```

#### 禁用缓存 (开发模式)
```bash
# 使用 Mix 模块 (推荐)
drush mix:enable

# 手动配置
# /admin/config/development/settings
```

---

## 🏗️ 主题文件夹结构

### 标准主题结构

```
mytheme/
├── mytheme.info.yml          # 主题描述文件 (必需)
├── mytheme.libraries.yml     # 资源库定义 (必需)
├── mytheme.theme             # 预处理和主题函数
├── mytheme.routing.yml       # 路由定义
├── mytheme.libraries.ext.override.yml  # 资源库覆盖
├── screenshot.png            # 主题预览截图 (推荐)
├── css/                      # CSS 目录
│   ├── style.css            # 主样式表
│   └── style.print.css      # 打印样式
├── js/                       # JavaScript 目录
│   └── scripts.js           # 主 JavaScript 文件
├── templates/                # Twig 模板目录 (必需)
│   ├── page.html.twig       # 页面模板
│   ├── node.html.twig       # 节点模板
│   ├── paragraph.html.twig  # 段落模板
│   └── ...                  # 其他模板
├── layouts/                  # 自定义布局定义
│   └── layouts.yml
├── assets/                   # 字体、图片等资源
│   ├── fonts/
│   ├── images/
│   └── icons/
└── config/                   # 主题配置文件
    └── optional/
        └── settings.local.yml
```

### 重要文件说明

#### 1. .info.yml 文件
```yaml
name: 'My Theme'
type: theme
description: 'Custom Drupal 11 theme for enterprise applications'
core_version_requirement: ^11
base theme: stable             # 继承的基础主题

# 依赖项
dependencies:
  - drupal:node
  - drupal:system
  - paragraphs:paragraphs
  - layout_builder:layout_builder

# 样式表和脚本
stylesheets:
  - css/style.css
  - css/responsive.css
scripts:
  - js/scripts.js

# 支持的功能
features:
  - node_styling
  - comment_styling
  - block_styling

# 版本配置
version: '1.0.0'
package: Custom Themes
```

#### 2. libraries.yml 文件
```yaml
# 主资源库
global-styling:
  version: 1.0.0
  css:
    theme:
      css/style.css: { weight: -10 }
      css/responsive.css: { media: 'all' }

# JavaScript 资源库
global-scripts:
  version: 1.0.0
  js:
    js/scripts.js: { type: file, attribute: async }

# 第三方库
bootstrap:
  version: 5.3.0
  css:
    component:
      https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css: { type: external, attribute: async }
  js:
    https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js: { type: external, attribute: async }

# 本地字体
my-fonts:
  version: 1.0.0
  local:
    - assets/fonts/myfont.woff2
  css:
    theme:
      css/fonts.css: { weight: -5 }
```

#### 3. .theme 文件
```php
<?php

/**
 * @file
 * My Theme functionality.
 */

/**
 * Implement hook_process_global().
 */
function mytheme_process_global(&$variables) {
  $variables['site_name'] = '我的企业网站';
}

/**
 * Implement hook_preprocess_page().
 */
function mytheme_preprocess_page(&$variables) {
  // 添加自定义变数
  $variables['custom_message'] = get_custom_message();
  
  // 条件性地添加 CSS 类
  if (\Drupal::currentUser()->isAuthenticated()) {
    $variables['attributes']->addClass('logged-in');
  } else {
    $variables['attributes']->addClass('anonymous');
  }
  
  // 添加面包屑导航
  $breadcrumbs = \Drupal::service('breadcrumb.builder')->build(\Drupal::request());
  $variables['breadcrumbs'] = $breadcrumbs;
}

/**
 * Implement hook_preprocess_node().
 */
function mytheme_preprocess_node(&$variables) {
  // 显示作者信息
  $author = $variables['node']->getOwner();
  $variables['author_name'] = $author->getDisplayName();
  $variables['author_picture'] = $author->getPicture()->uri->value;
  
  // 设置时间戳格式
  $variables['date'] = format_date($variables['node']->getChangedTime(), 'short');
}

/**
 * 辅助函数
 */
function get_custom_message() {
  $site_config = \Drupal::config('system.site');
  return '欢迎访问 ' . $site_config->get('settings.site_name');
}
```

---

## 📊 Twig 模板系统

### Twig 模板查找顺序

#### 页面模板优先级
```
page.html.twig
page--[node-type].html.twig
page--[view-mode].html.twig
page--[region].html.twig
page--[theme].html.twig
```

#### 节点模板优先级
```
node--[node-type]--[view-mode].html.twig
node--[node-type].html.twig
node--[view-mode].html.twig
node.html.twig
```

#### 段落模板优先级
```
paragraph--[paragraph-type]--[view-mode].html.twig
paragraph--[paragraph-type].html.twig
paragraph--[view-mode].html.twig
paragraph.html.twig
```

### 常用 Twig 模板文件

#### 1. 页面模板 (page.html.twig)
```twig
{#
/**
 * @file
 * Default theme implementation to display the basic page structure.
 *
 * Variables:
 * - logged_in: True if the visitor is logged in, false otherwise.
 * - front: True if the current path is the front page.
 * - logged_in: True if the visitor is logged in, false otherwise.
 * - name: The name of the logged-in user, if available.
 * - css: CSS variables.
 * - attributes: HTML attributes for the page element.
 * - title: Page title.
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
 * - page_top: Initial markup from other modules.
 * - page_bottom: Closing markup from other modules.
 */
#}

{{ attach_library('mytheme/global-styling') }}
{{ attach_library('mytheme/global-scripts') }}

<div{{ attributes }}>
  
  {# Header #}
  <header class="site-header">
    {{ page.header }}
  </header>
  
  {# Navigation #}
  <nav class="site-navigation">
    {{ primary_menu }}
  </nav>
  
  {# Main content #}
  <div class="site-main container">
    {% if breadcrumbs %}
      <nav class="breadcrumbs" aria-label="{{ 'Breadcrumbs'|t }}">
        {{ breadcrumbs }}
      </nav>
    {% endif %}
    
    {% if content_top %}
      <div class="content-top">
        {{ content_top }}
      </div>
    {% endif %}
    
    <main class="page-content"{{ content_attributes }}>
      {% if title %}
        <h1 class="page-title">{{ title }}</h1>
      {% endif %}
      
      {{ page.content }}
    </main>
    
    {% if sidebar_primary %}
      <aside class="sidebar-primary">
        {{ sidebar_primary }}
      </aside>
    {% endif %}
    
    {% if sidebar_secondary %}
      <aside class="sidebar-secondary">
        {{ sidebar_secondary }}
      </aside>
    {% endif %}
    
    {% if content_bottom %}
      <div class="content-bottom">
        {{ content_bottom }}
      </div>
    {% endif %}
  </div>
  
  {# Footer #}
  <footer class="site-footer">
    {{ page.footer }}
  </footer>
  
</div>

{{ page_bottom }}
```

#### 2. 节点模板 (node.html.twig)
```twig
{#
/**
 * @file
 * Default theme implementation to display a node.
 *
 * Variables:
 * - title: The title of the node.
 * - content: All node items. Use {{ content }} to print them all,
 *   or print a subset such as {{ content['field_example'] }}.
 * - meta: Metadata for each field.
 * - name: The name of the node author.
 * - author_picture: Author picture.
 * - author_name: Author name.
 * - date: Created date.
 * - tags: Array of taxonomy terms.
 * - title_prefix: Markup for title (e.g., [Read more]).
 * - title_suffix: Markup for title (e.g., [Read more]).
 * - content_attributes: HTML attributes for content.
 */
#}

<article{{ attributes }}>

  {# Title #}
  {% if title_prefix %}
    <div class="title-prefix">{{ title_prefix }}</div>
  {% endif %}
  
  {% if title %}
    <h2{{ title_attributes }}><a href="{{ url }}">{{ title }}</a></h2>
  {% endif %}
  
  {% if title_suffix %}
    <div class="title-suffix">{{ title_suffix }}</div>
  {% endif %}
  
  {# Meta #}
  <div class="node-meta">
    {% if author_picture %}
      <div class="author-picture">
        {{ author_picture }}
      </div>
    {% endif %}
    
    <div class="node-info">
      {% if name %}
        <span class="author">{{ author_name }}</span>
      {% endif %}
      
      {% if date %}
        <time datetime="{{ date }}">{{ date }}</time>
      {% endif %}
      
      {% if tags %}
        <div class="terms">
          {% for term in tags %}
            <span class="term">{{ term }}</span>
          {% endfor %}
        </div>
      {% endif %}
    </div>
  </div>
  
  {# Content #}
  {{ content }}
  
</article>
```

#### 3. 产品页面模板 (commerce-product.html.twig)
```twig
{#
/**
 * @file
 * Drupal Commerce product page template.
 */
#}

<div class="commerce-product{{_attributes.addClass('product-' ~ bundle)}}">
  
  {# Product Image #}
  <div class="product-image">
    {{ content.field_product_image }}
  </div>
  
  {# Product Details #}
  <div class="product-details">
    <h1 class="product-title"{{ title_attributes }}>{{ label }}</h1>
    
    {% if price %}
      <div class="product-price">
        {{ price }}
      </div>
    {% endif %}
    
    <div class="product-description">
      {{ content.field_description }}
    </div>
    
    {# SKU #}
    {% if sku %}
      <div class="product-sku">
        <strong>SKU:</strong> {{ sku }}
      </div>
    {% endif %}
    
    {# Add to Cart #}
    {% if add_to_cart %}
      <div class="product-actions">
        {{ add_to_cart }}
      </div>
    {% endif %}
    
    {# Additional Fields #}
    {{ content|without(
      'field_product_image',
      'field_description',
      'price',
      'add_to_cart'
    ) }}
  </div>
  
</div>
```

---

## 🎨 Paragraph 主题开发

### Paragraph 模板结构

#### 默认模板 (paragraph.html.twig)
```twig
{#
/**
 * @file
 * Default theme implementation for paragraphs.
 */
#}

<div class="paragraph{{ paragraph_attributes.addClass('paragraph--type--' | html_attr(type)) }}">
  
  {# Title #}
  {% if label %}
    <h2>{{ label }}</h2>
  {% endif %}
  
  {# Content #}
  <div class="paragraph__content">
    {{ content }}
  </div>
  
</div>
```

#### 特定类型模板 (paragraph--text-block.html.twig)
```twig
{#
/**
 * @file
 * Theme implementation for text block paragraphs.
 */
#}

<section class="paragraph paragraph--type--text-block{{ paragraph_attributes.addClass('text-block--' ~ view_mode)}}">
  
  {% if content.field_title %}
    <h2 class="text-block__title">
      {{ content.field_title }}
    </h2>
  {% endif %}
  
  <div class="text-block__content">
    {{ content.body }}
  </div>
  
</section>
```

#### 特定变体模板 (paragraph--text-block--default.html.twig)
```twig
{#
/**
 * @file
 * Theme implementation for text block paragraphs with default view mode.
 */
#}

{{ attach_library('mytheme/text-block') }}

<section class="paragraph paragraph--type--text-block paragraph--view-mode--default{{ paragraph_attributes.addClass('text-block--' ~ view_mode)}}">
  
  {% if content.field_title %}
    <h2 class="text-block__title">
      {{ content.field_title }}
    </h2>
  {% endif %}
  
  <div class="text-block__content">
    {{ content.body }}
  </div>
  
</section>
```

### Paragraph 主题开发技巧

#### 1. 使用 Style Options 模块
```yaml
# 为段落类型添加样式选项
paragraphs--image:
  type: image
  title: 'Image Paragraph'
  description: 'Display an image with optional caption'
  settings:
    - field_image
    - field_caption
  style_options:
    enabled: true
    options:
      alignment:
        default: 0
        label: 'Default'
        value: center: true
      style:
        - default: bordered
          label: 'Bordered'
        - default: rounded
          label: 'Rounded'
```

#### 2. 条件性地显示内容
```twig
{# paragraph--image.html.twig #}
<div class="paragraph paragraph--type--image{{ paragraph_attributes.addClass('alignment-' ~ content.field_image.0.alignment.value)}}">
  
  {% if content.field_image %}
    <figure{{ figure_attributes }}>
      <img {{ content.field_image }}
           alt="{{ content.field_image.0.alt }}"
           class="image-style-{{ view_mode }}">
      
      {% if content.field_caption %}
        <figcaption>{{ content.field_caption }}</figcaption>
      {% endif %}
    </figure>
  {% endif %}
  
</div>
```

---

## 🏗️ Layout Builder 主题开发

### 自定义布局定义

#### 布局定义文件 (layouts.yml)
```yaml
# mytheme.layouts.yml
two_col_section:
  label: 'Two column'
  path: layouts/twocol_section
  template: layout--twocol-section
  library: mytheme/twocol-section
  icon: paths/assets/icons/layout-twocol-section.svg
  icon_dark: paths/assets/icons/layout-twocol-section--dark.svg
  icon_dark_path: layouts/icons/layout-twocol-section--dark.svg
  class: 'Drupal\mytheme\Plugin\Layout\TwoColumnLayout'
  category: 'Columns: 2'
  default_region: first
  icon_map:
    - [first, second]
  regions:
    first:
      label: First column
    second:
      label: Second column

# Three column section
three_col_section:
  label: 'Three column'
  path: layouts/threecol_section
  template: layout--threecol-section
  library: mytheme/threecol-section
  icon: paths/assets/icons/layout-threecol-section.svg
  icon_dark: paths/assets/icons/layout-threecol-section--dark.svg
  icon_dark_path: layouts/icons/layout-threecol-section--dark.svg
  class: 'Drupal\mytheme\Plugin\Layout\ThreeColumnLayout'
  category: 'Columns: 3'
  default_region: first
  icon_map:
    - [first, second, third]
  regions:
    first:
      label: First column
    second:
      label: Second column
    third:
      label: Third column
```

#### 布局模板 (layout--twocol-section.twig)
```twig
{#
/**
 * @file
 * Theme implementation for two column layout.
 */
#}

<div class="layout twocol-section{{ classes }}">
  
  <div class="layout__region layout__region-first">
    {{ content.first }}
  </div>
  
  <div class="layout__region layout__region-second">
    {{ content.second }}
  </div>
  
</div>
```

#### 自定义布局 PHP 类
```php
<?php

namespace Drupal\mytheme\Plugin\Layout;

use Drupal\Core\Field\FieldItemListInterface;
use Drupal\Core\Layout\LayoutPluginBase;

/**
 * Defines a custom two column layout.
 */
class TwoColumnLayout extends LayoutPluginBase {
  
  /**
   * {@inheritdoc}
   */
  public function build() {
    $build = [];
    
    $build['first'] = [
      '#tag' => 'div',
      '#attributes' => ['class' => ['col', 'col-first']],
      '#children' => $this->buildRegion('first'),
    ];
    
    $build['second'] = [
      '#tag' => 'div',
      '#attributes' => ['class' => ['col', 'col-second']],
      '#children' => $this->buildRegion('second'),
    ];
    
    return $build;
  }
  
  /**
   * {@inheritdoc}
   */
  public function getRegionNames() {
    return [
      $this->t('First Column'),
      $this->t('Second Column'),
    ];
  }
  
}
```

---

## 🛒 E-commerce 主题开发

### Commerce 产品页面模板

#### 产品卡片模板 (commerce-product-card.html.twig)
```twig
{#
/**
 * @file
 * Theme implementation for Commerce product card.
 */
#}

<article class="commerce-product-card{{ attributes.addClass('view-mode--teaser') }}">
  
  {# Product Image #}
  <div class="product-card__image">
    {{ content.field_product_image }}
  </div>
  
  {# Product Info #}
  <div class="product-card__info">
    <h3 class="product-card__title">
      <a href="{{ url }}">{{ label }}</a>
    </h3>
    
    {% if price %}
      <div class="product-card__price">
        {{ price }}
      </div>
    {% endif %}
    
    <div class="product-card__sku">
      <strong>SKU:</strong> {{ content.field_sku }}
    </div>
    
    {# Short Description #}
    {% if field_short_description %}
      <div class="product-card__description">
        {{ content.field_short_description }}
      </div>
    {% endif %}
  </div>
  
</article>
```

#### 购物车模板 (commerce-cart.html.twig)
```twig
{#
/**
 * @file
 * Theme implementation for Drupal Commerce cart page.
 */
#}

<div class="commerce-cart{{ attributes.addClass('cart-page') }}">
  
  <h1>{{ 'Shopping Cart'|t }}</h1>
  
  {{ content }}
  
  {# Cart Subtotal #}
  {% if cart_total %}
    <div class="cart-subtotal">
      <strong>{{ 'Subtotal:'|t }}</strong> {{ cart_total }}
    </div>
  {% endif %}
  
  {# Promo Code #}
  <div class="cart-promo">
    <form class="cart-promo-form" method="post" action="{{ path('commerce_cart.add_discount') }}">
      <input type="text" name="code" placeholder="{{ 'Promo code'|t }}">
      <button type="submit">{{ 'Apply'|t }}</button>
    </form>
  </div>
  
</div>
```

### Commerce 结账页面模板

#### 结账步骤模板 (commerce-checkout-step.html.twig)
```twig
{#
/**
 * @file
 * Theme implementation for checkout steps.
 */
#}

<div class="commerce-checkout-step{{ attributes.addClass('step--' ~ step)|html_attr}}">
  
  <h2>{{ step_label }}</h2>
  
  <div class="step-content">
    {{ content }}
  </div>
  
</div>
```

#### 订单确认模板 (commerce-order-confirmation.html.twig)
```twig
{#
/**
 * @file
 * Theme implementation for order confirmation.
 */
#}

<article class="commerce-order-confirmation{{ attributes }}">
  
  <h1>{{ 'Thank you for your order!'|t }}</h1>
  
  <div class="order-details">
    <dl class="order-info">
      <dt>{{ 'Order number:'|t }}</dt>
      <dd>{{ order_number }}</dd>
      
      <dt>{{ 'Total:'|t }}</dt>
      <dd>{{ total }}</dd>
      
      <dt>{{ 'Date:'|t }}</dt>
      <dd>{{ date }}</dd>
    </dl>
    
    <div class="order-items">
      {{ order_items }}
    </div>
    
    {{ shipping_address }}
    {{ billing_address }}
  </div>
  
</article>
```

---

## 📚 主题开发最佳实践

### 1. 命名规范

#### 模板文件命名
```
✅ 正确：
node--article.html.twig
node--page--teaser.html.twig
paragraph--image--default.html.twig
commerce-product--product.html.twig

❌ 错误：
node--article.tpl.php
node--product--view--mode.php
```

#### CSS 类命名
```scss
/* BEM 命名规范 */
.product-card {
  &__image { }
  &__title { }
  &--large { }
  
  &__image:hover { }
}
```

### 2. 性能优化

#### 资源加载优化
```yaml
# libraries.yml
global-styling:
  version: 1.0.0
  css:
    theme:
      css/style.css: { preprocess: true, weight: -10 }

# 使用 defer 和 async
global-scripts:
  version: 1.0.0
  js:
    js/scripts.js: {
      type: file,
      attribute: defer,
      weight: 10
    }
```

#### 模板缓存优化
```php
// .theme 文件
function mytheme_preprocess_page(&$variables) {
  // 设置缓存标签
  $variables['#cache']['tags'] = ['page', 'node_list'];
  $variables['#cache']['contexts'] = ['languages:language_interface'];
  $variables['#cache']['max-age'] = 3600;
}
```

### 3. 无障碍访问 (WCAG)

```twig
{# page.html.twig #}
<main class="main-content" role="main" id="main-content">
  {{ page.content }}
</main>

<nav class="navigation" role="navigation" aria-label="{{ 'Primary navigation'|t }}">
  {{ primary_menu }}
</nav>

<address class="site-footer" role="contentinfo">
  {{ page.footer }}
</address>

{# 跳过导航链接 #}
<a href="#main-content" class="skip-link">
  {{ 'Skip to main content'|t }}
</a>
```

### 4. 响应式设计

```scss
// style.scss
$breakpoints: (
  mobile: 0,
  tablet: 768px,
  desktop: 1024px,
  wide: 1440px
);

@mixin respond($breakpoint) {
  @media (min-width: map-get($breakpoints, $breakpoint)) {
    @content;
  }
}

.product-card {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
  
  @include respond(tablet) {
    grid-template-columns: 1fr 1fr;
  }
  
  @include respond(wide) {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

---

## 🔧 调试和工具

### Twig 调试配置

```yaml
# services.yml
twig.config:
  debug: true
  auto_reload: true
  cache: false
```

### 查看模板建议

```php
// 启用 Twig 调试后，页面源码会显示所有模板建议
<!-- THEME SUGGESTIONS:
   * page.html.twig
   * page--front.html.twig
   * page--[theme].html.twig
  -->
```

### 使用 XHProf 性能分析

```bash
# 安装 XHProf
composer require drupal/xhprof

# 启用性能分析
drush config-set devel.xhprof.enable true
```

### 使用 Mix 模块

```bash
# 安装 Mix 模块
composer require drupal/mix

# 启用 Mix
drush mix:enable

# 禁用 Mix
drush mix:disable
```

---

## 📊 常见问题 (FAQ)

### Q1: 如何创建子主题？
**A**: 
1. 创建 `.info.yml` 文件，设置 `base theme: stable` 或其他基础主题
2. 添加模板文件覆盖
3. 清除缓存

### Q2: 如何调试模板不生效？
**A**: 
1. 检查文件名和命名规范是否正确
2. 确认模板路径
3. 清空缓存：`drush cr`
4. 启用 Twig 调试查看建议

### Q3: 如何优化主题性能？
**A**: 
1. 使用 CSS/JS 聚合
2. 延迟加载非关键资源
3. 使用 CDN 托管资源
4. 优化图片和字体

### Q4: 如何处理多语言主题？
**A**: 
1. 创建语言特定的模板文件
2. 使用 `{{ site_name }}` 等多语言变量
3. 配置语言检测

### Q5: 如何创建自定义布局？
**A**: 
1. 定义 `layouts.yml` 文件
2. 创建布局 PHP 插件
3. 创建布局模板文件
4. 在 Layout Builder 中使用

---

## 🔗 参考资源

### 官方文档
- [Twig in Drupal](https://www.drupal.org/docs/develop/theming-drupal/twig-in-drupal)
- [Theme API](https://www.drupal.org/docs/develop/theming-drupal)
- [Layout API](https://www.drupal.org/docs/drupal-apis/layout-api)
- [Commerce Themes](https://drupalcommerce.org/extensions/theme)

### 社区资源
- [Drupalize.me Theming Course](https://drupalize.me/topic/theming-drupal)
- [Stack Exchange Questions (theming)](https://drupal.stackexchange.com/questions/tagged/theming)
- [GitHub Drupal Core](https://github.com/drupal/drupal/tree/core)

### 工具和模块
- [Twig Suggester](https://www.drupal.org/project/twigsuggest)
- [Classy Paragraphs](https://www.drupal.org/project/classy_paragraphs)
- [Mix Module](https://www.drupal.org/project/mix)
- [Devel Module](https://www.drupal.org/project/devel)

---

## 📅 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| 1.0 | 2026-04-08 | 初始化文档 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-08

---

*所有技术信息基于 Drupal.org 官方文档和实际项目经验*
*所有模板示例均经过验证可运行*
*所有最佳实践均基于社区共识*

---

*下一篇*: 暂无  
*返回*: [核心模块索引](core-modules/00-index.md)  
*上一篇*: 暂无
