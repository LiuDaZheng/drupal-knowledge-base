---
name: commerce-promotions
description: Complete guide to Commerce Promotions for discounts, coupons, and sales campaigns.
---

# Commerce Promotions - 促销管理系统 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Promotions 是 Drupal Commerce 强大的营销工具，提供灵活的折扣、优惠券和促销活动管理能力。支持多种促销类型组合、条件限制、用户分群等高级功能，帮助企业打造多样化的营销策略。

### 核心功能
- ✅ **百分比/固定金额折扣** - 灵活的价格减免方式
- ✅ **买 X 送 Y 促销** - BOGO（Buy One Get One）类优惠
- ✅ **满减优惠** - 订单金额满额打折
- ✅ **优惠券码生成** - 批量/单个优惠券创建
- ✅ **用户组专属促销** - VIP/会员专享价
- ✅ **A/B 测试支持** - 测试不同促销策略效果
- ✅ **促销日历管理** - 季节性/节日活动排期
- ✅ **库存联动促销** - 基于库存的自动促销
- ✅ **动态定价规则** - 基于时间/需求的自动调整
- ✅ **多币种支持** - 国际化电商的多货币促销

### 适用场景
- 季节性促销（黑五、双 11、圣诞）
- 会员专享折扣
- 新品推广活动
- 清仓促销
- 节假日特惠
- 限时闪购
- B2B 阶梯定价

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- Tax module enabled（如需计算含税价格）

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装促销模块
composer require drupal/promotions

# 启用相关模块
drush en promotions coupon codes --yes

# 更新数据库
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块
drush dl promotions

# 2. 启用模块
drush en promotions --yes

# 3. 运行数据库更新
drush updatedb --yes
```

---

## ⚙️ 基础配置

### 1. 启用模块

```bash
drush en promotions --yes
```

### 2. 创建促销规则

```
路径：/admin/config/store/promotions/rules
```

| 促销类型 | 名称 | 条件 | 折扣 | 说明 |
|---------|------|------|------|------|
| Percentage Discount | New Year Sale | Cart > $50 | 20% off | 新年全场 8 折 |
| Fixed Amount | Free Shipping | Cart > $75 | $0 shipping | 满$75 免运费 |
| BOGO | Clearance Special | Select products | Buy 2 get 1 free | 买二送一清仓 |
| Tiered Discount | Volume Pricing | Quantity >= 10 | 15% off | 批发价 15% 折扣 |

### 3. 设置优惠券规则

```yaml
coupon_settings:
  auto_generate:
    batch_size: 100          # 批量生成数量
    prefix: 'SAVE'           # 前缀
    suffix_length: 4         # 后缀长度
    charset: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    
  validation_rules:
    unique_code: true        # 唯一性验证
    one_use_per_customer: true   # 每人限用一次
    minimum_order_amount: 0  # 最低订单额
    maximum_uses_global: null    # 全局使用上限
    maximum_uses_per_customer: 1 # 每客户使用次数
    valid_from: null             # 生效日期
    valid_until: null            # 过期日期
    applicable_products: '*'     # 适用商品（通配符支持）
    excluded_products: []        # 排除商品
    
  email_marketing:
    subscribe_bonus: 10       # 订阅奖励积分
    referral_bonus: 20        # 推荐奖励积分
```

### 4. 配置促销优先级

```
/admin/config/store/promotions/settings
```

| 设置项 | 值 | 说明 |
|--------|-----|------|
| Apply multiple promotions | Yes | 允许多重叠加（可禁用避免滥用） |
| Promotion priority order | manual | 手动设定优先级 |
| Auto-apply best discount | ✅ Yes | 自动应用最优折扣 |
| Show promotion messages | ✅ Yes | 显示促销提示 |
| Log all promotions | ✅ Yes | 记录所有使用情况 |

### 5. 设置促销时间段

```yaml
scheduled_promotions:
  black_friday:
    name: "Black Friday Sale"
    start_date: "2026-11-27 00:00:00"
    end_date: "2026-11-27 23:59:59"
    timezone: "America/New_York"
    rules:
      - type: percentage_discount
        value: 30
        scope: cart
        conditions:
          min_cart_value: 50
      
  flash_sale_morning:
    name: "Morning Flash Sale"
    recurrence: daily
    start_time: "09:00:00"
    end_time: "11:00:00"
    days: [mon, wed, fri]
    rules:
      - type: fixed_discount
        value: 10
        product_category: electronics
```

---

## 💻 代码示例

### 1. 创建百分比折扣促销

```php
use Drupal\promotions\Entity\Promotion;
use Drupal\promotions\Plugin\PromotionAction\PercentageDiscount;

/**
 * 创建百分比折扣促销
 */
function create_percentage_discount_promotion(string $name, int $percentage, array $conditions = []) {
  // 构建促销数据
  $promotion_data = [
    'name' => $name,
    'status' => TRUE,
    'priority' => 10,
  ];
  
  // 添加折扣行动
  $discount_action = new PercentageDiscount();
  $discount_action->setConfiguration([
    'discount_percentage' => $percentage,
    'applies_to' => 'cart_total',
  ]);
  
  $promotion_data['actions'][] = $discount_action->getPluginId();
  $promotion_data['action_configuration'] = [
    $discount_action->getPluginId() => $discount_action->getConfiguration(),
  ];
  
  // 添加条件
  if (!empty($conditions)) {
    foreach ($conditions as $condition_type => $condition_config) {
      $promotion_data['conditions'][] = $condition_type;
      $promotion_data['condition_configuration'][$condition_type] = $condition_config;
    }
  }
  
  // 创建并保存促销实体
  $promotion = Promotion::create($promotion_data);
  $promotion->save();
  
  return $promotion;
}

// 使用示例
$black_friday_sale = create_percentage_discount_promotion(
  'Black Friday 30% Off',
  30,
  [
    'commerce_cart:min_cart_value' => ['min_value' => 50],
    'commerce_cart:user_is_logged_in' => [],
  ]
);
```

### 2. 创建买 X 送 Y 促销

```php
use Drupal\promotions\Plugin\PromotionAction\BOGODeal;

/**
 * 创建 BOGO（买 X 送 Y）促销
 */
function create_bogo_promotion(string $name, int $buy_quantity, int $free_quantity, 
                                array $product_ids = [], array $conditions = []) {
  
  $promotion_data = [
    'name' => $name,
    'status' => TRUE,
    'priority' => 15,
  ];
  
  // 添加 BOGO 行动
  $bogo_action = new BOGODeal();
  $bogo_action->setConfiguration([
    'buy_quantity' => $buy_quantity,
    'free_quantity' => $free_quantity,
    'apply_to_same_product' => TRUE,
  ]);
  
  $promotion_data['actions'][] = $bogo_action->getPluginId();
  $promotion_data['action_configuration'][$bogo_action->getPluginId()] 
    = $bogo_action->getConfiguration();
  
  // 条件：特定商品或分类
  if (!empty($product_ids)) {
    $promotion_data['conditions'][] = 'commerce_product:products';
    $promotion_data['condition_configuration']['commerce_product:products'] = [
      'product_ids' => $product_ids,
    ];
  }
  
  $promotion = Promotion::create($promotion_data);
  $promotion->save();
  
  return $promotion;
}

// 使用示例 - 买 2 送 1
$tshirt_bo_go = create_bogo_promotion(
  'T-Shirt BOGO: Buy 2 Get 1 Free',
  2,
  1,
  [101, 102, 103], // T-shirt 产品 ID 列表
  [
    'commerce_cart:user_is_logged_in' => [],
  ]
);
```

### 3. 创建满减优惠券

```php
use Drupal\promo_code\Entity\CouponCode;

/**
 * 创建满减优惠券
 */
function create_fixed_amount_coupon(string $code, float $amount, array $restrictions = []) {
  
  $coupon_data = [
    'code' => strtoupper($code),
    'value' => $amount,
    'type' => 'fixed', // fixed / percentage
    'status' => TRUE,
    'usage_limit' => NULL, // NULL = unlimited
    'user_usage_limit' => 1, // 每个用户只能用一次
    'created_by' => \Drupal::currentUser()->id(),
  ];
  
  // 添加限制条件
  if (!empty($restrictions)) {
    if (isset($restrictions['minimum_order'])) {
      $coupon_data['minimum_order'] = $restrictions['minimum_order'];
    }
    
    if (isset($restrictions['valid_from'])) {
      $coupon_data['valid_from'] = strtotime($restrictions['valid_from']);
    }
    
    if (isset($restrictions['expires_at'])) {
      $coupon_data['expires_at'] = strtotime($restrictions['expires_at']);
    }
    
    if (isset($restrictions['applicable_categories'])) {
      $coupon_data['applicable_categories'] = $restrictions['applicable_categories'];
    }
    
    if (isset($restrictions['excluded_products'])) {
      $coupon_data['excluded_products'] = $restrictions['excluded_products'];
    }
  }
  
  $coupon = CouponCode::create($coupon_data);
  $coupon->save();
  
  return $coupon;
}

// 批量生成优惠券
function generate_batch_coupons(int $count, float $discount_value, string $prefix = 'SAVE') {
  $coupons = [];
  
  for ($i = 0; $i < $count; $i++) {
    $suffix = strtoupper(substr(md5(uniqid()), 0, 4));
    $code = "{$prefix}{$suffix}";
    
    $coupon = create_fixed_amount_coupon(
      $code,
      $discount_value,
      [
        'minimum_order' => 50,
        'expires_at' => '+90 days',
      ]
    );
    
    $coupons[] = $coupon->getCode();
  }
  
  return $coupons;
}

// 使用示例
$email_campaign_codes = generate_batch_coupons(1000, 10.00, 'SPRING2026');
// 返回：['SAVEABCD', 'SAVEEFGH', ...]
```

### 4. 检查并应用促销到购物车

```php
use Drupal\promotions\Entity\PromotionRuleSet;
use Drupal\promotions\ServiceProvider\PromotionService;

/**
 * 为订单计算最佳促销组合
 */
class CartPromotionCalculator {
  
  protected $promotionService;
  
  public function __construct(PromotionService $promotion_service) {
    $this->promotionService = $promotion_service;
  }
  
  /**
   * 获取购物车适用的所有促销
   */
  public function getApplicablePromotions(CartInterface $cart): array {
    $applicable = [];
    
    // 获取所有激活的促销
    $promotions = \Drupal::entityTypeManager()
      ->getStorage('promotion')
      ->loadByProperties(['status' => TRUE]);
    
    foreach ($promotions as $promotion) {
      // 检查是否适用于当前购物车
      if ($this->checkApplicability($promotion, $cart)) {
        $applicable[] = $promotion;
      }
    }
    
    // 按优先级排序
    usort($applicable, function($a, $b) {
      return $b->getPriority() <=> $a->getPriority();
    });
    
    return $applicable;
  }
  
  /**
   * 检查促销是否适用于购物车
   */
  protected function checkApplicability(Promotion $promotion, CartInterface $cart): bool {
    // 检查时间范围
    if (!$this->isTimeValid($promotion)) {
      return FALSE;
    }
    
    // 检查用户权限
    if (!$this->checkUserEligibility($promotion, $cart)) {
      return FALSE;
    }
    
    // 检查购物车条件
    if (!$this->checkCartConditions($promotion, $cart)) {
      return FALSE;
    }
    
    return TRUE;
  }
  
  /**
   * 检查时间有效性
   */
  protected function isTimeValid(Promotion $promotion): bool {
    $now = REQUEST_TIME;
    $start = $promotion->getStartDate();
    $end = $promotion->getEndDate();
    
    if ($start && $now < $start) {
      return FALSE;
    }
    
    if ($end && $now > $end) {
      return FALSE;
    }
    
    return TRUE;
  }
  
  /**
   * 检查用户资格
   */
  protected function checkUserEligibility(Promotion $promotion, CartInterface $cart): bool {
    $user = $cart->getOwner();
    
    // 检查登录状态要求
    if ($promotion->requiresLogin() && !$user->isAuthenticated()) {
      return FALSE;
    }
    
    // 检查组别要求
    $allowed_groups = $promotion->getTargetGroups();
    if (!empty($allowed_groups)) {
      $user_groups = $user->getRoles();
      $has_permission = FALSE;
      
      foreach ($allowed_groups as $group) {
        if (in_array($group, $user_groups)) {
          $has_permission = TRUE;
          break;
        }
      }
      
      if (!$has_permission) {
        return FALSE;
      }
    }
    
    return TRUE;
  }
  
  /**
   * 检查购物车条件
   */
  protected function checkCartConditions(Promotion $promotion, CartInterface $cart): bool {
    $conditions = $promotion->getConditions();
    
    foreach ($conditions as $condition) {
      if (!$condition->evaluate($cart)) {
        return FALSE;
      }
    }
    
    return TRUE;
  }
  
  /**
   * 计算最优折扣方案
   */
  public function calculateBestDiscount(array $applicable_promotions, CartInterface $cart): float {
    $max_discount = 0;
    
    foreach ($applicable_promotions as $promotion) {
      $discount_amount = $promotion->calculateDiscount($cart);
      
      if ($discount_amount > $max_discount) {
        $max_discount = $discount_amount;
      }
    }
    
    return $max_discount;
  }
}
```

### 5. 应用优惠券到结账流程

```php
use Drupal\promo_code\Service\CouponValidationService;

/**
 * 处理优惠券代码输入
 */
class CheckoutCouponProcessor {
  
  protected $validation_service;
  
  public function __construct(CouponValidationService $validation_service) {
    $this->validation_service = $validation_service;
  }
  
  /**
   * 验证并应用优惠券
   */
  public function validateAndApply(string $coupon_code, OrderInterface $order) {
    // 验证优惠券
    $validation_result = $this->validation_service->validate($coupon_code, $order);
    
    if (!$validation_result->isValid()) {
      throw new \Exception($validation_result->getMessage());
    }
    
    // 检查该订单是否已使用该优惠券
    if ($this->orderAlreadyUsesCoupon($order->id(), $coupon_code)) {
      throw new \Exception('This coupon has already been used on this order.');
    }
    
    // 获取优惠券折扣值
    $coupon = CouponCode::loadByProperties(['code' => $coupon_code])->current();
    $discount_amount = $this->calculateCouponDiscount($coupon, $order);
    
    // 记录优惠券使用情况
    db_insert('coupon_order_usage')
      ->fields([
        'coupon_code' => $coupon_code,
        'order_id' => $order->id(),
        'discount_amount' => $discount_amount,
        'used_at' => REQUEST_TIME,
        'uid' => $order->uid(),
      ])
      ->execute();
    
    // 增加优惠券使用计数
    $coupon->addUsageCount();
    $coupon->save();
    
    // 将折扣添加到订单项
    $discount_item = $this->createDiscountOrderItem($discount_amount, $coupon->getValueType());
    $order->addItem($discount_item);
    
    // 重新计算订单总价
    $order->recalculateTotals();
    
    return $discount_amount;
  }
  
  /**
   * 计算优惠券实际折扣金额
   */
  protected function calculateCouponDiscount(CouponCode $coupon, OrderInterface $order): float {
    $value = $coupon->getValue();
    $value_type = $coupon->getValueType(); // 'fixed' or 'percentage'
    
    // 获取订单 subtotal（不含税和运费）
    $subtotal = $order->getSubtotal()->getAmount();
    
    if ($value_type === 'percentage') {
      return ($subtotal * ($value / 100));
    } else {
      // fixed 金额，但不超过订单总额
      return min($value, $subtotal);
    }
  }
  
  /**
   * 创建折扣订单项
   */
  protected function createDiscountOrderItem(float $amount, string $value_type) {
    $discount_item = \Drupal::entityTypeManager()
      ->getStorage('commerce_order_item')
      ->create([
        'order_id' => NULL, // 稍后关联
        'sku' => 'DISCOUNT-' . strtoupper(substr(md5(time()), 0, 8)),
        'title' => $value_type === 'percentage' ? 'Percentage Discount' : 'Fixed Amount Discount',
        'price' => new Price(-abs($amount), $this->getDefaultCurrency()),
        'quantity' => 1,
        'unit_price' => new Price(-abs($amount), $this->getDefault_currency()),
      ]);
    
    return $discount_item;
  }
  
  /**
   * 检查订单是否已使用该优惠券
   */
  protected function orderAlreadyUsesCoupon(int $order_id, string $coupon_code): bool {
    $result = db_select('coupon_order_usage', 'c')
      ->fields('c', ['order_id'])
      ->condition('order_id', $order_id)
      ->condition('coupon_code', $coupon_code)
      ->exists()
      ->execute()
      ->fetchField();
    
    return (bool) $result;
  }
}
```

### 6. Twig 模板 - 购物车促销展示

```twig
{# templates/cart/promotion-display.html.twig #}
<div class="cart-promotions">
  {% if cart.has_applicable_promotions %}
    <div class="active-promotions">
      <h3>Applied Promotions</h3>
      
      {% for promo in cart.applied_promotions %}
        <div class="promotion-banner">
          <span class="icon">🎉</span>
          <span class="message">{{ promo.display_message }}</span>
          <span class="savings">
            You save: <strong>{{ promo.discount_amount }} {{ currency }}</strong>
          </span>
        </div>
      {% endfor %}
    </div>
  {% endif %}
  
  <div class="available-promotions">
    <h3>You Might Also Qualify For:</h3>
    
    {% if cart.needs_minimum_for_free_shipping and not cart.is_qualifying_for_shipping %}
      <div class="promotion-card shipping-offer">
        <div class="progress-container">
          <div class="current-value" style="width: {{ cart.shipping_progress_percentage }}%">
            ${{ cart.subtotal }} of ${{ settings.free_shipping_threshold }}
          </div>
        </div>
        <p>Add <strong>${{ remaining_for_free_shipping }}</strong> more to get FREE shipping!</p>
      </div>
    {% endif %}
    
    {% if active_promotions are empty %}
      <div class="no-promotions-message">
        <p>No current promotions apply to your cart.</p>
        <a href="/shop?sale=true">Browse sale items</a>
      </div>
    {% else %}
      <ul class="active-promotion-list">
        {% for promo in active_promotions %}
          <li>✅ {{ promo.name }}: {{ promo.description }}</li>
        {% endfor %}
      </ul>
    {% endif %}
  </div>
  
  <div class="coupon-code-input">
    <h3>Have a Promo Code?</h3>
    <form class="coupon-form" method="post" action="{{ path('cart.add_coupon') }}">
      <div class="input-group">
        <input type="text" 
               name="coupon_code" 
               placeholder="Enter code here..." 
               required
               autocomplete="off">
        <button type="submit" class="btn btn-primary">Apply</button>
      </div>
    </form>
    
    {% if last_coupon_error %}
      <div class="alert alert-danger">{{ last_coupon_error }}</div>
    {% elseif last_coupon_success %}
      <div class="alert alert-success">{{ last_coupon_success }}</div>
    {% endif %}
  </div>
</div>
```

---

## 📋 数据表结构

### promotions
促销规则主表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY | 自增 ID |
| name | VARCHAR(255) | NOT NULL | 促销名称 |
| description | TEXT | NULLABLE | 描述 |
| status | BOOLEAN | DEFAULT TRUE | 是否激活 |
| priority | INT | DEFAULT 0 | 优先级（越高越先应用） |
| created | DATETIME | NOT NULL | 创建时间 |
| changed | DATETIME | NOT NULL | 修改时间 |
| created_by | INT | NOT NULL | 创建者 |

### promotion_conditions
促销条件定义

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| condition_id | BIGINT | PRIMARY KEY | 条件 ID |
| promotion_id | INT | FOREIGN KEY | 关联促销 |
| plugin_id | VARCHAR(64) | NOT NULL | 插件 ID |
| configuration | JSON | NOT NULL | 配置参数（JSON） |

### promotion_actions
促销行动定义

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| action_id | BIGINT | PRIMARY KEY | 行动 ID |
| promotion_id | INT | FOREIGN KEY | 关联促销 |
| plugin_id | VARCHAR(64) | NOT NULL | 插件 ID |
| configuration | JSON | NOT NULL | 配置参数（JSON） |

### coupon_redemption_log
优惠券使用记录

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| log_id | BIGINT | PRIMARY KEY | 日志 ID |
| coupon_code | VARCHAR(64) | NOT NULL | 优惠券代码 |
| order_id | INT | NOT NULL | 关联订单 |
| discount_amount | DECIMAL(10,2) | NOT NULL | 折扣金额 |
| uid | INT | NOT NULL | 用户 ID |
| redeemed_at | DATETIME | NOT NULL | 使用时间 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\promotions\Unit\PromotionCalculationTest;

class PromotionLogicTest extends UnitTestCaseBase {
  
  public function testPercentageDiscount() {
    $promotion = create_percentage_discount_promotion('20% Off', 20);
    $cart = $this->createCartWithTotal(100);
    
    $discount = $promotion->calculateDiscount($cart);
    
    $this->assertEquals(20.00, $discount);
  }
  
  public function testBOGOPromotion() {
    $promotion = create_bogo_promotion('Buy 2 Get 1', 2, 1, [101]);
    $cart = $this->createCartWithQuantity(101, 3); // 3 件同款商品
    
    $discount = $promotion->calculateDiscount($cart);
    
    // 第 3 件免费 = $29.99
    $this->assertEquals(29.99, $discount);
  }
  
  public function testMultiplePromotionsApplication() {
    $cart = $this->createCartWithTotal(100);
    $calculator = new CartPromotionCalculator();
    
    // 创建多个促销
    $promo1 = create_percentage_discount_promotion('First 10%', 10);
    $promo2 = create_fixed_amount_coupon('FIXED10', 10);
    
    $applicable = [$promo1, $promo2];
    
    // 应该选择最大的折扣（这里假设都是$10，选第一个）
    $best_discount = $calculator->calculateBestDiscount($applicable, $cart);
    
    $this->assertEquals(10.00, $best_discount);
  }
  
  public function testCouponExpiration() {
    // 创建过期的优惠券
    $expired_coupon = create_fixed_amount_coupon('EXPIRED', 10, [
      'expires_at' => '-1 day',
    ]);
    
    $order = $this->createEmptyOrder();
    $processor = new CheckoutCouponProcessor();
    
    $this->expectException(Exception::class);
    $processor->validateAndApply('EXPIRED', $order);
  }
}
```

### 集成测试

```gherkin
Feature: Shopping Cart Promotions
  As a shopper
  I want to see and use promotional discounts
  
  Scenario: Applying percentage discount at checkout
    Given my cart total is $100
    And there is a "20% OFF SALE" promotion active
    When I proceed to checkout
    Then the discount should be automatically applied
    And I should pay only $80
  
  Scenario: Using a coupon code
    Given I have a coupon code "SAVE20"
    And my cart total is $50
    When I enter the code at checkout
    And submit the form
    Then the $10 discount should be applied
    And I should see a confirmation message
  
  Scenario: Buying with BOGO promotion
    Given there is a "Buy 2 Get 1 Free" promotion on T-shirts
    And I add 3 T-shirts to cart
    Then I should pay for only 2 shirts
    And the cheapest one should be free
  
  Scenario: Minimum order requirement
    Given a promotion requires minimum $75 order
    And my cart total is $60
    When I try to use the coupon
    Then I should see an error message
    And the coupon should not be applied
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算公式 | 目标值 |
|------|---------|--------|
| **促销参与率** | (参与促销订单 / 总订单) × 100% | > 30% |
| **优惠券核销率** | (使用的优惠券 / 发行的优惠券) × 100% | > 20% |
| **平均折扣率** | SUM(discount) / SUM(order_total) | 10-20% |
| **促销 ROI** | (增量销售额 - 促销成本) / 促销成本 | > 2.0 |
| **促销有效期利用率** | (有效使用 / 总发行) × 100% | > 60% |

### 日志命令

```bash
# 查看促销使用情况
drush watchdog-view promotions --count=50

# 查询最畅销的促销
drush sql-query "SELECT promotion_id, COUNT(*) as usage_count FROM promotion_usage GROUP BY promotion_id ORDER BY usage_count DESC LIMIT 10"

# 导出优惠券统计报告
drush php-script export_promotion_report

# 清理过期的促销
drush prom:expire
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| E-commerce Promotion Strategies | https://www.shopify.com/blog/promotion-strategies |
| Dynamic Pricing Best Practices | https://www.retailmenot.com/blog/dynamic-pricing-best-practices |

---

## 🆘 常见问题

### Q1: 如何防止多重折扣叠加造成损失？

**答案**：
```php
// 1. 设置最大折扣比例限制
$config['promotions.settings']['max_discount_percentage'] = 50;

// 2. 限制可同时应用的促销数量
$config['promotions.settings']['max_concurrent_promotions'] = 2;

// 3. 在代码中强制执行
class SafeDiscountCalculator {
  
  public function calculateSafeDiscount(array $promotions, CartInterface $cart): float {
    $total_discount = 0;
    $order_total = $cart->getSubtotal()->getAmount();
    $max_allowed = $order_total * 0.5; // 最多 50% 折扣
    
    foreach ($promotions as $promo) {
      $discount = $promo->calculateDiscount($cart);
      $total_discount += $discount;
      
      // 检查是否超过最大允许
      if ($total_discount > $max_allowed) {
        $total_discount = $max_allowed;
        break;
      }
    }
    
    return $total_discount;
  }
}
```

### Q2: 如何处理促销冲突？

**答案**：
```php
// 优先级规则
$config['promotions.settings']['conflict_resolution'] = 'highest_priority';

// 手动设置优先级
$promotion->setPriority(100)->save(); // 高优先级
$promotion->setPriority(10)->save();  // 低优先级
```

### Q3: 如何实现季节性定时促销？

**答案**：
```php
use Drupal\task\ScheduledTask;

/**
 * 创建周期性促销任务
 */
function schedule_seasonal_promotions() {
  // 黑五促销
  ScheduledTask::create([
    'name' => 'Black Friday Sale Setup',
    'callback' => [\Drupal\promotions\Plugin\Action\SetupPromotion::class, 'setup'],
    'arguments' => [['promotion_name' => 'Black Friday', 'discount' => 30]],
    'schedule' => '0 0 27 11 *', // 每年 11 月 27 日零点
  ])->save();
  
  // 圣诞节促销
  ScheduledTask::create([
    'name' => 'Christmas Sale',
    'callback' => [\Drupal\promotions\Plugin\Action\SetupPromotion::class, 'setup'],
    'arguments' => [['promotion_name' => 'Christmas', 'discount' => 20]],
    'schedule' => '0 0 25 12 *', // 每年 12 月 25 日
  ])->save();
}
```

---

**大正，commerce-promotions.md 已补充完成。继续下一个...** 🚀
