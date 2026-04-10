---
name: commerce-stripe
description: Complete guide to Stripe payment integration with Drupal Commerce. Covers installation, configuration, webhooks, and best practices for processing credit card payments.
---

# Commerce Stripe - Stripe 支付集成 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Stripe 模块提供与 Stripe 支付网关的深度集成，支持信用卡、借记卡、Apple Pay、Google Pay 等支付方式。适用于处理在线交易、订阅付款和一次性付款。

### 核心功能
- ✅ 实时信用卡支付
- ✅ Apple Pay / Google Pay 支持
- ✅ 定期订阅和分期付款
- ✅ 支付令牌化（PCI DSS 合规）
- ✅ Webhook 自动处理
- ✅ 退款管理
- ✅ 多币种支持
- ✅ 客户数据存储（Card on File）
- ✅ 3D Secure 验证

### 适用场景
- 标准电商网站
- SaaS 订阅服务
- 会员制平台
- 数字商品销售
- B2B/B2C 混合业务

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Stripe 账号（测试/生产模式）
- SSL 证书（HTTPS 必需）

### 安装步骤

#### 方法 1: 使用 Composer (推荐)
```bash
cd /path/to/drupal/root
composer require drupal/stripe_payment
drush en stripe_payment
```

#### 方法 2: 手动下载
```bash
# 1. 下载模块
drush dl stripe_payment

# 2. 启用模块
drush en stripe_payment --yes

# 3. 配置页面访问
# @link https://YOUR-SITE.com/admin/config/payment/stripe_payment
```

#### 方法 3: 使用 Drupal UI
1. 访问 `/admin/modules`
2. 找到 "Stripe Payment"
3. 勾选并点击 "Install"

---

## 💳 Stripe 账号配置

### 1. 注册 Stripe 账号
访问 [https://stripe.com](https://stripe.com) 注册账号

### 2. 获取 API 密钥

#### 测试环境
```
Publishable Key: pk_test_xxxxxxxxxxxx
Secret Key: sk_test_xxxxxxxxxxxx
Webhook Signing Secret: whsec_xxxxxxxxxxxx
```

#### 生产环境
```
Publishable Key: pk_live_xxxxxxxxxxxx
Secret Key: sk_live_xxxxxxxxxxxx
Webhook Signing Secret: whsec_xxxxxxxxxxxx
```

### 3. 配置 Stripe Dashboard
1. 登录 [Stripe Dashboard](https://dashboard.stripe.com)
2. 进入 **Developers → API keys**
3. 复制 Live Keys 或 Test Keys
4. 设置 Webhook endpoint

---

## ⚙️ Drupal 配置

### 1. 启用模块
```bash
drush en stripe_payment --yes
```

### 2. 配置基本设置

#### 路径：`/admin/config/payment/stripe_payment`

**General Settings (常规设置)**
| 选项 | 值 | 说明 |
|------|-----|------|
| Enable Stripe | ✅ Enabled | 启用 Stripe 支付 |
| Publishable Key | `pk_test_...` | 公钥 |
| Secret Key | `sk_test_...` | 私钥 |
| API Version | `2024-12-18.acacia` | Stripe API 版本 |

**Payment Method Settings (支付方法设置)**
| 选项 | 值 | 说明 |
|------|-----|------|
| Default Currency | CNY / USD | 默认货币 |
| Allow International Payments | ❌ Disabled | 是否允许国际支付 |
| Require CVV | ✅ Yes | 需要 CVV |
| Save Cards | ✅ Yes | 保存卡片信息 |

### 3. 配置 Webhook

#### 在 Stripe Dashboard 中设置
1. 访问 **Developers → Developers → Webhooks**
2. 点击 **Add endpoint**
3. Endpoint URL: `https://your-site.com/stripe-webhook`
4. Select events:
   ```
   ✓ payment_intent.succeeded
   ✓ payment_intent.payment_failed
   ✓ charge.refunded
   ✓ customer.subscription.created
   ✓ customer.subscription.deleted
   ```
5. Click **Add endpoint**

#### 在 Drupal 中验证
```bash
# 检查 webhook 路由
drush rr stripe_webhook

# 测试 webhook
curl -X POST https://your-site.com/stripe-webhook \
  -H "Stripe-Signature: YOUR_SIGNING_SECRET" \
  --data '{"type":"ping"}'
```

---

## 🛍️ 在商店中集成 Stripe

### 1. 创建商品类型
```
/content-types/manage/shop_product
```

### 2. 添加价格字段
```
Manage fields → Add field → Price
```

### 3. 配置结账流程
```
/admin/store/settings/checkout
→ Add Stripe as payment method
→ Set payment order
```

### 4. 前端集成（可选）
```html
<!-- Stripe Elements -->
<div id="payment-element"></div>

<script src="https://js.stripe.com/v3/"></script>
<script>
  const stripe = Stripe('YOUR_PUBLISHABLE_KEY');
  const elements = stripe.elements();
  const paymentElement = elements.create('payment');
  paymentElement.mount('#payment-element');
</script>
```

---

## 🔧 高级配置

### 1. 自定义支付按钮样式
```css
.StripeElement {
  padding: 12px;
  border-radius: 8px;
  background: #f9f9f9;
}

.StripeElement--focus {
  border-color: #635bff;
  box-shadow: 0 0 0 2px #e0e0ff;
}
```

### 2. 多货币支持
```php
// 在 hooks 中添加货币转换
function mymodule_stripe_payment_currency_convert($amount, $from_currency, $to_currency) {
  $rates = [
    'USD' => 1.0,
    'EUR' => 0.85,
    'CNY' => 7.2,
  ];
  return ($amount * $rates[$to_currency]) / $rates[$from_currency];
}
```

### 3. 订单状态映射
```yaml
payment_intent.succeeded: completed
payment_intent.payment_failed: failed
charge.refunded: refunded
```

---

## 🔐 安全最佳实践

### 1. PCI DSS 合规
- ✅ 使用 Stripe Elements（不收集卡片数据）
- ✅ Tokenization 替代直接处理
- ✅ HTTPS 强制要求
- ✅ Webhook signature 验证

### 2. 服务器安全
```bash
# 限制 access.php.settings
.settings.php:
  settings['stripe_secret_key'] = getenv('STRIPE_SECRET_KEY');
```

### 3. Webhook 签名验证
```php
\Drupal::service('stripe.webhook')
  ->verifyEvent($payload, $sig_header, $secret);
```

---

## 📋 数据表结构

### stripe_payment_settings
| 字段 | 类型 | 说明 |
|------|------|------|
| sid | INT | 序列 ID |
| publishable_key | VARCHAR(255) | 公钥 |
| secret_key | VARCHAR(255) | 私钥（加密存储） |
| api_version | VARCHAR(50) | API 版本 |
| currency | VARCHAR(3) | 默认货币 |

### stripe_payment_method
| 字段 | 类型 | 说明 |
|------|------|------|
| pmid | INT | 支付方法 ID |
| uid | INT | 用户 ID |
| stripe_customer_id | VARCHAR(100) | Stripe 客户 ID |
| payment_method_id | VARCHAR(100) | Stripe 支付方法 ID |
| is_default | BOOLEAN | 是否默认 |

---

## 🧪 测试建议

### 测试卡号（Stripe）

| 卡号 | 结果 | 用途 |
|------|------|------|
| 4242 4242 4242 4242 | Success | 成功支付 |
| 4000 0000 0000 9995 | Decline | 拒付 |
| 4000 0025 0000 3155 | Requires Action | 3D Secure |
| 4000 0000 0000 3036 | Expired | 过期卡 |

### 测试流程
```bash
# 1. 启用测试模式
drush config-set stripe_payment.settings mode test

# 2. 创建测试订单
# 使用测试卡号 4242 4242 4242 4242

# 3. 检查 Stripe Dashboard
# https://dashboard.stripe.com/test/payments

# 4. 验证 webhook
drush watchdog-message stripe-test-log
```

---

## 📊 监控与日志

### 日志级别
```bash
# 查看 Stripe 相关日志
drush watchdog-view stripe

# 导出日志
drush watchdog-export stripe > stripe.log
```

### 关键指标
- Payment success rate
- Failed payment reasons
- Refund count/value
- Average transaction amount

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Stripe 官方文档 | https://stripe.com/docs |
| Drupal Commerce | https://www.drupal.org/project/commerce |
| Stripe Payment Module | https://www.drupal.org/project/stripe_payment |
| Stripe API Reference | https://stripe.com/docs/api |
| Test Cards | https://stripe.com/docs/testing#cards |
| Webhooks Guide | https://stripe.com/docs/webhooks |

---

## 🆘 常见问题

### Q1: 为什么支付失败？
- 检查 API 密钥是否正确
- 确认 Webhook 已配置
- 检查订单金额格式
- 验证 SSL 证书

### Q2: 如何恢复被删除的订单？
- Stripe Dashboard → Payments → 找到订单 → Resubmit
- 或使用 API: `POST /v1/payment_intents/{id}/cancel`

### Q3: 如何处理退款？
```bash
# 通过 UI
/store/orders/{order-id}/refund

# 通过代码
\Drupal::service('stripe.refund')->create($payment_id, $amount);
```

---

**大正，commerce-stripe.md 已创建完成。您有其他指令吗？** 🚀
