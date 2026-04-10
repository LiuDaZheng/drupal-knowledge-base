---
name: commerce-email
description: Complete guide to Commerce Email for order notifications, customer communications, and marketing emails.
---

# Commerce Email - 订单邮件通知系统 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Email 是 Drupal Commerce 的核心通信模块，提供完整的订单确认、发货通知、客户账户管理等自动化邮件系统。支持邮件模板自定义、多语言支持和 A/B 测试功能。

### 核心功能
- ✅ **订单确认邮件** - 提交后自动发送
- ✅ **订单状态更新通知** - 每个阶段变化提醒
- ✅ **发货追踪通知** - 包含物流链接
- ✅ **支付失败提醒** - 及时引导重新支付
- ✅ **密码重置邮件** - 安全验证流程
- ✅ **欢迎邮件** - 新用户 onboarding
- ✅ **营销邮件集成** - 促销/新品通知
- ✅ **模板变量替换** - 个性化内容
- ✅ **HTML + 纯文本双格式**
- ✅ **附件支持** - 发票/收据下载

### 适用场景
- B2C/B2B 订单系统
- 需要客户沟通的电商
- 多用户平台
- SaaS 订阅管理
- 需要合规通知的业务

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

# 安装邮件通知模块
composer require drupal/email_notifications mail_template

# 启用相关模块
drush en email_notifications mail_template --yes

# 更新数据库
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块
drush dl email_notifications

# 2. 启用模块
drush en email_notifications --yes

# 3. 运行数据库更新
drush updatedb --yes
```

---

## ⚙️ 基础配置

### 1. 启用模块

```bash
drush en email_notifications --yes
```

### 2. 配置邮件发送设置

```
路径：/admin/config/system/mail/settings
```

| 选项 | 默认值 | 说明 |
|------|--------|------|
| Mail handler | Default PHP mail | PHP mail() 函数 |
| SMTP configuration | None | 可配置 SMTP |
| From address | noreply@yoursite.com | 发件人邮箱 |
| From name | Store Name | 发件人名称 |
| Reply-to address | support@yoursite.com | 回复地址 |

### 3. 设置邮件模板

```yaml
email_templates:
  order_confirmation:
    subject: "Order #{{ order.number }} - Confirmed"
    from_name: "{{ site.name }}"
    from_email: "orders@{{ site.address }}"
    
    body_html: |
      <h1>Thank you for your order!</h1>
      <p>Your order has been confirmed and is being processed.</p>
      <table>
        {% for item in order.items %}
          <tr>
            <td>{{ item.title }}</td>
            <td>{{ item.quantity }} × {{ item.price }}</td>
          </tr>
        {% endfor %}
      </table>
      <p><a href="{{ order.url }}">View Order Details</a></p>
    
    body_text: |
      Thank you for your order!
      
      Your order #{order.number} has been confirmed.
      
      Order items:
      {% for item in order.items %}
      - {{ item.title }} x {{ item.quantity }} @ {{ item.price }}
      {% endfor %}
      
      View at: {{ order.url }}
    
    send_to: ['customer', 'admin']
    trigger: 'commerce_order.place'
    
  order_status_update:
    subject: "Order #{{ order.number }} Status Updated"
    template: 'order_status_update'
    conditions:
      - status_change
    personalization_enabled: true
    
  shipment_notification:
    subject: "Your order #{{ order.number }} has shipped!"
    include_tracking_link: true
    include_invoice_attachment: true
```

### 4. 定义邮件类型和触发时机

```
/admin/config/store/email/types
```

| 邮件类型 | 触发时机 | 收件人 | 优先级 |
|---------|---------|--------|--------|
| Order Confirm | 订单创建 | Customer, Admin | High |
| Order Update | 状态变更 | Customer | Medium |
| Payment Success | 支付成功 | Customer | High |
| Payment Failed | 支付失败 | Customer | High |
| Shipment Confirm | 发货通知 | Customer | High |
| Delivery Confirm | 送达确认 | Customer | Low |
| Password Reset | 密码重置请求 | User | Critical |
| Account Created | 新注册 | User | Medium |
| Welcome Email | 注册后首次 | New User | Medium |
| Abandoned Cart | 购物车放弃 | Customer | Medium |
| Promotion Email | 促销活动 | Subscribers | Low |

---

## 💻 代码示例

### 1. 发送订单确认邮件

```php
use Drupal\commerce_order\Entity\Order;

/**
 * 在订单创建后发送确认邮件
 */
function mymodule_commerce_order_place(Order $order) {
  if ($order->getStatus() === 'complete') {
    // 发送邮件给顾客
    $mail_manager = \Drupal::service('plugin.manager.mail');
    
    $params = [
      'order' => $order,
      'site_name' => \Drupal::service('extension.list.module')->get('system')->info['name'],
    ];
    
    $langcode = $order->getOwner()->getPreferredLangcode();
    
    $mail_manager->send(
      'commerce_customer',
      'order_confirmation',
      $order->getOwner(),
      $langcode,
      NULL,
      NULL,
      $params
    );
    
    // 发送给管理员
    $admin_mail = \Drupal::config('commerce_settings')->get('admin_email');
    if ($admin_mail) {
      $admin_user = \Drupal\user\User::loadByEmail($admin_mail);
      if ($admin_user) {
        $mail_manager->send(
          'commerce_admin',
          'new_order_notification',
          $admin_user,
          'en',
          NULL,
          NULL,
          $params
        );
      }
    }
    
    \Drupal::logger('commerce')
      ->info('Order confirmation email sent for :order_id', [':order_id' => $order->id()]);
  }
}
```

### 2. 构建邮件模板

```php
use Drupal\mailtemplate\MailTemplateInterface;

/**
 * 创建自定义邮件模板
 */
class CommerceEmailTemplateBuilder {
  
  /**
   * 创建订单状态更新邮件
   */
  public function createOrderStatusUpdateTemplate(string $template_id): MailTemplateInterface {
    $template = \Drupal::entityTypeManager()
      ->getStorage('mail_template')
      ->create([
        'id' => $template_id,
        'label' => 'Order Status Update',
        'description' => 'Sent when order status changes',
        'subject' => 'Order #[nid] status has been updated to [status]',
      ]);
    
    // 添加 HTML 模板
    $template->addLanguageContent('en', [
      'body' => [
        '#type' => 'mail_template_body',
        '#value' => $this->buildOrderStatusHtmlTemplate(),
        '#format' => 'full_html',
      ],
      'text_body' => [
        '#type' => 'mail_template_body',
        '#value' => $this->buildOrderStatusTextTemplate(),
        '#format' => 'plain_text',
      ],
    ]);
    
    $template->save();
    
    return $template;
  }
  
  /**
   * 构建 HTML 模板内容
   */
  protected function buildOrderStatusHtmlTemplate(): string {
    return <<<HTML
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Order Status Update</title>
</head>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
  
  <div style="background-color: #f8f9fa; padding: 20px; border-radius: 5px;">
    <h2 style="color: #333;">Your Order Has Been Updated</h2>
    
    <p>Dear {customer_name},</p>
    
    <p>Your order <strong>[order_number]</strong> has changed status to:</p>
    
    <div style="text-align: center; margin: 30px 0;">
      <span style="display: inline-block; padding: 15px 30px; background-color: [status_color]; color: white; border-radius: 5px; font-size: 18px;">
        [status_label]
      </span>
    </div>
    
    <p><strong>Status Details:</strong> [status_message]</p>
    
    <table style="width: 100%; margin: 20px 0; border-collapse: collapse;">
      <tr>
        <th style="padding: 10px; text-align: left; border-bottom: 2px solid #ddd;">Order Number</th>
        <td style="padding: 10px; border-bottom: 2px solid #ddd;">[order_number]</td>
      </tr>
      <tr>
        <th style="padding: 10px; text-align: left; border-bottom: 2px solid #ddd;">Date</th>
        <td style="padding: 10px; border-bottom: 2px solid #ddd;">[order_date]</td>
      </tr>
      <tr>
        <th style="padding: 10px; text-align: left; border-bottom: 2px solid #ddd;">Total</th>
        <td style="padding: 10px; border-bottom: 2px solid #ddd;">[order_total]</td>
      </tr>
    </table>
    
    <div style="text-align: center; margin-top: 30px;">
      <a href="[order_url]" style="background-color: #007bff; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
        View Order Details
      </a>
    </div>
    
    <hr style="margin: 30px 0; border: none; border-top: 1px solid #ddd;">
    
    <p style="font-size: 12px; color: #999;">
      If you have any questions, please contact our support team.<br>
      This email was sent to [customer_email].
    </p>
  </div>
</body>
</html>
HTML;
  }
  
  /**
   * 构建纯文本模板
   */
  protected function buildOrderStatusTextTemplate(): string {
    return <<<TEXT
Your Order Has Been Updated

Dear {customer_name},

Your order [order_number] has changed status to: [status_label]

Status Details: [status_message]

Order Information:
- Order Number: [order_number]
- Date: [order_date]
- Total: [order_total]

View your order details here: [order_url]

If you have any questions, please contact our support team.

This email was sent to [customer_email].
TEXT;
  }
}
```

### 3. 动态模板变量处理器

```php
use Drupal\Core\Template\Attribute;

/**
 * 扩展邮件模板变量
 */
class CommerceEmailVariables {
  
  /**
   * 获取可用模板变量
   */
  public static function getAvailableVariables(string $event_type): array {
    $variables = [
      // 通用变量
      'site_name' => \Drupal::service('renderer')->renderRoot()->getSiteName(),
      'site_address' => \Drupal::settings->get('site_address'),
      'current_date' => date('Y-m-d H:i:s'),
    ];
    
    // 根据事件类型添加特定变量
    switch ($event_type) {
      case 'commerce_order.place':
        $variables = array_merge($variables, [
          'order' => '\Drupal\commerce_order\Entity\Order',
          'order.number' => 'Order ID',
          'order.total' => 'Total Amount',
          'order.date' => 'Order Date',
          'customer' => '\Drupal\user\Entity\User',
          'customer.name' => 'Customer Name',
          'customer.email' => 'Customer Email',
        ]);
        break;
        
      case 'commerce_order.status_change':
        $variables = array_merge($variables, [
          'previous_status' => 'Previous Order Status',
          'new_status' => 'New Order Status',
          'status_message' => 'Status Description',
        ]);
        break;
        
      case 'commerce_checkout.payment':
        $variables = array_merge($variables, [
          'payment_method' => 'Payment Method Used',
          'transaction_id' => 'Payment Transaction ID',
          'payment_amount' => 'Payment Amount',
        ]);
        break;
    }
    
    return $variables;
  }
  
  /**
   * 渲染模板并替换变量
   */
  public static function renderTemplate(string $template, array $variables): string {
    $twig = \Drupal::service('twig.loader.themed_file_system');
    
    // 处理嵌套数组变量
    foreach ($variables as $key => $value) {
      if (is_object($value)) {
        $method_name = lcfirst(str_replace('.', '_', $key));
        
        if (method_exists($value, $method_name)) {
          $variables[$key] = $value->$method_name();
        } elseif (property_exists($value, $key)) {
          $variables[$key] = $value->$key;
        }
      }
    }
    
    return $twig->renderString($template, $variables);
  }
}
```

### 4. A/B 测试邮件主题

```php
use Drupal\experiment\ABTestExperiment;

/**
 * 实现邮件 A/B 测试
 */
class EmailSubjectABTester {
  
  /**
   * 为不同的用户提供不同的邮件主题
   */
  public function determineSubjectVariant(UserInterface $user, string $template_id): string {
    $experiment_key = "email_ab_test_{$template_id}";
    
    // 决定用户属于哪个实验组
    $bucket = $this->getExperimentBucket($user, $experiment_key);
    
    // 获取对应的主题变体
    $variants = [
      'control' => 'Your order #[order_number] is confirmed!',
      'variant_a' => '🎉 Great news! Your order #[order_number] is confirmed',
      'variant_b' => 'Thank you! Order #[order_number] confirmation inside',
    ];
    
    return $variants[$bucket] ?? $variants['control'];
  }
  
  /**
   * 记录打开率用于分析
   */
  public function recordEmailOpen(UserInterface $user, string $template_id) {
    db_insert('email_experiment_tracking')
      ->fields([
        'user_id' => $user->id(),
        'template_id' => $template_id,
        'action' => 'open',
        'timestamp' => REQUEST_TIME,
        'ip_address' => \Drupal::request()->getClientIp(),
      ])
      ->execute();
  }
  
  /**
   * 获取用户所属实验组
   */
  protected function getExperimentBucket(UserInterface $user, string $experiment_key): string {
    $user_identifier = $user->isAnonymous() 
      ? 'anon_' . session_id() 
      : 'user_' . $user->id();
    
    $hash = md5($experiment_key . $user_identifier);
    $bucket_num = hexdec(substr($hash, -2)) % 3;
    
    return match ($bucket_num) {
      0 => 'control',
      1 => 'variant_a',
      default => 'variant_b',
    };
  }
}
```

### 5. Twig 模板 - 订单确认邮件

```twig
{# templates/email/order-confirmation.html.twig #}
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Order Confirmation</title>
</head>
<body style="font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; line-height: 1.6; color: #333; background-color: #f4f4f4; margin: 0; padding: 20px;">
  
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
    
    <!-- Header -->
    <tr>
      <td style="background-color: #2c3e50; padding: 30px; text-align: center;">
        <h1 style="color: #ffffff; margin: 0; font-size: 24px;">🛒 Order Confirmed</h1>
        <p style="color: #ecf0f1; margin: 10px 0 0 0; font-size: 14px;">Thank you for your purchase!</p>
      </td>
    </tr>
    
    <!-- Greeting -->
    <tr>
      <td style="padding: 30px;">
        <p style="font-size: 16px; margin-bottom: 20px;">
          Hi <strong>{{ order.customer.name }}</strong>,
        </p>
        <p style="margin-bottom: 30px;">
          Thanks for shopping with us! Your order has been received and is being processed.
        </p>
      </td>
    </tr>
    
    <!-- Order Summary -->
    <tr>
      <td style="padding: 0 30px 30px;">
        <table width="100%" cellpadding="0" cellspacing="0" style="border: 1px solid #e0e0e0; border-radius: 5px;">
          
          <!-- Items Header -->
          <tr style="background-color: #f8f9fa;">
            <th style="padding: 15px; text-align: left; font-size: 14px; color: #555;">Item</th>
            <th style="padding: 15px; text-align: center; font-size: 14px; color: #555;">Qty</th>
            <th style="padding: 15px; text-align: right; font-size: 14px; color: #555;">Price</th>
          </tr>
          
          <!-- Items -->
          {% for item in order.items %}
          <tr style="border-bottom: 1px solid #eee;">
            <td style="padding: 15px; vertical-align: top;">
              <strong>{{ item.title }}</strong>
              {% if item.options %}
                <div style="font-size: 12px; color: #999; margin-top: 5px;">
                  {% for option in item.options %}
                    {{ option.label }}: {{ option.value }}{% if not loop.last %}, {% endif %}
                  {% endfor %}
                </div>
              {% endif %}
            </td>
            <td style="padding: 15px; text-align: center;">{{ item.quantity }}</td>
            <td style="padding: 15px; text-align: right;">
              {{ item.price.currency }}{{ "%.2f"|format(item.price.amount) }}
            </td>
          </tr>
          {% endfor %}
          
          <!-- Subtotal -->
          <tr>
            <td colspan="3" style="padding: 15px; text-align: right; background-color: #fafafa;">
              <strong>Subtotal:</strong>
            </td>
            <td style="padding: 15px; text-align: right; background-color: #fafafa;">
              <strong>{{ order.subtotal.currency }}{{ "%.2f"|format(order.subtotal.amount) }}</strong>
            </td>
          </tr>
          
          {% if order.shippingTotal.amount > 0 %}
          <tr>
            <td colspan="3" style="padding: 15px; text-align: right;">
              Shipping:
            </td>
            <td style="padding: 15px; text-align: right;">
              {{ order.shippingTotal.currency }}{{ "%.2f"|format(order.shippingTotal.amount) }}
            </td>
          </tr>
          {% endif %}
          
          {% if order.getTotalTax().amount > 0 %}
          <tr>
            <td colspan="3" style="padding: 15px; text-align: right;">
              Tax:
            </td>
            <td style="padding: 15px; text-align: right;">
              {{ order.getTotalTax().currency }}{{ "%.2f"|format(order.getTotalTax().amount) }}
            </td>
          </tr>
          {% endif %}
          
          <!-- Grand Total -->
          <tr style="background-color: #2c3e50;">
            <td colspan="3" style="padding: 20px; text-align: right;">
              <span style="color: #ffffff; font-size: 18px;">Total:</span>
            </td>
            <td style="padding: 20px; text-align: right;">
              <span style="color: #ffffff; font-size: 20px; font-weight: bold;">
                {{ order.total.currency }}{{ "%.2f"|format(order.total.amount) }}
              </span>
            </td>
          </tr>
        </table>
      </td>
    </tr>
    
    <!-- Order Details Info -->
    <tr>
      <td style="padding: 0 30px 30px;">
        <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f8f9fa; border-radius: 5px; padding: 20px;">
          <tr>
            <td style="width: 50%; vertical-align: top; padding-right: 20px;">
              <h3 style="font-size: 14px; margin: 0 0 10px 0; color: #555;">Shipping Address</h3>
              <p style="font-size: 14px; margin: 0; line-height: 1.5;">
                {{ order.shippingAddress.line1 }}<br>
                {{ order.shippingAddress.city }}, {{ order.shippingAddress.state }} {{ order.shippingAddress.postcode }}<br>
                {{ order.shippingAddress.country }}
              </p>
            </td>
            <td style="width: 50%; vertical-align: top;">
              <h3 style="font-size: 14px; margin: 0 0 10px 0; color: #555;">Order Information</h3>
              <p style="font-size: 14px; margin: 0 0 5px 0;"><strong>Order #:</strong> {{ order.number }}</p>
              <p style="font-size: 14px; margin: 0 0 5px 0;"><strong>Date:</strong> {{ order.created|date('F d, Y') }}</p>
              <p style="font-size: 14px; margin: 0;"><strong>Status:</strong> {{ order.getStatusLabel() }}</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
    
    <!-- Call to Action -->
    <tr>
      <td style="padding: 0 30px 30px; text-align: center;">
        <a href="{{ path('commerce_customer.order.view', {'orderId': order.id}) }}" 
           style="display: inline-block; background-color: #27ae60; color: #ffffff; padding: 15px 40px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px;">
          View Order Details
        </a>
      </td>
    </tr>
    
    <!-- Footer -->
    <tr>
      <td style="background-color: #34495e; padding: 30px; text-align: center;">
        <p style="color: #ecf0f1; font-size: 14px; margin: 0 0 10px 0;">
          Need Help? Contact Our Support Team
        </p>
        <p style="color: #bdc3c7; font-size: 12px; margin: 0;">
          Email: {{ 'support@yourstore.com' }} | Phone: {{ '1-800-STORE' }}
        </p>
        <hr style="border: none; border-top: 1px solid #465c71; margin: 20px 0;">
        <p style="color: #7f8c8d; font-size: 11px; margin: 0;">
          © {{ '2026' }} {{ site_name }}. All rights reserved.<br>
          You received this email because you placed an order with us.
        </p>
      </td>
    </tr>
    
  </table>
</body>
</html>
```

---

## 📋 数据表结构

### commerce_mail_log
邮件发送日志表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| log_id | BIGINT | PRIMARY KEY | 自增 ID |
| template_id | VARCHAR(64) | NOT NULL | 模板 ID |
| event_type | VARCHAR(64) | NOT NULL | 事件类型 |
| recipient_uid | INT | NOT NULL | 接收者用户 ID |
| recipient_email | VARCHAR(255) | NOT NULL | 接收者邮箱 |
| status | VARCHAR(20) | DEFAULT 'pending' | pending/sent/failed/bounced |
| sent_at | DATETIME | NULLABLE | 发送时间 |
| error_message | TEXT | NULLABLE | 错误信息 |

### mail_template_content
邮件模板多语言内容

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| content_id | BIGINT | PRIMARY KEY | 自增 ID |
| template_id | VARCHAR(64) | FOREIGN KEY | 关联模板 |
| langcode | VARCHAR(12) | FOREIGN KEY | 语言代码 |
| subject | TEXT | NOT NULL | 邮件主题 |
| body_html | LONGTEXT | NULLABLE | HTML 正文 |
| body_text | LONGTEXT | NULLABLE | 纯文本正文 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\commerce\Unit\OrderEmailTest;

class OrderNotificationTest extends UnitTestCaseBase {
  
  public function testOrderConfirmationEmailTriggered() {
    $order = $this->createCompletedOrder();
    
    $events = [];
    \Drupal::eventDispatcher()->addListener('commerce_order.place', function($event) use (&$events) {
      $events[] = $event;
    });
    
    // 模拟订单完成
    $order->setStatus('complete');
    $order->save();
    
    // 应该触发邮件发送事件
    $this->assertCount(1, $events);
    $this->assertEquals('complete', $events[0]->order->getStatus());
  }
  
  public function testEmailTemplateVariables() {
    $order = $this->createTestOrder();
    
    $variables = CommerceEmailVariables::getAvailableVariables('commerce_order.place');
    
    $this->assertArrayHasKey('order', $variables);
    $this->assertArrayHasKey('customer', $variables);
    $this->assertArrayHasKey('site_name', $variables);
  }
  
  public function testMailSendingFailureHandling() {
    $order = $this->createCompletedOrder();
    
    // 模拟邮件发送失败
    $mail_manager = $this->createMock(\Drupal\mail\MailerInterface::class);
    $mail_manager->expects($this->once())
      ->method('send')
      ->willThrowException(new \RuntimeException('SMTP connection failed'));
    
    \Drupal::inject('plugin.manager.mail')->setPluginInstance($mail_manager);
    
    // 应该记录错误到日志
    $log_entries = watchdog_get_messages('commerce');
    $this->assertNotEmpty($log_entries);
  }
}
```

### 集成测试

```gherkin
Feature: Order Email Notifications
  As a customer
  I want to receive email updates about my orders
  
  Scenario: Receiving order confirmation
    Given I have just completed a purchase
    When the order is created
    Then I should receive an order confirmation email
    And the email should contain all order items
    And the email should have a link to view order details
  
  Scenario: Receiving payment failure notification
    Given my payment transaction failed
    When the system detects the failure
    Then I should immediately receive an email
    And the email should explain what went wrong
    And provide instructions to retry payment
  
  Scenario: Receiving shipment tracking information
    Given my order has been shipped
    When the shipment notification is triggered
    Then I should receive an email with tracking number
    And the email should include a link to carrier website
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算公式 | 目标值 |
|------|---------|--------|
| **发送成功率** | (成功发送 / 总尝试) × 100% | > 95% |
| **平均发送延迟** | 从触发到实际发送时长 | < 1 分钟 |
| **退信率** | (bounce / 发送总数) × 100% | < 2% |
| **打开率** | (打开邮件数 / 发送总数) × 100% | 20-40% |

### 日志命令

```bash
# 查看邮件发送日志
drush watchdog-view mail --count=50

# 查询失败的邮件
drush sql-query "SELECT COUNT(*) FROM commerce_mail_log WHERE status='failed'"

# 导出邮件统计报告
drush php-script export_email_delivery_report
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Drupal Mail API | https://www.drupal.org/docs/core-api/core-api-modules/mail-api |
| Email Deliverability Best Practices | https://www.sendgrid.com/blog/email-deliverability-best-practices/ |

---

## 🆘 常见问题

### Q1: 如何防止邮件进入垃圾箱？

**答案**：
```php
// 1. SPF/DKIM/DMARC 记录配置
$config['commerce_mail.settings']['spf_record'] = 'v=spf1 include:_spf.yourdomain.com ~all';
$config['commerce_mail.settings']['dkim_domain'] = 'yourdomain.com';
$config['commerce_mail.settings']['dkim_selector'] = 'default';

// 2. 避免垃圾邮件关键词
$content_filter = [
  'free', 'discount', 'limited time', 'guaranteed',
  'click here', 'act now', 'winner', 'congratulations',
];

// 3. 保持健康的发送频率
function check_send_frequency_limits(UserInterface $user) {
  $recent_count = get_recent_emails_sent($user, DAY);
  if ($recent_count >= 10) {
    throw new \Exception('Email limit reached for today.');
  }
}
```

### Q2: 如何支持邮件预览功能？

**答案**：
```php
/**
 * 生成邮件预览 URL
 */
function generate_email_preview_url(string $template_id, array $preview_data) {
  $token = md5(serialize($preview_data) . SECRET_KEY);
  $url = Url::fromRoute('commerce.mail.preview', [
    'template' => $template_id,
    'token' => $token,
  ])->toString();
  
  return $url;
}

// 预览页面路由
function callback_mail_preview(RouteMatchInterface $match) {
  $template_id = $match->getParameter('template');
  $token = $match->getParameter('token');
  
  // 验证 token...
  
  $preview_data = unserialize(base64_decode(explode('_', $token)[1]));
  $mailer = \Drupal::service('plugin.manager.mail');
  
  return $mailer->renderPreview($template_id, $preview_data);
}
```

### Q3: 如何实现多语言邮件？

**答案**：
```php
/**
 * 根据用户语言发送本地化邮件
 */
function send_multilingual_email(Order $order) {
  $user = $order->getOwner();
  $langcode = $user->getPreferredLangcode();
  
  $params = [
    'order' => $order,
    'site_name' => \Drupal::service('renderer')->renderRoot()->getSiteName(),
  ];
  
  // 加载对应语言的邮件模板
  $template = \Drupal::entityTypeManager()
    ->getStorage('mail_template')
    ->load("order_confirmation_{$langcode}");
  
  \Drupal::service('plugin.manager.mail')
    ->send('commerce_customer', $template->id(), $user, $langcode, NULL, NULL, $params);
}
```

---

**大正，commerce-email.md 已补充完成。继续下一个...** 🚀
