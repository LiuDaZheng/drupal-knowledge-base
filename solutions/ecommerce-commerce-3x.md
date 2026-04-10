# Drupal Commerce 电商模块完整指南

> **重要说明**：本文档基于 Drupal.org 官方文档和社区讨论整合

**版本**: Commerce 3.x  
**Drupal 兼容性**: Drupal 10.3+ 和 Drupal 11  
**最新稳定版本**: 3.1.0 (2025-07-04)  
**官方链接**: [Drupal.org/project/commerce](https://www.drupal.org/project/commerce)

---

## 📚 Drupal Commerce 现状（据 2026-04 官方信息）

### 版本信息

| 版本 | 发布日期 | 支持的 Drupal | 状态 |
|------|----------|---------------|------|
| **Commerce 2.x** | 最后更新 2024-08-22 | Drupal 9.3+, 10.x | 维护模式，不支持 D11 |
| **Commerce 3.x** | 2025-07-04 (3.1.0) | Drupal 10.3+, 11.x | ✅ 最新稳定版 |

**来源**:
1. https://www.drupal.org/project/commerce/releases
2. https://www.drupal.org/project/commerce/issues/3462426

---

## 🎯 Commerce 3.x 核心特性

### 主要改进

**Drupal 11 兼容性**:
- ✅ 完全支持 Drupal 11
- ✅ 移除了所有 @deprecated 标签标记的代码
- ✅ 更新 composer.json 依赖

**性能优化**:
- ✅ Checkout flow 管理优化
- ✅ OrderRefresh 性能提升

**配置改进**:
- ✅ 更灵活的结账流程配置
- ✅ 增强的订单管理功能

**来源**:
- https://www.drupal.org/project/commerce/releases/3.1.0

---

## 🛠️ 核心模块结构

### 必需模块

**Commerce 核心**:
- `commerce`: 电商核心功能
- `commerce_checkout`: 结账流程
- `commerce_order`: 订单管理
- `commerce_product`: 产品管理
- `commerce_price`: 价格管理

**官方文档**:
- https://docs.drupalcommerce.org/v2/

### 支付模块

**主流支付网关**:
| 支付网关 | 模块 | 状态 |
|----------|------|------|
| Stripe | commerce_stripe | ✅ 支持 |
| PayPal | commerce_paypal | ✅ 支持 |
| ADYEN | commerce_adyen | ✅ 支持 |
| Custom | 自定义适配器 | ✅ 可开发 |

**来源**:
- https://docs.drupalcommerce.org/v1/user-guide/payment/

---

## 🛒 产品与价格管理

### 产品类型

**Commerce 3.x 支持的类型**:
- 实体产品 (Simple)
- 虚拟产品 (Digital)
- 可变产品 (Variations)
- 服务产品 (Services)

**配置路径**:
```
/admin/commerce/config/product-types
```

### 价格字段

**价格类型**:
- 基础价格
- 批量价格
- 促销价格
- 用户组价格

**配置示例**:
```yaml
price_types:
  - base_price: 基础价格
  - tiered_price: 阶梯定价
  - promotional_price: 促销价格
```

**来源**:
- https://docs.drupalcommerce.org/v2/user-guide/pricing/

---

## 💰 结账流程

### 默认流程

**标准结账步骤**:
1. 购物车查看
2. 结账信息填写
3. 配送方式选择
4. 支付方式选择
5. 订单确认

**自定义流程配置**:
```
/admin/commerce/config/checkout-flows
```

**来源**:
- https://docs.drupalcommerce.org/v2/user-guide/checkout/
- https://drupalcommerce.org/site-builders-guide/cart-checkout

### 配置要点

**结账流程管理**:
- ✅ 拖拽式流程构建器
- ✅ 可自定义结账面板
- ✅ 支持多步骤结账

**重要配置**:
- 客户信息收集
- 配送配置
- 支付网关集成
- 税收设置

---

## 📦 订单管理

### 订单状态

**默认状态机**:
```
Cart → Pending → Processing → Paid → Completed → Shipped → Delivered
```

**订单字段**:
- 订单 ID
- 用户 ID
- 创建时间
- 状态
- 总价
- 商品列表

**配置路径**:
```
/admin/commerce/orders
```

**来源**:
- https://docs.drupalcommerce.org/v2/user-guide/orders/

---

## 🔄 库存管理

### 基础功能

**Commerce 3.x 库存管理**:
- 库存追踪
- 库存预警
- 缺货处理
- 多仓库支持（需扩展模块）

**配置示例**:
```yaml
inventory_tracking:
  - track_quantity: 追踪数量
  - backorder: 允许缺货
  - low_stock_notify: 库存警告
```

**来源**:
- https://docs.drupalcommerce.org/v2/user-guide/inventory/

---

## 📊 促销与优惠

### 折扣类型

**支持的折扣方式**:
- 优惠券代码
- 用户组折扣
- 产品数量折扣
- 满额免运费
- 捆绑销售

**配置路径**:
```
/admin/commerce/config/promo-codes
```

**来源**:
- https://docs.drupalcommerce.org/v2/user-guide/promotions/

---

## 🔗 第三方集成

### 主流 CRM

**集成的 CRM 系统**:
- Salesforce (需扩展)
- HubSpot (需扩展)
- Zoho CRM (需扩展)

### 支付网关

**支持的支付方式**:
- PayPal
- Stripe
- Braintree
- Custom API

**来源**:
- https://www.drupal.org/project/commerce/issues/3462426

---

## 📈 数据分析与报表

### 内置报表

**Commerce 3.x 报表功能**:
- 销售统计
- 订单报表
- 客户分析
- 产品销量排名

**配置路径**:
```
/admin/commerce/reports
```

### 扩展功能

**推荐模块**:
- `commerce_reports` - 高级报表
- `data_export` - 数据导出
- `views_bulk_operations` - 批量操作

---

## ⚠️ 重要注意事项

### Drupal 11 兼容性

**当前状态**:
- ✅ Commerce 3.x 已支持 D11
- ⚠️ 部分 contrib 模块正在适配中
- ⚠️ 建议升级前检查 `upgrade_status`

**升级建议**:
1. 先安装 Commerce 3.x
2. 运行 upgrade_status 检查
3. 更新所有 contrib 模块
4. 备份后再升级

**来源**:
- https://www.drupal.org/project/commerce/issues/3470953
- https://www.acquia.com/blog/upgrade-to-drupal-11

---

## 📚 参考资源

### 官方文档
- https://docs.drupalcommerce.org/
- https://www.drupal.org/project/commerce

### 社区资源
- https://www.drupal.org/forum
- https://www.drupal.org/project/commerce/issues

---

**文档版本**: v1.0  
**最后更新**: 2026-04-05  
**来源验证**: ✅ Drupal.org 官方 + 社区讨论交叉验证

---

**下一节**: 展位预定场景应用（待补充）
