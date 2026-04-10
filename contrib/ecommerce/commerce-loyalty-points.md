---
name: commerce-loyalty-points
description: Complete guide to Commerce Loyalty Points for reward programs, points accumulation and redemption.
---

# Commerce Loyalty Points - 积分奖励系统 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Loyalty Points 是 Drupal Commerce 完整的会员忠诚度管理系统，提供积分累积、兑换优惠券、会员等级、活动激励等功能，帮助企业建立长期客户关系并提升复购率。

### 核心功能
- ✅ **消费积分累积** - 根据订单金额自动计算积分
- ✅ **积分兑换折扣券** - 积分可兑换优惠券或直接抵扣现金
- ✅ **会员等级系统** - 基于累计积分/消费金额分级管理
- ✅ **生日/节日奖励** - 特殊日期赠送积分或优惠券
- ✅ **积分有效期管理** - 支持积分过期和提醒机制
- ✅ **积分交易历史** - 完整的积分收支记录
- ✅ **推荐好友奖励** - 邀请朋友获得额外积分
- ✅ **任务成就系统** - 完成特定行为获取积分（首次评论、分享等）
- ✅ **积分转让** - 用户间积分转移（可选）
- ✅ **报表分析** - 积分发放与消耗统计

### 适用场景
- B2C 会员制电商（零售、餐饮、美妆等）
- 高频消费零售业
- 需要客户留存和复购的业务
- SaaS 订阅平台（会员级别管理）
- 连锁门店会员体系
- O2O 线上线下融合业务

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- Mail API 配置完成

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装忠诚度和积分模块
composer require drupal/loyalty_points

# 启用相关模块
drush en loyalty_points points_system --yes

# 更新数据库
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块
drush dl loyalty_points

# 2. 启用模块
drush en loyalty_points --yes

# 3. 运行数据库更新
drush updatedb --yes
```

---

## ⚙️ 基础配置

### 1. 启用模块

```bash
drush en loyalty_points --yes
```

### 2. 创建积分规则

```
路径：/admin/config/store/points/rules
```

| 规则名称 | 触发条件 | 积分数值 | 说明 |
|---------|---------|---------|------|
| 消费奖励 | 订单支付成功 | 每$1 = 1 积分 | 基础消费积分 |
| 新客注册 | 新用户注册 | +50 积分 | 欢迎礼金 |
| 首次购买 | 第一次下单 | +100 积分 | 首单奖励 |
| 生日奖励 | 账户设置生日当天 | +200 积分 | 月度特权 |
| 撰写评论 | 商品评价发布 | +20 积分 | UGC 激励 |
| 社交分享 | 分享到社交平台 | +10 积分/次 | 拉新激励 |
| 签到奖励 | 每日登录签到 | 连续签到递增 | 活跃度培养 |
| 推荐好友 | 朋友通过邀请注册 | +50 积分 | 裂变增长 |

### 3. 配置积分汇率

```yaml
earning_rules:
  purchase:
    base_rate: 1           # 基础汇率：$1 = 1 积分
    minimum_order: 10      # 最低订单额
    bonus_categories:       # 分类加成
      electronics: 1.5     # 电子产品 1.5 倍
      fashion: 2.0         # 服装 2 倍
    
  registration:
    welcome_bonus: 50      # 注册奖励
    verify_email: 10       # 邮箱验证奖励
  
  social_actions:
    review: 20             # 写评论
    share_facebook: 10     # Facebook 分享
    share_twitter: 10      # Twitter 分享
    refer_friend: 50       # 推荐好友

redemption_rules:
  discount_coupons:
    '100_points': '$1.00 coupon'
    '500_points': '$5.00 coupon'
    '1000_points': '$10.00 coupon'
    '5000_points': '$50.00 coupon'
  
  direct_discount:
    enable: true
    max_discount_percentage: 10  # 最大抵扣比例 10%
```

### 4. 设置会员等级

```yaml
membership_levels:
  bronze:
    name: "Bronze Member"
    icon: "🥉"
    min_points: 0
    benefits:
      - Standard points earning
      - Birthday bonus
  
  silver:
    name: "Silver Member"
    icon: "🥈"
    min_points: 1000
    benefits:
      - 1.2x points multiplier
      - Free shipping over $50
      - Early access to sales
  
  gold:
    name: "Gold Member"
    icon: "🥇"
    min_points: 5000
    benefits:
      - 1.5x points multiplier
      - Free shipping always
      - VIP customer support
      - Exclusive events
  
  platinum:
    name: "Platinum Member"
    icon: "💎"
    min_points: 10000
    benefits:
      - 2x points multiplier
      - Personal shopper
      - Annual gift
      - Private sales
```

### 5. 配置积分有效期

```
路径：/admin/config/store/points/settings
```

| 选项 | 默认值 | 说明 |
|------|--------|------|
| Enable expiration | ❌ No | 是否启用过期 |
| Expiration period | 365 days | 有效期时长 |
| Expiration type | Rolling | 滚动过期（先进先出） |
| Show remaining_days | ✅ Yes | 显示剩余天数 |
| Send reminder | ✅ Yes | 发送到期提醒邮件 |
| Reminder frequency | Weekly | 提醒频率（过期前 30 天开始每周） |

---

## 💻 代码示例

### 1. 计算订单积分

```php
use Drupal\loyalty_points\Plugin\PointsEarning\EarnPointsByPurchase;
use Drupal\commerce_order\Entity\Order;

/**
 * 计算订单应获得的积分
 */
class OrderPointsCalculator {
  
  /**
   * 计算订单积分总额
   */
  public function calculate(Order $order): int {
    $total_points = 0;
    
    // 1. 计算基础积分（按订单金额）
    $base_points = $this->calculateBasePoints($order);
    $total_points += $base_points;
    
    // 2. 计算分类奖金
    $category_bonus = $this->calculateCategoryBonus($order);
    $total_points += $category_bonus;
    
    // 3. 应用会员等级加成
    $member_multiplier = $this->getMemberMultiplier($order->uid());
    $total_points = (int) ($total_points * $member_multiplier);
    
    // 4. 添加促销加成
    if ($this->hasPromotionBonus($order)) {
      $promotional_points = $this->getPromotionalPoints($order);
      $total_points += $promotional_points;
    }
    
    return max(0, $total_points);
  }
  
  /**
   * 计算基础积分（订单金额 × 汇率）
   */
  protected function calculateBasePoints(Order $order): int {
    $settings = \Drupal::config('loyalty_points.settings');
    $base_rate = $settings->get('earning_rules.purchase.base_rate') ?? 1;
    
    // 排除税费和运费
    $amount_to_calculate = $order->getTotalAmount()
      ->subtract($order->getTotalTax())
      ->subtract($order->getShippingTotal());
    
    return (int) floor($amount_to_calculate->getAmount() * $base_rate);
  }
  
  /**
   * 计算分类奖金
   */
  protected function calculateCategoryBonus(Order $order): int {
    $bonus_multiplier = \Drupal::config('loyalty_points.settings')
      ->get('earning_rules.purchase.bonus_categories');
    
    $extra_points = 0;
    
    foreach ($order->getItems() as $item) {
      $variation = $item->getProductVariation();
      $categories = $variation->getCategories();
      
      foreach ($categories as $category) {
        $multiplier = $bonus_multiplier[$category->id()] ?? 1;
        
        if ($multiplier > 1) {
          $points_from_item = $item->getQuantity() 
            * $item->getPrice()->getAmount() 
            * (floatval($multiplier) - 1);
          
          $extra_points += $points_from_item;
        }
      }
    }
    
    return (int) floor($extra_points);
  }
  
  /**
   * 获取会员等级乘数
   */
  protected function getMemberMultiplier(int $user_id): float {
    $points = \Drupal::entityTypeManager()
      ->getStorage('loyalty_points_balance')
      ->loadByProperties(['uid' => $user_id])
      ->current()
      ->getBalance();
    
    $levels = \Drupal::config('loyalty_points.membership_levels');
    
    foreach ($levels as $level_name => $level_data) {
      if ($points >= $level_data['min_points']) {
        return $levels->get("{$level_name}.benefits")['multiplier'] ?? 1;
      }
    }
    
    return 1.0;
  }
}
```

### 2. 发放积分到用户账户

```php
use Drupal\loyalty_points\Entity\PointsTransaction;
use Drupal\loyalty_points\Entity\PointsBalance;

/**
 * 向用户发放积分
 */
function credit_user_points(UserInterface $user, int $points, string $reason, array $context = []) {
  // 查找或创建余额记录
  $balance = PointsBalance::loadByProperties([
    'uid' => $user->id(),
  ])->current();
  
  if (!$balance) {
    $balance = PointsBalance::create([
      'uid' => $user->id(),
      'balance' => 0,
    ]);
    $balance->save();
  }
  
  // 创建交易记录
  $transaction = PointsTransaction::create([
    'uid' => $user->id(),
    'type' => 'credit',
    'amount' => $points,
    'reason' => $reason,
    'source_type' => $context['source_type'] ?? null,
    'source_id' => $context['source_id'] ?? null,
    'reference' => $context['reference'] ?? null,
    'created' => REQUEST_TIME,
  ]);
  
  $transaction->save();
  
  // 更新余额
  $new_balance = $balance->getBalance() + $points;
  $balance->setBalance($new_balance);
  $balance->save();
  
  // 检查是否需要升级会员等级
  $this->checkMembershipUpgrade($user, $new_balance);
  
  // 发送通知
  send_points_credit_notification($user, $points, $reason);
  
  return $transaction;
}

/**
 * 扣除积分（用于兑换）
 */
function debit_user_points(UserInterface $user, int $points, string $reason, array $context = []) {
  $balance = PointsBalance::loadByProperties([
    'uid' => $user->id(),
  ])->current();
  
  if (!$balance || $balance->getBalance() < $points) {
    throw new \Exception('Insufficient points balance.');
  }
  
  // 检查是否有即将过期的积分
  $expire_warning = FALSE;
  if (\Drupal::config('loyalty_points.settings')->get('enable_expiration')) {
    $expire_warning = check_soon_expiry($balance, $user);
  }
  
  // 创建扣减交易记录
  $transaction = PointsTransaction::create([
    'uid' => $user->id(),
    'type' => 'debit',
    'amount' => $points,
    'reason' => $reason,
    'source_type' => $context['source_type'] ?? null,
    'source_id' => $context['source_id'] ?? null,
    'reference' => $context['reference'] ?? null,
    'expiration_warning' => $expire_warning,
    'created' => REQUEST_TIME,
  ]);
  
  $transaction->save();
  
  // 更新余额
  $new_balance = $balance->getBalance() - $points;
  $balance->setBalance($new_balance);
  $balance->save();
  
  // 检查是否需要降级
  $this->checkMembershipDowngrade($user, $new_balance);
  
  // 发送通知
  send_points_debit_notification($user, $points, $reason);
  
  return $transaction;
}
```

### 3. 积分兑换优惠券

```php
use Drupal\promo_code\Entity\Coupon;

/**
 * 用积分兑换优惠券
 */
function redeem_points_for_coupon(UserInterface $user, int $points_amount) {
  // 验证积分余额
  $balance = PointsBalance::loadByProperties([
    'uid' => $user->id(),
  ])->current();
  
  if (!$balance || $balance->getBalance() < $points_amount) {
    throw new \Exception('Insufficient points balance.');
  }
  
  // 确定兑换的优惠券面额
  $coupon_value = determine_coupon_value($points_amount);
  
  // 生成唯一优惠码
  $coupon_code = strtoupper(substr(md5(uniqid(rand(), TRUE)), 0, 8));
  
  // 创建优惠券
  $coupon = Coupon::create([
    'code' => $coupon_code,
    'value' => $coupon_value,
    'type' => 'fixed',
    'usage_limit' => 1,
    'user_usage_limit' => 1,
    'expires_at' => REQUEST_TIME + (90 * DAY), // 90 天有效
    'status' => TRUE,
  ]);
  
  $coupon->save();
  
  // 扣除积分
  debit_user_points($user, $points_amount, 'redeemed_for_coupon', [
    'source_type' => 'coupon_redemption',
    'source_id' => $coupon->id(),
  ]);
  
  // 保存兑换记录
  db_insert('points_redeem_history')
    ->fields([
      'uid' => $user->id(),
      'points_spent' => $points_amount,
      'coupon_code' => $coupon_code,
      'coupon_value' => $coupon_value,
      'redeemed_at' => REQUEST_TIME,
    ])
    ->execute();
  
  // 发送邮件通知
  send_coupon_redeem_notification($user, $coupon_code, $coupon_value);
  
  return $coupon;
}

/**
 * 根据积分数量确定优惠券价值
 */
function determine_coupon_value(int $points_amount) {
  $rates = \Drupal::config('loyalty_points.settings')->get('redemption_rules.discount_coupons');
  
  foreach ($rates as $points_threshold => $coupon_value) {
    if ($points_amount >= intval(str_replace('_points', '', $points_threshold))) {
      return floatval(str_replace(['$', ' coupon'], '', $coupon_value));
    }
  }
  
  // 默认比例：100 积分 = $1
  return $points_amount / 100;
}
```

### 4. 会员等级升级检测

```php
use Drupal\loyalty_points\Plugin\PointsSystem\MembershipLevel;

/**
 * 检查并处理会员等级升级
 */
function check_membership_upgrade(UserInterface $user, int $new_balance) {
  $current_level = get_current_membership_level($user);
  $levels = \Drupal::config('loyalty_points.membership_levels');
  
  foreach ($levels as $level_name => $level_data) {
    if ($new_balance >= $level_data['min_points']) {
      // 发现可以升级的等级
      if ($current_level != $level_name && is_upgrade_level($current_level, $level_name)) {
        upgrade_member_level($user, $level_name, $new_balance);
      }
      break;
    }
  }
}

/**
 * 执行会员等级升级
 */
function upgrade_member_level(UserInterface $user, string $new_level, int $points) {
  $old_level = get_current_membership_level($user);
  $level_data = \Drupal::config('loyalty_points.membership_levels')->get($new_level);
  
  // 更新用户标签
  $user->addTag("membership_{$new_level}");
  $user->removeTag("membership_{$old_level}");
  $user->save();
  
  // 创建升级通知记录
  db_insert('membership_change_log')
    ->fields([
      'uid' => $user->id(),
      'from_level' => $old_level,
      'to_level' => $new_level,
      'trigger_points' => $points,
      'changed_at' => REQUEST_TIME,
    ])
    ->execute();
  
  // 发送升级通知
  send_membership_upgrade_notification($user, $old_level, $new_level, $level_data);
  
  // 给予首次升级奖励（可选）
  if ($old_level === 'bronze') {
    credit_user_points($user, 100, 'first_upgrade_bonus', [
      'source_type' => 'upgrade_bonus',
      'from_level' => $old_level,
      'to_level' => $new_level,
    ]);
  }
}

/**
 * 发送升级通知邮件
 */
function send_membership_upgrade_notification(UserInterface $user, $old_level, $new_level, $level_data) {
  $mail_manager = \Drupal::service('plugin.manager.mail');
  
  $mail_manager->send(
    'loyalty_points',
    'membership_upgrade',
    $user,
    [
      'new_level' => $level_data['name'],
      'icon' => $level_data['icon'],
      'benefits' => $level_data['benefits'],
      'previous_level' => ucfirst($old_level),
      'view_benefits_url' => Url::fromRoute('page.membership-benefits')->toString(),
    ]
  );
}
```

### 5. Twig 模板 - 会员中心页面

```twig
{# templates/loyalty/membership-dashboard.html.twig #}
<div class="membership-dashboard">
  <div class="header-section">
    <h1>Welcome, {{ user.display_name }}!</h1>
    
    <div class="current-membership">
      <div class="membership-badge">
        <span class="level-icon">{{ current_level.icon }}</span>
        <div class="level-info">
          <h2>{{ current_level.name }}</h2>
          <p class="join-date">Member since {{ joined_date }}</p>
        </div>
      </div>
      
      <a href="/membership/benefits" class="btn btn-outline">
        View Benefits
      </a>
    </div>
  </div>
  
  <div class="points-summary">
    <div class="points-card">
      <div class="label">Available Points</div>
      <div class="amount">{{ points_balance }}</div>
      <div class="expiry-warning" style="color: red;">
        {% if expiring_soon_count %}
          ⚠️ {{ expiring_soon_count }} points expire in {{ expiring_soon_days }} days
        {% endif %}
      </div>
    </div>
    
    <div class="points-history">
      <h3>Recent Transactions</h3>
      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Type</th>
            <th>Description</th>
            <th>Points</th>
          </tr>
        </thead>
        <tbody>
          {% for transaction in recent_transactions %}
            <tr>
              <td>{{ transaction.created|date('M d, Y') }}</td>
              <td>
                {% if transaction.type == 'credit' %}
                  <span class="badge badge-success">➕ Credit</span>
                {% else %}
                  <span class="badge badge-danger">➖ Debit</span>
                {% endif %}
              </td>
              <td>{{ transaction.reason }}</td>
              <td class="{{ transaction.type }}">
                {{ transaction.amount }} pts
              </td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
    </div>
  </div>
  
  <div class="progress-to-next-level">
    <h3>Progress to {{ next_level.name }}</h3>
    <div class="progress-bar-container">
      <div class="progress-bar-fill" style="width: {{ progress_percentage }}%">
        <span class="fill-text">{{ points_needed }} more points needed</span>
      </div>
    </div>
    
    <div class="next-level-benefits">
      <h4>Better rewards await:</h4>
      <ul>
        {% for benefit in next_level.benefits %}
          <li>{{ benefit }}</li>
        {% endfor %}
      </ul>
    </div>
  </div>
  
  <div class="redemption-center">
    <h3>Redeem Your Points</h3>
    
    <div class="coupon-options">
      {% for threshold, value in redemption_rates %}
        <div class="coupon-option">
          <div class="cost">{{ threshold }}</div>
          <div class="reward">{{ value }}</div>
          <button class="btn-redeem" data-threshold="{{ threshold }}" data-value="{{ value }}">
            Redeem Now
          </button>
        </div>
      {% endfor %}
    </div>
  </div>
  
  <div class="available-activities">
    <h3>Earn More Points</h3>
    
    <table class="activities-table">
      <thead>
        <tr>
          <th>Activity</th>
          <th>Points Reward</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Make a purchase</td>
          <td><strong>$1 = 1 point</strong></td>
          <td><a href="/shop">Shop Now</a></td>
        </tr>
        <tr>
          <td>Write a product review</td>
          <td><strong>+20 points</strong></td>
          <td><a href="/reviews/write">Write Review</a></td>
        </tr>
        <tr>
          <td>Share on social media</td>
          <td><strong>+10 points/share</strong></td>
          <td><a href="/social-share">Share</a></td>
        </tr>
        <tr>
          <td>Refer a friend</td>
          <td><strong>+50 points</strong></td>
          <td><a href="/refer-friends">Refer Now</a></td>
        </tr>
        <tr>
          <td>Daily check-in</td>
          <td><strong>+5-50 points</strong></td>
          <td><button class="btn-checkin">Check In</button></td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
```

---

## 📋 数据表结构

### loyalty_points_balance

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY | 自增 ID |
| uid | INT | FOREIGN KEY | 用户 ID |
| balance | INT | DEFAULT 0 | 当前余额 |
| lifetime_earned | INT | DEFAULT 0 | 终身累积 |
| lifetime_redeemed | INT | DEFAULT 0 | 终身消耗 |
| last_transaction | DATETIME | NULLABLE | 最后交易时间 |
| created | DATETIME | NOT NULL | 创建时间 |
| changed | DATETIME | NOT NULL | 更新时间 |

**索引**: UNIQUE INDEX `idx_uid` (uid)

### points_transaction

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| tid | BIGINT | PRIMARY KEY | 交易 ID |
| uid | INT | NOT NULL | 用户 ID |
| type | VARCHAR(10) | NOT NULL | credit/debit |
| amount | INT | NOT NULL | 积分数量 |
| reason | VARCHAR(255) | NOT NULL | 原因 |
| source_type | VARCHAR(50) | NULLABLE | 来源类型 |
| source_id | INT | NULLABLE | 来源 ID |
| reference | VARCHAR(100) | NULLABLE | 参考编号 |
| created | DATETIME | NOT NULL | 交易时间 |

**索引**:
- `idx_uid_created` (uid, created DESC)
- `idx_source` (source_type, source_id)

### membership_level_history

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| log_id | BIGINT | PRIMARY KEY | 日志 ID |
| uid | INT | NOT NULL | 用户 ID |
| from_level | VARCHAR(20) | NOT NULL | 原等级 |
| to_level | VARCHAR(20) | NOT NULL | 新等级 |
| trigger_points | INT | NOT NULL | 触发积分 |
| change_type | VARCHAR(10) | NOT NULL | upgrade/downgrade |
| changed_at | DATETIME | NOT NULL | 变更时间 |

### membership_settings

存储会员等级配置和权益定义

### points_redeem_history

记录积分兑换历史

| 字段 | 类型 | 说明 |
|------|------|------|
| record_id | BIGINT | 主键 |
| uid | INT | 用户 ID |
| points_spent | INT | 消耗的积分 |
| redemption_type | VARCHAR(50) | 兑换类型 |
| redemption_value | VARCHAR(100) | 兑换价值 |
| redeemed_at | DATETIME | 兑换时间 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\loyalty_points\Unit\PointsCalculatorTest;

class PointsCalculationTest extends UnitTestCaseBase {
  
  public function testBasicPurchasePoints() {
    $order = $this->createOrderWithAmount(100);
    $calculator = new OrderPointsCalculator();
    
    $points = $calculator->calculate($order);
    
    // 默认汇率 $1 = 1 point
    $this->assertEquals(100, $points);
  }
  
  public function testCategoryBonus() {
    // 电子产品 1.5 倍积分
    $order = $this->createElectronicsOrder(100);
    $calculator = new OrderPointsCalculator();
    
    $points = $calculator->calculate($order);
    
    // 100 + (100 * 0.5) = 150 points
    $this->assertEquals(150, $points);
  }
  
  public function testMembershipMultiplier() {
    $order = $this->createOrderWithAmount(100);
    $user = $this->createUserWithMembership('gold');
    
    $calculator = new OrderPointsCalculator();
    $points = $calculator->calculate($order, $user);
    
    // Gold 会员 1.5 倍
    $this->assertEquals(150, $points);
  }
  
  public function testMinimumOrderThreshold() {
    $order = $this->createOrderWithAmount(5);
    $calculator = new OrderPointsCalculator();
    
    // 低于最低订单额不获奖励
    $points = $calculator->calculate($order);
    $this->assertEquals(0, $points);
  }
}
```

### 集成测试

```gherkin
Feature: Loyalty Points Program
  As a registered customer
  I want to earn and redeem points
  
  Scenario: Earning points from purchase
    Given I am a Bronze member with 0 points
    And I make a $100 purchase
    Then I should receive 100 loyalty points
    And my account should show 100 total points
    And I should receive an email notification
  
  Scenario: Redeming points for coupon
    Given I have 500 points in my account
    When I redeem them for a $5 coupon
    Then my balance should decrease by 500
    And I should receive a coupon code: ABC12345
    And the coupon should be valid for 90 days
  
  Scenario: Membership level upgrade
    Given I have 9500 points (Silver member)
    And I earn 600 more points from purchases
    Then my status should upgrade to Gold member
    And I should receive new benefits
    And my points multiplier should increase to 1.5x
  
  Scenario: Points expiration
    Given I have 1000 points that expire in 30 days
    When 15 days pass without using them
    Then I should receive weekly reminder emails
    And after 30 days the points should be deducted
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算公式 | 目标值 |
|------|---------|--------|
| **积分活跃率** | (有积分变动的用户 / 总用户) × 100% | > 40% |
| **平均积分持有量** | SUM(balance) / ACTIVE_USERS | 500-1000 pts |
| **积分消耗率** | 消耗的积分 / 发放的积分 | 60-70% |
| **会员升级率** | 月内升级用户 / 总用户 | > 5% |
| **优惠券核销率** | 已使用的优惠券 / 发行的优惠券 | > 30% |

### 日志命令

```bash
# 查看积分相关日志
drush watchdog-view loyalty_points --count=50

# 查询积分余额异常的用户
drush sql-query "SELECT uid, balance FROM loyalty_points_balance WHERE balance < -100"

# 导出积分发放统计
drush php-script export_points_summary

# 清理过期积分
drush loyalty:expire-points
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| CRM Customer Loyalty Programs | https://www.salesforce.com/products/marketing-cloud/learn/articles/customer-loyalty-program/ |
| Points-Based Loyalty Systems | https://www.hubspot.com/loyalty-programs |

---

## 🆘 常见问题

### Q1: 如何防止刷积分？

**答案**：
```php
// 1. 限制每日 earning 上限
$config['loyalty_points.settings']['daily_earning_limit'] = 1000;

// 2. 检查异常模式
function detect_abnormal_earning(UserInterface $user) {
  $recent_transactions = load_recent_transactions($user, 24); // 最近 24 小时
  
  $credits = array_filter($recent_transactions, fn($t) => $t->type === 'credit');
  $total_credits = array_sum(array_map(fn($t) => $t->amount, $credits));
  
  if ($total_credits > \Drupal::config('loyalty_points.settings')->get('daily_earning_limit')) {
    flag_account_for_review($user);
    return FALSE;
  }
  
  return TRUE;
}

// 3. 验证码验证高风险操作
function add_captcha_to_high_risk_actions(FormStateInterface $form_state, $form_id) {
  if ($form_id == 'point_claim_form' && !is_trusted_user(\Drupal::currentUser())) {
    $form['captcha'] = [
      '#type' => 'captcha',
      '#captcha_type' => 'easy_captcha',
    ];
  }
}
```

### Q2: 如何处理跨站点的积分同步？

**答案**：
```php
// 使用 Single Sign-On + Centralized Points Service
$config['loyalty_points.settings']['multi_site_sync'] = TRUE;

// API endpoint for sync
function points_sync_api_handler(Request $request) {
  $user = authenticate_api_token($request->headers->get('Authorization'));
  $site_id = $request->attributes->get('site_id');
  
  $balance = get_user_balance($user, $site_id);
  
  // 同步到其他站点
  sync_points_across_sites($user->id(), $balance, $site_id);
  
  return JsonResponse(['success' => TRUE, 'balance' => $balance]);
}
```

### Q3: 如何实现积分转让功能？

**答案**：
```php
/**
 * 允许用户之间转让积分
 */
function transfer_points(UserInterface $sender, UserInterface $recipient, int $amount) {
  // 验证双方权限
  if (!$sender->hasPermission('transfer points')) {
    throw new AccessDeniedException('Not authorized to transfer points.');
  }
  
  if ($sender->id() === $recipient->id()) {
    throw new \Exception('Cannot transfer points to yourself.');
  }
  
  // 检查余额
  $sender_balance = PointsBalance::loadByProperties(['uid' => $sender->id()])->current();
  if ($sender_balance->getBalance() < $amount) {
    throw new \Exception('Insufficient points balance.');
  }
  
  // 扣除发送方积分
  debit_user_points($sender, $amount, 'transfer_sent', [
    'source_type' => 'transfer',
    'recipient_id' => $recipient->id(),
  ]);
  
  // 增加接收方积分
  credit_user_points($recipient, $amount, 'transfer_received', [
    'source_type' => 'transfer',
    'sender_id' => $sender->id(),
  ]);
  
  // 记录转账日志
  db_insert('points_transfer_log')
    ->fields([
      'sender_id' => $sender->id(),
      'recipient_id' => $recipient->id(),
      'amount' => $amount,
      'transferred_at' => REQUEST_TIME,
    ])
    ->execute();
}
```

---

**大正，commerce-loyalty-points.md 已补充完成。继续下一个...** 🚀
