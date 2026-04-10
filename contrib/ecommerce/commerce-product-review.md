---
name: commerce-product-review
description: Complete guide to Commerce Product Review for customer reviews, ratings, and feedback.
---

# Commerce Product Review - 产品评论系统 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Product Review 是 Drupal Commerce 的用户反馈和评价管理系统，允许客户对产品进行评分、撰写评论、上传图片和视频，帮助其他买家做出购买决策，同时为企业收集用户反馈提供完整的数据支持。

### 核心功能
- ✅ **星级评分系统** - 支持 1-5 星或自定义评分范围
- ✅ **文本评论** - 详细的文字评价和内容
- ✅ **评论审核工作流** - 管理员可设置自动审批或人工审核
- ✅ **点赞/反对机制** - "有用"/"无用"投票系统
- ✅ **已购买验证标签** - 认证购买者标识
- ✅ **SEO 结构化数据** - Schema.org Rich Snippets 支持
- ✅ **图片/视频上传** - 多媒体评论内容
- ✅ **评论回复** - 用户之间和管理员的互动
- ✅ **评论举报** - 不当内容快速报告
- ✅ **评分聚合统计** - 平均评分、评论数量等

### 适用场景
- B2C 电商（所有商品类型）
- 高客单价商品（需要信任建设）
- 数字内容和软件产品
- 服务类电商平台
- UGC 内容驱动型网站
- 跨境电商（多语言评论）

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- File module enabled
- User module enabled

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装评论模块
composer require drupal/product_review

# 启用相关模块
drush en product_review user_comments --yes

# 更新数据库
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块
drush dl product_review

# 2. 启用模块
drush en product_review --yes

# 3. 运行数据库更新
drush updatedb --yes
```

---

## ⚙️ 基础配置

### 1. 启用模块

```bash
drush en product_review --yes
```

### 2. 创建评论字段

在产品类型中添加工能评论字段：

```
路径：/admin/structure/content-type/manage/shop_product/manage/fields
→ Add field → Text / Number
→ Field type: Comment
→ Widget: Text area / Star rating
```

或通过 Drush：
```bash
drush ciff:add-field product [product-type] comments comment \
  --label="Product Reviews" \
  --widget=textarea \
  --required=no
```

### 3. 配置评分系统

```
路径：/admin/config/store/reviews/settings
```

| 选项 | 默认值 | 说明 |
|------|--------|------|
| Enable reviews | ✅ Yes | 启用评论功能 |
| Require purchase verification | ❌ No | 必须购买后评论 |
| Rating scale | 5 | 评分等级（1-5） |
| Min review length | 20 | 最少字数要求 |
| Allow images | ✅ Yes | 允许上传图片 |
| Max images per review | 3 | 每条评论最多图片数 |
| Auto approve | ❌ No | 不自动审批 |

### 4. 设置审核流程

```yaml
moderation_settings:
  auto_approve_conditions:
    verified_purchase: true
    positive_history: true
  manual_review_required:
    first_review: true
    contains_links: true
    flag_keywords: ['spam', 'promo']
  moderator_assignments:
    default_moderator: 'admin'
    category_specific:
      electronics: 'tech_moderator'
      fashion: 'fashion_moderator'
```

### 5. 配置邮件通知

```
/admin/config/system/mail/product_review
```

| 通知类型 | 收件人 | 触发时机 |
|---------|--------|---------|
| New review notification | Admin | 新评论提交 |
| Reply notification | Original reviewer | 收到回复 |
| Helpful notification | Review author | 获得有用票 |

---

## 💻 代码示例

### 1. 添加商品评论

```php
use Drupal\product_review\Entity\ReviewInterface;
use Drupal\commerce_order\Entity\OrderItem;

/**
 * 提交产品评论
 */
function submit_product_review(ProductVariation $variation, array $data) {
  $user = \Drupal::currentUser();
  
  // 验证权限
  if (!$user->hasPermission('post product reviews')) {
    throw new AccessDeniedException('You do not have permission to post reviews.');
  }
  
  // 检查是否已评论过该产品
  $existing = \Drupal::entityTypeManager()
    ->getStorage('product_review')
    ->loadByProperties([
      'reviewer_id' => $user->id(),
      'variation_id' => $variation->id(),
    ]);
  
  if (!empty($existing)) {
    throw new \Exception('You have already reviewed this product.');
  }
  
  // 验证评论长度
  if (strlen($data['comment']) < 20) {
    throw new \Exception('Review must be at least 20 characters long.');
  }
  
  // 创建评论实体
  $review = ReviewInterface::create([
    'revision_user' => $user->id(),
    'status' => \Drupal\product_review\Entity\Review::PENDING,
    'rating' => max(1, min(5, $data['rating'])), // 确保在 1-5 范围内
    'comment' => $data['comment'],
    'variation_id' => $variation->id(),
    'purchase_verified' => check_purchase_verification($user, $variation),
    'helpful_count' => 0,
    'not_helpful_count' => 0,
  ]);
  
  // 保存评论
  $review->save();
  
  // 处理附件（如图片）
  if (!empty($data['images'])) {
    process_review_attachments($review, $data['images']);
  }
  
  // 发送通知
  send_new_review_notification($review);
  
  return $review;
}

/**
 * 检查购买验证
 */
function check_purchase_verification(UserInterface $user, ProductVariation $variation) {
  $order_items = \Drupal::entityTypeManager()
    ->getStorage('commerce_order_item')
    ->getQuery()
    ->condition('uid', $user->id())
    ->condition('status', 'completed')
    ->execute();
  
  foreach ($order_items as $order_item_id) {
    $item = OrderItem::load($order_item_id);
    if ($item->getProductVariation()->id() === $variation->id()) {
      return TRUE;
    }
  }
  
  return FALSE;
}
```

### 2. 有用/无用投票

```php
/**
 * 标记评论为有用/无用
 */
function vote_on_review(ReviewInterface $review, $vote_type, UserInterface $voter) {
  $vote_types = ['helpful', 'not_helpful'];
  
  if (!in_array($vote_type, $vote_types)) {
    throw new \InvalidArgumentException('Invalid vote type');
  }
  
  // 检查投票历史
  $votes = \Drupal::entityTypeManager()
    ->getStorage('product_review_vote')
    ->loadByProperties([
      'review_id' => $review->id(),
      'voter_id' => $voter->id(),
    ]);
  
  if (!empty($votes)) {
    $vote = reset($votes);
    
    // 如果改变投票，更新计数
    if ($vote->getVoteType() !== $vote_type) {
      decrement_vote_count($review, $vote->getVoteType());
      increment_vote_count($review, $vote_type);
      
      $vote->setVoteType($vote_type);
      $vote->save();
    }
    
    return;
  }
  
  // 首次投票
  $new_vote = \Drupal::entityTypeManager()
    ->getStorage('product_review_vote')
    ->create([
      'review_id' => $review->id(),
      'voter_id' => $voter->id(),
      'vote_type' => $vote_type,
      'created' => REQUEST_TIME,
    ]);
  
  $new_vote->save();
  increment_vote_count($review, $vote_type);
}

/**
 * 增加投票计数
 */
function increment_vote_count(ReviewInterface $review, $type) {
  if ($type === 'helpful') {
    $review->setHelpfulCount($review->getHelpfulCount() + 1);
  } else {
    $review->setNotHelpfulCount($review->getNotHelpfulCount() + 1);
  }
  $review->save();
}

/**
 * 减少投票计数
 */
function decrement_vote_count(ReviewInterface $review, $type) {
  if ($type === 'helpful') {
    $review->setHelpfulCount(max(0, $review->getHelpfulCount() - 1));
  } else {
    $review->setNotHelpfulCount(max(0, $review->getNotHelpfulCount() - 1));
  }
  $review->save();
}
```

### 3. SEO 结构化数据生成

```php
/**
 * 为产品页面添加 Schema.org 评论结构化数据
 */
function mymodule_page_add_markup(array &$build, \Drupal\Core\Page\AssetAttachments $asset_attachments) {
  $node = \Drupal::routeMatch()->getParameter('node');
  
  if (!$node || !$node->hasField('comments')) {
    return;
  }
  
  $reviews = $node->getCommentField()->referencedEntities();
  
  if (empty($reviews)) {
    return;
  }
  
  $schema_data = [
    '@context' => 'https://schema.org/',
    '@type' => 'Product',
    'aggregateRating' => [
      '@type' => 'AggregateRating',
      'ratingValue' => get_average_rating($reviews),
      'reviewCount' => count($reviews),
      'bestRating' => 5,
      'worstRating' => 1,
    ],
    'review' => array_map(function($review) {
      return [
        '@type' => 'Review',
        'author' => [
          '@type' => 'Person',
          'name' => $review->getOwner()->getDisplayName(),
        ],
        'datePublished' => date('Y-m-d', $review->getCreated()),
        'reviewBody' => strip_tags($review->getText()->value),
        'reviewRating' => [
          '@type' => 'Rating',
          'bestRating' => 5,
          'ratingValue' => $review->getRating(),
        ],
        ...( $review->isVerifiedPurchase() ? [
          'proofOfPurchase' => 'Verified Purchase'
        ] : []),
      ];
    }, $reviews),
  ];
  
  $build['#attached']['jsonld'][] = $schema_data;
}

/**
 * 计算平均评分
 */
function get_average_rating($reviews) {
  if (empty($reviews)) {
    return 0;
  }
  
  $total_rating = array_sum(array_map(function($review) {
    return $review->getRating();
  }, $reviews));
  
  return round($total_rating / count($reviews), 1);
}
```

### 4. Twig 模板 - 评论列表展示

```twig
{# templates/review/list.html.twig #}
<div class="product-reviews">
  <div class="reviews-header">
    <h2>Customer Reviews ({{ total_reviews }})</h2>
    
    <div class="rating-summary">
      <span class="overall-rating">{{ average_rating }}</span>
      <div class="star-rating">
        {% for star in 1..5 %}
          {% if star <= average_rating %}
            <i class="fas fa-star"></i>
          {% else %}
            <i class="far fa-star"></i>
          {% endif %}
        {% endfor %}
      </div>
      <span class="count">(Based on {{ total_reviews }} reviews)</span>
    </div>
    
    <a href="#write-review" class="btn btn-primary">Write a Review</a>
  </div>
  
  {% if total_reviews > 0 %}
    <div class="filter-sort">
      <select id="sort-reviews">
        <option value="newest">Newest First</option>
        <option value="oldest">Oldest First</option>
        <option value="highest">Highest Rated</option>
        <option value="lowest">Lowest Rated</option>
        <option value="helpful">Most Helpful</option>
      </select>
      
      <select id="filter-rating">
        <option value="">All Ratings</option>
        <option value="5">⭐⭐⭐⭐⭐ (5 Stars)</option>
        <option value="4">⭐⭐⭐⭐ (4 Stars)</option>
        <option value="3">⭐⭐⭐ (3 Stars)</option>
        <option value="2">⭐⭐ (2 Stars)</option>
        <option value="1">⭐ (1 Star)</option>
      </select>
    </div>
    
    <div class="rating-breakdown">
      <div class="bar-container">
        <span class="label">5 stars</span>
        <div class="bar">
          <div class="fill" style="width: {{ five_star_percentage }}%"></div>
        </div>
        <span class="count">{{ five_star_count }}</span>
      </div>
      
      {% for i in 4..1 %}
        <div class="bar-container">
          <span class="label">{{ i }} stars</span>
          <div class="bar">
            <div class="fill" style="width: {{ i ~'_star_percentage'}}%"></div>
          </div>
          <span class="count">{{ i ~'_star_count' }}</span>
        </div>
      {% endfor %}
    </div>
    
    <div class="review-list">
      {% for review in reviews %}
        <article class="review-item" id="review-{{ review.id }}">
          <div class="review-header">
            <div class="reviewer-info">
              <img src="{{ review.author.avatar }}" alt="{{ review.author.name }}" width="40" height="40">
              <div class="info">
                <strong>{{ review.author.name }}</strong>
                {% if review.is_verified_purchase %}
                  <span class="badge verified-purchase" title="Verified Purchase">✅ Verified Purchase</span>
                {% endif %}
                <span class="date">{{ review.created|date('F d, Y') }}</span>
              </div>
            </div>
            
            <div class="star-rating-mini">
              {% for star in 1..5 %}
                {% if star <= review.rating %}
                  <i class="fas fa-star text-warning"></i>
                {% else %}
                  <i class="far fa-star"></i>
                {% endif %}
              {% endfor %}
            </div>
          </div>
          
          <div class="review-content">
            <h3 class="review-title">{{ review.title }}</h3>
            <p class="review-text">{{ review.text|striptags|raw }}</p>
            
            {% if review.images is not empty %}
              <div class="review-images">
                {% for image in review.images %}
                  <img src="{{ image.uri }}" alt="User uploaded image" class="review-image">
                {% endfor %}
              </div>
            {% endif %}
          </div>
          
          <div class="review-footer">
            <div class="helpfulness">
              <button class="btn-helpful" data-review-id="{{ review.id }}">
                👍 Helpful ({{ review.helpful_count }})
              </button>
              <button class="btn-not-helpful" data-review-id="{{ review.id }}">
                👎 Not Helpful ({{ review.not_helpful_count }})
              </button>
            </div>
            
            <button class="btn-report" data-review-id="{{ review.id }}">Report</button>
            <button class="btn-reply">Reply</button>
          </div>
          
          {% if review.replies is not empty %}
            <div class="replies">
              {% for reply in review.replies %}
                <div class="reply-item">
                  <strong>{{ reply.author.name }}</strong>
                  <span class="reply-date">{{ reply.created|date('F d, Y') }}</span>
                  <p>{{ reply.text }}</p>
                </div>
              {% endfor %}
            </div>
          {% endif %}
        </article>
      {% endfor %}
    </div>
    
    <div class="pagination">
      {{ pagination }}
    </div>
  {% else %}
    <div class="no-reviews">
      <p>No reviews yet. Be the first to review this product!</p>
      <a href="#write-review" class="btn btn-primary">Write a Review</a>
    </div>
  {% endif %}
</div>
```

---

## 📋 数据表结构

### commerce_product_comment (评论主表)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| cid | INT | PRIMARY KEY | 自增 ID |
| nid | INT | NOT NULL | 节点 ID（产品） |
| uid | INT | NOT NULL | 作者用户 ID |
| subject | VARCHAR(255) | NULLABLE | 评论标题 |
| message | LONGTEXT | NOT NULL | 评论内容 |
| rating | TINYINT | DEFAULT 0 | 评分（1-5） |
| status | TINYINT | DEFAULT 0 | 发布状态 |
| thread | INT | DEFAULT 0 | 线程 ID |
| created | INT | NOT NULL | 创建时间戳 |
| changed | INT | NOT NULL | 修改时间戳 |
| ip_address | VARCHAR(45) | NULLABLE | 提交 IP |

### commerce_product_comment_flag (有用/无用投票)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| fid | INT | PRIMARY KEY | 自增 ID |
| entity_type | VARCHAR(32) | NOT NULL | 实体类型 |
| entity_id | INT | NOT NULL | 实体 ID |
| flagger_id | INT | NOT NULL | 投票者 ID |
| flag_type | VARCHAR(50) | NOT NULL | 投票类型 |
| created | INT | NOT NULL | 投票时间 |

### commerce_product_report (举报记录)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| rid | INT | PRIMARY KEY | 自增 ID |
| review_id | INT | NOT NULL | 关联评论 ID |
| reporter_id | INT | NOT NULL | 举报者 ID |
| reason | VARCHAR(255) | NOT NULL | 举报原因 |
| details | TEXT | NULLABLE | 详细信息 |
| status | VARCHAR(20) | DEFAULT 'pending' | 处理状态 |
| resolved_by | INT | NULLABLE | 解决者 |
| resolved_at | DATETIME | NULLABLE | 解决时间 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\product_review\Unit\ReviewTest;

class ReviewSubmissionTest extends UnitTestCaseBase {
  
  public function testReviewWithValidData() {
    $user = $this->createUser();
    $product = $this->createTestProduct();
    
    $data = [
      'rating' => 5,
      'title' => 'Excellent product!',
      'message' => str_repeat('Great quality. ', 25), // 超过 20 字
      'verified_purchase' => TRUE,
    ];
    
    $review = submit_product_review($product, $user, $data);
    
    $this->assertEquals(5, $review->getRating());
    $this->assertTrue($review->isVerifiedPurchase());
    $this->assertEquals(\Drupal\product_review\Entity\Review::PENDING, $review->getStatus());
  }
  
  public function testReviewTooShort() {
    $user = $this->createUser();
    $product = $this->createTestProduct();
    
    $data = [
      'rating' => 4,
      'title' => 'Good',
      'message' => 'Good', // 只有 4 个字
    ];
    
    $this->expectException(Exception::class);
    submit_product_review($product, $user, $data);
  }
  
  public function testDoubleRating() {
    $user = $this->createUser();
    $product = $this->createTestProduct();
    
    // 第一次评论
    submit_product_review($product, $user, ['rating' => 5, 'message' => str_repeat('x', 30)]);
    
    // 第二次尝试
    $this->expectException(Exception::class);
    submit_product_review($product, $user, ['rating' => 4, 'message' => str_repeat('y', 30)]);
  }
}
```

### 集成测试

```gherkin
Feature: Product Reviews
  As a customer
  I want to read and write product reviews
  
  Scenario: Writing a verified purchase review
    Given I purchased this product last week
    When I go to the product page
    And I write a 5-star review with detailed comments
    Then my review should be marked as "Verified Purchase"
    And the average rating should update
  
  Scenario: Upvoting helpful review
    Given there is an existing review with 10 helpful votes
    When I click "Helpful" on that review
    Then the vote count should increase to 11
    And I cannot vote again on the same review
  
  Scenario: Review moderation workflow
    Given review auto-approval is disabled
    When a new review is submitted
    Then it should be in "Pending" status
    And admin should receive a notification
    And only after admin approval, it appears on the product page
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算方式 | 目标值 |
|------|---------|--------|
| **评论转化率** | (有评论产品销量 / 总销量) × 100% | +20% |
| **平均响应时间** | 从评论提交到上线时长 | < 24 小时 |
| **举报率** | (被举报评论 / 总评论) × 100% | < 1% |
| **有用票比率** | (有帮助票 / 总投票) × 100% | > 80% |

### 日志命令

```bash
# 查看评论相关日志
drush watchdog-view comment --count=50

# 查找待审核评论
drush sql-query "SELECT COUNT(*) FROM commerce_product_comment WHERE status = 0"

# 导出评论统计
drush php-script export_review_statistics

# 清理过期内容
drush php-script cleanup_spam_comments
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Drupal Comment Module | https://www.drupal.org/project/comment |
| Schema.org Reviews | https://schema.org/Review |
| Review Moderation Best Practices | https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/HTTPS |

---

## 🆘 常见问题

### Q1: 如何防止评论垃圾？

**答案**：
```php
// 1. CAPTCHA 验证
function mymodule_form_alter(&$form, FormStateInterface $form_state, $form_id) {
  if ($form_id == 'comment_node_product_form') {
    $form['captcha'] = [
      '#type' => 'captcha',
      '#captcha_type' => 'easy_captcha',
    ];
  }
}

// 2. Rate limiting
$config['commerce_review.settings']['max_reviews_per_day'] = 3;

// 3. Link detection
$pattern = '/https?:\/\/[^\s]+/';
if (preg_match($pattern, $comment_text)) {
  // 要求人工审核
  set_status(PENDING_MANUAL_REVIEW);
}
```

### Q2: 如何处理跨语言的评论？

**答案**：
```php
// 使用 Content Translation 模块
$config['product_review.settings']['enable_translation'] = TRUE;

// 显示本地化评论
function show_localized_reviews($product_id, $langcode) {
  $storage = \Drupal::entityTypeManager()->getStorage('product_review');
  return $storage->loadByProperties([
    'nid' => $product_id,
    'langcode' => $langcode,
  ]);
}
```

### Q3: 如何屏蔽恶意用户？

**答案**：
```php
// 标记用户为可疑
function flag_suspicious_user($user_id) {
  db_insert('review_blacklist')
    ->fields(['uid' => $user_id, 'reason' => 'spam', 'created' => REQUEST_TIME])
    ->execute();
}

// 阻止提交
function block_if_blacklisted($user_id) {
  $result = db_select('review_blacklist', 'r')
    ->fields('r', ['uid'])
    ->condition('uid', $user_id)
    ->execute()
    ->fetchField();
  
  if ($result) {
    throw new AccessDeniedException('You are temporarily blocked from posting reviews.');
  }
}
```

---

**大正，commerce-product-review.md 已补充完成。您还有其他指令吗？** 🚀
