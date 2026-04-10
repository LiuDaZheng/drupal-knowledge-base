# Drupal 内容建模最佳实践

> 来源：Drupal 官方文档 (drupal.org/docs)  
> 最后更新：2026-04-10  
> 适用版本：Drupal 8/9/10/11

---

## 目录

1. [内容类型设计](#1-内容类型设计)
2. [字段设计](#2-字段设计)
3. [Views 设计](#3-views-设计)
4. [实际案例](#4-实际案例)

---

## 1. 内容类型设计

### 1.1 设计原则

**核心原则**：
- 内容类型应该反映业务实体
- 每个内容类型有明确的用途
- 避免过度细分或过度合并

**设计流程**：

```
1. 识别业务实体
   ↓
2. 定义内容类型
   ↓
3. 规划字段
   ↓
4. 配置显示
   ↓
5. 测试验证
```

**内容类型分类**：

| 类别 | 用途 | 示例 |
|------|------|------|
| 核心内容 | 站点主要内容 | 文章、页面 |
| 媒体内容 | 多媒体资源 | 图片、视频、音频 |
| 结构化内容 | 有固定结构的数据 | 产品、活动、人员 |
| 辅助内容 | 支持性功能 | FAQ、术语表、导航 |

**最佳实践**：

1. **命名规范**：
   - 使用小写字母和下划线
   - 名称应清晰描述内容用途
   - 避免缩写和模糊术语

2. **数量控制**：
   - 小型站点：5-10 个内容类型
   - 中型站点：10-20 个内容类型
   - 大型站点：20-50 个内容类型

3. **复用策略**：
   - 相似内容使用相同类型
   - 通过字段区分变体
   - 使用段落处理复杂布局

**参考**：
- https://www.drupal.org/docs/user_guide/en/structure-content-type.html
- https://www.drupal.org/docs/administering-a-drupal-site/managing-content-0/working-with-content-types-and-fields

---

### 1.2 文章类型

**适用场景**：
- 博客文章
- 新闻稿
- 公告
- 教程

**字段设计**：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Title | Text | 是 | 文章标题 |
| Body | Text (formatted) | 是 | 文章内容 |
| Image | Image | 否 | 特色图片 |
| Author | Entity reference | 自动 | 作者（系统自动） |
| Created date | Date | 自动 | 创建日期 |
| Tags | Taxonomy term | 否 | 标签分类 |
| Category | Taxonomy term | 否 | 文章分类 |

**显示配置**：

```yaml
# 默认显示模式
teaser:
  fields:
    - image (缩略图)
    - title (链接)
    - body (摘要，200 字符)
    - created (日期)
    
full:
  fields:
    - image (大图)
    - title (H1)
    - body (完整内容)
    - field_tags (标签列表)
    - author (作者信息)
    - created (完整日期)
```

**最佳实践**：

1. **摘要生成**：使用正文前 N 字符或手动摘要字段
2. **图片优化**：为列表和详情提供不同图片样式
3. **URL 别名**：配置自动 URL 别名模式
4. **修订版本**：启用修订以便内容追溯

**配置示例**：
```php
// 编程方式创建文章类型
$node_type = \Drupal\node\Entity\NodeType::create([
  'type' => 'article',
  'name' => t('Article'),
  'description' => t('Use for blog posts and news articles.'),
]);
$node_type->save();
```

**参考**：
- https://new.drupal.org/docs/drupal-cms/get-started/get-to-know-drupal-cms/default-content-types

---

### 1.3 页面类型

**适用场景**：
- 静态页面
- 关于页面
- 联系页面
- 服务页面

**字段设计**：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Title | Text | 是 | 页面标题 |
| Body | Text (formatted) | 否 | 页面内容 |
| Layout sections | Paragraphs | 否 | 布局区块 |
| Sidebar | Text (formatted) | 否 | 侧边栏内容 |
| Call-to-action | Link | 否 | 行动号召链接 |
| Meta description | Text | 否 | SEO 描述 |
| Menu link | Menu link | 否 | 菜单链接 |

**显示配置**：

```yaml
default:
  regions:
    header:
      - title
    content:
      - body
      - layout_sections
    sidebar:
      - sidebar
    footer:
      - call_to_action
```

**最佳实践**：

1. **灵活布局**：使用段落模块支持多种布局
2. **SEO 优化**：包含 meta 描述和关键词字段
3. **菜单集成**：自动或手动添加到菜单
4. **模板覆盖**：为特殊页面创建自定义模板

**参考**：
- https://www.drupal.org/docs/user_guide/en/structure-content-type.html

---

### 1.4 产品类型

**适用场景**：
- 电子商务产品
- 服务产品
- 下载产品
- 订阅服务

**字段设计**：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Title | Text | 是 | 产品名称 |
| Description | Text (formatted) | 是 | 产品描述 |
| SKU | Text | 是 | 库存单位 |
| Price | Decimal | 是 | 价格 |
| Images | Image | 否 | 产品图片（多张） |
| Category | Taxonomy term | 是 | 产品分类 |
| Attributes | List (text) | 否 | 产品属性（颜色、尺寸等） |
| Stock quantity | Integer | 否 | 库存数量 |
| Related products | Entity reference | 否 | 相关产品 |
| Specifications | Text (long) | 否 | 技术规格 |

**显示配置**：

```yaml
product_listing:
  fields:
    - image (缩略图)
    - title (链接)
    - price (价格)
    - category (分类标签)
    
product_full:
  fields:
    - images (图片画廊)
    - title (H1)
    - price (大字显示)
    - description (完整描述)
    - attributes (属性列表)
    - specifications (规格表)
    - related_products (产品网格)
```

**最佳实践**：

1. **变体管理**：使用产品变体处理不同规格
2. **价格显示**：支持多种货币和折扣
3. **库存管理**：集成库存跟踪
4. **搜索优化**：为搜索配置合适的字段权重

**参考**：
- https://www.drupal.org/docs/7/howtos/book-drupal-7-the-essentials/part-b-information-structure-in-drupal

---

### 1.5 自定义类型

**常见自定义类型**：

| 类型 | 用途 | 关键字段 |
|------|------|---------|
| Event | 活动管理 | 日期、地点、报名 |
| Person | 人员档案 | 姓名、职位、联系方式 |
| Resource | 资源下载 | 文件、描述、分类 |
| FAQ | 常见问题 | 问题、答案、分类 |
| Testimonial | 客户评价 | 评价内容、客户信息 |
| Portfolio | 作品展示 | 图片、描述、客户 |

**设计流程**：

1. **需求分析**：
   - 确定内容用途
   - 识别目标用户
   - 定义显示场景

2. **字段规划**：
   - 列出所有必要字段
   - 确定字段类型
   - 设置验证规则

3. **显示设计**：
   - 设计列表视图
   - 设计详情视图
   - 考虑响应式布局

4. **权限配置**：
   - 定义创建权限
   - 定义编辑权限
   - 定义发布权限

**示例：活动类型**：

| 字段 | 类型 | 配置 |
|------|------|------|
| Title | Text | 活动名称 |
| Date start | Datetime | 开始时间 |
| Date end | Datetime | 结束时间 |
| Location | Text | 活动地点 |
| Map | Geofield | 地图坐标 |
| Description | Text (formatted) | 活动描述 |
| Image | Image | 活动图片 |
| Max attendees | Integer | 最大人数 |
| Registration link | Link | 报名链接 |
| Speaker | Entity reference | 演讲者（引用人员） |

**最佳实践**：

1. **可扩展性**：预留扩展字段
2. **数据验证**：设置合理的字段验证
3. **工作流**：配置内容审核流程
4. **集成考虑**：预留外部系统集成字段

**参考**：
- https://www.drupal.org/docs/user_guide/en/planning-structure.html

---

## 2. 字段设计

### 2.1 文本字段

**字段类型**：

| 类型 | 用途 | 配置选项 |
|------|------|---------|
| Text (plain) | 纯文本 | 长度限制、默认值 |
| Text (formatted) | 富文本 | 文本格式、字数限制 |
| Text (long) | 长文本 | 文本格式 |
| Text (long, formatted) | 长富文本 | 文本格式、摘要 |

**最佳实践**：

1. **长度限制**：
   ```php
   // 设置最大长度
   'max_length' => 255,  // 短文本
   'max_length' => 1024, // 中等文本
   // 不设置（长文本）
   ```

2. **文本格式**：
   - 用户内容：使用受限格式（Filtered HTML）
   - 编辑内容：使用完整格式（Full HTML）
   - 系统内容：使用纯文本

3. **默认值**：
   ```php
   $field_config->setDefaultValue([
     ['value' => '默认文本内容'],
   ]);
   ```

4. **验证规则**：
   ```php
   // 添加字段验证
   $field->setSetting('allowed_values', [
     'min_length' => 10,
     'max_length' => 500,
   ]);
   ```

**使用场景**：

| 场景 | 推荐类型 | 说明 |
|------|---------|------|
| 标题 | Text (plain) | 255 字符限制 |
| 摘要 | Text (formatted) | 限制字数，允许基本格式 |
| 正文 | Text (long, formatted) | 完整富文本 |
| 描述 | Text (formatted) | 中等长度富文本 |
| 代码 | Text (long) | 纯文本，保留格式 |

**参考**：
- https://www.drupal.org/docs/user_guide/en/structure-fields.html

---

### 2.2 引用字段

**字段类型**：

| 类型 | 用途 | 说明 |
|------|------|------|
| Entity reference | 引用实体 | 节点、用户、术语等 |
| Entity reference (autocomplete) | 自动完成 | 大型数据集 |
| Entity reference (select) | 下拉选择 | 小型数据集 |
| Entity reference (views widget) | Views 小部件 | 复杂筛选 |

**配置选项**：

```yaml
field_related_articles:
  type: entity_reference
  settings:
    target_type: node
    target_bundles:
      - article
    handler: default
    handler_settings:
      auto_create: false
      auto_create_bundle: article
```

**最佳实践**：

1. **引用限制**：
   - 限制可引用的内容类型
   - 限制可引用的词汇表
   - 使用筛选条件缩小选择范围

2. **显示优化**：
   ```php
   // 自定义引用实体显示
   $display->setComponent('field_related', [
     'type' => 'entity_reference_entity_view',
     'settings' => [
       'view_mode' => 'teaser',
     ],
   ]);
   ```

3. **反向引用**：
   ```php
   // 配置反向引用字段
   // 在目标内容类型中添加字段
   // 显示引用当前内容的所有内容
   ```

4. **性能考虑**：
   - 大量数据使用自动完成
   - 配置索引优化查询
   - 使用缓存减少数据库查询

**使用场景**：

| 场景 | 配置建议 |
|------|---------|
| 相关文章 | 同分类的文章，限制 5 个 |
| 作者 | 引用用户，自动完成 |
| 产品分类 | 引用词汇，下拉选择 |
| 产品图片 | 引用媒体，无限数量 |
| 上级页面 | 引用页面，树形选择 |

**参考**：
- https://www.drupal.org/docs/administering-a-drupal-site/managing-content-0/working-with-content-types-and-fields

---

### 2.3 图像字段

**字段类型**：

| 类型 | 用途 | 说明 |
|------|------|------|
| Image | 单张图片 | 基础图片字段 |
| Image (multiple) | 多张图片 | 图片画廊 |
| Media | 媒体实体 | 可复用的媒体 |

**配置选项**：

```yaml
field_image:
  type: image
  settings:
    default_image:
      uuid: null
      alt: ''
      title: ''
      width: null
      height: null
    alt_field: true
    alt_field_required: true
    title_field: false
    max_resolution: ''
    min_resolution: ''
    file_directory: '[date:custom:Y]-[date:custom:m]'
    file_extensions: 'png gif jpg jpeg webp'
    max_filesize: '5 MB'
```

**最佳实践**：

1. **图片样式**：
   ```php
   // 创建图片样式
   $style = ImageStyle::create([
     'name' => 'content_thumbnail',
     'label' => 'Content Thumbnail',
     'effects' => [
       [
         'name' => 'image_scale_and_crop',
         'data' => ['width' => 400, 'height' => 300],
       ],
     ],
   ]);
   $style->save();
   ```

2. **响应式图片**：
   ```yaml
   # 配置响应式图片样式
   field_image:
     type: responsive_image
     settings:
       responsive_image_style: content_responsive
   ```

3. **懒加载**：
   - 启用图片懒加载模块
   - 配置占位符图片
   - 优化首屏加载

4. **SEO 优化**：
   - 强制 ALT 文本
   - 支持标题文本
   - 自动生成文件名

**使用场景**：

| 场景 | 配置建议 |
|------|---------|
| 特色图片 | 单张，强制 ALT，多种样式 |
| 图片画廊 | 多张，拖拽排序，灯箱效果 |
| 产品图片 | 多张，主图标记，缩放功能 |
| 用户头像 | 单张，固定尺寸，裁剪 |
| 背景图片 | 单张，全尺寸，覆盖模式 |

**参考**：
- https://www.drupal.org/docs/user_guide/en/structure-fields.html

---

### 2.4 复合字段

**字段类型**：

| 类型 | 用途 | 说明 |
|------|------|------|
| Paragraphs | 段落 | 可复用内容块 |
| Field collection | 字段集合 | 字段组合（已过时） |
| Composite field | 复合字段 | 自定义复合 |

**Paragraphs 配置**：

```yaml
# 段落类型：文本块
paragraph_type: text_block
fields:
  - field_title (文本)
  - field_body (富文本)
  - field_background (颜色选择)

# 段落类型：图片 + 文本
paragraph_type: image_text
fields:
  - field_image (图片)
  - field_caption (文本)
  - field_position (列表：左/右)

# 段落类型：引用
paragraph_type: quote
fields:
  - field_quote (长文本)
  - field_author (文本)
  - field_source (文本)
```

**最佳实践**：

1. **段落设计**：
   - 每个段落类型有单一用途
   - 提供清晰的段落标签
   - 限制可用段落类型

2. **嵌套控制**：
   ```php
   // 限制段落嵌套
   $field_config->setSetting('allowed_bundles', [
     'text_block',
     'image_text',
     'quote',
   ]);
   $field_config->setSetting('cardinality', -1); // 无限数量
   ```

3. **预览配置**：
   ```php
   // 启用段落预览
   $field_config->setSetting('preview_mode', 1); // 显示预览
   ```

4. **显示优化**：
   - 为段落创建专用模板
   - 配置段落样式类
   - 支持拖拽重排序

**使用场景**：

| 场景 | 段落类型 |
|------|---------|
| 页面构建器 | 文本、图片、视频、CTA、分隔线 |
| 产品详情 | 描述、规格、评价、相关产品 |
| 活动页面 | 详情、议程、演讲者、地图 |
| 着陆页 | Hero、特性、评价、FAQ、CTA |

**参考**：
- https://www.drupal.org/docs/contributed-modules/paragraphs

---

## 3. Views 设计

### 3.1 列表视图

**核心原则**：
- 明确视图目的
- 优化查询性能
- 提供合适的筛选

**基础配置**：

```yaml
view.article_list:
  label: 'Article List'
  module: views
  description: 'List of articles'
  tag: ''
  base_table: node_field_data
  base_field: nid
  display:
    default:
      display_plugin: default
      display_title: Master
      options:
        query:
          type: sql
        relationships: {  }
        access:
          type: perm
        cache:
          type: tag
        exposed_form:
          type: basic
        pager:
          type: full
          options:
            items_per_page: 10
            offset: 0
        style:
          type: grid
          options:
            columns: 3
            rows: 0
        row:
          type: entity
          options:
            view_mode: teaser
        fields:
          title:
            label: Title
            exclude: false
            alter:
              alter_text: false
            link_to_entity: true
        filters:
          status:
            value: '1'
            table: node_field_data
            field: status
            id: status
            plugin_id: boolean
            expose:
              operator: ''
          type:
            value:
              article: article
            table: node_field_data
            field: type
            id: type
            plugin_id: bundle
        sorts:
          created:
            order: DESC
            table: node_field_data
            field: created
            id: created
            plugin_id: date
```

**最佳实践**：

1. **性能优化**：
   - 使用缓存（至少 15 分钟）
   - 添加必要索引
   - 限制结果数量
   - 避免 N+1 查询

2. **分页配置**：
   - 列表页：10-20 项/页
   - 搜索页：10 项/页
   - 管理页：25-50 项/页

3. **空结果处理**：
   ```php
   // 配置空结果文本
   $display->setOption('empty', [
     'content' => '没有找到相关内容。',
     'format' => 'plain',
   ]);
   ```

**参考**：
- https://www.drupal.org/node/1578406

---

### 3.2 筛选器

**筛选器类型**：

| 类型 | 用途 | 示例 |
|------|------|------|
| 内容类型 | 按类型筛选 | 文章、页面、产品 |
| 分类术语 | 按分类筛选 | 新闻、博客、案例 |
| 日期范围 | 按时间筛选 | 本月、本年、自定义 |
| 状态 | 按状态筛选 | 已发布、草稿、归档 |
| 作者 | 按作者筛选 | 用户选择 |
| 关键词 | 全文搜索 | 标题 + 正文搜索 |

**暴露筛选器配置**：

```yaml
exposed_filters:
  field_category:
    type: select
    label: Category
    required: false
    multiple: false
    remember: false
    
  field_date:
    type: date_popup
    label: Date Range
    required: false
    
  search_api_fulltext:
    type: search
    label: Search
    required: false
```

**最佳实践**：

1. **筛选器位置**：
   - 重要筛选器放在顶部
   - 相关筛选器分组显示
   - 提供重置按钮

2. **默认值设置**：
   ```php
   // 设置筛选器默认值
   $display->setOption('exposed_form', [
     'options' => [
       'default_group_multiple' => [],
       'default_group_operator' => 'AND',
     ],
   ]);
   ```

3. **AJAX 支持**：
   - 启用 AJAX 无刷新筛选
   - 配置自动提交（可选）
   - 显示加载状态

4. **URL 参数**：
   - 筛选条件反映在 URL
   - 支持书签和分享
   - SEO 友好的 URL

**参考**：
- https://www.drupal.org/docs/7/howtos/book-drupal-7-the-essentials/part-b-information-structure-in-drupal/10-advanced-views-configuration

---

### 3.3 排序

**排序选项**：

| 字段 | 方向 | 用途 |
|------|------|------|
| Created date | DESC | 最新内容优先 |
| Created date | ASC | 最旧内容优先 |
| Title | ASC | 字母顺序 |
| Title | DESC | 倒序字母 |
| Content updated | DESC | 最近更新 |
| Comment count | DESC | 热门内容 |
| Random | - | 随机显示 |

**暴露排序配置**：

```yaml
exposed_sorts:
  created:
    label: Date
    default: DESC
    options:
      DESC: 'Newest first'
      ASC: 'Oldest first'
      
  title:
    label: Title
    default: ASC
    options:
      ASC: 'A to Z'
      DESC: 'Z to A'
      
  comment_count:
    label: Popularity
    default: DESC
    options:
      DESC: 'Most comments'
      ASC: 'Least comments'
```

**最佳实践**：

1. **默认排序**：
   - 内容列表：按创建日期降序
   - 目录列表：按标题升序
   - 产品列表：按相关性或销量

2. **多字段排序**：
   ```php
   // 配置多字段排序
   // 1. 置顶内容优先
   // 2. 然后按日期排序
   $view->add_sort([
     'id' => 'field_sticky',
     'table' => 'node__field_sticky',
     'field' => 'field_sticky',
     'order' => 'DESC',
   ]);
   $view->add_sort([
     'id' => 'created',
     'table' => 'node_field_data',
     'field' => 'created',
     'order' => 'DESC',
   ]);
   ```

3. **用户选择**：
   - 提供常用排序选项
   - 记住用户偏好（可选）
   - 移动端简化排序选项

**参考**：
- https://www.drupal.org/project/views/issues/1397848

---

### 3.4 显示配置

**显示模式**：

| 模式 | 用途 | 配置要点 |
|------|------|---------|
| Page | 独立页面 | URL 路径、菜单、区块 |
| Block | 可放置区块 | 区域、可见性、缓存 |
| Feed | RSS/Atom 订阅 | 标题、描述、项目数 |
| Embed | 嵌入内容 | 短代码、API 调用 |
| Attachment | 附加显示 | 依附于其他显示 |

**样式插件**：

| 样式 | 用途 | 配置 |
|------|------|------|
| Grid | 网格布局 | 列数、行数、对齐 |
| Table | 表格布局 | 列、排序、分组 |
| HTML list | 列表布局 | 有序/无序、类名 |
| Unformatted | 无格式 | 自定义模板 |
| RSS | RSS 订阅 | 字段映射 |

**最佳实践**：

1. **响应式设计**：
   ```css
   /* 网格响应式 */
   .views-grid {
     display: grid;
     grid-template-columns: repeat(3, 1fr);
   }
   
   @media (max-width: 768px) {
     .views-grid {
       grid-template-columns: repeat(2, 1fr);
     }
   }
   
   @media (max-width: 480px) {
     .views-grid {
       grid-template-columns: 1fr;
     }
   }
   ```

2. **缓存配置**：
   ```php
   // 视图缓存设置
   $display->setOption('cache', [
     'type' => 'tag',
     'options' => [
       'results_lifespan' => 900, // 15 分钟
       'results_lifespan_custom' => 0,
       'results_lifespan_granularity' => 1000,
     ],
   ]);
   ```

3. **权限控制**：
   - 基于角色的访问控制
   - 基于内容的访问控制
   - 基于上下文的访问控制

4. **多语言支持**：
   - 启用语言筛选器
   - 配置语言回退
   - 翻译视图标签

**参考**：
- https://www.drupal.org/docs/7/howtos/book-drupal-7-the-essentials/part-b-information-structure-in-drupal/10-advanced-views-configuration

---

## 4. 实际案例

### 4.1 企业网站案例

**需求**：
- 公司新闻
- 产品服务
- 客户案例
- 联系我们

**内容类型设计**：

```yaml
# 新闻
news:
  fields:
    - title
    - body
    - field_image
    - field_category
    - field_tags
    - field_publish_date
    
# 产品
product:
  fields:
    - title
    - body
    - field_images (多张)
    - field_category
    - field_specifications (段落)
    - field_documents (文件下载)
    
# 案例
case_study:
  fields:
    - title
    - field_client (文本)
    - field_challenge (富文本)
    - field_solution (富文本)
    - field_results (富文本)
    - field_images
    - field_testimonial (引用)
```

**Views 配置**：

```yaml
# 新闻列表
news_list:
  type: page
  path: /news
  style: grid (3 列)
  pager: full (10 项/页)
  filters:
    - status (published)
    - type (news)
    - field_category (暴露)
  sorts:
    - field_publish_date (DESC)
    
# 产品目录
product_catalog:
  type: page
  path: /products
  style: grid (4 列)
  pager: full (12 项/页)
  filters:
    - status
    - type
    - field_category (暴露，多选)
  sorts:
    - title (ASC)
```

**参考**：
- https://www.drupal.org/docs/user_guide/en/planning-structure.html

---

### 4.2 电子商务网站案例

**需求**：
- 产品目录
- 产品分类
- 产品搜索
- 相关产品

**内容类型设计**：

```yaml
# 产品
product:
  fields:
    - title
    - field_sku
    - field_description
    - field_price
    - field_sale_price
    - field_images
    - field_category
    - field_attributes (颜色、尺寸)
    - field_stock
    - field_related_products
    
# 产品评论
product_review:
  fields:
    - title
    - field_product (引用)
    - field_rating (1-5)
    - field_review (富文本)
    - field_reviewer_name
    - field_verified_purchase (布尔)
```

**Views 配置**：

```yaml
# 产品搜索
product_search:
  type: page
  path: /products/search
  style: grid
  exposed_filters:
    - search_api_fulltext (关键词)
    - field_category (分类)
    - field_price (价格范围)
    - field_attributes (属性)
  sorts:
    - search_api_relevance (默认)
    - field_price (可选)
    - title (可选)
    
# 相关产品块
related_products:
  type: block
  style: grid (4 列)
  filters:
    - field_category (与当前产品相同)
    - nid (排除当前产品)
  limit: 8
  sort: random
```

**参考**：
- https://www.drupal.org/docs/7/howtos/book-drupal-7-the-essentials/part-b-information-structure-in-drupal

---

### 4.3 教育网站案例

**需求**：
- 课程目录
- 教师档案
- 学生作品
- 活动日历

**内容类型设计**：

```yaml
# 课程
course:
  fields:
    - title
    - field_code
    - field_description
    - field_instructor (引用教师)
    - field_credits
    - field_schedule (段落：时间、地点)
    - field_syllabus (文件)
    - field_prerequisites (引用课程)
    
# 教师
faculty:
  fields:
    - title (姓名)
    - field_photo
    - field_title (职称)
    - field_department (分类)
    - field_bio (富文本)
    - field_courses (引用课程)
    - field_publications (文本长)
    - field_contact_email
    
# 活动
event:
  fields:
    - title
    - field_date_start
    - field_date_end
    - field_location
    - field_description
    - field_image
    - field_registration_link
```

**Views 配置**：

```yaml
# 课程目录
course_catalog:
  type: page
  path: /courses
  style: table
  fields:
    - field_code
    - title
    - field_instructor
    - field_credits
    - field_department
  exposed_filters:
    - field_department
    - field_credits
  sorts:
    - field_code (ASC)
    
# 活动日历
event_calendar:
  type: page
  path: /events
  style: calendar (使用 Calendar 模块)
  filters:
    - field_date_start (>= today)
  sorts:
    - field_date_start (ASC)
```

**参考**：
- https://www.drupal.org/docs/user_guide/en/structure-fields.html

---

## 附录：内容建模检查清单

### 设计阶段

- [ ] 识别所有业务实体
- [ ] 定义内容类型列表
- [ ] 规划每个类型的字段
- [ ] 设计显示模式
- [ ] 规划 Views 需求

### 实施阶段

- [ ] 创建内容类型
- [ ] 添加字段
- [ ] 配置字段验证
- [ ] 设置显示模式
- [ ] 创建 Views
- [ ] 配置权限

### 测试阶段

- [ ] 测试内容创建
- [ ] 测试内容编辑
- [ ] 测试内容显示
- [ ] 测试 Views 筛选
- [ ] 测试权限控制
- [ ] 性能测试

### 优化阶段

- [ ] 收集用户反馈
- [ ] 分析使用数据
- [ ] 优化字段配置
- [ ] 调整 Views 性能
- [ ] 更新文档

---

*文档来源：Drupal 官方文档 (https://www.drupal.org/docs)*
