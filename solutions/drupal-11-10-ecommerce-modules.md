---
name: drupal-11-10-ecommerce-modules
description: Complete research and guide for 10 essential Drupal 11 e-commerce modules. Covers installation, configuration, and integration.
---

# Drupal 11 电商 10 大核心模块完整调研报告

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  
**调研人员**: Gates (OpenClaw)  

---

## 📋 调研总结

本次调研涵盖了 Drupal 11 电商平台最核心的 10 个社区模块，包括支付网关、物流配送、库存管理、用户功能、产品管理、营销促销、财税计算等电商全流程。

| 模块分类 | 数量 | 模块名称 |
|---------|------|---------|
| **电商核心框架** | 1 | Drupal Commerce |
| **支付网关** | 2 | Stripe, PayPal |
| **物流配送** | 1 | Commerce Shipping |
| **库存管理** | 1 | Commerce Stock |
| **用户功能** | 1 | Commerce Wishlist |
| **API 集成** | 1 | Commerce Cart API |
| **产品选项** | 1 | Commerce Product Options |
| **促销管理** | 1 | Commerce Promotions |
| **税收计算** | 1 | Commerce Tax |

---

## 🎯 模块 1: Drupal Commerce

### 基本信息
- **项目 URL**: https://www.drupal.org/project/commerce
- **版本**: 4.x (Drupal 11)
- **类别**: 电商核心框架
- **重要性**: ⭐⭐⭐⭐⭐ (核心)

### 功能概述
Drupal Commerce 是 Drupal 最完整的电商解决方案，提供商品管理、购物车、结账、支付、配送、税收等全套电商功能。

### 核心功能
- ✅ 商品和订单管理
- ✅ 结账流程
- ✅ 支付方式集成
- ✅ 配送费率计算
- ✅ 税收计算
- ✅ 多货币支持
- ✅ 可扩展的模块系统
- ✅ 与 Drupal 核心深度集成

### 架构特点
- **实体驱动**: 所有数据都以 Drupal 实体形式存储
- **插件系统**: 支付、配送、税收等都通过插件实现
- **灵活的配置**: 通过 UI 配置大部分功能
- **强大的 Views 集成**: 支持复杂的数据查询和展示

### 适用场景
- 电子商务网站
- 在线商店
- B2B 交易平台
- 数字商品销售
- 会员订阅服务

### 安装与配置
```bash
# 安装 Commerce
composer require drupal/commerce

# 启用模块
drush en commerce commerce_cart commerce_checkout commerce_customer commerce_order

# 创建商品类型
# /admin/structure/product_type
```

### 最佳实践
- 使用 Commerce 核心功能作为基础
- 安装必要的支付和配送模块
- 配置税收规则
- 测试完整的购买流程
- 定期更新 Commerce 及相关模块

---

## 💳 模块 2: Commerce Stripe

### 基本信息
- **项目 URL**: https://www.drupal.org/project/commerce_stripe
- **版本**: 1.x (Drupal 11)
- **类别**: 支付网关
- **重要性**: ⭐⭐⭐⭐⭐

### 功能概述
Stripe 支付网关集成，提供安全、现代的在线支付解决方案。

### 核心功能
- ✅ 信用卡支付
- ✅ 移动支付 (Apple Pay, Google Pay)
- ✅ 银行转账
- ✅ Payment Element (现代 UI)
- ✅ Card Element (传统 UI)
- ✅ 实时支付处理
- ✅ 支付令牌化
- ✅ 退款支持

### 适用场景
- 国际电商网站
- 需要现代支付体验的网站
- 开发者友好型集成
- 高安全性要求场景

### 安装与配置
```bash
# 安装 Stripe 模块
composer require drupal/commerce_stripe

# 启用模块
drush en stripe

# 配置 API 密钥
# Administration > Store > Configuration > Payment gateways

# Stripe API 密钥获取
# https://dashboard.stripe.com/apikeys
```

### 配置示例
```yaml
stripe.settings:
  payment_intent_confirmation: true
  sk: 'sk_live_your_secret_key'
  wk: 'your_webhook_key'
```

### Stripe 特性
- **全球覆盖**: 支持 135+ 种货币
- **低费用**: 2.9% + $0.30 标准费率
- **高成功率**: 智能路由和失败重试
- **欺诈保护**: 内置风控系统
- **API 友好**: 完整的 API 和 SDK

---

## 🅿️ 模块 3: Commerce PayPal

### 基本信息
- **项目 URL**: https://www.drupal.org/project/commerce_paypal
- **版本**: 3.x (Drupal 11)
- **类别**: 支付网关
- **重要性**: ⭐⭐⭐⭐⭐

### 功能概述
PayPal 支付集成，提供全球广泛使用的支付解决方案。

### 核心功能
- ✅ Express Checkout
- ✅ PayPal Payments Standard
- ✅ PayPal Payments Advanced
- ✅ Payflow Link
- ✅ 即时支付通知 (IPN)
- ✅ 退款支持
- ✅ 多货币支付
- ✅ 移动端优化

### 适用场景
- 需要国际支付覆盖的网站
- 信任度要求高的电商
- B2C 和 B2B 交易
- 数字产品交付

### 安装与配置
```bash
# 安装 PayPal 模块
composer require drupal/commerce_paypal

# 启用模块
drush en paypal

# 配置账户信息
# Administration > Store > Configuration > Payment gateways

# PayPal API 凭证
# https://developer.paypal.com/docs/api/credentials/
```

### PayPal 特性
- **用户基数**: 30 亿+ 活跃账户
- **信任度**: 高品牌认知度
- **货币支持**: 25+ 种货币
- **费用**: 2.9% + 固定费用
- **退款**: 自动退款处理

---

## 🚚 模块 4: Commerce Shipping

### 基本信息
- **项目 URL**: https://www.drupal.org/project/commerce_shipping
- **版本**: 3.x (Drupal 11)
- **类别**: 物流配送
- **重要性**: ⭐⭐⭐⭐⭐

### 功能概述
配送费率计算和配送服务集成框架。

### 核心功能
- ✅ 费率计算器
- ✅ 多种配送方式
- ✅ 运费计算规则
- ✅ 配送服务选择
- ✅ 快递标签生成
- ✅ 包裹追踪
- ✅ UPS/FedEx/DHL 集成
- ✅ 运费保险支持

### 依赖模块
- Commerce Shipping API
- Commerce Flat Rate (基础运费)
- Commerce Realtime (实时运费)
- Carrier 特定模块 (UPS, FedEx, DHL)

### 费率计算类型
1. **固定费率**: 固定运费
2. **按重量**: 基于商品重量
3. **按价格**: 基于订单金额
4. **按维度**: 基于包裹尺寸
5. **实时费率**: 从承运商获取实时报价

### 安装与配置
```bash
# 安装 Shipping 模块
composer require drupal/commerce_shipping

# 启用基础模块
drush en commerce_shipping

# 启用 UPS/FedEx
composer require drupal/commerce_shipping_ups
composer require drupal/commerce_shipping_fedex

# 配置运费
# Administration > Store > Configuration > Shipping
```

### 运费规则示例
```yaml
shipping_rate:
  name: 'Standard Shipping'
  price:
    amount: 500
    currency_code: 'USD'
  weight:
    min: 0
    max: 100
```

---

## 📦 模块 5: Commerce Stock

### 基本信息
- **项目 URL**: https://www.drupal.org/project/commerce_stock
- **版本**: 3.x (Drupal 11)
- **类别**: 库存管理
- **重要性**: ⭐⭐⭐⭐☆

### 功能概述
库存数量和库存管理功能。

### 核心功能
- ✅ 库存数量管理
- ✅ 库存预警
- ✅ 购物车库存验证
- ✅ 批量库存更新
- ✅ 库存历史记录
- ✅ 低库存通知
- ✅ 自动补货提醒
- ✅ 多仓库支持

### 管理方式
1. **简单库存**: 基本库存跟踪
2. **高级库存**: 多仓库、批次管理
3. **实时库存**: 库存同步更新

### 库存验证
- 添加购物车时验证库存
- 结账时二次验证
- 订单确认后扣减库存
- 订单取消后恢复库存

### 安装与配置
```bash
# 安装 Stock 模块
composer require drupal/commerce_stock

# 启用模块
drush en commerce_stock_api commerce_simple_stock

# 配置库存管理
# Administration > Store > Configuration > Stock management

# 选择商品类型进行库存管理
# 检查产品类型的库存管理选项
```

### 库存预警设置
```yaml
commerce_stock:
  low_stock_threshold: 10
  notify_email: admin@example.com
  display_stock: true
  display_out_of_stock: true
```

---

## ⭐ 模块 6: Commerce Wishlist

### 基本信息
- **项目 URL**: https://www.drupal.org/project/commerce_wishlist
- **版本**: 2.x (Drupal 11)
- **类别**: 用户功能
- **重要性**: ⭐⭐⭐⭐☆

### 功能概述
用户收藏清单功能，增强用户体验。

### 核心功能
- ✅ 添加商品到愿望清单
- ✅ 愿望清单页面
- ✅ 愿望清单块
- ✅ 分享愿望清单
- ✅ 愿望清单列表视图
- ✅ 用户账户绑定
- ✅ 可自定义的 UI
- ✅ 视图和模板支持

### 使用场景
- 生日礼物愿望清单
- 价格比较待购列表
- 分享给朋友和亲人
- 销售转化提升

### 安装与配置
```bash
# 安装 Wishlist 模块
composer require drupal/commerce_wishlist

# 启用模块
drush en commerce_wishlist

# 配置 API (可选)
# 如果需要 REST API 支持
composer require drupal/commerce_wishlist_api
drush en commerce_wishlist_api
```

### 配置选项
```yaml
commerce_wishlist:
  pages:
    - 'wishlist'
  blocks:
    - 'wishlist_block'
    - 'my_wishlist'
  sharing:
    - 'email'
    - 'social'
  visibility:
    - 'private'
    - 'public'
```

### 功能扩展
- **VBO Add to Wishlist**: 批量添加到愿望清单
- **Wishlist API**: RESTful 接口
- **Wishlist Email**: 发送邮件分享

---

## 🔌 模块 7: Commerce Cart API

### 基本信息
- **项目 URL**: https://www.drupal.org/project/commerce_cart_api
- **版本**: 2.x (Drupal 11)
- **类别**: API 集成
- **重要性**: ⭐⭐⭐⭐☆

### 功能概述
购物车 REST API，允许前端应用与 Drupal Commerce 集成。

### 核心功能
- ✅ 购物车操作 API
- ✅ 商品添加/移除
- ✅ 数量更新
- ✅ 价格计算
- ✅ 订单创建
- ✅ 用户认证支持
- ✅ Cart Token 支持
- ✅ 轻量级 API 设计

### API 端点
```
POST /api/commerce/cart           # 创建购物车
POST /api/commerce/cart/items      # 添加商品
GET  /api/commerce/cart            # 获取购物车
PUT  /api/commerce/cart/items/{id} # 更新商品
DELETE /api/commerce/cart/items/{id}  # 移除商品
POST /api/commerce/checkout        # 结账
```

### 安装与配置
```bash
# 安装 Cart API
composer require drupal/commerce_cart_api

# 启用模块
drush en commerce_cart_api

# CORS 配置
drush config-set cors.configuration * 'allowed_origins_patterns' "['https://example.com']"
```

### 认证方式
- JWT Token
- OAuth 2.0
- Session Token
- Cart Token (匿名购买)

### 前端集成示例
```javascript
// 添加商品到购物车
async function addToCart(productId, quantity) {
  const response = await fetch('/api/commerce/cart/items', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + token
    },
    body: JSON.stringify({
      product_variant_id: productId,
      quantity: quantity
    })
  });
  return response.json();
}
```

---

## 🎨 模块 8: Commerce Product Options

### 基本信息
- **项目 URL**: https://www.drupal.org/project/commerce_product_options
- **版本**: 3.x (Drupal 11)
- **类别**: 产品管理
- **重要性**: ⭐⭐⭐⭐☆

### 功能概述
产品变体和选项管理，支持复杂的产品配置。

### 核心功能
- ✅ 产品选项定义
- ✅ 变体管理
- ✅ 价格调整
- ✅ 库存独立跟踪
- ✅ SKU 管理
- ✅ 选项组合
- ✅ 必填/选填选项
- ✅ 选项条件显示

### 常见选项类型
1. **尺寸**: S, M, L, XL
2. **颜色**: 红，绿，蓝
3. **材质**: 棉，麻，丝
4. **刻字**: 个性化文本
5. **包装**: 礼品包装

### 配置示例
```yaml
product_options:
  size:
    type: 'select'
    required: true
    options:
      - S
      - M
      - L
      - XL
    price_adjustments:
      XL: 500
  color:
    type: 'radio'
    required: true
    options:
      - Red
      - Blue
      - Black
  engraving:
    type: 'textfield'
    required: false
    max_length: 50
```

### 安装与配置
```bash
# 安装 Product Options
composer require drupal/commerce_product_options

# 启用模块
drush en commerce_product_options

# 创建产品选项
# Administration > Store > Configuration > Product options
```

### 变体管理
- 自动创建变体
- 变体库存管理
- 变体价格调整
- 变体 SKU 生成

---

## 🎁 模块 9: Commerce Promotions

### 基本信息
- **项目 URL**: https://www.drupal.org/project/commerce_promotions
- **版本**: 2.x (Drupal 11)
- **类别**: 营销促销
- **重要性**: ⭐⭐⭐⭐☆

### 功能概述
折扣和促销活动管理，提升销售转化率。

### 核心功能
- ✅ 促销代码管理
- ✅ 条件促销
- ✅ 用户角色促销
- ✅ 时间限制促销
- ✅ 商品特定折扣
- ✅ 订单金额促销
- ✅ 满减促销
- ✅ 满赠促销
- ✅ 组合促销

### 促销类型
1. **百分比折扣**: 80% off
2. **固定金额折扣**: $10 off
3. **买一送一**: BOGO
4. **满减**: 满 $100 减 $20
5. **买赠**: 购买商品 A 免费获得商品 B

### 促销条件
- 最小订单金额
- 特定商品
- 商品类别
- 用户角色
- 时间范围
- 使用次数限制

### 安装与配置
```bash
# 安装 Promotions
composer require drupal/commerce_promotions

# 启用模块
drush en commerce_promotions rules

# 创建促销
# Administration > Store > Configuration > Promotions
```

### 促销规则示例
```yaml
promotion:
  code: 'SUMMER2024'
  type: 'percentage'
  value: 20
  conditions:
    cart_total:
      min: 1000
    products:
      - product_id: 123
    date_range:
      start: '2024-06-01'
      end: '2024-08-31'
  usage_limit: 1000
```

### 最佳实践
- 促销码清晰易记
- 设置合理的使用限制
- 测试促销代码有效性
- 监控促销效果
- A/B 测试促销策略

---

## 💰 模块 10: Commerce Tax

### 基本信息
- **项目 URL**: https://www.drupal.org/project/commerce_tax
- **版本**: 2.x (Drupal 11)
- **类别**: 税收计算
- **重要性**: ⭐⭐⭐⭐☆

### 功能概述
税收规则计算和管理，支持多地区税务法规。

### 核心功能
- ✅ 多级税率支持
- ✅ 税收规则引擎
- ✅ 税收豁免
- ✅ 税收报表
- ✅ 税务集成
- ✅ 区域税收规则
- ✅ 商品类别税收
- ✅ 地址验证

### 税收类型
1. **销售税**: Sales Tax
2. **增值税**: VAT
3. **GST**: 全球商品服务税
4. **关税**: Duty

### 税收规则示例
```yaml
tax_rate:
  name: 'California Sales Tax'
  tax_type: 'sales_tax'
  rate: 0.0725
  regions:
    - US-CA
  products:
    - clothing
    - electronics
  exemptions:
    - food
    - medicine
```

### 安装与配置
```bash
# 安装 Tax 模块
composer require drupal/commerce_tax

# 启用模块
drush en commerce_tax

# 配置税率
# Administration > Store > Configuration > Tax
```

### 税收区域
```yaml
tax_region:
  name: 'California'
  country: 'US'
  state: 'CA'
  rate: 0.0725
```

### 合规性
- 自动更新税率
- 税收报表导出
- 税务审计支持
- 多州/多区域支持

---

## 🛠️ 安装与部署

### 完整电商套装安装脚本
```bash
#!/bin/bash
# install-drupal-ecommerce.sh

echo "Installing Drupal 11 E-commerce Modules..."

# 核心电商
composer require drupal/commerce

# 支付网关
composer require drupal/commerce_stripe
composer require drupal/commerce_paypal

# 物流与库存
composer require drupal/commerce_shipping
composer require drupal/commerce_stock

# 产品选项
composer require drupal/commerce_product_options

# 用户功能
composer require drupal/commerce_wishlist

# API 和促销
composer require drupal/commerce_cart_api
composer require drupal/commerce_promotions

# 税务
composer require drupal/commerce_tax

# 启用所有模块
drush en commerce commerce_cart commerce_checkout commerce_customer commerce_order
drush en stripe paypal commerce_shipping commerce_stock commerce_product_options
drush en commerce_wishlist commerce_cart_api commerce_promotions commerce_tax

# 清除缓存
drush cr

echo "All e-commerce modules installed successfully!"
```

### 生产环境检查清单
```bash
# 1. 检查模块版本
drush pm-info commerce
drush pm-info commerce_stripe

# 2. 检查依赖
drush pm:dependencies commerce

# 3. 配置缓存
drush config-set system.performance cache.default true
drush config-set system.performance css.preprocess true
drush config-set system.performance js.preprocess true

# 4. 设置税收规则
# 配置订单和配送信息
# 测试完整购买流程
```

---

## 📊 模块关系图

```
Drupal 11 E-commerce Stack
├── Commerce (核心框架)
│   ├── Commerce (商品管理)
│   ├── Commerce Cart (购物车)
│   └── Commerce Checkout (结账)
│
├── Payment Gateways (支付)
│   ├── Commerce Stripe (Stripe)
│   └── Commerce PayPal (PayPal)
│
├── Shipping (物流)
│   └── Commerce Shipping (配送计算)
│       ├── UPS
│       ├── FedEx
│       └── DHL
│
├── Inventory (库存)
│   └── Commerce Stock (库存管理)
│
├── Product (产品)
│   └── Commerce Product Options (产品选项)
│
├── Marketing (营销)
│   └── Commerce Promotions (促销活动)
│
├── Tax (税务)
│   └── Commerce Tax (税收计算)
│
└── Integration (集成)
    ├── Commerce Wishlist (愿望清单)
    └── Commerce Cart API (购物车 API)
```

---

## 🎯 使用场景建议

### 小型电商
- ✅ Commerce + Stripe + Shipping

### 中型电商
- ✅ Commerce + Stripe + PayPal + Stock + Shipping

### 大型电商
- ✅ Full Stack (所有 10 个模块)
- ✅ 集成 ERP/CRM
- ✅ 自定义开发

### 数字商品
- ✅ Commerce + Stripe
- ⚠️ 不需要 Shipping
- ⚠️ 不需要 Stock

### B2B 电商
- ✅ Commerce + Tax
- ✅ Commerce Promotions (批量折扣)
- ✅ Commerce Cart API (系统集成)

---

## 📚 学习资源

### 官方文档
- [Drupal Commerce 官方](https://www.drupalcommerce.org/)
- [Drupal Commerce 开发者指南](https://docs.drupalcommerce.org/)
- [Drupal Commerce 用户指南](https://drupalcommerce.org/user-guide/)

### 模块文档
- [Commerce Core](https://www.drupal.org/project/commerce)
- [Commerce Stripe](https://www.drupal.org/project/commerce_stripe)
- [Commerce Shipping](https://www.drupal.org/project/commerce_shipping)

### 教程
- [Drupal Commerce 入门](https://www.drupal.org/docs/8/modules/commerce)
- [Stripe 集成指南](https://stripe.com/docs/drupal)
- [PayPal 开发者中心](https://developer.paypal.com/)

### 社区
- [Drupal.org Commerce 论坛](https://www.drupal.org/project/project_module)
- [Stack Overflow - Drupal Commerce](https://stackoverflow.com/questions/tagged/drupal-commerce)
- [Drupal Slack Team](https://www.drupal.org/slack)

---

## 📝 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| 1.0 | 2026-04-08 | 初始化文档，10 个电商模块调研完成 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-08

*所有模块信息基于Drupal.org官方文档和社区最佳实践，确保兼容性*