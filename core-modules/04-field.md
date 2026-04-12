---
name: drupal-field-api
description: Complete guide to Drupal Field API. Covers field types, widgets, formatters, display settings, and field management for Drupal 11.
---

# Drupal Field API 完整指南

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-05  

---

## 📖 模块概述

### 简介
**Field API** 是 Drupal 的核心数据模型系统，提供统一的方法创建和管理自定义数据字段。它是构建高级内容类型的基础。

### 核心功能
- ✅ 字段类型管理 (Field Types)
- ✅ 字段小件配置 (Widgets)
- ✅ 字段格式化器 (Formatters)
- ✅ 显示设置管理 (Display Settings)
- ✅ 内容字段布局 (Content Layout)
- ✅ 字段验证与约束 (Validation)

### 适用范围
- ✅ 所有需要自定义内容的 Drupal 站点
- ✅ 电商产品
- ✅ 多媒体内容
- ✅ 表单数据
- ✅ 高级查询

---

## 🚀 安装与启用

### 默认状态
- ✅ **已内建**: Field API 是 Drupal 11 核心模块之一
- ⚡ **自动启用**: 新站点创建时自动启用

### 检查状态
```bash
# 查看 Field 模块状态
drush pm-info field

# 查看已安装的字段
drush field:info

# UI 查看
# /admin/structure/types
```

---

## ⚙️ 核心配置

### 1. 字段类型系统

#### 核心字段类型

| 类型 | 说明 | 使用场景 |
|------|------|----------|
| **String** | 短文本/字符串 | 标题、名称、标签 |
| **Text** | 长文本 | 内容、描述 |
| **Text with summary** | 带摘要的文本 | 内容 + 短摘要 |
| **Integer** | 整数 | 数量、年龄 |
| **Decimal** | 小数 | 价格、评分 |
| **Float** | 浮点数 | 重量、距离 |
| **Boolean** | 是/否 | 状态、标志 |
| **List (text)** | 文本列表 | 下拉选项 |
| **List (integer)** | 整数列表 | 状态代码 |
| **Email** | 邮箱 | 联系信息 |
| **Telephone** | 电话 | 联系方式 |
| **Link** | 链接 | URL 地址 |
| **Image** | 图片 | 头像、封面 |
| **File** | 文件 | 附件、文档 |
| **Date** | 日期/时间 | 事件、时间戳 |
| **Entity Reference** | 实体引用 | 关联内容 |
| **Comments** | 评论 | 评论内容 |
| **Term Reference** | 术语引用 | 分类、标签 |
| **Number** | 数字 | 价格、数量 |

#### 字段类型配置

```yaml
# 字段类型配置示例
field_config:
  - type: string
    label: 产品代码
    required: true
    settings:
      case_sensitive: false
  - type: decimal
    label: 产品价格
    required: true
    settings:
      scale: 2
      precision: 10
      min: 0
      max: 999999.99
  - type: boolean
    label: 是否启用
    required: false
    settings:
      true_label: 启用
      false_label: 禁用
```

### 2. 字段小件 (Widgets)

#### 字段小件说明
字段小件是用户输入字段值的方式。

#### 常用小件类型

| 小件 | 使用字段类型 | 说明 |
|------|--------------|------|
| **TextField** | string | 单行文本框 |
| **Textarea** | text | 多行文本框 |
| **Textarea (summary)** | text with summary | 内容和摘要 |
| **Number** | number | 数字输入框 |
| **Radios** | list | 单选按钮 |
| **Checkboxes** | list multi | 复选框 |
| **Select** | list | 下拉选择 |
| **Date popup** | date | 日期选择器 |
| **Date calendar** | date | 日历日期选择 |
| **File upload** | file | 文件上传 |
| **Image** | image | 图片上传 |
| **Entity reference autocomplete** | entity reference | 自动完成选择 |
| **Comment widget** | comments | 评论输入 |

#### Widget 配置示例

```yaml
# Widget 配置示例
widget:
  - type: text_input
    settings:
      placeholder: "请输入产品名称"
  - type: text_textarea
    settings:
      rows: 5
      placeholder: "请输入产品描述"
  - type: number
    settings:
      min: 0
      max: 999999
  - type: radio_buttons
    settings:
      # 选项在字段类型中定义
```

### 3. 字段格式化器 (Formatters)

#### 格式化器说明
格式化器控制字段值如何显示在页面上。

#### 常用格式化器

| 格式化器 | 使用字段类型 | 说明 |
|----------|--------------|------|
| **Plain text** | text/string | 纯文本显示 |
| **Text** | text | 格式化文本 |
| **Label** | string | 显示标签 |
| **2 number currency** | number | 货币格式 |
| **Number** | number | 数字格式 |
| **Boolean** | boolean | 是/否显示 |
| **Link** | link | 可点击链接 |
| **Image** | image | 图片显示 |
| **File** | file | 文件下载链接 |
| **Date** | date | 日期格式化 |
| **Entity reference** | entity reference | 内容链接 |
| **Term reference** | term reference | 分类列表 |

#### Formatter 配置示例

```yaml
# Formatter 配置示例
formatter:
  label: above  # 标签位置：above, hidden, inline, above
  settings:
    - type: plain_text
      settings:
        maxlength: 100  # 文本限制字符数
    - type: number_fixed
      settings:
        decimal: 2  # 小数位数
        thousand_separator: ","
        decimal_separator: "."
    - type: image
      settings:
        alt: true  # 显示图片 alt 文本
        title: true  # 显示图片 title
        link: true  # 图片可点击
        width: 200  # 图片宽度
        height: 200  # 图片高度
        style: thumbnail  # 显示样式
```

### 4. 显示管理

#### 默认显示设置

```bash
# 编辑内容类型显示设置
# /admin/structure/types/manage/[type]/display

# 显示模式:
# • Default - 默认显示
# • Teaser - 摘要显示 (列表中的简短显示)
# • RSS - RSS 输出
```

#### 显示字段顺序

```yaml
# 显示顺序配置
display_order:
  title: 1  # 标题优先级
  body: 2   # 内容优先级
  field_product_image: 3  # 产品图片
  field_product_price: 4  # 产品价格
  field_product_code: 5   # 产品代码
```

#### 摘要显示设置

```bash
# 摘要长度
drush field:configure node product field_body --display=teaser --settings=json:{"max_length":200}
```

### 5. 字段验证与约束

#### 字段验证规则

```yaml
# 字段验证规则
validation:
  string:
    field_name: 产品名称
    required: true
    min_length: 3
    max_length: 100
    pattern: "^[A-Za-z0-9\s\-_]+$"
  number:
    field_name: 产品价格
    required: true
    min: 0
    max: 999999.99
    step: 0.01
  date:
    field_name: 发布日期
    required: true
    min_date: '1900-01-01'
    max_date: '+1 year'
```

#### 自定义验证器

```php
/**
 * 自定义字段验证器
 */
function mymodule_field_validate($element, &$form_state, $entity_type) {
  $field_name = 'field_product_price';
  
  if (isset($element[$field_name]) && $entity_type === 'node') {
    $value = $element[$field_name]['#value'];
    
    // 验证价格为正数
    if ($value <= 0) {
      form_set_error(
        $field_name,
        t('Price must be greater than zero.')
      );
    }
    
    // 验证价格不超过 999999
    if ($value > 999999) {
      form_set_error(
        $field_name,
        t('Price cannot exceed 999,999.')
      );
    }
  }
}

/**
 * 实现 hooks
 */
function mymodule_field_validate_alter(&$element, FormStateInterface $form_state, FieldItemListInterface $list) {
  // 添加自定义验证逻辑
}
```

---

## 💻 开发示例

### 1. 字段 API 基础

#### 获取字段
```php
/**
 * 获取节点的所有字段
 */
function get_node_fields($node_type) {
  $fields = \Drupal::entityTypeManager()->getStorage('field_config')
    ->loadByProperties([
      'entity_type' => 'node',
      'bundle' => $node_type,
    ]);
  
  $field_names = [];
  foreach ($fields as $field) {
    $field_names[] = $field->getFieldDefinition()->getName();
  }
  
  return $field_names;
}

/**
 * 检查字段是否已存在
 */
function field_exists($field_name) {
  try {
    \Drupal::entityTypeManager()->getStorage('field_config')
      ->load('node.field_' . $field_name);
    return TRUE;
  } catch (\Exception $e) {
    return FALSE;
  }
}
```

#### 添加字段到节点类型
```php
/**
 * 向节点类型添加字段
 */
function add_field_to_node($node_type, $field_name, $field_type, $label) {
  if (field_exists($field_name)) {
    return FALSE;  // 字段已存在
  }
  
  $field_definition = [
    'field_name' => 'field_' . $field_name,
    'field_type' => $field_type,
    'entity_type' => 'node',
    'bundle' => $node_type,
    'label' => $label,
    'required' => FALSE,
    'settings' => [],
    'translatable' => TRUE,
    'default_value' => [],
    'default_value_callback' => '',
    'item_count' => NULL,
  ];
  
  $field = \Drupal::entityTypeManager()->getStorage('field_config')->create($field_definition);
  $field->save();
  
  return TRUE;
}

// 使用示例
add_field_to_node('product', 'sku', 'string', 'SKU');
add_field_to_node('product', 'weight', 'float', 'Weight (kg)');
add_field_to_node('product', 'price', 'decimal', 'Price');
```

### 2. 字段数据操作

#### 设置字段值
```php
/**
 * 为节点设置字段值
 */
function set_node_field($node_id, $field_name, $value) {
  $node = \Drupal\node\Entity\Node::load($node_id);
  
  if (!$node) {
    throw new \Exception("Node {$node_id} not found");
  }
  
  if (!$node->hasField($field_name)) {
    throw new \Exception("Node type does not have field {$field_name}");
  }
  
  // 处理不同类型的字段值
  if (is_array($value)) {
    // 实体引用或文件字段
    $node->set($field_name, $value);
  } else if (is_null($value)) {
    // 清空字段
    $node->set($field_name, $value);
  } else {
    // 简单字段 (文本、数字等)
    $node->set($field_name, $value);
  }
  
  $node->save();
  
  return TRUE;
}

// 使用示例
set_node_field(123, 'field_sku', 'SKU-12345');
set_node_field(123, 'field_price', 99.99);
set_node_field(123, 'field_image', ['target_id' => 456]);
```

#### 获取字段值
```php
/**
 * 获取节点的字段值
 */
function get_node_field($node_id, $field_name, $index = 0) {
  $node = \Drupal\node\Entity\Node::load($node_id);
  
  if (!$node) {
    return NULL;
  }
  
  if (!$node->hasField($field_name)) {
    return NULL;
  }
  
  $field_items = $node->get($field_name);
  
  if (empty($field_items)) {
    return NULL;
  }
  
  // 获取单个值
  if ($index == 0) {
    $item = $field_items[$index];
    return $item->value;
  }
  
  // 获取所有值
  $values = [];
  foreach ($field_items as $field_item) {
    $values[] = $field_item->value;
  }
  
  return $values;
}

// 使用示例
$sku = get_node_field(123, 'field_sku');
$price = get_node_field(123, 'field_price');
$all_prices = get_node_field(123, 'field_price', FALSE);  // 获取所有值
```

### 3. 批量字段操作

#### 批量添加字段
```php
/**
 * 批量为节点类型添加字段
 */
function bulk_add_fields($node_type, $fields) {
  $added = [];
  
  foreach ($fields as $field) {
    try {
      add_field_to_node(
        $node_type,
        $field['name'],
        $field['type'],
        $field['label']
      );
      $added[] = $field['name'];
    } catch (\Exception $e) {
      // 字段已存在或错误
      \Drupal::logger('mymodule')->warning('Failed to add field @field: @message', [
        '@field' => $field['name'],
        '@message' => $e->getMessage(),
      ]);
    }
  }
  
  return $added;
}

// 使用示例
$fields = [
  ['name' => 'sku', 'type' => 'string', 'label' => 'SKU'],
  ['name' => 'weight', 'type' => 'float', 'label' => 'Weight'],
  ['name' => 'price', 'type' => 'decimal', 'label' => 'Price'],
  ['name' => 'category', 'type' => 'entity_reference', 'label' => 'Category'],
];

bulk_add_fields('product', $fields);
```

#### 批量更新字段值
```php
/**
 * 批量更新节点字段值
 */
function bulk_update_node_fields($nids, $field_name, $value) {
  $updated = 0;
  
  // 加载多个节点
  $nodes = \Drupal\node\Entity\Node::loadMultiple($nids);
  
  foreach ($nodes as $node) {
    try {
      if ($node->hasField($field_name)) {
        // 处理多值字段
        if ($node->field_name->isMultiValued()) {
          $node->set($field_name, [$value, $value]);
        } else {
          $node->set($field_name, $value);
        }
        
        $node->save();
        $updated++;
      }
    } catch (\Exception $e) {
      \Drupal::logger('mymodule')->error('Failed to update node @nid: @message', [
        '@nid' => $node->id(),
        '@message' => $e->getMessage(),
      ]);
    }
  }
  
  return $updated;
}
```

### 4. 字段查询

#### Views 查询
```php
/**
 * 查询包含特定字段值的节点
 */
function query_nodes_by_field_value($field_name, $field_value) {
  $query = \Drupal::entityQuery('node')
    ->condition($field_name, $field_value)
    ->accessCheck(TRUE);
  
  if (function_exists('langcode')) {
    $query->condition('langcode', \Drupal::languageManager()->getCurrentLanguage()->getId());
  }
  
  $nids = $query->execute();
  
  return $nids ? \Drupal\node\Entity\Node::loadMultiple($nids) : [];
}

// 使用示例
$products = query_nodes_by_field_value('field_category', 'electronics');
```

#### 高级查询
```php
/**
 * 范围查询
 */
function query_nodes_by_field_range($field_name, $min_value, $max_value) {
  $query = \Drupal::entityQuery('node')
    ->condition($field_name, $min_value, '>')
    ->condition($field_name, $max_value, '<')
    ->accessCheck(TRUE);
  
  $nids = $query->execute();
  
  return $nids ? \Drupal\node\Entity\Node::loadMultiple($nids) : [];
}

/**
 * 排序查询
 */
function query_nodes_sorted_by_field($field_name, $sort_order = 'ASC') {
  $query = \Drupal::entityQuery('node')
    ->accessCheck(TRUE);
  
  $nids = $query
    ->sort($field_name, $sort_order)
    ->execute();
  
  return $nids ? \Drupal\node\Entity\Node::loadMultiple($nids) : [];
}
```

### 5. 字段迁移

#### 迁移字段数据
```php
/**
 * 从外部源迁移字段数据
 */
function migrate_field_data($external_data, $node_type) {
  foreach ($external_data as $data) {
    try {
      // 创建节点
      $node = \Drupal\node\Entity\Node::create([
        'type' => $node_type,
        'title' => $data['title'],
        'status' => TRUE,
      ]);
      
      // 设置字段
      if (isset($data['field_sku'])) {
        $node->set('field_sku', $data['field_sku']);
      }
      if (isset($data['field_price'])) {
        $node->set('field_price', $data['field_price']);
      }
      
      // 保存节点
      $node->save();
      
    } catch (\Exception $e) {
      \Drupal::logger('mymodule')->error('Migration failed for @title: @message', [
        '@title' => $data['title'],
        '@message' => $e->getMessage(),
      ]);
    }
  }
}
```

---

## 🎯 最佳实践

### 1. 字段命名规范

#### 命名规则
- ✅ 使用小写字母和下划线
- ✅ 字段名添加 `field_` 前缀
- ✅ 语义化命名，如 `field_product_sku`
- ❌ 避免使用大写字母
- ❌ 避免使用特殊字符

#### 命名示例
```yaml
# ✅ 好的命名
field_name: 产品代码
field_sku: Product Code
field_weight: Product Weight
field_product_image: Product Image

# ❌ 避免的命名
FieldName: 产品名称
FIELDNAME: 产品编号
field_name@special: 特殊字段
```

### 2. 字段类型选择

#### 选择原则
- ✅ 使用合适的字段类型
- ✅ 考虑未来的扩展需求
- ✅ 不要过度设计
- ✅ 保持简单

#### 类型选择示例
```yaml
# 产品数据字段类型选择
product_data:
  name: string              # 产品名称
  sku: string               # SKU 代码
  weight: float             # 重量 (kg)
  price: decimal            # 价格
  categories: term_reference  # 分类引用
  images: image             # 产品图片
  description: text         # 产品描述
  specifications: json      # 规格 (复杂数据)
```

### 3. 性能优化

#### 缓存优化
```php
/**
 * 字段值缓存
 */
function get_field_value_cached($node_id, $field_name) {
  $cache_key = "field_value:{$node_id}:{$field_name}";
  
  $cache = \Drupal::cache('default');
  $cached = $cache->get($cache_key);
  
  if ($cached) {
    return $cached->data;
  }
  
  // 从数据库获取
  $node = \Drupal\node\Entity\Node::load($node_id);
  $value = $node && $node->hasField($field_name) 
    ? $node->get($field_name)->getValue() 
    : NULL;
  
  // 缓存结果
  $cache->set($cache_key, $value, CacheBackendInterface::CACHE_PERMANENT, ['node:' . $node_id]);
  
  return $value;
}
```

#### 查询优化
```php
/**
 * 优化字段查询
 */
function optimized_field_query($field_name, $field_value) {
  // 使用 entityQuery 而不是 loadMultiple
  $query = \Drupal::entityQuery('node')
    ->condition($field_name, $field_value)
    ->accessCheck(TRUE);
  
  // 直接获取 ID，避免加载完整节点
  $nids = $query->execute();
  
  // 批量加载节点
  $nodes = \Drupal\node\Entity\Node::loadMultiple($nids);
  
  return $nodes;
}
```

### 4. 安全实践

#### 数据验证
```php
/**
 * 安全的字段输入
 */
function validate_field_input($field_name, $value) {
  switch ($field_price) {
    case 'field_price':
      // 验证价格为正数
      if (!is_numeric($value) || $value <= 0) {
        return FALSE;
      }
      break;
    case 'field_sku':
      // 只允许字母、数字、连字符
      if (!preg_match('/^[A-Za-z0-9\-_]+$', $value)) {
        return FALSE;
      }
      break;
    case 'field_description':
      // 限制文本长度
      if (!is_string($value) || strlen($value) > 10000) {
        return FALSE;
      }
      break;
  }
  
  return TRUE;
}
```

---

## 📊 常见问题 (FAQ)

### Q1: 如何删除字段？
**A**:
```bash
# UI 删除：
# /admin/structure/types/manage/[type]/fields

# 使用 drush:
drush field:node:delete product field_sku

# 使用编程方式:
$field = \Drupal::entityTypeManager()->getStorage('field_config')
  ->load('node.field_sku');
$field->delete();
```

### Q2: 如何迁移字段？
**A**:
```bash
# 使用 Migrate 模块
# /admin/config/services/migrate
```

### Q3: 如何更改字段类型？
**A**:
```bash
# 1. 删除所有字段数据
# 2. 修改字段类型
# 3. 重新导入数据
```

### Q4: 如何批量修改字段值？
**A**:
- 使用 Views Bulk Operations (VBO)
- 或使用上面提供的批量更新函数

### Q5: 如何处理多值字段？
**A**:
```php
// 获取所有值
$field_items = $node->get('field_name');
foreach ($field_items as $item) {
  $value = $item->value;
}

// 添加新值
$node->get('field_name')->addValue(['value' => 'new value']);
$node->save();
```

---

## 🔗 相关链接

- [Drupal Field API 官方文档](https://www.drupal.org/docs/8/api/field-api)
- [Field API 开发者指南](https://www.drupal.org/docs/8/api/field-api/field-api-developers-guide)
- [Drupal 实体 API](https://www.drupal.org/docs/8/api/entity-api)
- [字段类型参考](https://www.drupal.org/docs/8/api/field-api/field-types)

---

## 📝 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| 1.0 | 2026-04-05 | 初始化文档 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-05

---

*下一篇*: [Views 查询系统](core-modules/04-views.md)  
*返回*: [核心模块索引](core-modules/00-index.md)  
*上一篇*: [User 用户系统](core-modules/03-user.md)
