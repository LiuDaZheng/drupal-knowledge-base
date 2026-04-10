---
name: tawk-to
description: Complete guide to Tawk.to live chat integration with Drupal Commerce for customer support.
---

# Tawk.to - 实时在线聊天客服 (Drupal 11)

**版本**: 2.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Tawk.to 是免费的在线实时聊天解决方案，提供与 Drupal Commerce 的深度集成。支持订单详情关联、客户信息同步、智能路由、自动化回复等功能，帮助企业提升客户服务质量和销售转化率。

### 核心功能
- ✅ **实时在线聊天窗口** - 网站右下角悬浮聊天框
- ✅ **访客追踪和定位** - IP、地理位置、访问路径识别
- ✅ **订单详情关联** - 聊天中查看购物车和历史订单
- ✅ **自定义欢迎语** - 基于页面/行为的智能触发
- ✅ **离线消息表单** - 非工作时间留言收集
- ✅ **移动端适配** - 响应式设计完美显示
- ✅ **多语言支持** - 自动检测浏览器语言
- ✅ **文件传输** - 图片/文档共享
- ✅ **聊天历史记录** - 完整会话存档
- ✅ **团队协作** - 多客服分配转接
- ✅ **API 集成** - Webhook 事件通知
- ✅ **报表分析** - 响应时间、满意度统计

### 适用场景
- 需要即时客服的电商
- B2B 询价平台
- 高客单价咨询型销售
- 24/7在线服务需求
- 售后技术支持
- 潜在客户线索收集

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Tawk.to 账号（免费注册）
- SSL 证书（HTTPS 必需）

### 安装步骤

#### 方法 1: 注册 Tawk.to 账号

1. 访问 [https://www.tawk.to](https://www.tawk.to)
2. 点击 "Sign Up Free"
3. 填写基本信息并创建账号
4. 进入 Dashboard → Properties → Add Property
5. 输入你的网站域名

#### 方法 2: 获取 Widget 代码

```
路径：Tawk.to Dashboard → Live Chat → Settings → Embed Code
```

复制生成的 JavaScript 代码，格式如下：

```html
<script type="text/javascript">
var Tawk_API=Tawk_API||{}, Tawk_LoadStart=new Date();
(function(){
var s1=document.createElement("script"),s0=document.getElementsByTagName("script")[0];
s1.async=true;
s1.src='https://embed.tawk.to/YOUR_PROPERTY_ID/default';
s1.charset='UTF-8';
s1.setAttribute('crossorigin','*');
s0.parentNode.insertBefore(s1,s0);
})();
</script>
```

#### 方法 3: 在 Drupal 中集成

```bash
composer require drupal/tawk_to
drush en tawk_to --yes
```

或者直接在主题中添加：

```
/admin/config/system/theme/settings/[your-theme]
→ 在页脚下方添加 Tawk.to Widget 代码
```

---

## ⚙️ 基础配置

### 1. Tawk.to 设置

```
路径：/admin/config/services/tawk_to
```

| 配置项 | 值 | 说明 |
|--------|-----|------|
| Property ID | `xxxxxxxxx` | Tawk.to 属性 ID |
| Widget Language | auto | auto/en/es/zh 等 |
| Widget Theme | light/dark/custom | 主题风格 |
| Display Position | bottom-right/bottom-left | 显示位置 |
| Show Chat Button | ✅ Yes | 显示聊天按钮 |
| Minimize on Load | ✅ Yes | 默认最小化 |
| Prechat Form | ✅ Optional | 可选个人信息收集 |

### 2. 自定义样式配置

```yaml
tawk_widget_style:
  position: 'bottom-right'
  width: '380px'
  height: '500px'
  z_index: '99999'
  
  colors:
    primary: '#2c3e50'       # 聊天头部颜色
    secondary: '#34495e'     # 发送按钮颜色
    accent: '#3498db'        # 链接和高亮色
    background: '#ffffff'    # 聊天背景色
    
  font:
    family: 'Helvetica Neue, Arial, sans-serif'
    size: '14px'
    
  border_radius: '10px'
```

### 3. 触发器规则设置

```
路径：Tawk.to Dashboard → Live Chat → Triggers
```

| 触发器名称 | 条件 | 动作 |
|-----------|------|------|
| New Visitor | Page = product detail | Show greeting |
| High Value Cart | Cart value > $200 | Alert sales team |
| Checkout Page | Path = checkout | Proactive help offer |
| Revisit Customer | Returning visitor within 7 days | Welcome back message |
| Search No Results | Search results = 0 | Offer assistance |
| Time on Page > 2min | Duration > 120 seconds | Ask if need help |

### 4. 自动回复设置

```yaml
auto_replies:
  welcome_message:
    trigger: 'visitor_entering_chat'
    delay_seconds: 2
    text: "Hi! 👋 Thanks for chatting with us. How can we help?"
    
  business_hours_bot:
    condition: 'not_business_hours'
    message: "Thanks for reaching out! Our business hours are Mon-Fri 9AM-6PM EST. We'll respond as soon as we're back."
    
  order_status_inquiry:
    keywords: ['order status', 'where is my order', 'tracking']
    action: 'collect_order_number'
    followup: "I can help you track your order! Please provide your order number."
```

---

## 💻 代码示例

### 1. 获取当前用户订单信息

```php
use Drupal\commerce_order\Entity\Order;
use Drupal\tawk_api\Service\UserSessionService;

/**
 * 为 Tawk.to 准备用户数据
 */
class TawkToUserDataProvider {
  
  protected $session_service;
  
  public function __construct(UserSessionService $session_service) {
    $this->session_service = $session_service;
  }
  
  /**
   * 构建 Tawk.to 访客变量
   */
  public function getVisitorVariables(UserInterface $user): array {
    $variables = [
      'firstname' => $user->isAuthenticated() ? $user->getDisplayName() : 'Guest',
      'lastname' => $user->hasField('last_name') ? $user->getLastname() : '',
      'email' => $user->getEmail(),
      'phone' => $user->hasField('telephone') ? $user->getTelephone()->value : '',
    ];
    
    // 如果是匿名用户，使用会话 ID
    if (!$user->isAuthenticated()) {
      $variables['uid'] = 'guest_' . session_id();
      $variables['is_guest'] = TRUE;
    } else {
      $variables['uid'] = $user->id();
      $variables['customer_type'] = $this->getCustomerType($user);
    }
    
    // 附加订单信息
    if ($user->isAuthenticated()) {
      $recent_orders = $this->getUserRecentOrders($user->id());
      $variables['total_orders'] = count($recent_orders);
      $variables['lifetime_value'] = $this->calculateLifetimeValue($user->id());
      
      // 当前购物车
      $cart = \Drupal::service('commerce_cart.repository')->getActiveCart($user->id());
      if ($cart && !$cart->isEmpty()) {
        $variables['cart_total'] = $cart->getTotalAmount()->toString();
        $variables['cart_item_count'] = count($cart->getItems());
        $variables['has_active_cart'] = TRUE;
      }
    }
    
    // 来源信息
    $referer = \Drupal::request()->headers->get('HTTP_REFERER');
    $variables['referrer'] = $referer ?? '(direct)';
    $variables['landing_page'] = \Drupal::request()->getRequestUri();
    
    return $variables;
  }
  
  /**
   * 获取客户类型
   */
  protected function getCustomerType(UserInterface $user): string {
    $points = \Drupal::entityTypeManager()
      ->getStorage('loyalty_points_balance')
      ->loadByProperties(['uid' => $user->id()])
      ->current()?->getBalance() ?? 0;
    
    if ($points >= 10000) {
      return 'platinum';
    } elseif ($points >= 5000) {
      return 'gold';
    } elseif ($points >= 1000) {
      return 'silver';
    }
    
    return 'bronze';
  }
  
  /**
   * 获取最近订单
   */
  protected function getUserRecentOrders(int $user_id, int $limit = 3): array {
    $query = db_select('commerce_order', 'o')
      ->fields('o', ['order_id', 'status', 'created'])
      ->condition('uid', $user_id)
      ->condition('status', 'complete')
      ->orderBy('created', 'DESC')
      ->range(0, $limit);
    
    return $query->execute()->fetchAllAssoc('order_id');
  }
  
  /**
   * 计算客户终身价值
   */
  protected function calculateLifetimeValue(int $user_id): float {
    $query = db_select('commerce_order', 'o')
      ->fields('o', ['total_amount']);
      ->condition('uid', $user_id)
      ->condition('status', 'complete');
    
    $result = $query->execute();
    
    $total = 0;
    foreach ($result as $row) {
      $total += floatval($row->total_amount);
    }
    
    return round($total, 2);
  }
}
```

### 2. 将订单信息发送到 Tawk.to

```php
use Drupal\tawk_api\Service\WebhookSender;

/**
 * 通过 Webhook 发送订单上下文到 Tawk.to
 */
class TawkToOrderContextSender {
  
  protected $webhook_sender;
  
  public function __construct(WebhookSender $webhook_sender) {
    $this->webhook_sender = $webhook_sender;
  }
  
  /**
   * 当订单创建时发送上下文
   */
  public function sendOrderContext(Order $order): void {
    $data = [
      'event' => 'order_created',
      'timestamp' => date('Y-m-d H:i:s', $order->getCreated()),
      'order' => [
        'id' => $order->id(),
        'number' => $order->getOrderNumber(),
        'total' => $order->getTotalAmount()->toString(),
        'currency' => $order->getCurrency()->getId(),
        'status' => $order->getStatus(),
        'items_count' => count($order->getItems()),
      ],
      'customer' => [
        'id' => $order->getOwnerId(),
        'name' => $order->getCustomerName(),
        'email' => $order->getEmail(),
        'phone' => $order->getPhone(),
      ],
      'shipping_address' => [
        'line1' => $order->getShippingAddress()->getLine1(),
        'city' => $order->getShippingAddress()->getCity(),
        'state' => $order->getShippingAddress()->getState(),
        'postcode' => $order->getShippingAddress()->getPostalCode(),
        'country' => $order->getShippingAddress()->getCountryId(),
      ],
    ];
    
    $this->webhook_sender->send('/webhook/tawk_to/order_context', $data);
  }
  
  /**
   * 当订单状态变更时发送
   */
  public function sendOrderStatusUpdate(Order $order, string $old_status, string $new_status): void {
    $data = [
      'event' => 'order_status_updated',
      'order_id' => $order->id(),
      'old_status' => $old_status,
      'new_status' => $new_status,
      'updated_at' => date('Y-m-d H:i:s'),
    ];
    
    $this->webhook_sender->send('/webhook/tawk_to/order_status', $data);
  }
}
```

### 3. Tawk.to Webhook 处理器

```php
use Drupal\Core\Controller\ControllerBase;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;

/**
 * 处理 Tawk.to Webhook 请求
 */
class TawkToWebhookController extends ControllerBase {
  
  /**
   * 处理新消息事件
   */
  public function handleMessageEvent(Request $request) {
    $data = $request->toArray();
    
    if ($data['event'] === 'ticket.new' || $data['event'] === 'chat.transcript.requested') {
      $ticket = $data['data'];
      
      // 查找匹配的 Drupal 用户
      $user = $this->findUserByContactInfo($ticket['contact']['email']);
      
      if ($user) {
        // 记录聊天历史到用户备注
        $this->logChatToUserProfile($user, $ticket);
        
        // 如果是 VIP 客户，标记优先级
        if ($this->isVIPCustomer($user)) {
          $this->priorityRouteChat($ticket['ticket_id']);
        }
      }
      
      // 发送确认回复
      $this->sendAutoReply($ticket['ticket_id'], 'message_received');
    }
    
    return new JsonResponse(['status' => 'ok']);
  }
  
  /**
   * 处理聊天结束事件
   */
  public function handleTicketClosed(Request $request) {
    $data = $request->toArray();
    $ticket = $data['data'];
    
    // 获取满意度调查评分
    $rating = $ticket['survey']['rating'] ?? NULL;
    $feedback = $ticket['survey']['comment'] ?? '';
    
    // 保存到内部工单系统
    db_insert('tawk_to_tickets')
      ->fields([
        'tawk_ticket_id' => $ticket['ticket_id'],
        'status' => 'closed',
        'ended_at' => $ticket['properties']['endTime'],
        'rating' => $rating,
        'feedback' => $feedback,
        'transcript_url' => $ticket['transcriptUrl'],
      ])
      ->execute();
    
    // 如果是高价值客户的负面评价，通知主管
    if ($rating <= 2) {
      $this->alertManagerAboutNegativeFeedback($ticket);
    }
    
    return new JsonResponse(['status' => 'processed']);
  }
  
  /**
   * 根据联系信息查找用户
   */
  protected function findUserByContactInfo(string $email): ?UserInterface {
    $users = \Drupal\user\Entity\User::loadByProperties(['mail' => $email]);
    
    if (!empty($users)) {
      return reset($users);
    }
    
    return NULL;
  }
  
  /**
   * 将聊天记录保存到用户档案
   */
  protected function logChatToUserProfile(UserInterface $user, array $ticket): void {
    $chat_log_entry = [
      'uid' => $user->id(),
      'tawk_ticket_id' => $ticket['ticket_id'],
      'started_at' => $ticket['properties']['startTime'],
      'subject' => $ticket['subject'],
      'department' => $ticket['department'] ?? 'general',
    ];
    
    db_insert('user_chat_history')
      ->fields($chat_log_entry)
      ->execute();
    
    // 更新用户的最后在线时间
    $user->set('last_tawk_chat', REQUEST_TIME);
    $user->save();
  }
  
  /**
   * 优先路由 VIP 客户聊天
   */
  protected function priorityRouteChat(string $ticket_id): void {
    // 调用 Tawk.to API 设置优先级
    $api_endpoint = "https://api.tawk.io/properties/{property_id}/tickets/{$ticket_id}/prioritize";
    
    // 这里应该调用实际的 API
    // ...
  }
  
  /**
   * 发送自动回复
   */
  protected function sendAutoReply(string $ticket_id, string $template): void {
    // 获取预设的自动回复消息
    $message = $this->getAutoReplyMessage($template);
    
    // 通过 Tawk.to API 发送消息
    // ...
  }
  
  /**
   * 检查是否为 VIP 客户
   */
  protected function isVIPCustomer(UserInterface $user): bool {
    $points = \Drupal::entityTypeManager()
      ->getStorage('loyalty_points_balance')
      ->loadByProperties(['uid' => $user->id()])
      ->current()?->getBalance() ?? 0;
    
    return $points >= 5000; // Gold 及以上
  }
  
  /**
   * 管理负面情绪告警
   */
  protected function alertManagerAboutNegativeFeedback(array $ticket): void {
    // 发送邮件给客服经理
    $mail_manager = \Drupal::service('plugin.manager.mail');
    
    $mail_manager->send(
      'tawk_alerts',
      'negative_feedback_notification',
      \Drupal\user\User::loadByEmail('manager@example.com'),
      'en',
      NULL,
      NULL,
      [
        'ticket_id' => $ticket['ticket_id'],
        'customer_email' => $ticket['contact']['email'],
        'rating' => $ticket['survey']['rating'],
        'feedback' => $ticket['survey']['comment'],
        'transcript_url' => $ticket['transcriptUrl'],
      ]
    );
  }
  
  /**
   * 获取自动回复模板
   */
  protected function getAutoReplyMessage(string $template): string {
    $templates = [
      'message_received' => "Thank you for your message! Someone will be with you shortly.",
      'business_hours' => "Our office hours are Mon-Fri 9AM-6PM EST.",
      'order_inquiry' => "I'd be happy to check your order status. May I have your order number?",
    ];
    
    return $templates[$template] ?? "Thanks for reaching out!";
  }
}
```

### 4. Twig 模板 - 聊天插件注入

```twig
{# themes/custom/mytheme/templates/offcanvas-wrapper.html.twig #}
{# 在页脚注入 Tawk.to widget #}

{{ attach_library('mytheme/tawk-widget') }}

{% set tawk_property_id = 'your-property-id' %}

<script>
(function() {
  var Tawk_API = Tawk_API || {}, Tawk_LoadStart = new Date();
  
  // 用户数据
  {% if user.is_authenticated %}
  Tawk_API.onLoad = function() {
    Tawk_API.setAttributes({
      name: '{{ user.display_name }}',
      email: '{{ user.email }}',
      uid: '{{ user.id }}',
      customerType: '{{ get_customer_type(user) }}',
      totalOrders: '{{ user.total_orders }}',
      lifetimeValue: '${{ "%.2f"|format(user.lifetime_value) }}'
    });
  };
  {% else %}
  Tawk_API.onLoad = function() {
    Tawk_API.setAttributes({
      name: 'Guest',
      email: '',
      uid: 'guest_' + getSessionId(),
      isGuest: true
    });
  };
  {% endif %}
  
  var s1 = document.createElement("script"), s0 = document.getElementsByTagName("script")[0];
  s1.async = true;
  s1.src = 'https://embed.tawk.to/' + tawk_property_id + '/default';
  s1.charset = 'UTF-8';
  s1.setAttribute('crossorigin','*');
  s0.parentNode.insertBefore(s1, s0);
})();
</script>
```

### 5. 前端聊天界面增强

```javascript
// js/tawk-enhancements.js
Drupal.behaviors.tawkEnhancements = {
  attach: function(context, settings) {
    if (context !== document) return;
    
    // 监听订单完成，发送上下文到聊天
    $(document).on('CommerceOrderComplete', function(e, data) {
      if (typeof Tawk_API !== 'undefined') {
        Tawk_API.sendTicketData({
          subject: 'Order #' + data.order.number + ' Completed',
          custom: {
            orderId: data.order.id,
            orderTotal: data.order.total.amount,
            itemsCount: data.order.items.length
          }
        });
      }
    });
    
    // 在结账页面显示主动帮助提示
    if (window.location.pathname.indexOf('/checkout') !== -1) {
      if (typeof Tawk_API !== 'undefined') {
        setTimeout(function() {
          Tawk_API.showWidget();
          Tawk_API.chatOpen();
        }, 5000); // 5 秒后弹出
      }
    }
    
    // 购物车有高价值商品时标记为 VIP
    if (settings.cartTotal && parseFloat(settings.cartTotal) > 200) {
      if (typeof Tawk_API !== 'undefined') {
        Tawk_API.setAttributes({
          cartValue: settings.cartTotal,
          highValueCart: true
        });
      }
    }
  }
};
```

---

## 📋 数据表结构

### tawk_to_tickets
Tawk.to 票证记录表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY | 自增 ID |
| tawk_ticket_id | VARCHAR(64) | UNIQUE | Tawk.to 票证 ID |
| uid | INT | NULLABLE | 用户 ID |
| email | VARCHAR(255) | NOT NULL | 用户邮箱 |
| status | VARCHAR(20) | DEFAULT 'open' | open/closed/pending |
| department | VARCHAR(50) | NULLABLE | 部门 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| ended_at | DATETIME | NULLABLE | 结束时间 |
| rating | TINYINT | NULLABLE | 1-5 评分 |
| feedback | TEXT | NULLABLE | 反馈内容 |
| transcript_url | VARCHAR(255) | NULLABLE | 聊天记录 URL |

### user_chat_history
用户聊天历史表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| log_id | BIGINT | PRIMARY KEY | 自增 ID |
| uid | INT | FOREIGN KEY | 用户 ID |
| tawk_ticket_id | VARCHAR(64) | NOT NULL | 关联票证 |
| started_at | DATETIME | NOT NULL | 开始时间 |
| duration_seconds | INT | NULLABLE | 持续时长 |
| subject | VARCHAR(255) | NULLABLE | 主题 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\tawk_api\Unit\TawkToTest;

class TawkIntegrationTest extends KernelTestBase {
  
  protected static $modules = ['tawk_to'];
  
  public function testGetVisitorVariablesForAuthenticatedUser() {
    $user = $this->createUser();
    $provider = \Drupal::service('tawk.user_data_provider');
    
    $variables = $provider->getVisitorVariables($user);
    
    $this->assertEquals($user->getDisplayName(), $variables['firstname']);
    $this->assertEquals($user->getEmail(), $variables['email']);
    $this->assertArrayHasKey('customer_type', $variables);
  }
  
  public function testSendOrderContextWebhook() {
    $order = $this->createCompletedOrder();
    $sender = \Drupal::service('tawk.order_context_sender');
    
    // 模拟发送
    $sender->sendOrderContext($order);
    
    // 验证日志
    $logs = db_select('tawk_webhooks_sent', 'w')
      ->condition('order_id', $order->id())
      ->countQuery()
      ->execute()
      ->fetchField();
    
    $this->assertGreaterThan(0, $logs);
  }
}
```

### 集成测试

```gherkin
Feature: Live Chat Integration
  As a customer
  I want real-time support during shopping
  
  Scenario: Chat while browsing products
    Given I am viewing a product page
    When the chat widget appears after 30 seconds
    Then I should see a welcoming message
    And I can start a conversation instantly
    
  Scenario: Order status inquiry via chat
    Given I have a question about my order
    When I click on the chat button
    And my agent sees my order information automatically
    Then they can provide instant assistance
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算公式 | 目标值 |
|------|---------|--------|
| **平均响应时间** | From message to first response | < 60 seconds |
| **满意度评分** | Average rating from surveys | > 4.0 / 5.0 |
| **首次接触解决率** | FCRT = resolved without escalation | > 75% |
| **聊天转化率** | Chats leading to purchases | > 15% |

### 日志命令

```bash
# 查看聊天日志
drush watchdog-view tawk_to --count=50

# 查询今日聊天统计
drush sql-query "
  SELECT 
    COUNT(*) as total_chats,
    AVG(duration_seconds) as avg_duration,
    AVG(rating) as avg_rating
  FROM tawk_to_tickets
  WHERE DATE(created_at) = CURDATE() AND status = 'closed'
"

# 导出聊天报告
drush php-script export_tawk_to_report
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Tawk.to Documentation | https://help.tawk.to/ |
| Tawk.to API Reference | https://developers.tawk.to/ |
| Live Chat Best Practices | https://www.salesforce.com/products/service/software/live-chat/ |

---

## 🆘 常见问题

### Q1: 如何防止机器人滥用？

**答案**：
```php
class TawkToBotProtection {
  
  private const RATE_LIMIT_PER_IP = 10;
  private const WINDOW_MINUTES = 60;
  
  public function checkRateLimit(string $ip_address): bool {
    $cache_key = "tawk_rate_limit_{$ip_address}";
    
    $recent = \Drupal::cache('tawk_ratelimits')
      ->get($cache_key);
    
    if ($recent && count($recent->data) >= self::RATE_LIMIT_PER_IP) {
      return FALSE; // 超过限制
    }
    
    \Drupal::cache('tawk_ratelimits')
      ->set($cache_key, 
        array_merge($recent ? $recent->data : [], [REQUEST_TIME]),
        REQUEST_TIME + (self::WINDOW_MINUTES * 60));
    
    return TRUE;
  }
}
```

### Q2: 如何实现多语言支持？

**答案**：
```php
class TawkToMultilingualSupport {
  
  public function detectLanguage(): string {
    $browser_lang = \Drupal::request()->headers->get('Accept-Language');
    
    if (strpos($browser_lang, 'zh') !== FALSE) {
      return 'zh';
    } elseif (strpos($browser_lang, 'es') !== FALSE) {
      return 'es';
    } elseif (strpos($browser_lang, 'fr') !== FALSE) {
      return 'fr';
    }
    
    return 'en';
  }
  
  public function getLocalizedGreeting(string $langcode): string {
    $greetings = [
      'en' => 'Hi! How can we help you today?',
      'zh' => '您好！有什么可以帮助您的吗？',
      'es' => '¡Hola! ¿En qué podemos ayudarle hoy?',
      'fr' => 'Bonjour! Comment pouvons-nous vous aider aujourd\'hui?',
    ];
    
    return $greetings[$langcode] ?? $greetings['en'];
  }
}
```

### Q3: 如何处理离线留言？

**答案**：
```php
class OfflineMessageHandler {
  
  public function processOfflineForm(array $form_data): void {
    // 保存留言到数据库
    db_insert('offline_messages')
      ->fields([
        'name' => $form_data['name'],
        'email' => $form_data['email'],
        'phone' => $form_data['phone'] ?? '',
        'message' => $form_data['message'],
        'page_referer' => $form_data['referer'] ?? '',
        'received_at' => REQUEST_TIME,
        'status' => 'pending',
      ])
      ->execute();
    
    // 立即发送邮件通知客服
    $this->notifyStaffAboutNewMessage($form_data);
    
    // 发送确认邮件给用户
    $this->sendConfirmationEmail($form_data);
  }
  
  private function notifyStaffAboutNewMessage(array $data): void {
    $mail_manager = \Drupal::service('plugin.manager.mail');
    
    $mail_manager->send(
      'offline_message',
      'new_message_alert',
      \Drupal\user\User::loadByEmail('support@example.com'),
      'en',
      NULL,
      NULL,
      [
        'customer_name' => $data['name'],
        'customer_email' => $data['email'],
        'message' => $data['message'],
        'response_link' => Url::fromRoute('admin.support.offline_messages')->toString(),
      ]
    );
  }
}
```

---

**大正，tawk-to.md 已补充完成。现在所有 18 个电商模块文档都已完善！** 🚀
