# Drupal 11 电商 20 模块速查表

**版本**: v2.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**最后更新**: 2026-04-08  

---

## 📊 20 个模块完整列表

| 号 | 模块名 | 功能 | 安装命令 | 优先级 |
|----|--------|------|---------|--------|
| 1 | **Commerce** | 电商核心框架 | `composer require drupal/commerce` | ⭐⭐⭐⭐⭐ |
| 2 | **Commerce Stripe** | Stripe 支付 | `composer require drupal/commerce_stripe` | ⭐⭐⭐⭐⭐ |
| 3 | **Commerce PayPal** | PayPal 支付 | `composer require drupal/commerce_paypal` | ⭐⭐⭐⭐⭐ |
| 4 | **Commerce Shipping** | 物流配送 | `composer require drupal/commerce_shipping` | ⭐⭐⭐⭐⭐ |
| 5 | **Commerce Shipment** | 发货通知 | `composer require drupal/commerce_shipment` | ⭐⭐⭐⭐☆ |
| 6 | **Commerce Fulfillment** | 订单履行 | `composer require drupal/commerce_fulfillment` | ⭐⭐⭐⭐☆ |
| 7 | **Commerce Stock** | 库存管理 | `composer require drupal/commerce_stock` | ⭐⭐⭐⭐⭐ |
| 8 | **Commerce Product Options** | 产品选项 | `composer require drupal/commerce_product_options` | ⭐⭐⭐⭐⭐ |
| 9 | **Commerce Wishlist** | 愿望清单 | `composer require drupal/commerce_wishlist` | ⭐⭐⭐⭐☆ |
| 10 | **Commerce Product Review** | 产品评论 | `composer require drupal/commerce_product_review` | ⭐⭐⭐⭐☆ |
| 11 | **Commerce Loyalty Points** | 积分奖励 | `composer require drupal/commerce_loyalty_points` | ⭐⭐⭐⭐☆ |
| 12 | **Commerce Promotions** | 促销活动 | `composer require drupal/commerce_promotions` | ⭐⭐⭐⭐⭐ |
| 13 | **Commerce Upsell** | 上销售 | `composer require drupal/commerce_upsell` | ⭐⭐⭐⭐☆ |
| 14 | **Commerce Cart Reengage** | 购物车恢复 | `composer require drupal/commerce_reengage` | ⭐⭐⭐⭐⭐ |
| 15 | **Commerce Email** | 邮件通知 | `composer require drupal/commerce_email` | ⭐⭐⭐⭐⭐ |
| 16 | **Commerce Rec** | 推荐引擎 | `composer require drupal/commerce_rec` | ⭐⭐⭐⭐☆ |
| 17 | **Commerce Cart API** | 购物车 API | `composer require drupal/commerce_cart_api` | ⭐⭐⭐⭐☆ |
| 18 | **Commerce Tax** | 税收计算 | `composer require drupal/commerce_tax` | ⭐⭐⭐⭐☆ |
| 19 | **tawk.to** | 实时聊天 | `composer require drupal/tawkto` | ⭐⭐⭐⭐☆ |

---

## 🎯 快速安装方案

### 基础方案（8 个核心模块）
```bash
composer require drupal/commerce \
  drupal/commerce_stripe \
  drupal/commerce_paypal \
  drupal/commerce_shipping \
  drupal/commerce_stock \
  drupal/commerce_promotions \
  drupal/commerce_cart_api \
  drupal/commerce_email
```

### 完整方案（20 个模块）
```bash
#!/bin/bash
# 完整安装脚本
MODULES="commerce commerce_stripe commerce_paypal commerce_shipping commerce_shipment commerce_fulfillment commerce_stock commerce_product_options commerce_wishlist commerce_product_review commerce_loyalty_points commerce_promotions commerce_upsell commerce_reengage commerce_email commerce_rec commerce_cart_api commerce_tax tawkto"

for module in $MODULES; do
  composer require drupal/$module
done

drush en $MODULES
drush cr
```

---

## 📦 分类概览

### 核心框架 (1)
- Commerce

### 支付网关 (2)
- Commerce Stripe
- Commerce PayPal

### 物流配送 (3)
- Commerce Shipping
- Commerce Shipment
- Commerce Fulfillment

### 库存管理 (2)
- Commerce Stock
- Commerce Product Options

### 用户功能 (3)
- Commerce Wishlist
- Commerce Product Review
- Commerce Loyalty Points

### 营销促销 (3)
- Commerce Promotions
- Commerce Upsell
- Commerce Cart Reengage

### 订单通知 (2)
- Commerce Email
- Commerce Rec

### API 和客服 (4)
- Commerce Cart API
- Commerce Tax
- tawk.to

---

## 🔧 Drush 命令速查

```bash
# 启用所有电商模块
drush en commerce commerce_cart commerce_checkout commerce_payment

# 清除缓存
drush cr

# 检查模块状态
drush pm:status

# 查看模块信息
drush pm-info commerce
```

---

## 📋 配置清单

- [ ] 配置 Stripe API 密钥
- [ ] 配置 PayPal 账户
- [ ] 设置物流配送方式
- [ ] 配置税收规则
- [ ] 创建商品类型
- [ ] 测试完整购买流程

---

**版本**: v2.0 | **状态**: 活跃维护  
**更新时间**: 2026-04-08
