---
name: drupal-theme-customizations
description: Drupal 11 custom theme developments. Covers Paragraphs, Layout Builder, Commerce theming, and advanced custom theming patterns.
---

# Drupal 主题定制和高级主题开发

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 高级主题开发概述

### 主题定制领域

| 领域 | 说明 | 复杂度 |
|------|------|--------|
| **Paragraphs** | 段落式内容布局 | ⭐⭐⭐⭐ |
| **Layout Builder** | 可视化页面布局 | ⭐⭐⭐⭐⭐ |
| **Commerce** | 电子商务站点 | ⭐⭐⭐⭐⭐ |
| **Custom Blocks** | 自定义区块 | ⭐⭐⭐ |
| **Component Library** | 组件库 | ⭐⭐⭐⭐⭐ |

---

## 🎨 Paragraphs 主题开发

### Paragraphs 模块概述

Paragraphs 是 Drupal 的内容构建模块，允许通过可重用的内容段落创建复杂页面布局。

### Paragraph 模板命名规则

#### 模板优先级列表
```
1. paragraph--[paragraph-type]--[view-mode].html.twig
2. paragraph--[paragraph-type].html.twig
3. paragraph--[view-mode].html.twig
4. paragraph.html.twig
```

### 1. 基本 Paragraph 模板

#### paragraph.html.twig (通用模板)
```twig
{#
 * @file
 * Default theme implementation for paragraphs.
 *
 * Variables:
 * - paragraph: The paragraph entity.
 * - content: The paragraph content.
 * - paragraph_attributes: HTML attributes.
 * - classes: CSS classes.
 *)
 #}

<div{{ paragraph_attributes.addClass('paragraph', 'paragraph--type--' ~ paragraph.paragraphTypeBundle.id) }}>
  
  {# 显示区域标题 #}
  {% if content.field_paragraph_title %}
  <h2 class="paragraph-title">
    {{ content.field_paragraph_title }}
  </h2>
  {% endif %}
  
  {# 显示内容 #}
  <div class="paragraph-content">
    {{ content }}
  </div>
  
</div>
```

#### paragraph--text-block.html.twig (文本块段落)
```twig
{#
 * @file
 * Theme implementation for text block paragraphs.
 *)
 #}

{# attach_library('mytheme/paragraph-text-block') #}

<section class="paragraph paragraph--type--text-block{{ paragraph_attributes.addClass('alignment-' ~ (content.field_paragraph_alignment.0.alignment.value ?? 'left')) }}">
  
  {% if content.field_title %}
  <h2 class="text-block__title">
    {{ content.field_title }}
  </h2>
  {% endif %}
  
  <div class="text-block__content">
    {{ content.field_body }}
  </div>
  
  {% if content.field_button %}
  <div class="text-block__actions">
    {{ content.field_button }}
  </div>
  {% endif %}
  
</section>
```

#### paragraph--text-block--default.html.twig (默认显示模式)
```twig
{#
 * @file
 * Text block paragraph with default view mode.
 *)
 #}

<section class="paragraph paragraph--type--text-block paragraph--view-mode--default">
</section>
```

### 2. 图片段落模板

#### paragraph--image.html.twig
```twig
{#
 * @file
 * Theme implementation for image paragraphs.
 *)
 #}

<div class="paragraph paragraph--type--image{{ paragraph_attributes.addClass('image-style-' ~ content.field_image.0.style ?? 'large') }}">
  
  <figure class="image-figure">
    {{ content.field_image }}
    
    {% if content.field_caption %}
    <figcaption class="image-caption">
      {{ content.field_caption }}
    </figcaption>
    {% endif %}
  </figure>
  
</div>
```

#### paragraph--image--centered.html.twig (居中对齐)
```twig
{#
 * @file
 * Image paragraph with centered alignment.
 *)
 #}

<div class="paragraph paragraph--type--image paragraph--alignment--centered">
  <figure class="image-figure">
    {{ content.field_image }}
    
    {% if content.field_caption %}
    <figcaption>
      {{ content.field_caption }}
    </figcaption>
    {% endif %}
  </figure>
</div>
```

### 3. 列表段落模板

#### paragraph--list.html.twig
```twig
{#
 * @file
 * Theme implementation for list paragraphs.
 *)
 #}

<section class="paragraph paragraph--type--list{{ paragraph_attributes }}">
  
  {% if field_list_title %}
  <h2>{{ field_list_title }}</h2>
  {% endif %}
  
  <ul class="paragraph-list">
    {% for item in field_list_items %}
    <li class="list-item">
      {{ item }}
    </li>
    {% endfor %}
  </ul>
  
</section>
```

### 4. 使用 Style Options 为 Paragraphs 添加样式选择

#### 配置 Style Options
```yaml
# 在 Paragraph 类型配置中启用 style_options
paragraphs_type_image:
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
        - default: shadow
          label: 'Shadow'
```

#### 样式化 Paragraph 模板
```twig
{#
 * @file
 * Image paragraph with dynamic styles.
 *)
 #}

{% set alignment = content.field_image.0.alignment.value ?? 'default' %}
{% set image_style = content.field_image.0.style.value ?? 'default' %}

<div class="paragraph paragraph--type--image paragraph--alignment--{{ alignment }} paragraph--style--{{ image_style }}">
  {{ content.field_image }}
</div>
```

### 5. 段落组件样式

#### 使用 Classy Paragraphs 模块
```bash
# 安装 Classy Paragraphs 模块
composer require drupal/classy_paragraphs

# 启用模块
drush pm:install classy_paragraphs
```

#### 配置 Classy Paragraphs
```yaml
# sites/default/default.services.yml 或 services.yml
parameters:
  classy_paragraphs.settings:
    add_classes: true
    class_mapping:
      'text_block': 'text-block'
      'image': 'image-component'
      'list': 'list-component'
```

### 6. 动态 Paragraph 主题钩子

#### .theme 文件中的预处理
```php
<?php

/**
 * @file
 * Paragraph theme preprocessing.
 */

/**
 * 实现 hook_preprocess_paragraph()
 */
function mytheme_preprocess_paragraph(&$variables) {
  $paragraph = $variables['paragraph'];
  
  // 添加自定义 CSS 类
  $variables['paragraph_attributes']->addClass('paragraph--type--' . $paragraph->bundle());
  
  // 根据段落类型添加特殊样式
  switch ($paragraph->bundle()) {
    case 'text_block':
      $variables['attributes']->addClass('text-block-component');
      break;
      
    case 'image':
      $variables['attributes']->addClass('image-component');
      break;
  }
  
  // 添加区域信息
  if (!empty($variables['region'])) {
    $variables['paragraph_attributes']->addClass('region-' . $variables['region']);
  }
}

/**
 * 实现 hook_paragraph_view_mode_links_alter()
 */
function mytheme_paragraph_view_mode_links_alter(&$links, $paragraph, $view_mode) {
  // 自定义段落视 modes
  if ($view_mode == 'teaser') {
    $links['view']['#label'] = 'View Teaser';
    $links['view']['#attributes']['class'][] = 'paragraph-link';
  }
}
```

---

## 🏗️ Layout Builder 主题开发

### Layout Builder 概述

Layout Builder 允许通过可视化界面创建自定义页面布局，支持拖放区块到不同区域。

### 自定义布局定义

#### layouts.yml 文件
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

### 自定义布局 PHP 类

#### 两列布局插件
```php
<?php

/**
 * @file
 * Custom two column layout.
 */

namespace Drupal\mytheme\Plugin\Layout;

use Drupal\Core\Field\FieldItemListInterface;
use Drupal\Core\Layout\LayoutPluginBase;

/**
 * Defines a custom two column layout.
 *
 * @Layout(
 *   id = "two_col_section",
 *   label = @Translation("Two column section"),
 *   description = @Translation("A two column layout section."),
 *   core_version_requirement = "^11"
 * )
 */
class TwoColumnLayout extends LayoutPluginBase {
  
  /**
   * {@inheritdoc}
   */
  public function build() {
    $build = [];
    
    // 第一个列
    $build['first'] = [
      '#tag' => 'div',
      '#attributes' => [
        'class' => [
          'layout__region',
          'layout__region--first',
          'col',
          'col-first',
        ],
      ],
    ];
    
    // 第二个列
    $build['second'] = [
      '#tag' => 'div',
      '#attributes' => [
        'class' => [
          'layout__region',
          'layout__region--second',
          'col',
          'col-second',
        ],
      ],
    ];
    
    return $build;
  }
  
  /**
   * {@inheritdoc}
   */
  public function buildRegions() {
    return [
      'first',
      'second',
    ];
  }
  
  /**
   * {@inheritdoc}
   */
  public function defaultRegions() {
    return [
      'first',
      'second',
    ];
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

#### 三列布局插件
```php
<?php

namespace Drupal\mytheme\Plugin\Layout;

use Drupal\Core\Layout\LayoutPluginBase;

/**
 * Defines a custom three column layout.
 */
class ThreeColumnLayout extends LayoutPluginBase {
  
  public function build() {
    $build = [];
    
    // 三个列
    foreach (['first', 'second', 'third'] as $i => $region) {
      $build[$region] = [
        '#tag' => 'div',
        '#attributes' => [
          'class' => [
            'layout__region',
            'layout__region--' . $region,
            'col',
            'col-' . ($i + 1),
          ],
        ],
      ];
    }
    
    return $build;
  }
  
  public function getRegionNames() {
    return [
      $this->t('First Column'),
      $this->t('Second Column'),
      $this->t('Third Column'),
    ];
  }
  
}
```

### Layout 模板

#### layout--twocol-section.twig
```twig
{#
 * @file
 * Theme implementation for two column layout.
 *)
 #}

<div class="layout layout--twocol-section{{ classes }}">
  
  <div class="layout__region layout__region--first">
    {{ content.first }}
  </div>
  
  <div class="layout__region layout__region--second">
    {{ content.second }}
  </div>
  
</div>
```

#### layout--threecol-section.twig
```twig
{#
 * @file
 * Theme implementation for three column layout.
 *)
 #}

<div class="layout layout--threecol-section{{ classes }}">
  
  <div class="layout__region layout__region--first">
    {{ content.first }}
  </div>
  
  <div class="layout__region layout__region--second">
    {{ content.second }}
  </div>
  
  <div class="layout__region layout__region--third">
    {{ content.third }}
  </div>
  
</div>
```

### Layout Builder 区块模板

#### block.html.twig (自定义区块)
```twig
{#
 * @file
 * Theme implementation for custom blocks in Layout Builder.
 *)
 #}

<div class="custom-block block block--{{ block_id }} block--{{ view_mode }}{{ classes }}">
  
  {% if block_label %}
  <h3 class="custom-block__title">
    {{ block_label }}
  </h3>
  {% endif %}
  
  <div class="custom-block__content">
    {{ content }}
  </div>
  
</div>
```

---

## 🛒 Commerce 主题开发

### 产品页面模板

#### commerce-product.html.twig
```twig
{#
 * @file
 * Theme implementation for Commerce product pages.
 *)
 #}

<div class="commerce-product{{ _attributes.addClass('product-' ~ bundle)|html_attr}}">
  
  <div class="product--image">
    {{ content.field_product_image }}
  </div>
  
  <div class="product--info">
    <h1 class="product--title"{{ title_attributes }}>{{ label }}</h1>
    
    {% if price %}
    <div class="product--price">
      {{ price }}
    </div>
    {% endif %}
    
    {% if sku %}
    <div class="product--sku">
      <strong>{{ 'SKU:'|t }}</strong> {{ sku }}
    </div>
    {% endif %}
    
    <div class="product--description">
      {{ content.field_description }}
    </div>
    
    {% if add_to_cart %}
    <div class="product--actions">
      {{ add_to_cart }}
    </div>
    {% endif %}
    
    {# 其他字段 #}
    {{ content|without('field_product_image', 'price', 'sku', 'field_description', 'add_to_cart') }}
  </div>
  
</div>
```

### 产品列表模板

#### commerce-products-list.html.twig
```twig
{#
 * @file
 * Theme implementation for Commerce product list.
 *)
 #}

<div class="commerce-products-list">
  
  {% for product in products %}
  <article class="commerce-product product--item{{ _classes }}">
    
    <div class="product--image">
      {{ product.field_product_image }}
    </div>
    
    <div class="product--info">
      <h3 class="product--title">
        <a href="{{ product.url }}">{{ product.label }}</a>
      </h3>
      
      {% if product.price %}
      <div class="product--price">
        {{ product.price }}
      </div>
      {% endif %}
      
      <div class="product--actions">
        {{ product.add_to_cart }}
      </div>
    </div>
    
  </article>
  {% endfor %}
  
</div>
```

### 购物车模板

#### commerce-cart.html.twig
```twig
{#
 * @file
 * Theme implementation for Drupal Commerce cart page.
 *)
 #}

<div class="commerce-cart{{ _attributes.addClass('cart-page') }}">
  
  <h1>{{ 'Shopping Cart'|t }}</h1>
  
  {{ content }}
  
  <div class="cart-actions">
    {% if cart_total %}
    <div class="cart-subtotal">
      <strong>{{ 'Subtotal:'|t }}</strong> {{ cart_total }}
    </div>
    {% endif %}
    
    {% if promo_code %}
    <form class="cart-promo-form" method="post" action="{{ path('commerce_cart.add_discount') }}">
      <input type="text" name="code" placeholder="{{ 'Promo code'|t }}">
      <button type="submit">{{ 'Apply'|t }}</button>
    </form>
    {% endif %}
  </div>
  
</div>
```

### 结账页面模板

#### commerce-checkout-step.html.twig
```twig
{#
 * @file
 * Theme implementation for checkout steps.
 *)
 #}

<div class="commerce-checkout-step{{ attributes.addClass('step--' ~ step)|html_attr}}">
  
  <h2>{{ step_label }}</h2>
  
  <div class="step-content">
    {{ content }}
  </div>
  
</div>
```

#### 结账步骤模板
```twig
{#
 * @file
 * Commerce checkout payment step.
 *)
 #}

<div class="commerce-checkout-payment">
  <h2>{{ 'Payment'|t }}</h2>
  
  <div class="payment-methods">
    {{ content.payment_method }}
  </div>
  
  {% if payment_details %}
  <div class="payment-details">
    {{ payment_details }}
  </div>
  {% endif %}
  
</div>
```

### 订单模板

#### commerce-order.html.twig
```twig
{#
 * @file
 * Theme implementation for Commerce order pages.
 *)
 #}

<div class="commerce-order{{ attributes }}">
  
  <h1>{{ order_number }}</h1>
  
  <dl class="order-info">
    <dt>{{ 'Status:'|t }}</dt>
    <dd>{{ order_state }}</dd>
    
    <dt>{{ 'Total:'|t }}</dt>
    <dd>{{ order_total }}</dd>
    
    <dt>{{ 'Date:'|t }}</dt>
    <dd>{{ order_date }}</dd>
  </dl>
  
  <div class="order-items">
    {{ order_items }}
  </div>
  
  <div class="order-shipping">
    {{ shipping_address }}
  </div>
  
  <div class="order-billing">
    {{ billing_address }}
  </div>
  
</div>
```

---

## 🎨 主题定制技巧

### 1. 使用 CSS 变量

```scss
// _variables.scss
$primary-color: #007bff;
$secondary-color: #6c757d;
$success-color: #28a745;
$danger-color: #dc3545;

$font-family-base: 'Helvetica Neue', Helvetica, Arial, sans-serif;
$font-size-base: 1rem;
$line-height-base: 1.5;

$breakpoints: (
  xs: 0,
  sm: 576px,
  md: 768px,
  lg: 992px,
  xl: 1200px,
  xxl: 1400px
);
```

### 2. 使用 CSS Grid

```scss
// 响应式网格布局
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 2rem;
  
  @media (min-width: 768px) {
    grid-template-columns: repeat(3, 1fr);
  }
  
  @media (min-width: 1200px) {
    grid-template-columns: repeat(4, 1fr);
  }
}
```

### 3. 使用 CSS 自定义属性

```css
:root {
  --theme-spacing-unit: 0.25rem;
  --theme-font-size-scale: 1.2;
  --theme-color-primary: #007bff;
  --theme-color-secondary: #6c757d;
}

.component {
  padding: calc(var(--theme-spacing-unit) * 4);
  font-size: calc(1rem * var(--theme-font-size-scale));
  color: var(--theme-color-primary);
}
```

### 4. 自定义字段样式

```twig
{#
 * @file
 * Custom field styling.
 *)
 #}

{% set field_classes = 'custom-field custom-field__' ~ component.field_name %}

<div class="{{ field_classes }}"{{ field_attributes }}>
  {{ content }}
</div>
```

### 5. 主题设置

#### theme-settings.php
```php
<?php

/**
 * @file
 * Custom theme settings.
 */

/**
 * 实现 hook_formsystem_thmesettings_form_alter()
 */
function mytheme_form_system_themesettings_form_alter(&$form, \Drupal\Core\Form\FormStateInterface $form_state) {
  // 添加自定义设置
  $form['mytheme']['#tree'] = TRUE;
  $form['mytheme']['enable_custom_footer'] = [
    '#type' => 'checkbox',
    '#title' => t('Enable custom footer'),
    '#default_value' => $this->config('mytheme.settings')->get('enable_custom_footer', TRUE),
  ];
  
  $form['mytheme']['footer_text'] = [
    '#type' => 'textfield',
    '#title' => t('Footer text'),
    '#default_value' => $this->config('mytheme.settings')->get('footer_text', ''),
    '#size' => 60,
  ];
}

/**
 * 获取主题设置
 */
function mytheme_get_setting($setting_name, $default = NULL) {
  return \Drupal::config('mytheme.settings')->get($setting_name, $default);
}
```

#### settings.php
```yaml
# /themes/custom/mytheme/mytheme.settings.yml
enable_custom_footer: true
footer_text: '© 2026 Your Company. All rights reserved.'
custom_css_file: css/custom.css
```

---

## 📊 主题开发最佳实践

### 1. 性能优化

```yaml
# libraries.yml
optimized-style:
  version: 1.0.0
  css:
    theme:
      css/style.optimized.css: { preprocess: true, minify: true, weight: -10 }

# 启用 CSS/JS 聚合
$settings['css.preprocess'] = TRUE;
$settings['js.preprocess'] = TRUE;
```

### 2. 无障碍访问

```twig
{#
 * @file
 * Accessible theme structure.
 *)
 #}

<main class="main-content" role="main" id="main-content">
  {{ page.content }}
</main>

<nav class="navigation" role="navigation" aria-label="{{ 'Main navigation'|t }}">
  {{ page.primary_menu }}
</nav>

<address class="site-footer" role="contentinfo">
  {{ page.footer }}
</address>

{# 跳过链接 - 无障碍访问 #}
<a href="#main-content" class="visually-hidden focusable">
  {{ 'Skip to main content'|t }}
</a>
```

### 3. 响应式设计

```scss
// styles.scss
@import 'variables';

.responsive-container {
  width: 100%;
  padding: 1rem;
  
  @each $breakpoint, $width in $breakpoints {
    $min-width: map-get($breakpoints, $breakpoint);
    
    @if $min-width > 0 {
      @media (min-width: $min-width) {
        padding: calc(1rem * (1 + map-get($breakpoints, $breakpoint) / 1440 * 2));
      }
    }
  }
}
```

### 4. 主题开发调试

```yaml
# services.yml
twig.config:
  debug: true
  auto_reload: true
  cache: false

devel.settings:
  variable_get_cache: false
  node_access_check: false
```

---

## 📚 参考资源

### 官方文档
- [Layout Builder](https://www.drupal.org/docs/8/core/modules/layout-builder)
- [Paragraphs](https://www.drupal.org/docs/contributed-modules/paragraphs)
- [Commerce Theming](https://drupalcommerce.org/extensions/theme)

### 社区资源
- [Drupal.org Theming Forum](https://www.drupal.org/forum/section/6)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/drupal-theming)

---

## 📅 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| 1.0 | 2026-04-08 | 初始化文档 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-08

*此文档涵盖高级主题开发内容，包括 Paragraphs、Layout Builder、Commerce 等复杂场景*
