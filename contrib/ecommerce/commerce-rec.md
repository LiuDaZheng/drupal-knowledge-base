---
name: commerce-rec
description: Complete guide to Commerce Recommender for intelligent product recommendations using AI/ML.
---

# Commerce Recommender - AI 智能推荐引擎 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Recommender 是基于机器学习和人工智能的智能化商品推荐系统，通过协同过滤、内容分析、用户行为预测等算法，为用户提供个性化的购物体验，帮助电商提升转化率和客单价。

### 核心功能
- ✅ **协同过滤推荐** - 基于相似用户和物品的推荐
- ✅ **基于内容的推荐** - 根据商品属性相似度
- ✅ **实时个性化推荐** - 基于当前会话行为
- ✅ **序列模式挖掘** - 发现用户的购买路径
- ✅ **深度学习模型** - Neural Collaborative Filtering
- ✅ **A/B 测试框架** - 实验不同推荐策略
- ✅ **冷启动优化** - 新用户和新商品策略
- ✅ **效果追踪与分析** - CTR/CVR 指标监控
- ✅ **集成第三方服务** - Google Cloud ML / AWS Personalize
- ✅ **在线学习** - 实时模型更新

### 适用场景
- 大型电商平台（百万级 SKU）
- 需要精准推荐的业务
- 用户量大的增长型公司
- 数据驱动的营销团队
- 多设备全渠道体验

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- Machine Learning module (optional)

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装推荐引擎
composer require drupal/recommendation_engine ml_api

# 启用相关模块
drush en recommendation_engine ml_api --yes

# 更新数据库
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块
drush dl recommendation_engine

# 2. 启用模块
drush en recommendation_engine --yes

# 3. 运行数据库更新
drush updatedb --yes
```

---

## ⚙️ 基础配置

### 1. 启用模块

```bash
drush en recommendation_engine --yes
```

### 2. 选择推荐算法

```
路径：/admin/config/store/recommendations/algorithms
```

| 算法类型 | 说明 | 适用场景 | 数据需求 |
|---------|------|---------|---------|
| **Collaborative Filtering** | 基于用户行为相似度 | 有充足用户行为数据 | >1000 用户，>10000 交互 |
| **Content-Based** | 基于商品属性匹配 | 新品/长尾商品 | 完整的商品元数据 |
| **Hybrid** | 混合多种算法 | 通用场景 | 适中 |
| **Matrix Factorization** | 隐语义模型 | 稀疏数据场景 | 大规模历史数据 |
| **Deep Learning (NCF)** | 神经协同过滤 | 高复杂度关系 | 海量数据 |
| **Trending** | 热门趋势 | 新用户/冷启动 | 无需历史数据 |
| **Rule-Based** | 人工规则 | 运营可控性要求高 | 无 |

### 3. 配置推荐策略

```yaml
recommendation_strategies:
  new_visitor:
    algorithm: 'trending_top_sellers'
    data_window: '7_days'
    max_results: 10
    
  returning_user:
    algorithm: 'hybrid'
    weights:
      collaborative_filtering: 0.4
      content_based: 0.3
      trending: 0.2
      rule_based: 0.1
    
  logged_in_power_user:
    algorithm: 'deep_learning_ncf'
    real_time_updates: true
    personalization_score_threshold: 0.8
    
  checkout_page:
    algorithm: 'quick_add_rules'
    placement: 'order_confirmation'
    max_items: 2
    
  homepage:
    algorithm: 'diverse_trending'
    diversity_factor: 0.5
    categories_distribution: true
```

### 4. 设置评估指标

```
/admin/config/store/recommendations/metrics
```

| 指标 | 计算方式 | 目标值 |
|------|---------|--------|
| **点击率 (CTR)** | 点击数 / 曝光数 | > 5% |
| **转化率 (CVR)** | 购买数 / 点击数 | > 1% |
| **平均排序位置** | 用户点击推荐商品的平均排名 | < 3 |
| **召回率 (Recall@K)** | K 个推荐中包含的相关物品比例 | > 0.3 |
| **准确率 (Precision@K)** | 前 K 个推荐中相关的比例 | > 0.15 |
| **NDCG@K** | 归一化折损累积增益 | > 0.4 |

### 5. 数据管道配置

```yaml
data_pipeline:
  user_events:
    types: ['view', 'add_to_cart', 'purchase', 'search', 'click']
    sampling_rate: 1.0
    processing_interval: '5_minutes'
    
  batch_training:
    schedule: 'daily_3am'
    min_data_points: 10000
    retention_days: 90
    
  online_learning:
    enabled: true
    update_frequency: 'real_time'
    feedback_weight: 0.1
```

---

## 💻 代码示例

### 1. 实现协同过滤推荐器

```php
use Drupal\recommendation_engine\Plugin\RecommendationAlgorithm\CollaborativeFiltering;

/**
 * 协同过滤推荐算法实现
 */
class CollaborativeFilteringRecommender extends RecommendationAlgorithmBase {
  
  /**
   * 计算用户相似度矩阵
   */
  public function computeUserSimilarities(int $top_n = 100): array {
    // 获取所有用户的行为向量
    $user_vectors = $this->getUserBehaviorVectors();
    
    $similarities = [];
    
    foreach ($user_vectors as $uid_a => $vector_a) {
      foreach ($user_vectors as $uid_b => $vector_b) {
        if ($uid_a >= $uid_b) continue;
        
        // 余弦相似度
        $similarity = $this->calculateCosineSimilarity($vector_a, $vector_b);
        
        if ($similarity > 0.5) {  // 阈值过滤
          $similarities[$uid_a][$uid_b] = $similarity;
        }
      }
    }
    
    // 缓存结果
    \Drupal::cache('collaborative_filter_similarities')
      ->set('user_matrix_' . REQUEST_TIME, $similarities);
    
    return $similarities;
  }
  
  /**
   * 为用户生成推荐列表
   */
  public function getRecommendations(UserInterface $user, int $limit = 10): array {
    $user_id = $user->id();
    
    // 找到相似用户
    $similar_users = $this->findNearestNeighbors($user_id, 20);
    
    if (empty($similar_users)) {
      // 回退到热门商品
      return $this->getTrendingItems($limit);
    }
    
    // 收集相似用户喜欢但该用户未接触的商品
    $candidate_scores = [];
    
    foreach ($similar_users as $neighbor_id => $similarity_weight) {
      $neighbor_purchases = $this->getUserPurchases($neighbor_id);
      
      foreach ($neighbor_purchases as $item_id => $rating) {
        if (!$this->hasUserInteractedWith($user_id, $item_id)) {
          $candidate_scores[$item_id] = ($candidate_scores[$item_id] ?? 0) + 
            ($similarity_weight * $rating);
        }
      }
    }
    
    // 按得分排序并取 Top-K
    arsort($candidate_scores);
    $top_items = array_slice(array_keys($candidate_scores), 0, $limit);
    
    // 加载实体
    return \Drupal::entityTypeManager()
      ->getStorage('commerce_product_variation')
      ->loadMultiple($top_items);
  }
  
  /**
   * 计算用户行为向量
   */
  protected function getUserBehaviorVectors(): array {
    $query = db_select('user_item_interactions', 'i')
      ->fields('i', ['uid', 'item_id', 'rating'])
      ->orderBy('uid');
    
    $vectors = [];
    $current_uid = NULL;
    $current_vector = [];
    
    foreach ($query->execute() as $row) {
      if ($current_uid !== $row->uid) {
        if ($current_uid) {
          $vectors[$current_uid] = $current_vector;
        }
        $current_uid = $row->uid;
        $current_vector = [];
      }
      $current_vector[$row->item_id] = floatval($row->rating);
    }
    
    if ($current_uid) {
      $vectors[$current_uid] = $current_vector;
    }
    
    return $vectors;
  }
  
  /**
   * 计算余弦相似度
   */
  protected function calculateCosineSimilarity(array $vector_a, array $vector_b): float {
    $dot_product = 0;
    $magnitude_a = 0;
    $magnitude_b = 0;
    
    $common_keys = array_intersect_key($vector_a, $vector_b);
    
    foreach ($common_keys as $key => $value_a) {
      $value_b = $vector_b[$key];
      $dot_product += $value_a * $value_b;
      $magnitude_a += $value_a * $value_a;
      $magnitude_b += $value_b * $value_b;
    }
    
    if ($magnitude_a == 0 || $magnitude_b == 0) {
      return 0;
    }
    
    return $dot_product / (sqrt($magnitude_a) * sqrt($magnitude_b));
  }
}
```

### 2. 基于内容的推荐

```php
use Drupal\recommendation_engine\Plugin\RecommendationAlgorithm\ContentBased;

/**
 * 基于内容的推荐算法
 */
class ContentBasedRecommender extends RecommendationAlgorithmBase {
  
  /**
   * 构建商品特征向量
   */
  public function buildItemFeatureVectors(): array {
    $items = \Drupal::entityTypeManager()
      ->getStorage('commerce_product_variation')
      ->loadMultiple();
    
    $feature_vectors = [];
    
    foreach ($items as $item_id => $item) {
      $vector = $this->extractFeatures($item);
      $feature_vectors[$item_id] = $vector;
    }
    
    return $feature_vectors;
  }
  
  /**
   * 提取商品特征
   */
  protected function extractFeatures(ProductVariation $item): array {
    $features = [];
    
    // 分类特征（One-Hot Encoding）
    $categories = $item->getCategories()->toArray();
    foreach ($categories as $cat) {
      $features["category_{$cat->id()}"] = 1;
    }
    
    // 品牌特征
    $brand = $item->getBrand();
    if ($brand) {
      $features["brand_{$brand->id()}"] = 1;
    }
    
    // 价格区间
    $price = $item->getPrice()->getAmount();
    $features['price_range'] = $this->categorizePrice($price);
    
    // 标签特征
    $tags = $item->getTags()->toArray();
    foreach ($tags as $tag) {
      $features["tag_{$tag->id()}"] = 1;
    }
    
    return $features;
  }
  
  /**
   * 为给定商品找相似商品
   */
  public function findSimilarItems(ProductVariation $item, int $limit = 10): array {
    $item_vectors = $this->buildItemFeatureVectors();
    $target_vector = $item_vectors[$item->id()];
    
    $similarities = [];
    
    foreach ($item_vectors as $other_id => $vector) {
      if ($other_id === $item->id()) continue;
      
      // Jaccard 相似度用于二进制特征
      $similarity = $this->calculateJaccardSimilarity($target_vector, $vector);
      $similarities[$other_id] = $similarity;
    }
    
    arsort($similarities);
    $top_ids = array_slice(array_keys($similarities), 0, $limit);
    
    return \Drupal::entityTypeManager()
      ->getStorage('commerce_product_variation')
      ->loadMultiple($top_ids);
  }
  
  /**
   * 计算 Jaccard 相似度
   */
  protected function calculateJaccardSimilarity(array $a, array $b): float {
    $intersection = count(array_intersect_key($a, $b));
    $union = count(array_unique(array_merge(array_keys($a), array_keys($b))));
    
    return $union > 0 ? $intersection / $union : 0;
  }
}
```

### 3. A/B 测试框架

```php
use Drupal\experiment\ABTestManager;

/**
 * 管理推荐算法 A/B 测试
 */
class RecommendationABTestManager {
  
  protected $experiment_manager;
  
  public function __construct(ABTestManager $experiment_manager) {
    $this->experiment_manager = $experiment_manager;
  }
  
  /**
   * 运行推荐算法对比测试
   */
  public function runAlgorithmComparison(string $page_context): array {
    $experiment = [
      'id' => "rec_algorithm_test_{$page_context}",
      'name' => "Algorithm Comparison: {$page_context}",
      'variants' => [
        'control' => [
          'name' => 'Rule-Based',
          'algorithm' => 'rule_based_recommendations',
          'weight' => 50,
        ],
        'variant_a' => [
          'name' => 'Collaborative Filtering',
          'algorithm' => 'collaborative_filtering',
          'weight' => 50,
        ],
        'variant_b' => [
          'name' => 'Deep Learning NCF',
          'algorithm' => 'neural_collaborative_filtering',
          'weight' => 0,  // 暂时不展示
        ],
      ],
      'metrics' => ['ctr', 'cvr', 'avg_position'],
      'duration_days' => 14,
    ];
    
    $this->experiment_manager->createExperiment($experiment);
    
    return $experiment['id'];
  }
  
  /**
   * 确定用户应看到哪个变体
   */
  public function assignVariant(UserInterface $user, string $experiment_id): string {
    $user_id = $user->isAnonymous() ? 'anon_' . session_id() : 'user_' . $user->id();
    
    $hash = md5($experiment_id . $user_id);
    $bucket_num = hexdec(substr($hash, -2)) % 100;
    
    $experiment = $this->experiment_manager->getExperiment($experiment_id);
    
    $cumulative_weight = 0;
    foreach ($experiment['variants'] as $variant_id => $variant) {
      $cumulative_weight += $variant['weight'];
      
      if ($bucket_num < $cumulative_weight) {
        return $variant_id;
      }
    }
    
    return array_key_first($experiment['variants']);
  }
  
  /**
   * 记录用户互动用于分析
   */
  public function recordInteraction(string $experiment_id, string $variant_id, 
                                    string $action_type, int $position, 
                                    int $item_id): void {
    db_insert('ab_test_recommendation_tracking')
      ->fields([
        'experiment_id' => $experiment_id,
        'variant_id' => $variant_id,
        'user_id' => \Drupal::currentUser()->id(),
        'action_type' => $action_type,
        'position' => $position,
        'item_id' => $item_id,
        'timestamp' => REQUEST_TIME,
      ])
      ->execute();
  }
  
  /**
   * 计算各变体的指标
   */
  public function calculateMetrics(string $experiment_id): array {
    $metrics = [];
    
    $query = db_select('ab_test_recommendation_tracking', 't')
      ->fields('t', ['variant_id', 'action_type'])
      ->condition('experiment_id', $experiment_id);
    
    $results = $query->execute()->fetchAllAssoc('variant_id');
    
    foreach ($results as $variant_id => $rows) {
      $metrics[$variant_id] = [
        'impressions' => count($rows),
        'clicks' => count(array_filter($rows, fn($r) => $r->action_type === 'click')),
        'conversions' => count(array_filter($rows, fn($r) => $r->action_type === 'purchase')),
      ];
    }
    
    return $metrics;
  }
}
```

### 4. 冷启动策略

```php
use Drupal\recommendation_engine\Plugin\RecommendationAlgorithm\ColdStartStrategy;

/**
 * 冷启动推荐策略
 */
class ColdStartRecommender implements RecommendationAlgorithmInterface {
  
  /**
   * 为新用户提供推荐
   */
  public function recommendForNewUser(int $limit = 10): array {
    // 策略 1: 展示热门商品
    $trending = $this->getTrendingProducts($limit);
    
    // 策略 2: 根据注册来源/页面流量猜测偏好
    $source_hint = $this->guessPreferenceFromTrafficSource();
    
    if ($source_hint && !empty($trending)) {
      // 混合热门和用户可能感兴趣的类别
      return $this->mixTrendingWithCategory($trending, $source_hint);
    }
    
    return $trending;
  }
  
  /**
   * 为新商品生成推荐
   */
  public function recommendNewItem(ProductVariation $newItem, int $context_variants = NULL): array {
    if ($context_variants) {
      // 在上下文中推荐相似商品
      $content_based = new ContentBasedRecommender();
      return $content_based->findSimilarItems($newItem, 5);
    }
    
    // 没有上下文时，推荐给可能感兴趣的人群
    return $this->targetNewItemToPotentialBuyers($newItem);
  }
  
  /**
   * 从流量来源推测偏好
   */
  protected function guessPreferenceFromTrafficSource(): ?string {
    $referer = \Drupal::request()->headers->get('HTTP_REFERER');
    
    if (strpos($referer, '/electronics') !== FALSE) {
      return 'electronics';
    }
    
    if (strpos($referer, '/fashion') !== FALSE) {
      return 'fashion';
    }
    
    if (strpos($referer, '/sale') !== FALSE) {
      return 'discounted_items';
    }
    
    return NULL;
  }
}
```

### 5. Twig 模板 - 推荐组件

```twig
{# templates/recommendation/product-carousel.html.twig #}
<div class="recommendation-carousel" data-experiment="{{ experiment_id }}" data-variant="{{ current_variant }}">
  
  <div class="carousel-header">
    <h2>{{ title }}</h2>
    <div class="controls">
      <button class="prev-btn" aria-label="Previous">‹</button>
      <button class="next-btn" aria-label="Next">›</button>
    </div>
  </div>
  
  <div class="carousel-track">
    {% if recommendations is empty %}
      <p class="no-recommendations">Loading personalized recommendations...</p>
    {% else %}
      {% for item in recommendations %}
        <div class="product-card" 
             data-item-id="{{ item.id }}"
             data-position="{{ loop.index0 }}">
          
          <div class="card-image-wrapper">
            <a href="{{ item.product_url }}" class="card-link">
              <img src="{{ item.image }}" alt="{{ item.name }}" loading="lazy">
              
              {% if item.on_sale %}
                <span class="badge sale">Sale</span>
              {% endif %}
            </a>
            
            <button class="btn-add-cart" 
                    data-variant-id="{{ item.variation_id }}"
                    onclick="event.stopPropagation()">
              Add to Cart
            </button>
          </div>
          
          <div class="card-content">
            <h3 class="card-title">
              <a href="{{ item.product_url }}">{{ item.name }}</a>
            </h3>
            
            <div class="card-price">
              {% if item.original_price and item.on_sale %}
                <del>${{ "%.2f"|format(item.original_price) }}</del>
                <strong>${{ "%.2f"|format(item.price) }}</strong>
              {% else %}
                ${{ "%.2f"|format(item.price) }}
              {% endif %}
            </div>
            
            {% if item.rating %}
              <div class="card-rating">
                {% for star in 1..5 %}
                  {% if star <= item.rating %}
                    <i class="fas fa-star"></i>
                  {% else %}
                    <i class="far fa-star"></i>
                  {% endif %}
                {% endfor %}
                <span class="review-count">({{ item.review_count }})</span>
              </div>
            {% endif %}
            
            {% if item.reason %}
              <div class="card-reason">{{ item.reason }}</div>
            {% endif %}
            
            {% if item.low_stock %}
              <div class="low-stock-warning">⚠️ Only {{ item.stock_available }} left!</div>
            {% endif %}
          </div>
        </div>
      {% endfor %}
    {% endif %}
  </div>
  
  <!-- Tracking script -->
  <script>
    (function() {
      const experimentId = '{{ experiment_id }}';
      const variant = '{{ current_variant }}';
      
      document.querySelectorAll('.product-card').forEach((card, index) => {
        const itemId = card.dataset.itemId;
        const position = parseInt(card.dataset.position);
        
        // 记录曝光
        trackRecommendationExposure(experimentId, variant, itemId, position, 'impression', index + 1);
        
        // 鼠标悬停记录
        card.addEventListener('mouseenter', () => {
          trackRecommendationExposure(experimentId, variant, itemId, position, 'hover', index + 1);
        });
        
        // 点击链接记录
        card.querySelector('.card-link').addEventListener('click', (e) => {
          setTimeout(() => {
            trackRecommendationExposure(experimentId, variant, itemId, position, 'click', index + 1);
          }, 100);
        });
        
        // 加入购物车按钮点击
        card.querySelector('.btn-add-cart').addEventListener('click', (e) => {
          e.preventDefault();
          addToCart(itemId).then(() => {
            trackRecommendationExposure(experimentId, variant, itemId, position, 'add_to_cart', index + 1);
          });
        });
      });
      
      function trackRecommendationExposure(experiment, variant, itemId, position, action, rank) {
        fetch('/api/track-recommendation-interaction', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({
            experiment_id: experiment,
            variant_id: variant,
            item_id: itemId,
            position: position,
            action: action,
            rank: rank,
            timestamp: Date.now()
          })
        });
      }
    })();
  </script>
</div>
```

---

## 📋 数据表结构

### recommendation_exposures
推荐曝光记录表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY | 自增 ID |
| user_id | VARCHAR(64) | NOT NULL | 用户标识 |
| experiment_id | VARCHAR(64) | NOT NULL | 实验 ID |
| variant_id | VARCHAR(20) | NOT NULL | 变体 ID |
| item_id | INT | NOT NULL | 推荐商品 ID |
| position | INT | NOT NULL | 展示位置 |
| algorithm_used | VARCHAR(50) | NOT NULL | 使用的算法 |
| occurred_at | DATETIME | NOT NULL | 发生时间 |

**索引**: 
- `idx_experiment` ON (experiment_id, occurred_at DESC)
- `idx_user_event` ON (user_id, algorithm_used, occurred_at)

### recommendation_clicks
点击事件表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| click_id | BIGINT | PRIMARY KEY | 自增 ID |
| exposure_id | INT | FOREIGN KEY | 关联曝光记录 |
| user_id | VARCHAR(64) | NOT NULL | 用户 ID |
| item_id | INT | NOT NULL | 商品 ID |
| referrer_url | VARCHAR(255) | NULLABLE | 来源 URL |
| device_type | VARCHAR(20) | NULLABLE | 设备类型 |
| clicked_at | DATETIME | NOT NULL | 点击时间 |

### recommendation_purchases
购买转化表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| purchase_id | BIGINT | PRIMARY KEY | 自增 ID |
| click_id | INT | FOREIGN KEY | 关联点击记录 |
| order_id | INT | NOT NULL | 订单 ID |
| attributed_item_id | INT | NOT NULL | 归因商品 ID |
| purchased_at | DATETIME | NOT NULL | 购买时间 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\recommendation_engine\Unit\AlgorithmTest;

class AlgorithmPerformanceTest extends UnitTestCaseBase {
  
  public function testColdStartReturnsTrendingItems() {
    $recommender = new ColdStartRecommender();
    
    $recommendations = $recommender->recommendForNewUser(10);
    
    $this->assertCount(<= 10, $recommendations);
    
    // 验证是热门商品
    foreach ($recommendations as $item) {
      $views = $this->getItemViews($item->id());
      $this->assertGreaterThan(100, $views); // 假设热门定义
    }
  }
  
  public function testCollaborativeFilteringAccuracy() {
    $cf_recommender = new CollaborativeFilteringRecommender();
    
    // 创建测试数据集
    $test_user = $this->createTestUserWithManyPurchases();
    $recommendations = $cf_recommender->getRecommendations($test_user, 10);
    
    // 验证推荐的多样性
    $categories = array_map(fn($item) => $item->getCategory()->id(), $recommendations);
    $unique_categories = array_unique($categories);
    
    // 不应该全部来自同一分类
    $this->assertTrue(count($unique_categories) >= 2);
  }
  
  public function testContentBasedSimilarity() {
    $cb_recommender = new ContentBasedRecommender();
    
    $reference_item = $this->createElectronicsProduct();
    $similar = $cb_recommender->findSimilarItems($reference_item, 5);
    
    // 验证相似度高的都是电子产品
    foreach ($similar as $item) {
      $this->assertEquals('electronics', $item->getCategory()->id());
    }
  }
}
```

### 集成测试

```gherkin
Feature: Recommendation Algorithm Testing
  As a data scientist
  I want to compare different recommendation algorithms
  
  Scenario: Running A/B test on product page
    Given there is an active A/B test comparing algorithms
    When two users visit the same product page
    Then they should see different recommendation lists
    And their interactions should be tracked separately
    
  Scenario: Evaluating recommendation quality
    Given we have collected user interaction data
    When the evaluation job runs
    Then it should calculate CTR, CVR, and NDCG metrics
    And generate a comparison report
  
  Scenario: Cold start for new product
    Given a new product has been added
    When no user has interacted with it
    Then the content-based algorithm should suggest similar products
    And the trending algorithm should include it if it's popular
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算公式 | 目标值 |
|------|---------|--------|
| **CTR (Click-Through Rate)** | Clicks / Impressions | > 5% |
| **CVR (Conversion Rate)** | Conversions / Clicks | > 1% |
| **Revenue per Impression** | Revenue / Impressions | $0.01+ |
| **Diversity Score** | Unique categories recommended | > 0.3 |
| **Novelty Score** | Unseen items ratio | > 0.1 |
| **Model Training Time** | Batch training duration | < 1 hour |

### 日志命令

```bash
# 查看推荐系统日志
drush watchdog-view recommendation_engine --count=50

# 查询算法性能
drush sql-query "
  SELECT algorithm_used,
         COUNT(*) as impressions,
         SUM(CASE WHEN action='click' THEN 1 ELSE 0 END) as clicks,
         ROUND(SUM(CASE WHEN action='click' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as ctr
  FROM recommendation_exposures
  WHERE occurred_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
  GROUP BY algorithm_used
  ORDER BY ctr DESC
"

# 导出推荐分析报告
drush php-script export_recommendation_analytics
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Amazon Product Recommendations | https://www.amazon.research/topics/recommender-systems/ |
| Netflix Prize Competition | https://www.kaggle.com/datasets/wendykan/netflix-prize-data |

---

## 🆘 常见问题

### Q1: 如何处理大数据量的实时推荐？

**答案**：
```php
class RealTimeRecommendationService {
  
  private const CACHE_TTL = 300;  // 5 分钟
  
  public function getRealtimeRecommendations(UserInterface $user, int $limit = 10): array {
    $session_id = session_id();
    $cache_key = "rt_recs_{$session_id}_{$user->id()}";
    
    // 检查缓存
    $cached = \Drupal::cache('recommendation_cache')->get($cache_key);
    if ($cached && $cached->data) {
      return $cached->data;
    }
    
    // 实时计算（仅当需要时）
    if ($this->needsRealtimeUpdate($user)) {
      $recommendations = $this->computeRealtimeRecommendations($user);
      
      // 缓存结果
      \Drupal::cache('recommendation_cache')
        ->set($cache_key, ['data' => $recommendations], self::CACHE_TTL);
      
      return $recommendations;
    }
    
    return $cached->data ?? [];
  }
  
  private function needsRealtimeUpdate(UserInterface $user): bool {
    // 检查是否有重大行为变化
    $recent_sessions = get_recent_sessions($user, HOUR);
    return count($recent_sessions) > 5;  // 5 次以上浏览才重新计算
  }
}
```

### Q2: 如何防止推荐同质化？

**答案**：
```php
function addDiversityToRecommendations(array $recommendations, float $diversity_factor = 0.3): array {
  $original_count = count($recommendations);
  $diverse_count = ceil($original_count * (1 - $diversity_factor));
  
  // 取前 N 个最相关
  $high_confidence = array_slice($recommendations, 0, $diverse_count);
  
  // 补充一些多样性商品
  $diverse_items = $this->getDiverseItems(count($recommendations) - $diverse_count);
  
  return array_merge($high_confidence, $diverse_items);
}
```

### Q3: 如何实现跨设备的推荐一致性？

**答案**：
```php
class CrossDeviceRecommender {
  
  public function syncRecommendationsAcrossDevices(string $anonymous_id, UserInterface $authenticated_user): void {
    // 1. 获取匿名用户的会话历史
    $anon_history = $this->getAnonymousSessionHistory($anonymous_id);
    
    // 2. 迁移到登录用户
    $this->mergeSessionHistories($auth_user_id, $anon_history);
    
    // 3. 重新计算推荐
    $new_recs = $this->computePersonalizedRecommendations($auth_user);
    
    // 4. 同步到其他设备
    $this->syncToDeviceCache($auth_user_id, $new_recs);
  }
  
  private function syncToDeviceCache(int $user_id, array $recommendations): void {
    $devices = get_user_devices($user_id);
    
    foreach ($devices as $device_info) {
      \Drupal::cache("rec_cache_{$device_info['device_token']}")
        ->set('user_recs', $recommendations, DAY);
    }
  }
}
```

---

**大正，commerce-rec.md 已补充完成。继续下一个...** 🚀
