---
name: commerce-reengage
description: Complete guide to Commerce Reengage for cart recovery, abandoned cart emails, and customer re-engagement.
---

# Commerce Reengage - 购物车恢复与客户召回 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Reengage 提供完整的购物车放弃挽回和客户重新激活系统。通过自动化邮件序列、优惠券激励和行为追踪，帮助电商企业挽回大量因各种原因放弃结账的潜在销售，提升转化率。

### 核心功能
- ✅ **购物车放弃追踪** - 自动识别未完成的订单
- ✅ **自动化邮件序列** - 多层次触达（1h/24h/72h）
- ✅ **优惠券激励** - 限时折扣促进转化
- ✅ **短信通知支持** - 快速触达渠道
- ✅ **A/B 测试优化** - 测试不同文案和策略
- ✅ **转化率分析** - 详细的数据报表
- ✅ **个性化推荐** - 基于放弃商品推荐类似商品
- ✅ **用户分群策略** - VIP/新客差异化处理
- ✅ **跨渠道召回** - 邮件 + 短信 + App Push
- ✅ **智能发送时机** - 根据时区和学习算法优化

### 适用场景
- B2C 电商高 abandon rate（弃购率高）
- SaaS 订阅续费提醒
- 高客单价产品需要多次触达
- 需要复购增长的业务
- 多渠道营销整合

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- Mail API 配置完成
- Queue API enabled（用于异步任务）

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装重参与召回模块
composer require drupal/cart_recovery email_queue

# 启用相关模块
drush en cart_recovery email_queue reminder_queue --yes

# 更新数据库
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块
drush dl cart_recovery

# 2. 启用模块
drush en cart_recovery --yes

# 3. 运行数据库更新
drush updatedb --yes
```

---

## ⚙️ 基础配置

### 1. 启用模块

```bash
drush en cart_recovery --yes
```

### 2. 配置触发条件

```
路径：/admin/config/store/reengage/triggers
```

| 条件类型 | 判定规则 | 说明 |
|---------|---------|------|
| Cart Abandonment | Cart created but no checkout in 30min | 创建购物车但未结账超过 30 分钟 |
| Checkout Started | Checkout initiated but not completed | 开始结账但未完成支付 |
| Payment Failed | Payment transaction failed | 支付失败 |
| High Value Cart | Cart value > $200 | 高价值购物车特殊处理 |
| Returning Customer | User with >3 prior purchases | 老顾客优先召回 |
| New Customer First Cart | First cart from new user | 新用户首次购物车重点关注 |

### 3. 设置邮件序列模板

```yaml
abandoned_cart_sequence:
  email_1:
    delay_hours: 1          # 1 小时后发送
    subject_template: "Did you forget something? 🛒"
    sender_name: "Your Store Team"
    sender_email: "help@yourstore.com"
    
    content:
      greeting: "Hi {customer_first_name},"
      body: "You left some great items in your cart. They're waiting for you!"
      product_preview: true   # 显示商品缩略图
      call_to_action: "Complete Your Order"
      cta_url: "{cart_checkout_link}"
      
    personalization:
      include_product_images: true
      show_remaining_stock: true
    
  email_2:
    delay_hours: 24         # 24 小时后发送
    subject_template: "Still thinking about it?"
    discount_incentive:
      enabled: true
      discount_type: percentage
      discount_value: 10     # 10% off
      expiry_hours: 48       # 48 小时有效
      
    content:
      greeting: "Hi {customer_first_name},"
      body: "We noticed you haven't completed your order. As a special offer..."
      coupon_code_display: true
      
  email_3:
    delay_hours: 72         # 72 小时后发送
    subject_template: "Last chance! Your cart is expiring"
    urgency_message: 
      enabled: true
      message: "Your cart will be cleared in 24 hours!"
      
    content:
      urgency_tactics: ["low_stock_indicator", "countdown_timer"]
```

### 4. 配置优先级规则

```
/admin/config/store/reengage/settings
```

| 用户类型 | 处理策略 |
|---------|---------|
| VIP Members | 立即电话回访 + 专属客服跟进 |
| New Customers | 标准 3 封邮件序列 |
| Returning Customers | 2 封邮件 + 个性化优惠 |
| High Value Cart ($500+) | 人工跟进标记 + 高级优惠 |
| Anonymous Users | 仅发送一封提醒邮件 |

### 5. 设置发送频率限制

```yaml
sending_limits:
  emails_per_user_per_day: 2        # 每天每用户最多 2 封
  sms_per_user_per_week: 1          # 每周每用户最多 1 条短信
  phone_calls_per_month: 3          # 每月每用户最多 3 次电话
  exclude_recent_purchasers: 7 days # 最近 7 天购买过的不重复召回
```

---

## 💻 代码示例

### 1. 购物车放弃检测与记录

```php
use Drupal\commerce_cart\Entity\CartInterface;
use Drupal\reengage_entity\AbandonedCartRecord;

/**
 * 检测并记录购物车放弃事件
 */
class CartAbandonmentTracker {
  
  /**
   * 检查购物车是否被放弃
   */
  public function checkForAbandonment(CartInterface $cart): bool {
    // 获取最后一次活动
    $last_activity = \Drupal::cache('cart_last_activity')
      ->get("cart_{$cart->id()}");
    
    if (!$last_activity) {
      // 这是新的活跃购物车，记录活动时间
      $this->recordActivity($cart);
      return FALSE;
    }
    
    // 计算时间差
    $time_since_last_activity = REQUEST_TIME - $last_activity;
    $abandonment_threshold_minutes = 30;
    
    if ($time_since_last_activity >= ($abandonment_threshold_minutes * 60)) {
      // 超过阈值，视为放弃
      $this->markAsAbandoned($cart);
      return TRUE;
    }
    
    return FALSE;
  }
  
  /**
   * 记录购物车活动时间
   */
  protected function recordActivity(CartInterface $cart) {
    \Drupal::cache('cart_last_activity')
      ->set("cart_{$cart->id()}", REQUEST_TIME);
  }
  
  /**
   * 标记为已放弃并创建记录
   */
  protected function markAsAbandoned(CartInterface $cart) {
    // 检查是否已有放弃记录（避免重复）
    $existing = AbandonedCartRecord::loadByProperties([
      'cart_id' => $cart->id(),
      'status' => 'pending',
    ])->current();
    
    if ($existing) {
      return; // 已处理
    }
    
    // 创建新的放弃记录
    $abandoned_record = AbandonedCartRecord::create([
      'cart_id' => $cart->id(),
      'uid' => $cart->getOwner()->id(),
      'user_email' => $cart->getOwner()->getEmail(),
      'is_authenticated' => $cart->getOwner()->isAuthenticated(),
      'cart_total' => $cart->getTotalAmount()->toString(),
      'items_count' => count($cart->getItems()),
      'abandoned_at' => REQUEST_TIME,
      'status' => 'pending',
    ]);
    
    $abandoned_record->save();
    
    // 添加到待处理队列
    $this->addToReengagementQueue($abandoned_record);
    
    \Drupal::logger('reengage')
      ->info('Cart :cart_id marked as abandoned', [':cart_id' => $cart->id()]);
  }
  
  /**
   * 添加到重营销队列
   */
  protected function addToReengagementQueue(AbandonedCartRecord $record) {
    $queue = \Drupal::service('queue.cart_recovery');
    
    $queue->createItem([
      'record_id' => $record->id(),
      'scheduled_send_time' => REQUEST_TIME + (HOUR),  // 1 小时后
      'email_index' => 0,  // 第一封邮件
      'priority' => $this->calculatePriority($record),
    ]);
  }
  
  /**
   * 计算处理优先级
   */
  protected function calculatePriority(AbandonedCartRecord $record): int {
    $priority = 5;  // 默认中优先级
    
    // 高价值订单提升优先级
    $total = floatval($record->getCartTotal());
    if ($total > 500) {
      $priority -= 2;  // 高优先级 (-2)
    } elseif ($total > 200) {
      $priority -= 1;  // 中高优先级 (-1)
    }
    
    // VIP 客户提升优先级
    if ($record->isAuthenticated()) {
      $user = \Drupal\user\User::load($record->getUid());
      if ($this->isVIPMember($user)) {
        $priority -= 3;  // 最高优先级 (-3)
      }
    }
    
    return max(1, $priority);  // 保证最低 1
  }
}
```

### 2. 构建邮件序列

```php
use Drupal\mail\MailerInterface;

/**
 * 构建并发送放弃购物车邮件
 */
class AbandonedCartEmailBuilder {
  
  protected $mailer;
  protected $config;
  
  public function __construct(MailerInterface $mailer) {
    $this->mailer = $mailer;
    $this->config = \Drupal::config('reengage.abandoned_cart_sequence');
  }
  
  /**
   * 构建第 N 封邮件
   */
  public function buildEmail(int $email_index, AbandonedCartRecord $record): array {
    $email_config = $this->config->get("email_{$email_index}");
    
    if (!$email_config) {
      throw new \Exception("Email template for index {$email_index} not found.");
    }
    
    // 加载购物车详情
    $cart = \Drupal\commerce_cart\Entity\Cart::load($record->getCartId());
    
    // 解析内容模板
    $subject = $this->renderTemplate($email_config['subject_template'], [
      '{cart_total}' => $record->getCartTotal(),
    ]);
    
    $body_html = $this->buildEmailBody($email_config, $cart, $record);
    $body_text = strip_tags($body_html);
    
    // 添加促销码（如果配置了）
    $coupon_data = NULL;
    if (isset($email_config['discount_incentive'])) {
      $coupon_data = $this->generateIncentiveCoupon($record, $email_config['discount_incentive']);
      $body_html = $this->injectCouponToHTML($body_html, $coupon_data);
    }
    
    return [
      'to' => $record->getUserEmail(),
      'from' => $this->getDefaultSender(),
      'subject' => $subject,
      'body' => $body_text,
      'html' => $body_html,
      'template' => 'abandoned_cart_email_' . $email_index,
      'params' => [
        'cart_items' => $this->getProductPreviewData($cart),
        'checkout_url' => $cart->toUrl('checkout-page')->toString(),
        'coupon_code' => $coupon_data['code'] ?? NULL,
        'expiry_time' => $coupon_data['expires_at'] ?? NULL,
      ],
      'priority' => $email_config['priority'] ?? 'normal',
    ];
  }
  
  /**
   * 构建邮件主体 HTML
   */
  protected function buildEmailBody(array $config, CartInterface $cart, AbandonedCartRecord $record): string {
    // 使用 Twig 渲染模板
    $twig = \Drupal::service('twig.loader.themed_file_system');
    
    $template_data = [
      'customer_first_name' => $record->isAuthenticated() 
        ? \Drupal::entityTypeManager()->getStorage('user')->load($record->getUid())->getFirstName()
        : 'there',
      'cart_items' => $this->formatItemsForEmail($cart),
      'cart_total' => $record->getCartTotal(),
      'checkout_url' => $cart->toUrl('checkout-page')->toString(),
      'greeting' => $config['content']['greeting'] ?? 'Hello!',
      'body' => $config['content']['body'] ?? 'You left items in your cart.',
      'cta_button' => $config['content']['call_to_action'] ?? 'Return to Cart',
    ];
    
    // 添加紧迫感元素
    if (isset($config['urgency_message'])) {
      $template_data['urgency_message'] = $config['urgency_message']['enabled'] 
        ? $config['urgency_message']['message'] 
        : '';
    }
    
    return $twig->render('emails/abandoned-cart.html.twig', $template_data);
  }
  
  /**
   * 生成激励优惠券
   */
  protected function generateIncentiveCoupon(AbandonedCartRecord $record, array $incentive_config): array {
    $coupon_code = strtoupper(substr(md5(uniqid(rand())), 0, 8));
    
    $coupon = \Drupal\promo_code\Entity\CouponCode::create([
      'code' => $coupon_code,
      'value' => $incentive_config['discount_value'],
      'type' => $incentive_config['discount_type'] === 'percentage' ? 'percent' : 'fixed',
      'usage_limit' => 1,
      'user_usage_limit' => 1,
      'expires_at' => REQUEST_TIME + ($incentive_config['expiry_hours'] * HOUR),
      'status' => TRUE,
    ]);
    
    $coupon->save();
    
    return [
      'code' => $coupon_code,
      'value' => $incentive_config['discount_value'],
      'type' => $incentive_config['discount_type'],
      'expires_at' => $coupon->getExpiresAt(),
    ];
  }
  
  /**
   * 格式化商品列表用于邮件展示
   */
  protected function formatItemsForEmail(CartInterface $cart): array {
    $items = [];
    
    foreach ($cart->getItems() as $item) {
      $variation = $item->getProductVariation();
      $items[] = [
        'name' => $variation->getName(),
        'image' => $variation->getImage() ? $variation->getImage()->uri->url->toString() : null,
        'price' => $item->getPrice()->toString(),
        'quantity' => $item->getQuantity(),
        'product_url' => $variation->toUrl()->toString(),
      ];
    }
    
    return $items;
  }
}
```

### 3. 定时任务调度器

```php
use Drupal\queue\QueueRunnerInterface;

/**
 * 处理重营销队列
 */
class ReengagementQueueRunner {
  
  public function processPendingCampaigns() {
    $queue = \Drupal::service('queue.cart_recovery');
    
    // 获取即将发送的记录
    $items = $queue->getItems(['priority_low', 'priority_high', 'priority_normal'], 10);
    
    foreach ($items as $item) {
      $data = $item['data'];
      
      // 检查是否应该现在发送
      if (REQUEST_TIME >= $data['scheduled_send_time']) {
        $this->sendReengagementEmail($data['record_id'], $data['email_index']);
        
        // 从队列移除
        $queue->deleteItem($item['bid']);
      } else {
        // 放回队列（稍后重试）
        $queue->createItem($item['data'], $item['priority']);
      }
    }
  }
  
  /**
   * 发送邮件
   */
  protected function sendReengagementEmail(int $record_id, int $email_index) {
    $record = AbandonedCartRecord::load($record_id);
    
    if (!$record || $record->getStatus() !== 'pending') {
      return; // 记录不存在或已处理
    }
    
    $email_builder = new AbandonedCartEmailBuilder(\Drupal::service('plugin.manager.mail'));
    
    try {
      $email_data = $email_builder->buildEmail($email_index, $record);
      
      \Drupal::service('plugin.manager.mail')
        ->sendMultiple($email_data['to'], 'reengage', $email_data['template'], 'en', NULL, $email_data['from'], $email_data['params']);
      
      // 更新记录状态
      $record->setStatus('email_sent');
      $record->setLastSentEmail($email_index);
      $record->save();
      
      // 记录日志
      \Drupal::logger('reengage')
        ->info('Email sent to :email for cart :cart_id (email #{index})', [
          ':email' => $record->getUserEmail(),
          ':cart_id' => $record->getCartId(),
          ':index' => $email_index,
        ]);
      
      // 安排下一封邮件
      if ($email_index < 2) {
        $next_index = $email_index + 1;
        $delay_hours = match ($next_index) {
          1 => 24,
          2 => 48,
          default => 0,
        };
        
        $queue = \Drupal::service('queue.cart_recovery');
        $queue->createItem([
          'record_id' => $record_id,
          'scheduled_send_time' => REQUEST_TIME + ($delay_hours * HOUR),
          'email_index' => $next_index,
          'priority' => $record->getPriority(),
        ]);
      } else {
        // 完成序列，标记为已完成
        $record->setStatus('sequence_complete');
        $record->save();
      }
      
    } catch (\Exception $e) {
      // 发送失败，重试逻辑...
      \Drupal::logger('reengage')->error('Failed to send reengagement email: @message', ['@message' => $e->getMessage()]);
    }
  }
}
```

### 4. Twig 模板 - 放弃购物车邮件

```twig
{# templates/emails/abandoned-cart.html.twig #}
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>{{ subject }}</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  
  <div style="text-align: center; padding: 20px 0;">
    <img src="{{ site_url }}/sites/default/files/logo.png" alt="Store Logo" style="max-height: 50px;">
  </div>
  
  <h2 style="color: #2c3e50;">{{ greeting|raw }}</h2>
  
  <p>{{ body|raw }}</p>
  
  {% if urgency_message %}
    <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
      <strong>⏰ {{ urgency_message|raw }}</strong>
    </div>
  {% endif %}
  
  {% if coupon_code %}
    <div style="background-color: #d4edda; border: 2px dashed #28a745; padding: 20px; text-align: center; margin: 20px 0;">
      <p style="margin: 0; font-size: 14px; color: #155724;">Use this exclusive code:</p>
      <h3 style="margin: 10px 0; font-size: 24px; color: #155724;">{{ coupon_code }}</h3>
      <p style="margin: 5px 0; font-size: 12px; color: #155724;">
        Expires: {{ expiry_time|date('F d, Y h:i A') }}
      </p>
    </div>
  {% endif %}
  
  <h3>Your cart contains:</h3>
  
  <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
    {% for item in cart_items %}
      <tr style="border-bottom: 1px solid #eee;">
        <td style="padding: 15px 0;">
          {% if item.image %}
            <img src="{{ item.image }}" alt="{{ item.name }}" style="width: 60px; height: 60px; object-fit: cover; margin-right: 15px; vertical-align: middle;">
          {% endif %}
          <span style="vertical-align: middle;">
            {{ item.name }} × {{ item.quantity }}
          </span>
        </td>
        <td style="text-align: right; padding: 15px 0;">
          <strong>{{ item.price }}</strong>
        </td>
      </tr>
    {% endfor %}
    
    <tr style="background-color: #f8f9fa; font-weight: bold;">
      <td colspan="2" style="padding: 15px; text-align: right;">
        Total: {{ cart_total }}
      </td>
    </tr>
  </table>
  
  <div style="text-align: center; margin: 30px 0;">
    <a href="{{ checkout_url }}" 
       style="background-color: #007bff; color: white; padding: 15px 40px; text-decoration: none; border-radius: 5px; display: inline-block; font-weight: bold;">
      {{ cta_button|default('Return to Cart') }}
    </a>
  </div>
  
  <p style="text-align: center; font-size: 12px; color: #999; margin-top: 30px;">
    Questions? Reply to this email or contact our support team.<br>
    This offer expires in {{ expiry_days|default('48 hours') }}.
  </p>
  
</body>
</html>
```

---

## 📋 数据表结构

### abandoned_cart_record
放弃购物车记录表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY | 自增 ID |
| cart_id | INT | FOREIGN KEY | 关联购物车 |
| uid | INT | NOT NULL | 用户 ID |
| user_email | VARCHAR(255) | NOT NULL | 用户邮箱 |
| is_authenticated | BOOLEAN | DEFAULT FALSE | 是否登录 |
| cart_total | DECIMAL(10,2) | NOT NULL | 订单总额 |
| items_count | INT | NOT NULL | 商品数量 |
| abandoned_at | DATETIME | NOT NULL | 放弃时间 |
| status | VARCHAR(20) | DEFAULT 'pending' | pending/sent/converted/expired |
| last_sent_email | INT | DEFAULT 0 | 最后发送的邮件索引 |
| converted_at | DATETIME | NULLABLE | 转化时间 |
| converted_order_id | INT | NULLABLE | 转化订单 ID |

**索引**:
- `idx_uid` ON uid
- `idx_abandoned_at` ON abandoned_at DESC
- `idx_status` ON status

### reengage_analytics
重营销效果分析表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| analytics_id | BIGINT | PRIMARY KEY | 自增 ID |
| record_id | INT | NOT NULL | 关联记录 |
| event_type | VARCHAR(20) | NOT NULL | open/click/purchase |
| occurred_at | DATETIME | NOT NULL | 发生时间 |
| ip_address | VARCHAR(45) | NULLABLE | IP 地址 |
| user_agent | TEXT | NULLABLE | User-Agent |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\reengage\Unit\CartRecoveryTest;

class AbandonedCartLogicTest extends UnitTestCaseBase {
  
  public function testAbandonmentDetectionAfter30Minutes() {
    $cart = $this->createCartWithUser();
    $tracker = new CartAbandonmentTracker();
    
    // 初始活跃
    $this->assertFalse($tracker->checkForAbandonment($cart));
    
    // 模拟 30 分钟后
    $this->setCurrentTime(REQUEST_TIME + (30 * MINUTE));
    
    // 应该触发放弃
    $this->assertTrue($tracker->checkForAbandonment($cart));
  }
  
  public function testVIPCustomerHigherPriority() {
    $record = AbandonedCartRecord::create([
      'uid' => $this->createVIPUser()->id(),
      'cart_total' => '150.00',
    ]);
    
    $tracker = new CartAbandonmentTracker();
    $priority = $tracker->calculatePriority($record);
    
    // VIP + 中等金额应该是最高优先级 1
    $this->assertEquals(1, $priority);
  }
  
  public function testEmailSequenceTiming() {
    $record = $this->createAbandonedCartRecord();
    $builder = new AbandonedCartEmailBuilder();
    
    // 第一封应该在 1 小时后
    $email1_data = $builder->buildEmail(0, $record);
    $this->assertNotEmpty($email1_data['to']);
    
    // 第二封应该在 24 小时后
    $email2_data = $builder->buildEmail(1, $record);
    $this->assertArrayHasKey('coupon_code', $email2_data['params']);
  }
}
```

### 集成测试

```gherkin
Feature: Cart Recovery Campaign
  As a store owner
  I want to recover abandoned carts
  
  Scenario: Automated email sequence
    Given a customer abandons their cart after browsing
    When 1 hour passes
    Then they should receive the first reminder email
    And 24 hours later receive the discount incentive email
    And 72 hours later receive the final urgency email
  
  Scenario: Conversion tracking
    Given an abandoned cart email was sent
    When the customer clicks the link and completes purchase
    Then the abandoned cart record should be updated
    And conversion metrics should be recorded
    And no further emails should be sent
  
  Scenario: VIP customer treatment
    Given a VIP member abandons a high-value cart
    When the abandonment is detected
    Then they should receive priority processing
    And potentially a phone call from customer service
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算公式 | 行业基准 |
|------|---------|---------|
| **打开率** | (打开邮件数 / 发送总数) × 100% | 40-60% |
| **点击率** | (点击链接数 / 打开数) × 100% | 10-20% |
| **转化率** | (完成购买数 / 放弃数) × 100% | 10-15% |
| **收入挽回** | SUM(转化订单总额) | ROI > 5x |
| **平均挽回时间** | FROM abandonment TO purchase | < 48 小时 |

### 日志命令

```bash
# 查看重营销活动日志
drush watchdog-view reengage --count=50

# 查询转化率
drush sql-query "
  SELECT 
    COUNT(*) as total_abandoned,
    SUM(CASE WHEN status='converted' THEN 1 ELSE 0 END) as converted,
    ROUND(SUM(CASE WHEN status='converted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as recovery_rate
  FROM abandoned_cart_record
  WHERE abandoned_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
"

# 导出分析报告
drush php-script export_reengagement_report
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Cart Recovery Best Practices | https://www.klaviyo.com/blog/abandoned-cart-email-examples |
| Email Marketing Benchmarks | https://www.campaignmonitor.com/resources/guides/email-marketing-benchmarks/ |

---

## 🆘 常见问题

### Q1: 如何避免邮件骚扰用户？

**答案**：
```php
class EmailFrequencyController {
  
  private const MAX_EMAILS_PER_CART = 3;
  private const SESSION_COOLDOWN_HOURS = 24;
  
  public function shouldSendEmail(UserInterface $user, string $context): bool {
    // 检查历史发送次数
    $sent_count = $this->getRecentEmailCount($user, $context);
    if ($sent_count >= self::MAX_EMAILS_PER_CART) {
      return FALSE;
    }
    
    // 检查最近的互动
    $last_interaction = $this->getLastInteractionTime($user);
    if ($last_interaction && (REQUEST_TIME - $last_interaction) < (self::SESSION_COOLDOWN_HOURS * HOUR)) {
      return FALSE;
    }
    
    return TRUE;
  }
  
  public function recordEmailSent(UserInterface $user, string $context) {
    $key = "reengage_email_count_{$context}";
    $current = \Drupal::cache('reengage_stats')->get($key) ?? 0;
    \Drupal::cache('reengage_stats')->set($key, $current + 1);
  }
}
```

### Q2: 如何处理用户取消订阅？

**答案**：
```php
// 管理退订链接
function unsubscribe_from_reengage_emails(Request $request) {
  $token = $request->query->get('token');
  
  $unsubscribe_record = db_select('reengage_unsubscribe', 'u')
    ->fields('u')
    ->condition('token', $token)
    ->execute()
    ->fetchAssoc();
  
  if ($unsubscribe_record) {
    db_insert('reengage_preferences')
      ->fields([
        'uid' => $unsubscribe_record['uid'],
        'preference_type' => 'cart_recovery_emails',
        'allowed' => FALSE,
        'unsubscribed_at' => REQUEST_TIME,
      ])
      ->execute();
    
    return JsonResponse(['success' => TRUE, 'message' => 'You have been unsubscribed.']);
  }
}

// 发送邮件前检查偏好
if (!$this->userHasPermissionToSend(user_id, 'cart_recovery')) {
  // 跳过发送
}
```

### Q3: 如何优化发送时机？

**答案**：
```php
class SmartSendTimeOptimizer {
  
  public function calculateOptimalSendTime(UserInterface $user, AbandonedCartRecord $record): int {
    // 获取用户的历史打开时间偏好
    $preferred_hour = $this->getUserPreferredHour($user);
    
    if (!$preferred_hour) {
      // 默认策略：工作日晚上 7-9 点，周末下午 2-4 点
      return $this->getDefaultSendTime();
    }
    
    // 调整到最佳时间的下个小时
    return strtotime("today {$preferred_hour}:00");
  }
  
  protected function getUserPreferredHour(UserInterface $user): ?int {
    // 分析用户之前邮件的打开时间
    $opens = \Drupal::entityTypeManager()
      ->getStorage('reengage_open_event')
      ->loadByProperties(['uid' => $user->id()]);
    
    if (empty($opens)) {
      return NULL;
    }
    
    $hours = array_map(fn($open) => date('G', $open->getOccurredAt()), $opens);
    $most_common_hour = array_mode($hours);  // 计算众数
    
    return $most_common_hour;
  }
}
```

---

**大正，commerce-reengage.md 已补充完成。继续下一个...** 🚀
