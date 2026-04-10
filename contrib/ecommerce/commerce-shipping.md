---
name: commerce-shipping
description: Complete guide to Commerce Shipping module for Drupal Commerce. Covers shipping methods, rates calculation, tracking, and carrier integration.
---

# Commerce Shipping - 物流配送管理 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Shipping 提供灵活的配送方法管理和运费计算功能。支持多种承运商集成、基于重量/价格的费率计算、配送区域限制等核心电商配送需求。

### 核心功能
- ✅ 多种配送方法（固定运费、按重量、按价格）
- ✅ 配送区域和条件限制
- ✅ 运费实时计算
- ✅ USPS/FedEx/DHL 集成
- ✅ 订单发货通知
- ✅ 追踪号码跟踪
- ✅ 配送时间表管理

### 适用场景
- 实体商品电商
- 多仓库管理
- 区域配送限制
- B2B/B2C 混合业务

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装

### 安装步骤

#### 方法 1: 使用 Composer (推荐)
```bash
cd /path/to/drupal/root
composer require drupal/shipping
drush en shipping
```

#### 方法 2: 手动下载
```bash
# 1. 下载模块
drush dl shipping

# 2. 启用模块
drush en shipping --yes

# 3. 访问配置页面
# @link https://YOUR-SITE.com/admin/config/delivery/shipping
```

---

## ⚙️ 基础配置

### 1. 启用模块
```bash
drush en shipping --yes
```

### 2. 添加配送字段到商品类型
```
/content-types/manage/shop_product
→ Manage fields → Add field → Shipping weight/volume
```

### 3. 配置配送方法

#### 路径：`/admin/config/delivery/shipping/methods`

#### 标准配送方法

| 方法 | 说明 | 计费方式 |
|------|------|---------|
| **Flat Rate** | 固定运费 | 每订单固定金额 |
| **Weight Based** | 按重量计费 | $/kg 或 $/lb |
| **Price Based** | 按价格计费 | 订单总额百分比 |
| **Table Rates** | 表格式费率 | 多重条件组合 |

---

## 📦 配送方法配置详解

### 1. Flat Rate（固定运费）

#### 配置步骤
```
/admin/config/delivery/shipping/methods/add/flat
→ Method name: Standard Shipping
→ Fixed price: $5.99
→ Minimum order amount: $0.00
→ Maximum order amount: ∞
```

### 2. Weight-Based（按重量）

#### 费率表配置
```yaml
weight_ranges:
  - weight_max: 0.5
    rate: 3.99
    currency: USD
  - weight_max: 2.0
    rate: 7.99
    currency: USD
  - weight_max: 10.0
    rate: 15.99
    currency: USD
```

#### 代码示例
```php
use Drupal\shipping\Plugin\ShippingMethod\WeightBased;

$weight = $order->getTotalWeight();
if ($weight <= 0.5) {
  return 3.99;
} elseif ($weight <= 2.0) {
  return 7.99;
} else {
  return 15.99;
}
```

### 3. Table Rates（表格式费率）

#### 复杂条件配置
| 条件 1 | 条件 2 | 运费 |
|--------|--------|------|
| Region = NY | Weight < 5lbs | $4.99 |
| Region = CA | Weight < 5lbs | $5.99 |
| Region = Any | Weight > 5lbs | $12.99 |
| Region = International | Any weight | $29.99 |

---

## 🌍 配送区域管理

### 1. 定义区域

#### 美国各州示例
```
States = ['NY', 'CA', 'TX', 'FL', 'IL']
Region Name: Continental US
```

#### 国际区域示例
```
Countries = ['US', 'CA', 'MX', 'GB', 'DE', 'FR']
Region Name: North America & Europe
```

### 2. 区域限制

#### 按邮编范围
```bash
/admin/config/delivery/shipping/regions
→ Add ZIP code pattern: ^10.*|^90.*
→ Match area: New York City
```

#### 按距离半径
```php
// 基于 GPS 距离的配送限制
$distance = get_distance($origin, $destination);
if ($distance > 50) { // 超过 50 英里
  throw new ShippingException('超出配送范围');
}
```

---

## 🏭 承运商集成

### 1. USPS Integration

#### API 配置
```
Admin → Shipping → USPS Integration
→ API Username: your_usps_user
→ API Password: your_usps_pass
→ Web service URL: https://production.shippingapis.com
```

#### 获取实时运费
```php
use Drupal\shipping\Api\UspsApi;

$api = new UspsApi();
$rate = $api->getRate(
  origin_zip: '10001',
  destination_zip: '90210',
  weight_lbs: 2.5
);
```

### 2. FedEx Integration

#### 配置参数
```yaml
fedex:
  key: YOUR_FEDEx_KEY
  password: YOUR_PASSWORD
  meter: YOUR_METER_NUMBER
  environment: production
```

### 3. DHL Integration

```bash
# DHL Express API
curl -X POST https://exp.dhl.com/api/rates \
  -H "Authorization: Basic xxx" \
  -d '{"origin":"DE","destination":"US"}'
```

---

## 📋 数据表结构

### shipping_method
| 字段 | 类型 | 说明 |
|------|------|------|
| sid | INT | 配送方法 ID |
| plugin_id | VARCHAR(64) | 插件 ID |
| label | VARCHAR(255) | 显示名称 |
| weight_min | DECIMAL(10,3) | 最小重量 |
| weight_max | DECIMAL(10,3) | 最大重量 |
| enabled | BOOLEAN | 是否启用 |

### shipping_rate_table
| 字段 | 类型 | 说明 |
|------|------|------|
| rid | INT | 费率 ID |
| method_id | INT | 方法 ID |
| min_weight | DECIMAL(10,3) | 最小重量 |
| max_weight | DECIMAL(10,3) | 最大重量 |
| min_price | DECIMAL(10,2) | 最低订单额 |
| max_price | DECIMAL(10,2) | 最高订单额 |
| cost | DECIMAL(10,2) | 运费成本 |

### shipping_zone
| 字段 | 类型 | 说明 |
|------|------|------|
| zone_id | INT | 区域 ID |
| name | VARCHAR(255) | 区域名称 |
| country_code | VARCHAR(2) | 国家代码 |
| state_code | VARCHAR(20) | 州代码 |

---

## 🛠️ 自定义扩展

### 1. 创建自定义配送方法
```php
namespace Drupal\mymodule\Plugin\ShippingMethod;

use Drupal\shipping\Plugin\ShippingMethodBase;

/**
 * @ShippingMethod(
 *   id = "custom_shipping",
 *   label = @Translation("Custom Shipping"),
 *   description = @Translation("Custom shipping method")
 * )
 */
class CustomShipping extends ShippingMethodBase {
  
  public function calculateRate(OrderInterface $order) {
    // 自定义费率计算逻辑
    $total_weight = $order->getTotalWeight();
    return max(5.00, $total_weight * 2.00);
  }
}
```

### 2. 添加运费标签筛选
```php
function mymodule_shipping_rate_alter(&$rates, OrderInterface $order) {
  foreach ($rates as $rate) {
    if ($order->hasTag('fragile')) {
      $rate->cost += 2.00; // 易碎品加价
    }
  }
}
```

---

## 🧪 测试建议

### 测试用例

| 场景 | 输入 | 期望输出 |
|------|------|---------|
| 小包裹 | Weight=0.3kg | $3.99 |
| 中等包裹 | Weight=2.5kg | $7.99 |
| 大包裹 | Weight=15kg | $25.99 |
| 超区配送 | ZIP=海外 | 不可用 |

### 自动化测试
```php
public function testWeightBasedShipping() {
  $method = $this->container->get('plugin.manager.shipping')
    ->createInstance('weight_based');
  
  $order = $this->createTestOrder(['weight' => 2.5]);
  $rate = $method->calculateRate($order);
  
  $this->assertEquals(7.99, $rate->getCost());
}
```

---

## 📊 监控与日志

### 关键指标
- Average shipping cost per order
- Shipping method distribution
- Failed rate calculations
- Carrier API error rate

### 日志命令
```bash
# 查看配送相关日志
drush watchdog-view shipping

# 实时监控
drush watch:tail shipping
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Drupal Shipping Module | https://www.drupal.org/project/shipping |
| USPS Developer | https://www.usps.com/business/tools-apis.htm |
| FedEx API Docs | https://www.fedex.com/en-us/support/developercenter/cgien.html |
| DHL API | https://www.dhl.com/global-en/home/support/contact_us.html |

---

**大正，commerce-shipping.md 已创建完成。您有其他指令吗？** 🚀
