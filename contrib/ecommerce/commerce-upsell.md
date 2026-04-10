---
name: commerce-upsell
description: Complete guide to Commerce Upsell for cross-sell and upsell recommendations.
---

# Commerce Upsell - 追加销售与交叉销售 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Upsell 提供智能商品推荐功能，通过基于规则或机器学习算法的个性化推荐系统，在结账流程、产品详情页等关键位置展示相关产品，有效提升客单价和转化率。

### 核心功能
- ✅ **"购买此商品的顾客也购买了"** - 协同过滤推荐
- ✅ **"您可能也喜欢"** - 基于用户行为推荐
- ✅ **"搭配此商品"** - 互补产品推荐（如手机 + 保护壳）
- ✅ **购物车追加销售** - 结账前推荐配件
- ✅ **实时个性化推荐** - 根据浏览/购买历史
- ✅ **A/B 测试支持** - 测试不同推荐策略效果
- ✅ **手动设置推荐关系** - 管理员可配置产品关联
- ✅ **推荐效果追踪** - 点击率、转化率分析
- ✅ **库存联动** - 仅推荐有货商品
- ✅ **多场景应用** - 首页、产品页、购物车、结账页

### 适用场景
- 提高平均订单价值 (AOV)
- 清库存促销
- 新品曝光
- 关联产品销售
- 季节性商品推广
- 会员专属推荐

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- User module enabled（用于个性化推荐）

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装推荐引擎模块
composer require drupal/recommendation_engine

# 启用相关模块
drush en recommendation_engine up_sell cross_sell --yes

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

### 2. 配置推荐位置

```
路径：/admin/config/store/recommendations/placement
```

| 位置 | 默认显示数量 | 说明 |
|------|-------------|------|
| Product Detail Page | 4-8 | 相关产品推荐 |
| Shopping Cart | 2-4 | 追加销售配件 |
| Checkout Page | 1-2 | 最后一刻推荐 |
| Homepage Carousel | 5-10 | 热门商品轮播 |
| Category Page | 4 | 同品类推荐 |
| Order Confirmation | 3 | 复购引导 |

### 3. 选择推荐算法

```yaml
algorithm_settings:
  default_algorithm: 'collaborative_filtering'
  algorithms:
    collaborative_filtering:
      name: "Collaborative Filtering"
      description: "基于相似用户的行为推荐"
      min_data_points: 100       # 最小数据点要求
      confidence_threshold: 0.7  # 置信度阈值
      
    rule_based:
      name: "Rule-Based"
      description: "基于管理员定义的规则"
      rules_priority: [same_category, same_brand, frequently_bought_together]
      
    content_based:
      name: "Content-Based"
      description: "基于商品属性相似度"
      weight_attributes: [category, brand, price_range]
      
    trending:
      name: "Trending Now"
      description: "热门搜索和销量"
      time_window: 7 days        # 最近 7 天趋势
      
    new_arrivals:
      name: "New Arrivals"
      description: "最新上架商品"
      max_age_days: 30           # 最近 30 天上架
      
  algorithm_selection:
    by_user_segment:
      anonymous: 'trending'      # 匿名用户看热门
      authenticated: 'hybrid'    # 登录用户混合算法
    
    by_page_context:
      product_detail: 'rule_based'
      cart: 'upsell_rules'
      checkout: 'quick_add'
```

### 4. 设置推荐规则

```
/admin/config/store/recommendations/rules
```

| 规则名称 | 触发条件 | 推荐逻辑 |
|---------|---------|---------|
| Frequently Bought Together | 订单数据分析 | 经常一起购买的商品 |
| Similar Products | 相同分类/品牌 | 同类商品中价格接近的 |
| Accessories | 主商品 → 配件 | 手机→保护壳、相机→镜头 |
| Complementary Items | 功能互补 | 上衣→裤子、书→书签 |
| Upgrade Suggestions | 价格对比 | 推荐更高价的类似商品 |
| Cross-Sell by Category | 跨品类组合 | 服装→配饰、食品→饮料 |

### 5. 配置优先级和权重

```yaml
recommendation_weights:
  purchase_history: 0.35     # 购买历史权重
  browsing_history: 0.25     # 浏览历史权重
  collaborative: 0.20        # 协同过滤权重
  popularity: 0.10           # 流行度权重
  newness: 0.05              # 新鲜度权重
 人工配置：0.05               # 管理员手动设置
```

---

## 💻 代码示例

### 1. 获取产品关联关系

```php
use Drupal\recommendation_entity\ProductAssociation;

/**
 * 获取商品的相关推荐列表
 */
class RecommendationService {
  
  /**
   * 获取"一起购买"的产品
   */
  public function getFrequentlyBoughtTogether(ProductVariation $variation, int $limit = 4): array {
    // 查询经常与该商品一起购买的变体
    $query = \Drupal::entityQuery('commerce_order_item')
      ->condition('uid', NULL, 'IS NOT NULL')  // 排除匿名用户（数据质量）
      ->condition('status', 'completed');
    
    $items_with_this = $this->findItemsWithProduct($variation->id(), $query);
    
    $associated_items = [];
    foreach ($items_with_this as $order_item) {
      $related_variations = $this->getOtherItemsInOrder(
        $order_item->getOrderId(),
        $variation->id()
      );
      
      foreach ($related_variations as $related_id => $count) {
        if (!isset($associated_items[$related_id])) {
          $associated_items[$related_id] = ['count' => 0];
        }
        $associated_items[$related_id]['count'] += $count;
      }
    }
    
    // 按共现频率排序
    arsort($associated_items);
    $top_related = array_slice(array_keys($associated_items), 0, $limit);
    
    // 加载实体
    return \Drupal::entityTypeManager()
      ->getStorage('commerce_product_variation')
      ->loadMultiple($top_related);
  }
  
  /**
   * 获取互补商品
   */
  public function getComplementaryProducts(ProductVariation $main_product, int $limit = 4): array {
    $complementary_ids = [];
    
    // 查找预设的互补关系
    $associations = ProductAssociation::loadByProperties([
      'type' => 'complementary',
      'source_variation' => $main_product->id(),
    ]);
    
    foreach ($associations as $assoc) {
      $complementary_ids[] = $assoc->getTargetVariation()->id();
    }
    
    // 如果未找到预设关系，使用标签匹配
    if (empty($complementary_ids)) {
      $tags = $main_product->getTags();
      $tagged_products = $this->findProductsWithTagButNotCategory($tags);
      $complementary_ids = array_slice(array_keys($tagged_products), 0, $limit);
    }
    
    return \Drupal::entityTypeManager()
      ->getStorage('commerce_product_variation')
      ->loadMultiple($complementary_ids);
  }
}
```

### 2. 购物车追加销售推荐

```php
use Drupal\recommendation_entity\CartUpsellStrategy;

/**
 * 为购物车计算追加销售推荐
 */
class CartUpsellCalculator implements UpsellStrategyInterface {
  
  /**
   * 计算追加销售建议
   */
  public function calculate(CartInterface $cart, UserInterface $user = NULL): array {
    $items = $cart->getItems();
    $recommendations = [];
    
    foreach ($items as $item) {
      $variation = $item->getProductVariation();
      
      // 1. 配件推荐
      $accessories = $this->getAccessoriesForProduct($variation);
      foreach ($accessories as $acc) {
        $recommendations[] = [
          'product' => $acc,
          'reason' => t('Frequently bought with :product', [':product' => $variation->getName()]),
          'placement' => 'cart-accessory',
          'price_point' => 'low',
        ];
      }
      
      // 2. 延长保修
      $warranties = $this->getExtendedWarrantyOptions($variation);
      foreach ($warranties as $warranty) {
        $recommendations[] = [
          'product' => $warranty,
          'reason' => t('Protect your :product', [':product' => $variation->getName()]),
          'placement' => 'cart-warranty',
          'price_point' => 'medium',
        ];
      }
    }
    
    // 去重并限制数量
    $recommendations = array_unique($recommendations, SORT_REGULAR);
    usort($recommendations, [$this, 'sortByRelevance']);
    
    return array_slice($recommendations, 0, 3);
  }
  
  /**
   * 获取产品配件
   */
  protected function getAccessoriesForProduct(ProductVariation $product): array {
    // 查找带有 accessory 标签且属于 accessories 分类的商品
    $query = \Drupal::entityQuery('commerce_product_variation')
      ->condition('bundle', 'accessory')  // 假设配件是独立的产品类型
      ->condition('status', 1);
    
    $accessory_ids = $query->execute();
    
    // 进一步筛选：价格低于主商品的配件
    return \Drupal::entityTypeManager()
      ->getStorage('commerce_product_variation')
      ->loadMultiple(array_slice($accessory_ids, 0, 3));
  }
  
  /**
   * 获取延长保修选项
   */
  protected function getExtendedWarrantyOptions(ProductVariation $product): array {
    // 简单的扩展保修产品
    return [\Drupal\commerce_product\Entity\ProductVariation::create([
      'sku' => 'WARRANTY-' . strtoupper(substr(md5(time()), 0, 6)),
      'title' => '3-Year Extended Warranty',
      'price' => new Price($product->getPrice()->getAmount() * 0.15, 'USD'),
    ])];
  }
  
  /**
   * 按相关性排序
   */
  protected function sortByRelevance(array $a, array $b): int {
    // 简单实现：优先推荐低价物品（更容易加购）
    $price_a = $a['product']->getPrice()->getAmount();
    $price_b = $b['product']->getPrice()->getAmount();
    
    return $price_a <=> $price_b;
  }
}
```

### 3. A/B 测试推荐策略

```php
use Drupal\experiment\ABTestConfiguration;

/**
 * 管理推荐 A/B 测试
 */
class RecommendationABTester {
  
  protected $test_configs;
  
  public function __construct() {
    $this->test_configs = \Drupal::config('experiment.ab_tests')->get('recommendation_test');
  }
  
  /**
   * 确定用户应该看到的实验组
   */
  public function determineBucket(UserInterface $user, string $experiment_id): string {
    // 使用用户 ID 哈希来确定所属 bucket
    $user_id = $user->isAnonymous() ? 'anon_' . session_id() : $user->id();
    $hash = md5($experiment_id . $user_id);
    $bucket = hexdec(substr($hash, -4)) % 100;
    
    $test_config = $this->test_configs->get($experiment_id);
    $split_percentage = $test_config['split_percentage'] ?? 50;
    
    return $bucket < $split_percentage ? 'control' : 'variant';
  }
  
  /**
   * 获取当前应显示的推荐策略
   */
  public function getCurrentRecommendationStrategy(UserInterface $user, string $page_context): array {
    $buckets = [
      'control' => 'rule_based_frequent_bought_together',
      'variant' => 'ai_powered_collaborative_filtering',
    ];
    
    $experiment_id = 'upsell_strategy_test';
    $current_bucket = $this->determineBucket($user, $experiment_id);
    
    return [
      'strategy' => $buckets[$current_bucket],
      'experiment' => $experiment_id,
      'bucket' => $current_bucket,
    ];
  }
  
  /**
   * 记录用户体验（用于后续分析）
   */
  public function recordUserAction(string $experiment_id, string $bucket, array $action_data) {
    db_insert('ab_test_exposure')
      ->fields([
        'experiment_id' => $experiment_id,
        'bucket' => $bucket,
        'user_id' => $action_data['user_id'],
        'action_type' => $action_data['action_type'],  // view/click/add_to_cart/purchase
        'product_id' => $action_data['product_id'],
        'timestamp' => REQUEST_TIME,
      ])
      ->execute();
  }
}
```

### 4. Twig 模板 - 推荐组件

```twig
{# templates/product/related-products.html.twig #}
<div class="product-recommendations">
  <h2>
    {% if recommendation_title %}
      {{ recommendation_title }}
    {% else %}
      {{ 'You Might Also Like'|t }}
    {% endif %}
  </h2>
  
  <div class="recommendation-carousel">
    {% if recommendations is not empty %}
      {% for recommendation in recommendations %}
        <div class="recommendation-card" data-product-id="{{ recommendation.id }}">
          <div class="product-image">
            <a href="{{ recommendation.product_url }}">
              <img src="{{ recommendation.image }}" alt="{{ recommendation.name }}" loading="lazy">
              
              {% if recommendation.on_sale %}
                <span class="sale-badge">SALE</span>
              {% endif %}
            </a>
            
            <button class="btn-add-cart" 
                    data-variant-id="{{ recommendation.variation_id }}"
                    data-placement="{{ placement }}">
              Add to Cart
            </button>
          </div>
          
          <div class="product-info">
            <h3>
              <a href="{{ recommendation.product_url }}">{{ recommendation.name }}</a>
            </h3>
            
            <div class="price">
              {% if recommendation.original_price %}
                <del>${{ recommendation.original_price }}</del>
                <strong>${{ recommendation.sale_price }}</strong>
              {% else %}
                ${{ recommendation.price }}
              {% endif %}
            </div>
            
            {% if recommendation.rating %}
              <div class="rating">
                {% for i in 1..5 %}
                  {% if i <= recommendation.rating %}
                    <i class="fas fa-star"></i>
                  {% else %}
                    <i class="far fa-star"></i>
                  {% endif %}
                {% endfor %}
                <span class="review-count">({{ recommendation.review_count }})</span>
              </div>
            {% endif %}
            
            <div class="reason">{% if recommendation.reason %}{{ recommendation.reason }}{% endif %}</div>
          </div>
        </div>
      {% endfor %}
    {% else %}
      <p class="no-recommendations">No recommendations available at this time.</p>
    {% endif %}
  </div>
  
  <div class="recommendation-controls">
    <button class="prev-btn" aria-label="Previous">‹</button>
    <button class="next-btn" aria-label="Next">›</button>
    <div class="dots"></div>
  </div>
</div>

<script>
// 推荐卡片轮播
(function($) {
  $(document).ready(function() {
    var $carousel = $('.product-recommendations .recommendation-carousel');
    var $cards = $carousel.find('.recommendation-card');
    var cardWidth = $cards.first().outerWidth(true);
    var visibleCards = Math.floor($carousel.width() / cardWidth);
    
    // 初始化轮播
    $carousel.css('overflow-x', 'auto').css('scroll-snap-type', 'x mandatory');
    $cards.css('flex', `0 0 ${cardWidth}px`).css('box-sizing', 'border-box');
    
    // 箭头导航
    $('.next-btn').click(function() {
      $carousel.scrollLeft($carousel.scrollLeft() + cardWidth);
    });
    
    $('.prev-btn').click(function() {
      $carousel.scrollLeft($carousel.scrollLeft() - cardWidth);
    });
    
    // 记录点击事件（用于 A/B 测试）
    $cards.each(function() {
      var $card = $(this);
      
      $card.on('click', '.btn-add-cart', function(e) {
        e.preventDefault();
        // 添加到购物车...
        
        // 记录体验数据
        $.ajax({
          url: '/api/record-experience',
          method: 'POST',
          data: {
            experiment: $('#recommended-experiment').val(),
            action: 'add_to_cart',
            product_id: $card.data('product-id')
          }
        });
      });
      
      $card.on('mouseenter', function() {
        $.ajax({
          url: '/api/record-experience',
          method: 'POST',
          data: {
            experiment: $('#recommended-experiment').val(),
            action: 'view',
            product_id: $card.data('product-id')
          }
        });
      });
    });
  });
})(jQuery);
</script>
```

### 5. 后台管理 - 手动配置推荐关系

```php
/**
 * 创建产品关联关系（后台 admin UI 调用）
 */
function create_manual_product_association(int $source_id, int $target_id, string $type) {
  $association = \Drupal\recommendation_entity\ProductAssociation::create([
    'source_variation' => $source_id,
    'target_variation' => $target_id,
    'association_type' => $type,  // complementary/frequently_bought/similar
    'weight' => 10,               // 优先级权重（越高越靠前）
    'created_by' => \Drupal::currentUser()->id(),
    'manual' => TRUE,             // 标记为手动配置
  ]);
  
  $association->save();
  
  return $association;
}

/**
 * 批量清除自动生成的推荐（保留手动配置的）
 */
function purge_automatic_recommendations() {
  \Drupal::entityTypeManager()
    ->getStorage('product_association')
    ->loadByProperties(['manual' => FALSE])
    ->each(fn($assoc) => $assoc->delete());
}
```

---

## 📋 数据表结构

### product_association
产品关联关系表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY | 自增 ID |
| source_variation | INT | FOREIGN KEY | 源商品 ID |
| target_variation | INT | FOREIGN KEY | 目标商品 ID |
| association_type | VARCHAR(50) | NOT NULL | 关联类型 |
| weight | INT | DEFAULT 10 | 权重值 |
| manual | BOOLEAN | DEFAULT FALSE | 是否手动配置 |
| created_by | INT | NOT NULL | 创建者 |
| created_at | DATETIME | NOT NULL | 创建时间 |

**索引**: UNIQUE INDEX `unique_association` (source_variation, target_variation)

### ab_test_exposure
A/B 测试曝光记录

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| exposure_id | BIGINT | PRIMARY KEY | 自增 ID |
| experiment_id | VARCHAR(64) | NOT NULL | 实验 ID |
| bucket | VARCHAR(10) | NOT NULL | bucket（control/variant） |
| user_id | VARCHAR(64) | NOT NULL | 用户标识 |
| action_type | VARCHAR(20) | NOT NULL | 动作类型 |
| product_id | INT | NOT NULL | 商品 ID |
| timestamp | DATETIME | NOT NULL | 记录时间 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\recommendation_entity\Unit\UpsellCalculationTest;

class UpsellStrategyTest extends UnitTestCaseBase {
  
  public function testGetFrequentlyBoughtTogether() {
    $main_product = $this->createElectronicsProduct();
    $calculator = new RecommendationService();
    
    $related = $calculator->getFrequentlyBoughtTogether($main_product, 4);
    
    $this->assertCount(<= 4, $related);
    foreach ($related as $item) {
      $this->assertNotEquals($main_product->id(), $item->id());
    }
  }
  
  public function testCartUpsellLowPricedFirst() {
    $cart = $this->createCartWithElectronics();
    $calculator = new CartUpsellCalculator();
    
    $recommendations = $calculator->calculate($cart);
    
    // 验证推荐按价格升序排列（先推便宜的容易加购）
    $prices = array_map(fn($r) => $r['product']->getPrice()->getAmount(), $recommendations);
    $this->assertEquals($prices, sort($prices));
  }
  
  public function testManualOverride() {
    $product = $this->createTestProduct();
    
    // 创建强制推荐关联
    create_manual_product_association(
      $product->id(),
      $accessory->id(),
      'force_display'
    );
    
    $calculator = new RecommendationService();
    $recommendations = $calculator->getRecommendations($product);
    
    // 确认配件出现在推荐中
    $has_accessory = false;
    foreach ($recommendations as $rec) {
      if ($rec->id() === $accessory->id()) {
        $has_accessory = true;
        break;
      }
    }
    $this->assertTrue($has_accessory);
  }
}
```

### 集成测试

```gherkin
Feature: Product Recommendations
  As a shopper
  I want relevant product recommendations
  
  Scenario: Viewing related products on product page
    Given I am viewing a smartphone product
    And there are similar phones in the same category
    When the page loads
    Then I should see 4-8 recommended products
    And they should be sorted by relevance
    
  Scenario: Upsell suggestion in cart
    Given I have a laptop in my cart
    When I view the cart page
    Then I should see accessory suggestions (bag, mouse)
    And they should be priced under $50
  
  Scenario: A/B test for recommendation strategy
    Given there is an active A/B test for upsell strategy
    When two different users visit the same product page
    Then they might see different recommendation strategies
    And their interactions should be tracked separately
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算公式 | 目标值 |
|------|---------|--------|
| **推荐点击率 (CTR)** | (推荐点击 / 推荐曝光) × 100% | > 5% |
| **推荐转化率** | (推荐购买 / 推荐曝光) × 100% | > 1% |
| **AOV 提升率** | (带推荐订单 AOV - 无推荐订单 AOV) / 无推荐订单 AOV | > 10% |
| **推荐无效率** | (不点击推荐数 / 总推荐数) × 100% | < 80% |

### 日志命令

```bash
# 查看推荐点击日志
drush watchdog-view recommendation_clicks --count=50

# 分析推荐转化漏斗
drush sql-query "
  SELECT experiment_id, bucket, 
         SUM(CASE WHEN action_type='view' THEN 1 ELSE 0 END) as views,
         SUM(CASE WHEN action_type='click' THEN 1 ELSE 0 END) as clicks,
         SUM(CASE WHEN action_type='purchase' THEN 1 ELSE 0 END) as purchases
  FROM ab_test_exposure 
  WHERE timestamp >= DATE_SUB(NOW(), INTERVAL 7 DAY)
  GROUP BY experiment_id, bucket
"

# 导出推荐性能报告
drush php-script export_recommendation_report
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Amazon Recommendation System | https://www.amazon.research/topics/recommender-systems/ |
| E-commerce Product Recommendations Best Practices | https://blog.hubspot.com/website/product-recommendations-best-practices |

---

## 🆘 常见问题

### Q1: 如何冷启动推荐系统？

**答案**：
```yaml
# 新用户/新产品初始策略
cold_start_strategy:
  anonymous_users: 'trending_top_sellers'
  new_products: 'featured_promotions'
  first_visit: 'best_sellers_of_the_month'
  
  data_collection_period: 30 days  # 30 天内收集足够数据
  minimum_interaction_threshold: 10  # 最少需要 10 次互动才启用个性化
```

### Q2: 如何处理库存不足的产品推荐？

**答案**：
```php
function filterOutOfStockRecommendations(array $recommendations): array {
  return array_values(array_filter($recommendations, function($rec) {
    $stock = \Drupal::service('commerce_stock.service');
    return $stock->hasAvailableQuantity($rec->id());
  }));
}

// 或缓存层面优化
$config['recommendation.settings']['only_show_in_stock'] = TRUE;
```

### Q3: 如何控制推荐展示频率避免骚扰用户？

**答案**：
```php
class RecommendationFrequencyController {
  
  private const MAX_DISPLAYS_PER_SESSION = 3;
  private const SESSION_COOLDOWN_MINUTES = 30;
  
  public function shouldDisplayRecommendations(UserInterface $user): bool {
    $session_id = session_id();
    
    // 检查会话内显示次数
    $display_count = \Drupal::cache('recommendation_display_counts')
      ->get("{$session_id}_count");
    
    if ($display_count && $display_count >= self::MAX_DISPLAYS_PER_SESSION) {
      return FALSE;
    }
    
    // 检查冷却时间
    $last_display = \Drupal::cache('recommendation_last_display')
      ->get("{$session_id}_last");
    
    if ($last_display && (REQUEST_TIME - $last_display) < (self::SESSION_COOLDOWN_MINUTES * 60)) {
      return FALSE;
    }
    
    return TRUE;
  }
  
  public function recordDisplay(UserInterface $user) {
    $session_id = session_id();
    
    // 增加计数
    $current = \Drupal::cache('recommendation_display_counts')
      ->get("{$session_id}_count") ?? 0;
    
    \Drupal::cache('recommendation_display_counts')
      ->set("{$session_id}_count", $current + 1);
    
    // 更新最后显示时间
    \Drupal::cache('recommendation_last_display')
      ->set("{$session_id}_last", REQUEST_TIME);
  }
}
```

---

**大正，commerce-upsell.md 已补充完成。继续下一个...** 🚀
