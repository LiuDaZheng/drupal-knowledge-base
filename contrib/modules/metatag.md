---
name: drupal-metatag
description: Complete guide to Drupal Metatag module. Covers SEO meta tags, Open Graph, Twitter Cards, schema.org, and search engine optimization for Drupal 11.
---

# Drupal Metatag SEO 模块完整指南

**版本**: 1.x  
**Drupal 版本**: 10.x, 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-05  

---

## 📖 模块概述

### 简介
**Metatag** 是 Drupal 的核心 SEO 模块，提供全面的元数据标记功能，帮助网站优化搜索引擎表现。支持 Open Graph、Twitter Cards、Schema.org 等现代 Web 标准。

### 核心功能
- ✅ 自动 Meta 标签管理
- ✅ Open Graph 集成
- ✅ Twitter Cards 支持
- ✅ Schema.org/RDFa 标记
- ✅ 分页优化
- ✅ 自定义标签模板
- ✅ 页面级和节点级配置
- ✅ 多语言支持

### 适用场景
- ✅ 所有 SEO 优化
- ✅ 社交媒体分享优化
- ✅ 智能卡片展示
- ✅ 结构化数据标记
- ✅ 搜索引擎可见性提升

---

## 🚀 安装与配置

### 1. 安装方式

#### Composer 安装
```bash
# 安装 Metatag 核心模块
composer require drupal/metatag

# 安装常用扩展
composer require drupal/metatag_open_graph
composer require drupal/metatag_twitter_cards
composer require drupal/metatag_schema_org

# 启用模块
drush pm:install metatag metatag_open_graph metatag_twitter_cards metatag_schema_org
```

#### Drush 安装
```bash
# 下载元数据模块
drush dl metatag

# 启用核心模块
drush pm:install metatag
```

### 2. 基础设置

#### 全局配置
```yaml
# /admin/config/search/metatag

# 站点元标签设置
site_settings:
  title: {site:name} | {site:logo}
  description: {site:description}
  keywords:  Drupal, CMS, Content Management
  
  # SEO 优化
  canonical: '<front>'  # 规范链接
  robots: index, follow  # SEO 友好
  
  # 社交媒体
  og_site_name: {site:name}
  og_title: {node:title} - {site:name}
  og_description: {node:summary}
  og_image: {site:logo}
  og_type: website
```

#### 标签模板
```yaml
# 定义标签模板
meta_tags:
  - name: description
    tag: meta
    attributes:
      name: description
      content: {node:summary}
    conditions:
      - entity_bundle: node
      - node_type: article

  - name: keywords
    tag: meta
    attributes:
      name: keywords
      content: {node:tags}

  - property: og:title
    tag: meta
    attributes:
      property: og:title
      content: {node:title}

  - property: og:description
    tag: meta
    attributes:
      property: og:description
      content: {node:summary}

  - property: og:image
    tag: meta
    attributes:
      property: og:image
      content: {node:image}

  - name: twitter:card
    tag: meta
    attributes:
      name: twitter:card
      content: summary_large_image

  - name: twitter:title
    tag: meta
    attributes:
      name: twitter:title
      content: {node:title}

  - name: twitter:description
    tag: meta
    attributes:
      name: twitter:description
      content: {node:summary}
```

# 3. 内容类型配置

## 文章元标签
```yaml
article_meta:
  og_image:
    field: field_featured_image
    weight: -10
  
  og_title:
    pattern: '{node:title} - {bundle:name} | {site:name}'
  
  og_description:
    pattern: '{node:summary}'
  
  og_type: article
  twitter_card: summary_large_image
  
  schema_org_article:
    headline: '{node:title}'
    author: '{node:author}'
    datePublished: '{node:created}'
    image: '{node:image}'
```

## 产品元标签
```yaml
product_meta:
  og_type: product
  og_image: '{node:image}'
  og_price: '{node:price:amount}'
  og_price_currency: CNY
  availability: in_stock
  
  schema_org_product:
    name: '{node:title}'
    offers:
      price: '{node:price}'
      availability: http://schema.org/InStock
      url: '{node:url}'
```

---

## ⚙️ 核心功能配置

### 1. Open Graph 集成

#### OG 标签
```yaml
open_graph:
  - property: og:site_name
    tag: meta
    attributes:
      property: og:site_name
      content: '{site:name}'
  
  - property: og:title
    tag: meta
    attributes:
      property: og:title
      content: '{node:title}'
  
  - property: og:description
    tag: meta
    attributes:
      property: og:description
      content: '{node:summary}'
  
  - property: og:url
    tag: meta
    attributes:
      property: og:url
      content: '<canonical>'
  
  - property: og:type
    tag: meta
    attributes:
      property: og:type
      content: 'website'  # 或 article, product, book
  
  - property: og:image
    tag: meta
    attributes:
      property: og:image
      content: '{node:image:0:uri}'
  
  - property: og:image:secure_url
    tag: meta
    attributes:
      property: og:image:secure_url
      content: '{node:image:0:uri}'
  
  - property: og:image:alt
    tag: meta
    attributes:
      property: og:image:alt
      content: '{node:image:0:alt}'
  
  - property: og:locale
    tag: meta
    attributes:
      property: og:locale
      content: '{node:language:default:language-id}'
```

#### OG 扩展标签
```yaml
# 文章类型 OG
article_og:
  og:type: article
  og:article:published_time: '{node:created}'
  og:article:modified_time: '{node:changed}'
  og:article:author: '{node:author}'
  og:article:section: '{node:term:category}'

# 产品类型 OG
product_og:
  og:type: product
  og:price:amount: '{node:price:amount}'
  og:price:currency: CNY
  og:availability: in_stock
```

### 2. Twitter Cards 集成

#### 基础卡片
```yaml
twitter_cards:
  # 摘要卡片
  - name: twitter:card
    tag: meta
    attributes:
      name: twitter:card
      content: summary
  
  # 大图卡片
  - name: twitter:card
    tag: meta
    attributes:
      name: twitter:card
      content: summary_large_image
  
  # 标题
  - name: twitter:title
    tag: meta
    attributes:
      name: twitter:title
      content: '{node:title}'
  
  # 描述
  - name: twitter:description
    tag: meta
    attributes:
      name: twitter:description
      content: '{node:summary}'
  
  # 图片
  - name: twitter:image
    tag: meta
    attributes:
      name: twitter:image
      content: '{node:image:0:uri}'
  
  # 创建者
  - name: twitter:creator
    tag: meta
    attributes:
      name: twitter:creator
      content: '{site:twitter:handle}'
  
  # App ID
  - name: twitter:app:iphone:id
    tag: meta
    attributes:
      name: twitter:app:iphone:id
      content: '123456789'
```

#### Twitter 高级卡片
```yaml
# App 卡片
twitter_app:
  - name: twitter:card
    content: app
  
  - name: twitter:app:name:iphone
    content: '我的品牌'
  
  - name: twitter:app:id:iphone
    content: '123456789'
  
  - name: twitter:url
    content: '<canonical>'

# Player 卡片
twitter_player:
  - name: twitter:card
    content: player
  
  - name: twitter:player
    content: '{node:video:uri}'
  
  - name: twitter:player:width
    content: '640'
  
  - name: twitter:player:height
    content: '360'
```

### 3. Schema.org 集成

#### 基础 Schema.org
```yaml
schema_org:
  - itemprop: 'name'
    tag: meta
    attributes:
      itemprop: name
      content: '{node:title}'
  
  - itemprop: 'description'
    tag: meta
    attributes:
      itemprop: description
      content: '{node:summary}'
  
  - type: 'schema:WebPage'
    tag: meta
    attributes:
      typeof: schema:WebPage
  
  - property: 'schema:url'
    tag: link
    attributes:
      rel: canonical
      href: '<canonical>'
```

#### 文章内容 Schema
```yaml
article_schema:
  - type: 'schema:Article'
    attribute: typeof
  
  - itemprop: 'headline'
    content: '{node:title}'
  
  - itemprop: 'articleBody'
    tag: meta
    attributes:
      itemprop: articleBody
      content: '{node:body:value}'
  
  - itemprop: 'datePublished'
    tag: meta
    attributes:
      itemprop: datePublished
      content: '{node:created,date:Y-m-d}'
  
  - itemprop: 'dateModified'
    tag: meta
    attributes:
      itemprop: dateModified
      content: '{node:changed,date:Y-m-d}'
  
  - type: 'schema:Person'
    itemprop: 'author'
  
  - itemprop: 'author:name'
    content: '{node:author:name}'
  
  - itemprop: 'author:url'
    content: '{node:author:url}'
  
  - itemprop: 'publisher'
    type: 'schema:Organization'
  
  - itemprop: 'publisher:name'
    content: '{site:name}'

# 图片 Schema
article_image_schema:
  - type: 'schema:ImageObject'
    itemprop: 'image'
  
  - itemprop: '@id'
    content: '{node:image:0:url}'
  
  - itemprop: 'url'
    content: '{node:image:0:url}'
  
  - itemprop: 'caption'
    content: '{node:image:0:caption}'
```

### 4. 自定义标签

#### SEO 扩展标签
```yaml
seo_tags:
  # 规范链接
  - name: 'canonical'
    tag: link
    attributes:
      rel: canonical
      href: '<canonical>'
  
  # 作者
  - name: 'author'
    tag: meta
    attributes:
      name: author
      content: '{node:author}'
  
  # 主题
  - name: 'theme-color'
    tag: meta
    attributes:
      name: theme-color
      content: '#123456'
  
  # 分类
  - name: 'article:section'
    tag: meta
    attributes:
      property: article:section
      content: '{node:term:category}'
  
  # 关键字
  - name: 'keywords'
    tag: meta
    attributes:
      name: keywords
      content: '{node:tags}'
  
  # 语言
  - name: 'dc.language'
    tag: meta
    attributes:
      name: dc.language
      content: '{node:language:default:language-id}'
  
  # 机器人
  - name: 'robots'
    tag: meta
    attributes:
      name: robots
      content: 'index, follow'
```

#### 分页优化标签
```yaml
pagination_tags:
  # 分页链接
  - rel: next
    href: '<page:url>|@pager_next|pager_current_page>'
  
  - rel: prev
    href: '<page:url>|@pager_prev|pager_current_page>'
  
  # 规范链接
  - name: 'canonical'
    href: '<canonical>'
```

### 5. 页面级配置

#### 首页配置
```yaml
homepage_meta:
  og_type: website
  title: '<front:title>'
  description: '{site:description}'
  robots: index, follow
  
  twitter_card: summary_large_image
  
  schema_org:
    '@type': 'WebSite'
    name: '{site:name}'
    url: '<front:url>'
```

#### 404 页面配置
```yaml
page_404_meta:
  robots: noindex, nofollow
  og_type: error_page
  title: '404 - Page Not Found'
  description: '抱歉，您访问的页面不存在。'
  
  twitter_card: summary
  twitter:title: '404 - Page Not Found'
  twitter:description: '抱歉，您访问的页面不存在。'
```

---

## 💻 开发示例

### 1. Metatag API

#### 获取元标签
```php
/**
 * 获取节点的元标签
 */
function get_node_metatags($node_id) {
  $node = \Drupal\node\Entity\Node::load($node_id);
  
  if (!$node) {
    return [];
  }
  
  $metatag_helper = \Drupal::service('metatag.metatag_helper');
  $context = $metatag_helper->buildContext($node);
  
  return $metatag_helper->toTags($context);
}

/**
 * 获取特定标签
 */
function get_metatag_tag($tag_name, $context = NULL) {
  $metatag_helper = \Drupal::service('metatag.metatag_helper');
  $tag = $metatag_helper->getTag($tag_name);
  
  if ($context) {
    $tag_values = $metatag_helper->replaceTagsWithTokens($tag, $context);
    return $tag_values;
  }
  
  return $tag;
}
```

#### 设置元标签
```php
/**
 * 添加自定义元标签
 */
function add_custom_metatag($tag_name, $tag_value, $context = NULL) {
  $metatag_helper = \Drupal::service('metatag.metatag_helper');
  
  $tag_definition = [
    'name' => $tag_name,
    'tag' => 'meta',
    'attributes' => [
      'name' => $tag_name,
      'content' => $tag_value,
    ],
  ];
  
  $metatag_helper->add($tag_definition, $context);
}

/**
 * 动态设置 OG 标签
 */
function set_dynamic_open_graph($node_id) {
  $node = \Drupal\node\Entity\Node::load($node_id);
  
  $context = [
    'entity' => $node,
    'node' => $node,
  ];
  
  // 设置OG 标签
  add_custom_metatag('og:title', $node->getTitle());
  add_custom_metatag('og:description', $node->getBody()->getValue());
  add_custom_metatag('og:url', $node->toUrl('canonical')->toString());
  add_custom_metatag('og:image', $node->getImage()->uri);
}
```

### 2. 自定义 Meta 模块

#### 创建 Metatag 插件
```php
<?php

namespace Drupal\mymodule\Plugin\Metatag;

use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Plugin\ContainerFactoryPluginInterface;
use Drupal\metatag\Plugin\MetaTagInterface;

/**
 * Provides a 'SEO Tags' Tag group of meta tags.
 *
 * @MetaTagGroup(
 *   id = "my_seo_tags",
 *   label = @Translation("我的 SEO 标签"),
 *   description = @Translation("自定义 SEO 标签")
 * )
 */
class MySeoTags implements MetaTagInterface, ContainerFactoryPluginInterface {
  
  /**
   * The entity type manager.
   *
   * @var \Drupal\Core\Entity\EntityTypeManagerInterface
   */
  protected $entityTypeManager;
  
  /**
   * {@inheritdoc}
   */
  public function __construct(array $configuration, $plugin_id, $plugin_definition, EntityTypeManagerInterface $entity_type_manager) {
    parent::__construct($configuration, $plugin_id, $plugin_definition);
    $this->entityTypeManager = $entity_type_manager;
  }
  
  /**
   * 生成自定义 SEO 标签
   */
  public function getMetaTags() {
    return [
      'seocompany' => [
        'name' => 'seocompany',
        'tag' => 'meta',
        'label' => 'Company Name',
        'group' => 'seo',
        'weight' => -10,
      ],
      'seokeywords' => [
        'name' => 'seokeywords',
        'tag' => 'meta',
        'label' => 'SEO Keywords',
        'group' => 'seo',
        'weight' => -9,
        'tokens' => TRUE,
      ],
      'seodescription' => [
        'name' => 'seodescription',
        'tag' => 'meta',
        'label' => 'SEO Description',
        'group' => 'seo',
        'weight' => -8,
        'tokens' => TRUE,
      ],
    ];
  }
  
  /**
   * 替换标签中的 tokens
   */
  public static function replaceTags($tag, $context = []) {
    $tags = parent::replaceTags($tag, $context);
    
    // 自定义替换逻辑
    if ($tag == 'seo_keywords') {
      $tags['content'] = $tags['content'] . ', 自定义关键词';
    }
    
    return $tags;
  }
}
```

#### 创建 Token 扩展
```php
<?php

namespace Drupal\mymodule\Plugin\Metatag\Tag;

use Drupal\metatag\Plugin\MetaTagBase;

/**
 * Provides a 'Meta company' tag.
 *
 * @MetaTag(
 *   id = "meta_company",
 *   label = @Translation("Company Name"),
 *   description = @Translation("显示公司名称"),
 *   card_type = "meta"
 * )
 */
class MetaCompany extends MetaTagBase {
  
  /**
   * {@inheritdoc}
   */
  public function generate() {
    return \Drupal::config('system.site')->get('name');
  }
}
```

### 3. 批量元标签管理

#### 配置元标签
```php
/**
 * 批量设置节点的元标签
 */
function bulk_set_node_metatags($node_ids, $metatags) {
  $metatag_helper = \Drupal::service('metatag.metatag_helper');
  
  foreach ($node_ids as $node_id) {
    $node = \Drupal\node\Entity\Node::load($node_id);
    
    if (!$node) {
      continue;
    }
    
    // 设置元标签
    foreach ($metatags as $key => $value) {
      $metatag_helper->set($node, $key, $value);
    }
    
    $node->save();
  }
}

/**
 * 导出元标签配置
 */
function export_metatag_configuration() {
  $exporter = \Drupal::entityTypeManager()->getStorage('metatag_group')->exportAll();
  
  return $exporter;
}

/**
 * 导入元标签配置
 */
function import_metatag_configuration($config) {
  $importer = \Drupal::entityTypeManager()->getStorage('metatag_group')->importConfiguration($config);
  
  return $importer;
}
```

---

## 🎯 最佳实践

### 1. SEO 优化

#### 标题优化
```yaml
# ✅ 好的标题结构
page_title: '{node:title} - 产品名称 | 站点名称'

# ❌ 避免
page_title: '{site:name} | {node:title}'
```

#### 描述优化
```yaml
# ✅ 好的描述
meta_description: '简短描述，包含关键信息，不超过 160 字符。'

# ❌ 避免
meta_description: '{node:body}'  # 内容过长
```

#### 图片优化
```yaml
# ✅ 使用 SEO 友好的图片
og_image: {node:image:0:url}  # 高质量图片
image_alt: '{node:image:0:alt}'  # 包含关键字的 alt 文本

# ❌ 避免
og_image: ''  # 无图片
```

### 2. 性能优化

#### 缓存策略
```php
/**
 * 元标签缓存
 */
function cache_metatag($context) {
  $cache_backend = \Drupal::cache();
  $cache_tag = 'metatag_' . $context['entity']->id();
  
  $cached = $cache_backend->get($cache_tag);
  
  if ($cached) {
    return $cached->data;
  }
  
  // 生成元标签
  $metatags = generate_metatags($context);
  
  // 缓存结果
  $cache_backend->set($cache_tag, $metatags, CacheBackendInterface::CACHE_PERMANENT, [
    $metatag, 'entity',
  ]);
  
  return $metatags;
}
```

### 3. 多语言支持

#### 多语言标签
```yaml
multilingual_meta:
  - name: 'dc.language'
    value: '{node:language:default:language-id}'
    condition: 'node:language:default:language-id:langcode'
  
  - property: 'og:locale'
    value: '{node:language:default:language-id}'

# 翻译元标签
translatable_meta:
  title: '{i18n:node:title}'
  description: '{i18n:node:summary}'
```

### 4. 社交媒体优化

#### Facebook 优化
```yaml
facebook_meta:
  og:app_id: 123456789  # Facebook App ID
  og:url: '<canonical>'
  og:site_name: '{site:name}'
  og:title: '{node:title}'
  og:description: '{node:summary}'
  og:image: '{node:image}'
  og:type: article
```

#### LinkedIn 优化
```yaml
linkedin_meta:
  og:title: '{node:title}'
  og:description: '{node:summary}'
  og:image: '{node:image}'
  og:url: '<canonical>'
```

---

## 📊 常见问题 (FAQ)

### Q1: 如何测试元标签？
**A**: 
- 使用 Google Rich Results Test
- 使用 Facebook Debugger
- 使用 Twitter Card Validator

### Q2: 元标签不生效怎么办？
**A**: 
- 清除缓存
- 检查配置
- 验证标签优先级

### Q3: 如何自定义 OG 图片？
**A**: 
- 使用自定义字段
- 设置默认图片
- 使用条件逻辑

### Q4: 多语言站点如何处理？
**A**: 
- 为每个语言配置元标签
- 使用语言特定模板
- 设置 hreflang 标签

### Q5: Schema.org 数据怎么添加？
**A**: 
- 使用 Schema.org 模块
- 自定义 Meta 标签
- 使用 JSON-LD

---

## 🔗 相关链接

- [Drupal Metatag 官方文档](https://www.drupal.org/docs/8/core-modules-and-contributed-modules/core-module/metatag)
- [Metatag API](https://api.drupal.org/api/drupal/modules!metatag!metatag.api.php)
- [Schema.org](https://schema.org/)
- [Open Graph Protocol](https://ogp.me/)
- [Twitter Cards](https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards)

---

## 📝 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| 1.x | 2026-04-05 | 初始化文档 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-05
