---
name: drupal-views
description: Complete guide to Drupal Views module. Covers views creation, displays, filters, sorting, and advanced features for Drupal 11.
---

# Drupal Views 查询系统完整指南

**版本**: v1.0
**Drupal 版本**: 11.x
**状态**: 活跃维护
**更新时间**: 2026-04-05

---

## 📖 模块概述

### 简介
**Views** 是 Drupal 中最强大、最灵活的查询和显示模块。它允许用户创建自定义查询和复杂的页面展示，无需编写代码。

### 核心功能
- ✅ 自定义查询创建
- ✅ 多种显示方式 (表格、列表、网格、图表)
- ✅ 高级过滤器和条件
- ✅ 排序和分页
- ✅ 嵌入页面和区域
- ✅ 缓存和性能优化

### 适用范围
- ✅ 内容型网站必备
- ✅ 产品列表
- ✅ 新闻展示
- ✅ 数据报表
- ✅ 复杂查询结果

---

## 🚀 安装与启用

### 默认状态
- ✅ **已内建**: Views 是 Drupal 11 核心模块
- ⚡ **自动启用**: 新站点创建时自动启用

### 检查状态
```bash
# 查看 Views 模块状态
drush pm-info views

# 查看已创建的视图列表
drush view:list

# UI 查看
# /admin/structure/views
```

---

## ⚙️ 核心配置

### 1. Views 基础结构

#### 视图类型
| 类型 | 说明 | 使用场景 |
|------|------|----------|
| **Page** (页面) | 完整页面视图 | 内容列表页 |
| **Block** (区块) | 页面区块 | 侧边栏、顶部栏 |
| **Attachment** (附件) | 附加视图 | 分页、更多链接 |

#### 视图显示格式
| 格式 | 说明 | 使用场景 |
|------|------|----------|
| **HTML 列表** | 无序/有序列表 | 简单列表 |
| **表格** | 表格展示 | 数据报表 |
| **网格** | 网格布局 | 产品列表 |
| **全文** | 完整内容 | 文章列表 |
| **摘要** | 简短摘要 | 新闻列表 |
| **未格式化** | 原样显示 | 自定义输出 |

#### 视图结构
```
Views 视图结构:
├─ Query (查询)
│   ├─ Base table (基础表)
│   ├─ Relationships (关联表)
│   └─ Filters (过滤器)
├─ Fields (字段)
│   ├─ Display fields (显示字段)
│   └─ Sort by (排序字段)
├─ Format (格式化)
│   ├─ Display format (显示格式)
│   └─ Fields (字段选择)
├─ Filter criteria (过滤条件)
└─ Header/Footer (页头/页尾)
```

### 2. 创建简单视图

#### 创建页面视图
```bash
# 通过 UI 创建
# /admin/structure/views/add

# 填写视图信息:
# - Name: product list
# - View type: Node (内容)
# - Edit mode: Page
# - Title: Product List
# - Page path: /products

# 配置字段:
# - Title (产品标题)
# - Images (产品图片)
# - Price (价格)
# - SKU (产品代码)

# 配置排序:
# - Created date (创建日期) DESC

# 配置分页:
# - Show: 12 items (每项)

# 保存视图
```

#### 使用 drush 创建视图
```bash
# 使用 Drush 命令创建视图
drush view:create product_list node --title="Product List" --path=/products
```

### 3. 字段配置

#### 添加字段
```yaml
# Views 字段配置示例
fields:
  - name: title
    label: 产品名称
    settings:
      link_to_entity: true
  - name: field_product_image
    label: 产品图片
    settings:
      image_style: thumbnail
      alt: 产品图片
      title: 产品图片
  - name: field_price
    label: 价格
    settings:
      currency_format: CNY
      decimal_separator: .
      thousand_separator: ,
  - name: field_sku
    label: SKU
    settings:
      truncate: true
      max_length: 20
```

#### 字段样式
```yaml
# 字段样式设置
field_style:
  - field_title:
      type: label
      weight: -5
  - field_price:
      type: number_fixed
      weight: -3
      prefix: "¥"
  - field_sku:
      type: plain_text
      weight: -1
```

### 4. 过滤器设置

#### 常用过滤器

| 过滤器 | 说明 | 使用场景 |
|--------|------|----------|
| **Node: Published status** | 已发布状态 | 只显示已发布内容 |
| **Node: Type** | 内容类型 | 筛选特定类型 |
| **Node: Language** | 语言 | 多语言站点 |
| **Node: Created date** | 创建日期 | 按时间筛选 |
| **Node: Author** | 作者 | 筛选特定作者 |
| **Any term reference** | 术语引用 | 筛选分类/标签 |
| **Global: PHP filter** | PHP 过滤器 | 自定义筛选 |

#### 添加过滤器
```yaml
# Views 过滤器配置
filters:
  - name: status
    handler: views_handler_filter_boolean
    value: true  # 只显示已发布内容

  - name: type
    handler: views_handler_filter_in_list
    value:
      - product
      - special_offer

  - name: language
    handler: views_handler_filter_node_language
    value: en

  - name: created
    handler: views_handler_filter_date
    min_date: 'today - 30 days'
    max_date: today

  - name: field_price
    handler: views_handler_filter_numeric_relation
    operator: between
    min: 0
    max: 1000
```

#### 高级过滤器
```php
/**
 * 使用 PHP 过滤器创建自定义过滤条件
 */
function mymodule_views_filter_alter(&$filters, &$view) {
  if ($view->id() === 'product_list') {
    // 添加自定义过滤条件
    $filters['custom_filter'] = [
      'field' => 'field_price',
      'operator' => 'custom',
      'value' => function($value) {
        // 自定义过滤逻辑
        return $value >= 99.99;
      },
    ];
  }
}
```

### 5. 排序设置

#### 排序选项
```yaml
# Views 排序配置
sort:
  - field: created
    direction: DESC
    weight: 1

  - field: field_price
    direction: ASC
    weight: 2

  - field: title
    direction: ASC
    weight: 3
```

#### 自定义排序
```php
/**
 * 自定义 Views 排序
 */
function mymodule_views_query_alter(&$view) {
  if ($view->id() === 'product_list') {
    // 添加自定义排序
    $view->display_handler->set_option('sorts', [
      'field_stock_status' => [
        'id' => 'field_stock_status',
        'table' => 'field_data_field_stock_status',
        'field' => 'field_stock_status',
        'position' => 0,
        'order' => 'ASC',
      ],
      'created' => [
        'id' => 'created',
        'table' => 'node_field_data',
        'field' => 'created',
        'order' => 'DESC',
      ],
    ]);
  }
}
```

### 6. 显示控制

#### 页面显示
```yaml
# 页面配置
settings:
  path: /products
  title: 'Product List'
  pager:
    type: full
    items_per_page: 12
    offset: 0
    total_pages: NULL
    tags:
      first: '« First'
      previous: '‹ Previous'
      next: 'Next ›'
      last: 'Last »'
```

#### 区块显示
```yaml
# 区块配置
block_settings:
  path: 'block/products'  # 不使用路径
  block_description: '最新产品'
  block_region: sidebar
  header:
    - type: text
      content: '精选产品'
  footer:
    - type: more_link
      text: '查看更多'
      path: /products
```

---

## 💻 开发示例

### 1. 查询 API 基础

#### 创建视图查询
```php
/**
 * 创建简单的 View 对象
 */
function create_product_view() {
  // 使用 View 构建器
  $view = \Drupal::entityTypeManager()->getStorage('view')->create([
    'id' => 'product_list',
    'label' => '产品列表',
    'contents' => [
      'title' => 'Product List',
      'path' => 'products',
      'display' => [
        'default' => [
          'display_plugin' => 'default',
          'display_title' => 'Default',
          'display_options' => [
            'query' => [
              'type' => 'views_query',
            ],
            'use_ajax' => TRUE,
          ],
        ],
        'page' => [
          'display_plugin' => 'page',
          'display_title' => 'Page',
          'display_options' => [
            'path' => 'products',
            'menu' => [
              'type' => 'normal',
              'title' => 'Products',
            ],
          ],
        ],
      ],
    ],
  ]);

  // 保存视图
  $view->save();

  return $view;
}

// 使用示例
create_product_view();
```

#### 修改现有视图
```php
/**
 * 修改视图配置
 */
function modify_product_view() {
  $view = \Drupal::entityTypeManager()->getStorage('view')->load('product_list');

  if (!$view) {
    return FALSE;
  }

  // 添加新字段
  $view->display_handler->setOption('display', [
    'default' => [
      'display_options' => [
        'fields' => [
          'title' => [
            'id' => 'title',
            'table' => 'node_field_data',
            'field' => 'title',
            'label' => '产品名称',
            'link_to_entity' => TRUE,
          ],
          'field_price' => [
            'id' => 'field_price',
            'table' => 'commerce_line_item__field_price",
            'field' => 'field_price',
            'type' => 'price',
          ],
        ],
      ],
    ],
  ]);

  $view->save();

  return TRUE;
}
```

### 2. 视图查询

#### 基本查询
```php
/**
 * 创建基本视图查询
 */
function create_basic_view_query($entity_type = 'node') {
  $query = \Drupal::entityQuery($entity_type)
    ->condition('status', 1)  // 已发布

    // 添加排序
    ->sort('created', 'DESC')

    // 添加分页
    ->range(0, 10)

    // 启用权限检查
    ->accessCheck(TRUE);

  // 获取 ID 列表
  $nids = $query->execute();

  // 加载实体
  $entities = \Drupal::entityTypeManager()
    ->getStorage($entity_type)
    ->loadMultiple($nids);

  return $entities;
}
```

#### 高级查询
```php
/**
 * 创建复杂查询
 */
function create_complex_view_query($options) {
  $query = \Drupal::entityQuery('node')
    ->condition('status', 1)

    // 内容类型筛选
    ->condition('type', $options['type'] ?? NULL, 'IN')

    // 语言筛选
    ->condition('langcode', \Drupal::languageManager()->getCurrentLanguage()->getId())

    // 日期筛选
    ->condition('created', strtotime($options['date_start'] ?? '-30 days'), '>=')
    ->condition('created', strtotime($options['date_end'] ?? '+1 day'), '<')

    // 作者筛选
    ->condition('uid', $options['author'] ?? NULL)

    // 标签筛选
    ->condition('field_tags', $options['tags'] ?? NULL, 'IN')

    // 价格筛选
    ->condition('field_price', $options['price_min'] ?? 0, '>=')
    ->condition('field_price', $options['price_max'] ?? 99999, '<=')

    // 访问检查
    ->accessCheck(TRUE)

    // 按日期排序
    ->sort('created', 'DESC')

    // 分页
    ->range($options['offset'] ?? 0, $options['limit'] ?? 20);

  $nids = $query->execute();

  return \Drupal::entityTypeManager()
    ->getStorage('node')
    ->loadMultiple($nids);
}

// 使用示例
$products = create_complex_view_query([
  'type' => ['product', 'special_offer'],
  'date_start' => '30 days ago',
  'price_min' => 50,
  'price_max' => 500,
  'limit' => 20,
]);
```

### 3. 缓存与性能

#### 配置视图缓存
```php
/**
 * 优化视图缓存
 */
function cache_optimized_views($view_id) {
  $view = \Drupal::entityTypeManager()->getStorage('view')->load($view_id);

  if (!$view) {
    return FALSE;
  }

  // 启用缓存
  $view->setDisplayOption('default', 'cache', [
    'cache' => [
      'default_lifetime' => 3600,  // 1 小时
      'max_age' => 3600,
      'tags' => [
        'node_list',
        'view_list:' . $view_id,
      ],
      'context' => ['language:content'],
    ],
  ]);

  $view->save();

  return TRUE;
}

/**
 * 视图缓存标签
 */
function get_view_cache_tags($view) {
  $tags = [
    'view_list:' . $view->id(),
    'node_list',
  ];

  // 添加内容类型标签
  $view->getBaseFieldDefinitions();
  $bundles = $view->getStorageHandler()->getBundles();

  foreach ($bundles as $bundle) {
    $tags[] = 'node_list:' . $bundle;
  }

  return $tags;
}
```

### 4. Views Bulk Operations (VBO)

#### 创建批量操作
```php
/**
 * 创建 VBO 视图
 */
function create_vbo_view() {
  $view = \Drupal::entityTypeManager()->getStorage('view')->create([
    'id' => 'vbo_products',
    'label' => '产品批量操作',
    'display' => [
      'default' => [
        'display_options' => [
          'access' => [
            'type' => 'none',
          ],
          'fields' => [
            'nothing' => [
              'type' => 'views_bulk_operations',
              'options' => [
                'action_title' => '操作',
                'queue' => TRUE,
              ],
            ],
          ],
          'filter' => [
            'status' => [
              'field' => 'status',
              'id' => '1',
            ],
            'type' => [
              'field' => 'type',
              'value' => ['product'],
              'id' => 1,
            ],
          ],
          'row_plugin' => 'node',
          'options' => [
            'sticky' => TRUE,
            'summary' => TRUE,
          ],
        ],
      ],
    ],
  ]);

  $view->save();

  return $view;
}
```

### 5. 视图导出与导入

#### 导出视图
```php
/**
 * 导出视图配置
 */
function export_view_config($view_id) {
  $view = \Drupal::entityTypeManager()->getStorage('view')->load($view_id);

  if (!$view) {
    return FALSE;
  }

  // 转换为配置
  $config = $view->getRawConfiguration();

  // 保存到文件
  $file_path = \Drupal::service('file_system')->realpath('sites/default/files/views');

  try {
    file_put_contents($file_path . '/' . $view_id . '.yml', yaml_encode($config));
    return TRUE;
  } catch (\Exception $e) {
    \Drupal::logger('mymodule')->error('Failed to export view: @error', ['@error' => $e->getMessage()]);
    return FALSE;
  }
}
```

#### 配置模块导出
```bash
# 使用 drush 导出所有视图
drush config-export --name=views.settings

# 导出特定视图
drush config-export --name=views.view.product_list
```

---

## 🎯 最佳实践

### 1. 命名规范

#### Views 命名
- ✅ 使用描述性名称
- ✅ 小写字母和下划线
- ✅ 避免特殊字符
- ❌ 使用 `views1`, `test` 等

#### 推荐命名
```yaml
# ✅ 好的命名
product_list: 产品列表
recent_posts: 最新文章
author_articles: 作者文章
category_news: 分类新闻

# ❌ 避免的命名
test1: 测试 1
view1: 视图 1
```

### 2. 性能优化

#### 查询优化
```php
/**
 * 优化 Views 查询
 */
function optimize_views_query($view) {
  // 减少查询次数
  $view->display_handler->setOption('pager_type', 'full');

  // 使用分页
  $view->display_handler->setOption('items_per_page', 20);

  // 禁用不必要的字段加载
  $view->display_handler->setOption('fields', [
    'nid' => TRUE,  // 只加载需要的字段
    'title' => TRUE,
  ]);
}
```

#### 缓存策略
```yaml
# 缓存配置
cache_settings:
  - cache_views: TRUE
    cache_age: 3600
    cache_tags:
      - node_list
      - view_list

  - cache_views_query: TRUE
  - use_context: TRUE
```

### 3. 安全实践

#### 访问控制
```php
/**
 * 视图访问控制
 */
function access_control_views($view_id) {
  $view = \Drupal::entityTypeManager()->getStorage('view')->load($view_id);

  // 设置访问权限
  $view->display_handler->setOption('access', [
    'type' => 'permission',
    'settings' => [
      'permission' => ['access content'],
    ],
  ]);

  $view->save();
}
```

---

## 📊 常见问题 (FAQ)

### Q1: 如何快速创建常用视图？
**A**: 使用预配置模板或 Drush 命令

### Q2: 视图加载慢怎么办？
**A**:
- 启用缓存
- 优化查询
- 减少字段数量
- 使用分页

### Q3: 如何保存视图配置？
**A**:
- 使用配置导出
- 或使用 drush config-export

### Q4: 如何恢复视图？
**A**:
- 使用配置导入
- 或使用 drush config-import

### Q5: 如何调试视图？
**A**:
- 使用 Views UI 调试模式
- 检查查询日志
- 启用视图调试输出

---

## 🔗 相关链接

- [Drupal Views 官方文档](https://www.drupal.org/docs/8/core-modules-and-contributed-modules/core-module/views)
- [Views API 参考](https://api.drupal.org/api/drupal/core!modules!views!views.api.php)
- [Views 开发者指南](https://www.drupal.org/docs/8/developing-with-views)
- [Views 社区支持](https://www.drupal.org/project/views)

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

*下一篇*: [Configuration 配置系统](core-modules/05-config.md)
*返回*: [核心模块索引](core-modules/00-index.md)
*上一篇*: [Field 字段系统](core-modules/04-field.md)
