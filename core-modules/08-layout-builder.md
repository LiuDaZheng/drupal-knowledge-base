---
name: drupal-layout-builder
description: Complete guide to Drupal Layout Builder. Covers layout creation, blocks, components, and page building for Drupal 11.
---

# Drupal Layout Builder 布局系统完整指南

**版本**: v1.0
**Drupal 版本**: 11.x
**状态**: 活跃维护
**更新时间**: 2026-04-05

---

## 📖 模块概述

### 简介
**Layout Builder** 是 Drupal 的强大可视化页面构建器，允许用户通过拖放方式创建自定义页面布局，无需编写代码。

### 核心功能
- ✅ 可视化页面布局
- ✅ 区块拖放管理
- ✅ 自定义模板创建
- ✅ 条件布局系统
- ✅ 多列布局支持
- ✅ 区块配置管理

### 适用范围
- ✅ 内容型网站必备
- ✅ 企业官网页面
- ✅ 产品详情页
- ✅ 自定义首页
- ✅ 复杂布局需求

---

## 🚀 安装与启用

### 默认状态
- ✅ **已内建**: Layout Builder 是 Drupal 11 核心模块
- ⚡ **自动启用**: 新站点创建时自动启用

### 检查状态
```bash
# 查看 Layout Builder 状态
drush pm-info layout_builder

# 启用布局功能
drush en layout_builder

# UI 启用
# /admin/modules/core
```

---

## ⚙️ 核心配置

### 1. 布局基础

#### 布局类型
| 布局 | 说明 | 使用场景 |
|------|------|----------|
| **Default** | 默认布局 | 标准页面 |
| **Two Column** | 两列布局 | 左右分栏 |
| **Three Column** | 三列布局 | 三栏布局 |
| **Custom** | 自定义布局 | 特殊布局需求 |

#### 区块区域
```yaml
# 区块区域配置
regions:
  header:
    label: 头部区域
    weight: -10
  sidebar:
    label: 侧边栏
    weight: 0
  primary:
    label: 主要区域
    weight: 10
  footer:
    label: 底部区域
    weight: 100
```

#### 区块设置
```yaml
# 区块配置示例
block:
  type: 'block_content:basic'
  label: 'Basic block'
  region: 'primary'
  weight: '0'
  settings:
    id: 'basic_block_1'
    label_display: '0'
    status: true
  extra: []
```

### 2. 区块管理

#### 可用区块类型
```yaml
# 区块类型列表
block_types:
  - 'block_content:basic'          # 基础区块
  - 'system:main_menu'             # 主菜单
  - 'system:local_tasks'           # 本地标签
  - 'system:breadcrumbs'           # 面包屑导航
  - 'node:article_body'            # 文章内容
  - 'node:author'                  # 作者信息
  - 'views:block:recent_posts'     # Views 区块
  - 'custom:my_custom_block'       # 自定义区块
```

#### 区块创建
```bash
# 创建基础区块
# /admin/structure/block-content/manage/basic

# 创建自定义区块
drush block-content:create custom_title "Custom Title"
```

#### 区块配置
```yaml
# 区块模板配置
block_template:
  header:
    region: 'header'
    weight: '-10'
    template: 'header--custom.html.twig'
  footer:
    region: 'footer'
    weight: '100'
    template: 'footer--custom.html.twig'
  primary:
    region: 'primary'
    weight: '0'
```

### 3. 布局创建

#### 创建页面布局
```bash
# 启用页面布局功能
# /admin/structure/display-mode/content/article/view/layouts

# 配置布局
# /admin/structure/type/article/display/settings

# 使用布局构建器编辑页面
# Edit > Layout tab
```

#### 布局模板
```twig
{# 布局模板示例 #}
{% embed 'block-theme.html.twig' %}
  {% block content %}
    <div class="layout-container">
      {% for region, blocks in layout_regions %}
        <div class="layout-region {{ region }}">
          {% for block in blocks %}
            {{ block }}
          {% endfor %}
        </div>
      {% endfor %}
    </div>
  {% endblock %}
{% endembed %}
```

#### 多列布局
```yaml
# 两列布局配置
two_column_layout:
  regions:
    left:
      label: 左列
      weight: -10
      template: 'layout-builder--two-column-left.html.twig'
    right:
      label: 右列
      weight: 10
      template: 'layout-builder--two-column-right.html.twig'
  settings:
    left_width: '6'  # 6/12 列
    right_width: '6' # 6/12 列
```

### 4. 区块条件

#### 条件配置
```yaml
# 区块显示条件
block_conditions:
  - {type: 'node_type', settings: {bundle: {article: article}}}
  - {type: 'page_path', settings: {pages: '/node/*'}}
  - {type: 'user_role', settings: {roles: {authenticated: authenticated}}}
  - {type: 'date', settings: {time_min: 0, time_max: 17, timezone: UTC}}
```

#### 高级条件
```php
/**
 * 创建自定义区块条件
 */
function create_block_condition($condition_type, $settings) {
  $condition = [
    'id' => $condition_type,
    'settings' => $settings,
    'label' => $settings['label'] ?? $condition_type,
  ];

  return $condition;
}

/**
 * 区块显示条件
 */
function block_display_condition($block, $page) {
  $conditions = $block->getConditionList();

  foreach ($conditions as $condition) {
    $handler = \Drupal::service($condition['plugin']);

    if (!$handler->access($page)) {
      return FALSE;
    }
  }

  return TRUE;
}
```

---

## 💻 开发示例

### 1. 区块 API

#### 区块创建
```php
/**
 * 创建区块
 */
function create_layout_block($block_type, $label, $region, $weight = 0) {
  $block_content = \Drupal::entityTypeManager()->getStorage('block_content')->create([
    'type' => 'basic',
    'info' => $label,
    'langcode' => \Drupal::languageManager()->getDefaultLanguage()->getId(),
  ]);

  $block_content->save();

  // 创建区块实例
  $block = \Drupal::entityTypeManager()->getStorage('block')->create([
    'plugin' => $block_type,
    'provider' => 'mymodule',
    'label' => $label,
    'region' => $region,
    'weight' => $weight,
    'status' => TRUE,
    'data' => [],
  ]);

  $block->save();

  return $block;
}

// 使用示例
$block = create_layout_block('block_content:basic', 'My Custom Block', 'sidebar');
```

#### 区块修改
```php
/**
 * 修改区块
 */
function update_layout_block($block_id, $settings) {
  $block = \Drupal::entityTypeManager()->getStorage('block')->load($block_id);

  if (!$block) {
    throw new \Exception("Block {$block_id} not found");
  }

  // 更新区块设置
  foreach ($settings as $key => $value) {
    $block->set($key, $value);
  }

  $block->save();

  return TRUE;
}

/**
 * 移除区块
 */
function remove_layout_block($block_id) {
  $block = \Drupal::entityTypeManager()->getStorage('block')->load($block_id);

  if (!$block) {
    return FALSE;
  }

  $block->delete();

  return TRUE;
}
```

### 2. 布局构建

#### 创建布局
```php
/**
 * 创建页面布局
 */
function create_page_layout($node_type, $layout_name) {
  $display = \Drupal::entityTypeManager()->getStorage('entity_view_display')->create([
    'targetEntityType' => 'node',
    'bundle' => $node_type,
    'mode' => 'layout_builder',
    'weight' => 1,
  ]);

  $display->save();

  // 设置布局
  $display->set('settings', [
    'layout_builder_enabled' => TRUE,
    'layout_overrides' => [
      'full' => [
        'layout_id' => 'builder:custom',
        'components' => [
          [
            'uuid' => uniqid(),
            'region' => 'content',
            'label' => 'Content',
          ],
        ],
      ],
    ],
  ]);

  $display->save();

  return $display->id();
}
```

#### 布局组件
```php
/**
 * 添加布局组件
 */
function add_layout_component($entity_id, $component) {
  $entity_view_display = \Drupal::entityTypeManager()->getStorage('entity_view_display')->load('node.article.layout_builder');

  $layout_overrides = $entity_view_display->get('settings.layout_overrides');

  // 添加组件
  $layout_overrides['layout']['components'][] = $component;

  $entity_view_display->set('settings.layout_overrides', $layout_overrides);
  $entity_view_display->save();

  return TRUE;
}

/**
 * 修改布局组件
 */
function update_layout_component($entity_id, $component_uuid, $new_component) {
  $entity_view_display = \Drupal::entityTypeManager()->getStorage('entity_view_display')->load('node.article.layout_builder');

  $layout_overrides = $entity_view_display->get('settings.layout_overrides');

  // 查找并替换组件
  foreach ($layout_overrides['layout']['components'] as $key => $component) {
    if ($component['uuid'] === $component_uuid) {
      $layout_overrides['layout']['components'][$key] = $new_component;
      break;
    }
  }

  $entity_view_display->set('settings.layout_overrides', $layout_overrides);
  $entity_view_display->save();

  return TRUE;
}
```

### 3. 区块区域

#### 区域定义
```php
/**
 * 定义区块区域
 */
function define_region($region_id, $settings) {
  $region = [
    'id' => $region_id,
    'label' => $settings['label'] ?? $region_id,
    'weight' => $settings['weight'] ?? 0,
    'template' => $settings['template'] ?? 'region--' . $region_id . '.html.twig',
  ];

  return $region;
}

/**
 * 获取所有区域
 */
function get_layout_regions($display_mode = 'full') {
  $entity_display = \Drupal::entityTypeManager()->getStorage('entity_view_display')->load('node.article.' . $display_mode);

  if (!$entity_display) {
    return [];
  }

  $layout_overrides = $entity_display->get('settings.layout_overrides');

  if (!isset($layout_overrides[$display_mode])) {
    return [];
  }

  $layout = $layout_overrides[$display_mode]['layout_id'];

  // 获取布局类型定义的 region
  $layout_plugin = \Drupal::service('plugin.manager.layout')->createInstance($layout);
  $regions = $layout_plugin->getRegions();

  return $regions;
}
```

#### 区域渲染
```php
/**
 * 渲染区块区域
 */
function render_region($region_id, $block_ids) {
  $output = '<div class="region ' . $region_id . '">';

  foreach ($block_ids as $block_id) {
    $block = \Drupal::entityTypeManager()->getStorage('block')->load($block_id);

    if ($block && $block->getRegion() === $region_id && $block->getVisible()) {
      $block_view = \Drupal::service('rendering').render($block);
      $output .= $block_view;
    }
  }

  $output .= '</div>';

  return $output;
}

/**
 * 渲染全部布局
 */
function render_full_layout($entity_id, $display_mode) {
  $entity = \Drupal::entityTypeManager()->getStorage('node')->load($entity_id);

  // 获取布局构建器视图
  $display = \Drupal::entityTypeManager()->getStorage('entity_view_display')
    ->load('node.' . $entity->getType() . '.layout_builder');

  if (!$display) {
    return '';
  }

  // 渲染布局
  $view_builder = \Drupal::service('entity.view_builder');
  $build = $view_builder->build($entity, $display_mode, 'layout_builder');

  return \Drupal::service('renderer')->renderRoot($build);
}
```

---

## 🎯 最佳实践

### 1. 布局设计

#### 设计原则
- ✅ 响应式设计
- ✅ 移动优先
- ✅ 简洁布局
- ✅ 一致性

#### 布局模式
```yaml
# 推荐布局模式
patterns:
  - name: 'hero_section'
    template: 'hero-layout.html.twig'
    regions:
      - content
      - call_to_action

  - name: 'content_columns'
    template: 'columns-layout.html.twig'
    regions:
      - left_column
      - right_column

  - name: 'footer_area'
    template: 'footer-layout.html.twig'
    regions:
      - footer_primary
      - footer_secondary
```

### 2. 性能优化

#### 布局缓存
```php
/**
 * 优化布局渲染
 */
function optimize_layout_rendering($entity_id, $display_mode) {
  // 启用布局缓存
  $entity_view_display = \Drupal::entityTypeManager()
    ->getStorage('entity_view_display')
    ->load('node.article.layout_builder');

  if ($entity_view_display) {
    $settings = $entity_view_display->get('settings');

    // 确保启用缓存
    $settings['cache'] = [
      'max-age' => 3600,
      'tags' => ['layout_builder'],
    ];

    $entity_view_display->set('settings', $settings);
    $entity_view_display->save();
  }
}

/**
 * 区块缓存优化
 */
function optimize_block_caching($block_id) {
  $block = \Drupal::entityTypeManager()->getStorage('block')->load($block_id);

  if ($block) {
    // 设置缓存标签
    $block->setCacheTags(['layout_builder']);
    $block->setCacheMaxAge(3600);
    $block->save();
  }
}
```

### 3. 安全配置

#### 区块权限
```php
/**
 * 检查区块权限
 */
function check_block_permission($block_id, $account) {
  $block = \Drupal::entityTypeManager()->getStorage('block')->load($block_id);

  if (!$block) {
    return FALSE;
  }

  return $block->access('view', $account);
}

/**
 * 安全区块过滤
 */
function filter_safe_blocks($blocks) {
  $safe_blocks = [];

  foreach ($blocks as $block) {
    // 检查区块权限
    if ($block->access('execute')) {
      $safe_blocks[] = $block;
    }
  }

  return $safe_blocks;
}
```

---

## 📊 常见问题 (FAQ)

### Q1: 如何创建自定义布局?
**A**:
- 使用布局构建器
- 定义自定义区域
- 创建布局模板

### Q2: 如何禁用特定区块?
**A**:
- 在区块配置中设置可见性
- 通过权限控制
- 删除区块实例

### Q3: 如何优化布局性能?
**A**:
- 启用缓存
- 减少区块数量
- 优化模板文件

### Q4: 如何调试布局问题?
**A**:
- 启用布局构建器调试模式
- 检查区块可见性
- 验证区域配置

### Q5: 如何迁移布局?
**A**:
- 导出布局配置
- 使用配置管理器
- 导入布局设置

---

## 🔗 相关链接

- [Drupal Layout Builder 官方文档](https://www.drupal.org/docs/8/core-modules-and-contributed-modules/core-module/layout-builder)
- [布局构建器 API](https://api.drupal.org/api/drupal/modules!layout_builder!LayoutBuilder.php)
- [布局构建器指南](https://www.drupal.org/docs/8/using-layout-builder)
- [区块 API](https://api.drupal.org/api/drupal/modules!block!block.api.php)

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

*下一篇*: [Media 媒体系统](core-modules/08-media.md)
*返回*: [核心模块索引](core-modules/00-index.md)
*上一篇*: [Entity 实体系统](core-modules/06-entity.md)
