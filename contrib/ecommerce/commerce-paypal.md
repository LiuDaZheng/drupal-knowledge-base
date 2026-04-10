---
name: commerce-paypal
description: Complete guide to PayPal Commerce integration with Drupal Commerce. Covers payment, checkout, and subscription management.
---

# Commerce PayPal - PayPal 支付集成 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce PayPal 提供与 PayPal 生态系统的深度集成，支持 PayPal Checkout、PayPal Credit、Venmo 等多种支付方式。适用于全球电商业务。

### 核心功能
- ✅ PayPal Checkout（一键结账）
- ✅ 信用卡支付（通过 PayPal）
- ✅ Venmo 集成（美国）
- ✅ PayPal Credit 分期付款
- ✅ 退款管理
- ✅ 多币种支持（200+ 货币）
- ✅ 订单状态同步
- ✅ 发票自动生成

### 适用场景
- 跨境电商
- 小型/中型电商
- 服务类订阅
- B2B/B2C 混合业务

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- PayPal Business Account
- SSL 证书（HTTPS）

### 安装步骤

#### 方法 1: 使用 Composer (推荐)
```bash
cd /path/to/drupal/root
composer require drupal/paypal
drush en paypal
```

#### 方法 2: 手动下载
```bash
# 1. 下载模块
drush dl paypal

# 2. 启用模块
drush en paypal --yes

# 3. 访问配置页面
# @link https://YOUR-SITE.com/admin/config/payment/paypal
```

---

## 💳 PayPal 账号配置

### 1. 注册 PayPal 商业账号
访问 [https://www.paypal.com/business](https://www.paypal.com/business) 注册

### 2. 获取 API 凭证

#### PayPal Developer Dashboard
1. 登录 [PayPal Developer Dashboard](https://developer.paypal.com)
2. 进入 **Dashboard → My Apps & Credentials**
3. 切换到 **Live** 或 **Sandbox** 模式
4. 创建新的 REST API 应用

#### 获取凭据
```
Client ID: AaB...xyz123
Client Secret: EFG...abc456
```

### 3. 配置 PayPal 设置

| 选项 | 说明 |
|------|------|
| Sandbox Mode | 测试环境开关 |
| Environment | Live / Sandbox |
| Payment Action | Capture / Authorize |
| Button Layout | PayLater / Standard |

---

## ⚙️ Drupal 配置

### 1. 启用模块
```bash
drush en paypal --yes
```

### 2. 基本设置配置

#### 路径：`/admin/config/payment/paypal`

**General Settings**
| 选项 | 值 | 说明 |
|------|-----|------|
| Enable PayPal | ✅ Enabled | 启用 PayPal 支付 |
| Environment | Sandbox | 测试环境 |
| Client ID | xxxxxx | PayPal Client ID |
| Client Secret | xxxxxx | PayPal Secret Key |
| Payment Action | capture | 捕获授权金额 |

**Button Customization**
| 选项 | 值 |
|------|-----|
| Button Color | Gold / Blue / Black |
| Button Shape | Rectangular / Pill |
| Button Label | Checkout / Buy Now |
| Show Pay Later | ✅ Yes |

### 3. Webhook 配置

#### 在 PayPal 开发者后台
1. **Webhooks → Add webhook**
2. URL: `https://your-site.com/paypal-webhook`
3. Event types:
   ```
   ✓ PAYMENT.CAPTURE.COMPLETED
   ✓ PAYMENT.CAPTURE.DENIED
   ✓ PAYMENT.CAPTURE.REFUNDED
   ```

#### 验证回调
```bash
# 检查路由
drush rr paypal_webhook

# 测试 webhook
curl -X POST https://your-site.com/paypal-webhook \
  -H "Content-Type: application/json" \
  --data '{"event_type":"PAYMENT.CAPTURE.COMPLETED"}'
```

---

## 🛍️ 商店集成

### 1. 创建产品
```
/content-types/manage/product
→ Add product → Add price field
```

### 2. 配置结账
```
/admin/store/settings/checkout
→ Payment methods → PayPal
→ Set as default or optional
```

### 3. 前端按钮嵌入
```html
<!-- PayPal Buttons -->
<div id="paypal-button-container"></div>

<script src="https://www.paypal.com/sdk/js?client-id=YOUR_CLIENT_ID&currency=USD"></script>
<script>
  paypal.Buttons({
    createOrder: function(data, actions) {
      return actions.order.create({
        purchase_units: [{ amount: { value: '100.00' } }]
      });
    },
    onApprove: function(data, actions) {
      return actions.order.capture().then(function(details) {
        alert('Payment completed by ' + details.payer.name.given_name);
      });
    }
  }).render('#paypal-button-container');
</script>
```

---

## 🔧 高级功能

### 1. 订阅/分期支付
```php
// 创建 recurring payments
\Drupal\paypal\Plugin\PaymentMethod\Paid::createSubscription();
```

### 2. 多币种处理
```yaml
# settings.php
$config['paypal.settings']['accepted_currencies'] = ['USD', 'EUR', 'CNY'];
```

### 3. 自定义订单备注
```php
function mymodule_paypal_payment_form_alter(&$form, \Drupal\Core\Form\FormStateInterface $form_state) {
  $form['notes'] = [
    '#type' => 'textfield',
    '#title' => t('Order notes'),
  ];
}
```

---

## 📋 数据表结构

### paypal_settings
| 字段 | 类型 | 说明 |
|------|------|------|
| pid | INT | 设置 ID |
| client_id | VARCHAR(128) | PayPal Client ID |
| client_secret | VARCHAR(256) | PayPal Secret Key |
| mode | VARCHAR(20) | Sandbox/Live |
| currency | VARCHAR(10) | 默认货币 |

### paypal_transactions
| 字段 | 类型 | 说明 |
|------|------|------|
| txnid | VARCHAR(128) | PayPal 交易 ID |
| order_id | INT | Drupal 订单 ID |
| status | VARCHAR(50) | 交易状态 |
| amount | DECIMAL(10,2) | 交易金额 |
| timestamp | DATETIME | 交易时间 |

---

## 🧪 测试建议

### Sandbox 测试账号

| 邮箱 | 密码 | 用途 |
|------|------|------|
| buyer@example.com | 123456 | 买家账户 |
| seller@example.com | 123456 | 卖家账户 |

### 测试流程
```bash
# 1. 启用沙盒模式
drush config-set paypal.settings environment sandbox

# 2. 创建测试订单
# 使用 buyer@example.com 登录 PayPal

# 3. 查看 Dashboard
# https://sandbox.paypal.com

# 4. 检查日志
drush watchdog-view paypal
```

---

## 📊 监控与日志

### 关键指标
- Transaction success rate
- Failed transactions count
- Average transaction value
- Refund rate

### 日志命令
```bash
# 实时查看 PayPal 日志
drush watch:tail paypal

# 导出日志
drush watchdog-export paypal > paypal.log
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| PayPal Developer | https://developer.paypal.com |
| PayPal SDK Docs | https://developer.paypal.com/docs/checkout/ |
| Drupal PayPal Module | https://www.drupal.org/project/paypal |
| REST API Guide | https://developer.paypal.com/docs/api/overview/ |
| Webhook Events | https://developer.paypal.com/docs/api/webhooks/v1/#event-types |

---

## 🆘 常见问题

### Q1: 为什么连接失败？
- 检查 Client ID 和 Secret 是否正确
- 确认是 Sandbox 还是 Live 模式匹配
- 验证 HTTPS 配置

### Q2: 如何查询订单状态？
- Dashboard → Transactions
- 或使用 API: `GET /v2/checkout/orders/{order_id}`

### Q3: 如何处理退款？
```bash
# 通过 UI
/store/orders/{order-id}/refund

# 通过 API
POST /v2/payments/captures/{capture_id}/refund
```

---

**大正，commerce-paypal.md 已创建完成。您有其他指令吗？** 🚀
