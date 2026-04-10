---
name: commerce-product-options
description: Complete guide to Commerce Product Options for managing product variants, attributes, and variations in Drupal Commerce.
---

# Commerce Product Options - 产品选项管理 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Product Options 是 Drupal Commerce 用于管理产品变体和属性的核心模块。它允许为商品定义多种属性（如颜色、尺码、容量），并基于这些属性组合自动生成不同的商品变体（SKU）和价格差异。

### 核心功能
- ✅ **多属性配置** - 支持文本、选择列表、下拉菜单等多种字段类型
- ✅ **产品价格差异** - 基于选项自动计算价格调整
- ✅ **SKU 自动生成** - 根据选项值组合生成唯一 SKU
- ✅ **库存按变体跟踪** - 每个变体独立管理库存
- ✅ **前端选项展示** - 直观的选项选择器
- ✅ **搜索过滤支持** - 支持按属性筛选商品
- ✅ **条件显示规则** - 某些选项仅在特定条件下可用
- ✅ **必填项验证** - 确保用户选择必需选项

### 适用场景
- 服装/鞋帽电商（尺码 + 颜色组合）
- 电子产品（颜色 + 存储容量）
- 家具定制（尺寸 + 材质 + 颜色）
- 食品行业（口味 + 规格）
- 需要产品定制化的所有电商场景
- 可变价格商品管理

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装产品选项模块
composer require drupal/product_options

# 启用相关模块
drush en product_options --yes

# 运行数据库更新
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块
drush dl product_options

# 2. 启用模块
drush en product_options --yes

# 3. 更新数据库
drush updatedb --yes
```

---

## ⚙️ 基础配置

### 1. 创建产品属性类型

在 Commerce 管理界面配置产品属性：

```
路径：/admin/store/settings/product/options
```

#### 添加新属性

| 配置项 | 示例值 | 说明 |
|--------|--------|------|
| Machine name | `attribute_color` | 机器名（小写字母和下划线） |
| Label | 颜色 | 显示名称 |
| Type | Select list / Text field | 字段类型 |
| Required | ✅ Yes | 是否必选 |
| Multiple values | ❌ No | 是否多选 |
| Weight | 0 | 排序权重 |

### 2. 为产品类型添加属性字段

```
/admin/structure/content-type/manage/shop_product/manage/fields
→ Add field → Attribute field
→ Select attribute: Color, Size, etc.
→ Widget type: Dropdown / Radio buttons
```

### 3. 配置属性选项

对于 "Select list" 类型的属性，需要添加具体的选项值：

```yaml
attribute_options:
  attribute_color:
    - value: red
      label: 'Red'
      price_adjustment: 0.00
    
    - value: blue
      label: 'Blue'
      price_adjustment: 0.00
    
    - value: black
      label: 'Black'
      price_adjustment: 2.00  # 黑色款式额外 $2
    
  attribute_size:
    - value: s
      label: 'Small'
      price_adjustment: 0.00
    
    - value: m
      label: 'Medium'
      price_adjustment: 0.00
    
    - value: l
      label: 'Large'
      price_adjustment: 3.00
    
    - value: xl
      label: 'Extra Large'
      price_adjustment: 5.00
```

### 4. 设置价格调整策略

```
路径：/admin/store/settings/product/options/pricing
```

| 策略类型 | 说明 | 计算公式 |
|---------|------|---------|
| **Additive** | 累加模式 | Base Price + Option1 + Option2 |
| **Percentage** | 百分比模式 | Base Price × (1 + %Adjustment) |
| **Fixed** | 固定价格 | 忽略选项，固定售价 |
| **Custom Hook** | 自定义钩子 | 通过代码动态计算 |

#### 示例：T-Shirt 定价策略

```yaml
product_type: basic_tshirt
base_price: 19.99
pricing_strategy: additive
options_pricing:
  color_black: 2.00
  size_l: 3.00
  size_xl: 5.00
```

**价格计算示例**:
- S 码红色 T-shirt: $19.99 + $0 = **$19.99**
- M 码蓝色 T-shirt: $19.99 + $0 = **$19.99**
- L 码黑色 T-shirt: $19.99 + $2 + $3 = **$24.99**
- XL 码黑色 T-shirt: $19.99 + $2 + $5 = **$26.99**

---

## 💻 代码示例

### 1. 获取商品所有属性

```php
use Drupal\commerce_product\Entity\ProductVariation;

/**
 * 获取商品变体的所有属性
 */
function get_product_attributes(ProductVariation $variation) {
  $attributes = [];
  
  foreach ($variation->getFieldData() as $field_name => $field_data) {
    if (!empty($field_data['target_type']) && 
        $field_data['target_type'] === 'taxonomy_term') {
      
      $term = \Drupal\taxonomy\Term::load($field_data['target_id']);
      $attributes[] = [
        'name' => $term->getName(),
        'tid' => $term->id(),
        'bundle' => $term->getBundle(),
      ];
    }
  }
  
  return $attributes;
}
```

### 2. 创建具有选项的商品变体

```php
use Drupal\commerce_product\Entity\ProductVariation;
use Drupal\Core\Field\FieldItemListInterface;

/**
 * 创建带有选项的商品变体
 */
function create_variation_with_options($product_type, array $options) {
  // 构建变体数据
  $variation_data = [
    'type' => $product_type,
    'status' => TRUE,
    'sku' => generate_sku_from_options($options),
  ];
  
  // 创建变体
  $variation = ProductVariation::create($variation_data);
  
  // 设置属性
  foreach ($options as $attribute => $value) {
    $variation->{$attribute}->setValue(['target_id' => $value]);
  }
  
  // 保存
  $variation->save();
  
  return $variation;
}

/**
 * 根据选项生成 SKU
 */
function generate_sku_from_options(array $options) {
  $sku_parts = [];
  
  foreach ($options as $attribute => $value) {
    // 将属性名转换为缩写
    $prefix = str_replace('attribute_', '', $attribute);
    $sku_parts[] = strtoupper(substr($prefix, 0, 3)) . '-' . strtoupper(substr($value, 0, 3));
  }
  
  // 格式：COL-RED-SZ-L-001
  return implode('-', $sku_parts);
}
```

### 3. 计算最终价格

```php
use Drupal\commerce_price\Price;

/**
 * 根据选项计算商品最终价格
 */
function calculate_variant_price(ProductVariation $variation) {
  $base_price = $variation->getBasePrice();
  $total_adjustment = 0;
  
  // 遍历所有属性
  foreach ($variation->getFieldDefinitions() as $field_name => $field_def) {
    $items = $variation->get($field_name);
    
    foreach ($items as $item) {
      if ($item->target_id) {
        // 获取该选项的价格调整
        $adjustment = get_option_price_adjustment($field_name, $item->target_id);
        $total_adjustment += $adjustment;
      }
    }
  }
  
  // 返回最终价格
  $final_price = clone $base_price;
  $final_price->setAmount($final_price->getAmount() + $total_adjustment);
  
  return $final_price;
}

/**
 * 获取单个选项的价格调整值
 */
function get_option_price_adjustment($attribute_name, $option_value) {
  $settings = \Drupal::config('product_options.settings')->get("{$attribute_name}.price_adjustment");
  return $settings[$option_value] ?? 0;
}
```

### 4. 前端选项渲染 (Twig 模板)

```twig
{# templates/product-variation.html.twig #}
<div class="product-variation-options">
  {# 遍历所有属性 #}
  {% for attribute_field_name, attribute_field in variation.attributes %}
    <div class="attribute-option attribute-{{ attribute_field_name }}">
      <label>{{ attribute_field.label }}</label>
      
      {# 检查是否是单选或多选 #}
      {% if attribute_field.multiple == false %}
        {# 单选 - 下拉菜单 #}
        <select name="attributes[{{ attribute_field_name }}]" required>
          <option value="">请选择 {{ attribute_field.label }}</option>
          
          {% for option in attribute_field.options %}
            <option value="{{ option.value }}"
                    data-price={{ option.price_adjustment }}
                    {% if attribute_field.default == option.value %}selected{% endif %}>
              {{ option.label }} (+${{ option.price_adjustment }})
            </option>
          {% endfor %}
        </select>
        
      {% else %}
        {# 多选 - 复选框 #}
        <div class="checkbox-group">
          {% for option in attribute_field.options %}
            <label>
              <input type="checkbox" 
                     name="attributes[{{ attribute_field_name }}][]" 
                     value="{{ option.value }}"
                     data-price={{ option.price_adjustment }}>
              {{ option.label }} (+${{ option.price_adjustment }})
            </label>
          {% endfor %}
        </div>
      {% endif %}
    </div>
  {% endfor %}
</div>
```

### 5. JavaScript 动态价格计算

```javascript
(function($) {
  Drupal.behaviors.productOptionPriceUpdate = {
    attach: function(context, settings) {
      
      $('form.product-add-to-cart-form', context).once('productOptionPriceUpdate').each(function() {
        var form = $(this);
        var basePrice = parseFloat(form.data('base-price'));
        var priceDisplay = $('.product-variation-price', form);
        
        // 监听所有选项变化
        form.on('change', '.attribute-option select, .attribute-option input[type="checkbox"]', function() {
          updateVariantPrice(form, basePrice, priceDisplay);
        });
        
        // 初始计算价格
        updateVariantPrice(form, basePrice, priceDisplay);
      });
      
      /**
       * 更新商品变体价格
       */
      function updateVariantPrice(form, basePrice, priceDisplay) {
        var totalAdjustment = 0;
        var selectedAttributes = {};
        
        // 收集所有选中的属性
        form.find('.attribute-option select').each(function() {
          var $select = $(this);
          var fieldName = $select.attr('name').replace('attributes[', '').replace(']', '');
          var adjustment = parseFloat($select.find(':selected').data('price')) || 0;
          
          selectedAttributes[fieldName] = $select.val();
          totalAdjustment += adjustment;
        });
        
        // 更新价格显示
        var finalPrice = basePrice + totalAdjustment;
        priceDisplay.text(formatCurrency(finalPrice));
        
        // 触发事件通知其他组件
        form.trigger('variantSelected', {
          attributes: selectedAttributes,
          price: finalPrice,
          adjustment: totalAdjustment
        });
      }
      
      /**
       * 格式化货币
       */
      function formatCurrency(amount) {
        return '$' + amount.toFixed(2);
      }
    }
  };
})(jQuery);
```

---

## 📋 数据表结构

### taxonomy_vocabulary (商品属性分类)

| 字段 | 类型 | 说明 |
|------|------|------|
| vid | VARCHAR(32) | 分类 ID |
| name | VARCHAR(255) | 分类名称（如：Color, Size） |
| description | TEXT | 分类描述 |
| weight | INT | 排序权重 |

### taxonomy_term_data (商品属性值)

| 字段 | 类型 | 说明 |
|------|------|------|
| tid | INT | 术语 ID |
| vid | VARCHAR(32) | 所属分类 |
| name | VARCHAR(255) | 术语名称（如：Red, Blue） |
| description | TEXT | 术语描述 |
| format | VARCHAR(32) | 格式类型 |
| weight | INT | 排序权重 |
| language | CHAR(32) | 语言代码 |

### commerce_product_variation (商品变体)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INT | 变体 ID |
| sku | VARCHAR(64) | SKU |
| status | BOOLEAN | 是否激活 |
| created | DATETIME | 创建时间 |
| changed | DATETIME | 最后修改时间 |
| uid | INT | 作者用户 ID |

**索引**:
- `idx_sku` ON sku (唯一)
- `idx_status` ON status WHERE status = 1

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\commerce_product\Kernel\ProductTest;
use Drupal\commerce_product\Entity\ProductVariation;

class ProductOptionsTest extends KernelTestBase {
  
  protected static $modules = ['commerce_product', 'commerce_price'];
  
  /**
   * Test: Create variation with multiple options
   */
  public function testCreateVariationWithOptions() {
    // 创建颜色属性
    $color_taxonomy = $this->createTaxonomyVocabulary('attribute_colors');
    
    // 添加颜色选项
    $red_term = $this->createTerm($color_taxonomy, 'Red');
    $blue_term = $this->createTerm($color_taxonomy, 'Blue');
    $black_term = $this->createTerm($color_taxonomy, 'Black');
    
    // 创建尺码属性
    $size_taxonomy = $this->createTaxonomyVocabulary('attribute_sizes');
    $s_term = $this->createTerm($size_taxonomy, 'S');
    $m_term = $this->createTerm($size_taxonomy, 'M');
    $l_term = $this->createTerm($size_taxonomy, 'L');
    
    // 创建带选项的变体
    $variation = ProductVariation::create([
      'type' => 'tshirt',
      'sku' => 'SHIRT-RED-L',
    ]);
    
    $variation->setAttribute('attribute_color', $black_term->id());
    $variation->setAttribute('attribute_size', $l_term->id());
    
    $variation->save();
    
    // 验证属性正确保存
    $this->assertEquals($black_term->id(), 
      $variation->getAttribute('attribute_color')->target_id);
    $this->assertEquals($l_term->id(), 
      $variation->getAttribute('attribute_size')->target_id);
  }
  
  /**
   * Test: Price calculation with options
   */
  public function testPriceCalculationWithOptions() {
    // 配置价格调整
    \Drupal::configFactory()
      ->getEditable('product_options.settings')
      ->set('attribute_color.black.price_adjustment', 2.00)
      ->set('attribute_size.l.price_adjustment', 3.00)
      ->save();
    
    $variation = ProductVariation::create([
      'type' => 'tshirt',
      'base_price' => new Price('19.99', 'USD'),
      'attribute_color' => $this->black_term,
      'attribute_size' => $this->l_term,
    ]);
    
    $variation->save();
    
    // 计算最终价格
    $final_price = calculate_variant_price($variation);
    
    // 预期：19.99 + 2.00 + 3.00 = 24.99
    $this->assertEquals('24.99', $final_price->toString());
    $this->assertEquals('USD', $final_price->currency->id);
  }
  
  /**
   * Test: SKU generation from options
   */
  public function testSKUGeneration() {
    $options = [
      'attribute_color' => $this->black_term->id(),
      'attribute_size' => $this->l_term->id(),
    ];
    
    $sku = generate_sku_from_options($options);
    
    // 期望格式：COL-BLA-SIZ-L
    $this->assertMatchesRegularExpression('/^COL-BLA-SIZ-L$/', $sku);
  }
}
```

### 集成测试

```gherkin
Feature: Product Options Pricing
  As a customer
  I want to see correct prices for different product variations
  
  Scenario: Selecting larger size shows higher price
    Given I am on the product page for Basic T-Shirt
    And the base price is $19.99
    And L size costs an additional $3.00
    When I select L size
    Then the displayed price should be $22.99
  
  Scenario: Combining color and size adjustments
    Given I am viewing the T-Shirt product
    And Black color adds $2.00
    And L size adds $3.00
    When I select both Black and L
    Then the price should show $24.99
  
  Scenario: Unavailable combination shows error
    Given there is no stock for XL Red variant
    When I select Red and XL
    Then the Add to Cart button should be disabled
    And I should see "Out of Stock" message
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 说明 | 优化方向 |
|------|------|---------|
| **平均选项数** | 每个商品的属性数量 | 控制在 3-5 个内 |
| **变体爆炸率** | 选项组合导致的 SKU 增长 | 限制最大变体数 |
| **选项选择分布** | 各选项的热门程度 | 优化热销款库存 |
| **无效组合率** | 无法购买的颜色/尺码组合 | 清理无效 SKU |

### 常用查询

```sql
-- 统计每个属性的选项数量和使用情况
SELECT 
  tv.name AS attribute_name,
  COUNT(tt.tid) AS option_count,
  COUNT(cv.id) AS usage_count
FROM taxonomy_vocabulary tv
JOIN taxonomy_term_data tt ON tv.vid = tt.vid
LEFT JOIN commerce_product_variation cv ON tt.tid = cv.attribute_target_id
GROUP BY tv.name, tv.vid
ORDER BY usage_count DESC;

-- 查询最热门的选项组合
SELECT 
  p.name AS product_name,
  GROUP_CONCAT(DISTINCT tt.name ORDER BY tt.weight SEPARATOR ', ') AS selected_options,
  COUNT(*) AS purchase_count
FROM commerce_order_item oi
JOIN commerce_product_variation pv ON oi.variant_id = pv.id
JOIN commerce_product p ON pv.product_id = p.id
JOIN commerce_product_attribute pav ON pv.id = pav.variation_id
JOIN taxonomy_term_data tt ON pav.term_id = tt.tid
JOIN commerce_order o ON oi.order_id = o.id
WHERE o.status = 'completed'
GROUP BY p.name, selected_options
ORDER BY purchase_count DESC
LIMIT 10;
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Drupal Commerce Products | https://docs.drupalcommerce.org/v2/developer-guide/products/ |
| Product Attributes Documentation | https://www.drupal.org/docs/core-modules/commerce-product |
| Variants Guide | https://docs.drupalcommerce.org/v2/user-guide/products/variants/ |

---

## 🆘 常见问题

### Q1: 如何限制产品的最大变体数量？

**答案**：
```php
function mymodule_commerce_product_variation_presave(EntityInterface $entity) {
  $variation = $entity;
  $product_type = $variation->getType();
  
  // 获取当前产品的变体数量
  $current_count = \Drupal::entityTypeManager()
    ->getStorage('commerce_product_variation')
    ->getQuery()
    ->condition('product_id', $variation->getProductId())
    ->condition('type', $product_type)
    ->count()
    ->execute();
  
  // 如果超过限制（例如 50 个变体）
  if ($current_count >= 50) {
    throw new \Exception('Maximum 50 product variations allowed per product.');
  }
}
```

### Q2: 如何处理禁用属性后保留历史订单？

**答案**：
```php
// 禁用属性但不删除关联
function disable_attribute_safely($attribute_name) {
  // 标记为不可用，但保留数据
  db_update('product_option_attribute')
    ->fields(['is_active' => FALSE])
    ->condition('machine_name', $attribute_name)
    ->execute();
}
```

### Q3: 如何实现属性条件的动态显示？

**答案**：
```javascript
// 当用户选择某个选项时，隐藏无关的其他选项
$('select.attribute-color').on('change', function() {
  var selectedColor = $(this).val();
  
  if (selectedColor === 'blue') {
    // 只有蓝色有 XL 码
    $('#size-xl').hide();
  } else {
    // 其他颜色都提供全尺码
    $('#size-xl').show();
  }
});
```

---

**大正，commerce-product-options.md 已补充完成。您还有其他指令吗？** 🚀
