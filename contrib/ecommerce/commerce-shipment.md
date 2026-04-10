---
name: commerce-shipment
description: Complete guide to Commerce Shipment for tracking and managing orders, deliveries, and fulfillment status.
---

# Commerce Shipment - 发货通知管理 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Shipment 提供订单发货跟踪和配送状态管理功能。支持创建货运单、追踪包裹状态、自动发送发货通知邮件等功能。

### 核心功能
- ✅ 创建和管理货运单（Shipment）
- ✅ 追踪包裹状态更新
- ✅ 自动化发货通知邮件
- ✅ 承运商标签打印（Label Printing）
- ✅ 订单状态同步
- ✅ 批量发货处理

### 适用场景
- 实体商品电商
- 需要物流追踪的订单
- B2B 企业客户
- 多仓库发货管理

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- Shipping module（可选）

### 安装步骤

#### 方法 1: 使用 Composer (推荐)
```bash
cd /path/to/drupal/root
composer require drupal/shipment
drush en shipment
```

#### 方法 2: 手动下载
```bash
drush dl shipment
drush en shipment --yes
```

---

## ⚙️ 基础配置

### 1. 启用模块
```bash
drush en shipment --yes
```

### 2. 配置发货通知邮件

#### 路径：`/admin/store/settings/shipment/email`

**模板设置**
| 选项 | 默认值 | 说明 |
|------|--------|------|
| Subject | Your order has shipped | 邮件主题 |
| From Name | Store Name | 发件人名称 |
| From Email | noreply@store.com | 发件人邮箱 |
| Body Template | HTML template | 邮件内容模板 |

#### 邮件模板变量
```twig
{{ order.number }} - Order Number
{{ customer.name }} - Customer Name
{{ shipment.tracking_number }} - Tracking Number
{{ carrier.name }} - Carrier Name
{{ links.webview }} - Tracking Link
```

---

## 📦 订单流程

### 标准发货流程

```
Order Created
    ↓
Order Processing
    ↓ [Manual Approval]
Shipment Creation
    ↓
Tracking Number Assigned
    ↓
Notification Sent → Customer
    ↓
Delivery Confirmation
```

### 自动化配置

#### 触发规则
```yaml
# rules/shipment_automation.yml
rules_shipment_auto_create:
  LABEL: 'Automatically create shipment'
  COND: 
    - entity_is_type: 'commerce_order'
    - data_is: ['commerce-order:order-status', '=', 'processing']
  ACT:
    - plugin: 'shipment:create'
      feed:
        from_state: 'processing'
        to_state: 'shipped'
```

---

## 🔗 承运商集成

### 1. USPS Integration

#### API 端点
```
USPS Shipping API: https://secure.shippingapis.com
Authentication: Basic Auth
Format: XML
```

#### 获取追踪信息
```php
use Drupal\shipment\Api\UspsApi;

$api = new UspsApi();
$tracking_info = $api->getTracking('9400111899562901234567');

// 响应示例
[
  'status' => 'Delivered',
  'delivered_date' => '2026-04-08',
  'events' => [...]
]
```

### 2. FedEx Integration

```yaml
fedex_integration:
  account_number: '123456789'
  meter_number: '987654321'
  key: 'API_KEY'
  password: 'API_PASS'
```

### 3. DHL Integration

```bash
DHL Express API v1
POST /exp/v1/shipping/labels
Authorization: Bearer {token}
```

---

## 🛠️ 数据表结构

### shipment
| 字段 | 类型 | 说明 |
|------|------|------|
| shipment_id | INT | 货运单 ID |
| order_id | INT | 关联订单 ID |
| tracking_number | VARCHAR(50) | 追踪号码 |
| carrier_id | VARCHAR(50) | 承运商 ID |
| weight | DECIMAL(10,2) | 包裹重量 |
| dimensions | JSON | 尺寸 (LxWxH) |
| status | VARCHAR(50) | 状态 (created/shipped/delivered) |
| created_at | DATETIME | 创建时间 |

### shipment_event
| 字段 | 类型 | 说明 |
|------|------|------|
| event_id | INT | 事件 ID |
| shipment_id | INT | 货运单 ID |
| event_type | VARCHAR(50) | 事件类型 |
| location | VARCHAR(255) | 地点 |
| description | TEXT | 描述 |
| timestamp | DATETIME | 事件时间 |

### shipment_carrier
| 字段 | 类型 | 说明 |
|------|------|------|
| carrier_id | VARCHAR(50) | 承运商 ID |
| name | VARCHAR(100) | 名称 |
| api_key | VARCHAR(255) | API 密钥 |
| settings | JSON | 配置参数 |

---

## 🎨 前端集成

### 1. 用户账户页面

#### 追踪链接嵌入
```html
<!-- Orders page -->
<div class="shipment-tracking">
  <span>Tracking #</span> {{ shipment.tracking_number }}
  <a href="{{ shipment.tracking_url }}" target="_blank">
    Track Package
  </a>
</div>
```

### 2. 订单详情追加

```php
function mymodule_page_build_alter(&$page) {
  if (current_path() == 'user/{uid}/orders') {
    $page['shipment_tracking'] = [
      '#theme' => 'shipment_tracking',
      '#shipment' => $recent_order_shipment,
    ];
  }
}
```

---

## 💻 代码示例

### 创建货运单
```php
use Drupal\shipment\Entity\Shipment;
use Drupal\commerce_order\Entity\Order;

// 获取订单
$order = Order::load($order_id);

// 创建货运单
$shipment = Shipment::create([
  'order' => $order->id(),
  'tracking_number' => '1Z999AA10123456784',
  'carrier' => 'UPS',
]);

// 保存并发送通知
$shipment->save();
$shipment->sendNotificationEmail();
```

### 批量标记发货
```php
// Admin bulk action
$order_ids = [123, 124, 125];
foreach ($order_ids as $order_id) {
  $order = Order::load($order_id);
  $shipment = Shipment::createFromOrder($order, [
    'tracking_number' => uniqid('TRACK'),
    'carrier' => 'USPS',
  ]);
  $shipment->save();
}
```

---

## 🧪 测试建议

### 单元测试
```php
public function testCreateShipment() {
  $order = $this->createTestOrder();
  $shipment = Shipment::create([
    'order' => $order->id(),
    'tracking_number' => 'TEST123',
  ]);
  
  $this->assertEquals($order->id(), $shipment->getOrder()->id());
}
```

### 集成测试
```yaml
# tests/behat/shipment.feature
Scenario: User receives shipment notification
  Given I have an order in "processing" state
  When I mark the order as "shipped" with tracking number
  Then I should receive an email with tracking information
```

---

## 📊 监控与日志

### 关键指标
- Shipments per day
- Average processing time
- Failed notifications count
- Carrier API success rate

### 日志命令
```bash
# 查看 shipment 日志
drush watchdog-view shipment

# 导出交付记录
drush watchdog-export shipment > shipments.log
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Drupal Shipment Module | https://www.drupal.org/project/shipment |
| USPS Tracking API | https://pe.usps.com/text/pub28/28c1_005.htm |
| FedEx Tracking | https://www.fedex.com/en-us/shipping/tracking-api.html |

---

**大正，commerce-shipment.md 已创建完成。您还有其他指令吗？** 🚀
