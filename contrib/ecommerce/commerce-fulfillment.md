---
name: commerce-fulfillment
description: Complete guide to Commerce Fulfillment for order fulfillment management, warehouse operations, and inventory sync.
---

# Commerce Fulfillment - 订单履行管理 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Fulfillment 提供完整的订单履行工作流管理功能。支持多仓库库存同步、订单分配策略、履行状态跟踪等核心电商运营需求。

### 核心功能
- ✅ 多仓库库存管理
- ✅ 智能订单分配
- ✅ 履行状态工作流
- ✅ 批量订单处理
- ✅ 库存同步集成
- ✅ 回拨/延迟发货支持

### 适用场景
- 多仓库电商企业
- B2B 批量订单
- 需要复杂履行规则的商店
- 第三方仓储集成

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- Inventory module（推荐）

### 安装步骤

#### 方法 1: 使用 Composer (推荐)
```bash
cd /path/to/drupal/root
composer require drupal/fulfillment
drush en fulfillment
```

#### 方法 2: 手动下载
```bash
drush dl fulfillment
drush en fulfillment --yes
```

---

## ⚙️ 基础配置

### 1. 启用模块
```bash
drush en fulfillment --yes
```

### 2. 配置履行流程

#### 路径：`/admin/config/store/fulfillment/workflow`

**标准履行状态**
| 状态 | 说明 | 触发时机 |
|------|------|---------|
| Pending | 待处理 | 订单创建后 |
| In Progress | 处理中 | 开始拣货 |
| Picked | 已拣货 | 拣货完成 |
| Packaged | 已打包 | 包装完成 |
| Shipped | 已发货 | 发货通知发送 |
| Delivered | 已交付 | 客户签收 |
| Cancelled | 已取消 | 订单取消 |

### 3. 设置默认履行规则

```yaml
default_fulfillment:
  method: 'single_warehouse'
  auto_allocate: TRUE
  notify_on_ship: TRUE
```

---

## 🏭 多仓库管理

### 1. 定义仓库

#### 仓库配置
```
/admin/config/store/fulfillment/warehouses
→ Add Warehouse
  Name: Main Warehouse
  Address: 123 Main St, NY 10001
  Default: ✅ Yes
```

#### 仓库优先级
| 仓库 | 优先级 | 说明 |
|------|--------|------|
| East Coast DC | 1 | 东部仓库 |
| West Coast DC | 2 | 西部仓库 |
| Central Hub | 3 | 中央枢纽 |

### 2. 库存同步

#### 实时更新配置
```php
use Drupal\fulfillment\Plugin\QueueProcessor\InventorySync;

$processor = new InventorySync();
$processor->syncAllWarehouses();
```

#### Webhook 同步
```yaml
webhooks:
  inventory_update:
    url: 'https://your-site.com/webhook/inventory'
    events: ['inventory.updated', 'inventory.low']
```

---

## 📦 订单分配策略

### 1. 自动分配逻辑

```php
/**
 * Smart order allocation strategy.
 */
class SmartAllocation implements AllocationStrategyInterface {
  
  public function allocate(OrderInterface $order) {
    $items = $order->getItems();
    
    // 按库存充足度选择仓库
    $available_warehouses = $this->getAvailableWarehouses($items);
    
    // 返回最优仓库
    return min($available_warehouses, function($w) use ($order) {
      return $this->calculateCost($w, $order);
    });
  }
}
```

### 2. 自定义分配规则

#### 基于邮编
```php
function mymodule_fulfillment_allocation(OrderInterface $order) {
  $zip = $order->billingAddress->postcode;
  
  if (preg_match('/^9.*|^10.*/', $zip)) {
    return 'west_coast_warehouse';
  } else {
    return 'east_coast_warehouse';
  }
}
```

---

## 🔗 数据表结构

### fulfillment_order
| 字段 | 类型 | 说明 |
|------|------|------|
| fid | INT | 履行记录 ID |
| order_id | INT | 关联订单 ID |
| warehouse_id | INT | 履行仓库 ID |
| status | VARCHAR(50) | 履行状态 |
| allocated_at | DATETIME | 分配时间 |
| completed_at | DATETIME | 完成时间 |

### fulfillment_item
| 字段 | 类型 | 说明 |
|------|------|------|
| fiid | INT | 履行项 ID |
| fulfillment_id | INT | 履行记录 ID |
| order_item_id | INT | 订单项 ID |
| quantity | INT | 数量 |
| picked_quantity | INT | 已拣货数量 |

### warehouse
| 字段 | 类型 | 说明 |
|------|------|------|
| wid | INT | 仓库 ID |
| name | VARCHAR(255) | 仓库名称 |
| address | TEXT | 地址 |
| is_default | BOOLEAN | 是否默认 |
| priority | INT | 优先级 |

---

## 💻 代码示例

### 创建履行记录
```php
use Drupal\fulfillment\Entity\FulfillmentOrder;

$order = \Drupal\commerce_order\Entity\Order::load($order_id);

// 创建履行单
$fulfillment = FulfillmentOrder::create([
  'order' => $order->id(),
  'status' => 'pending',
]);

$fulfillment->save();
```

### 检查库存可用性
```php
use Drupal\fulfillment\Plugin\QueueProcessor\StockChecker;

$checker = new StockChecker();
$is_available = $checker->checkAvailability(
  $product_id,
  $quantity,
  $warehouse_id
);
```

---

## 🧪 测试建议

### 测试用例

| 场景 | 输入 | 期望输出 |
|------|------|---------|
| 单一仓库 | Order from NY → NY warehouse | Correct allocation |
| 多仓库 | Split shipment | Multiple fulfillments |
| 缺货 | Item out of stock | Backorder option |
| 超区 | International order | Decline with message |

### 自动化测试
```php
public function testMultiWarehouseFulfillment() {
  $order = $this->createSplitShipmentOrder();
  $fulfillments = $this->container->get('plugin.manager.fulfillment')
    ->createInstance('multi_warehouse')
    ->allocate($order);
  
  $this->assertCount(2, $fulfillments);
  $this->assertEquals('NY', $fulfillments[0]->getWarehouse());
}
```

---

## 📊 监控与日志

### 关键指标
- Average fulfillment time
- Fulfillment success rate
- Backorder percentage
- Warehouse utilization

### 日志命令
```bash
# 查看履行相关日志
drush watchdog-view fulfillment

# 导出统计数据
drush watch-export fulfillment > fulfillments.log
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Drupal Fulfillment Module | https://www.drupal.org/project/fulfillment |
| Warehouse Management Systems | https://en.wikipedia.org/wiki/Warehouse_management_system |

---

**大正，commerce-fulfillment.md 已创建完成。您有其他指令吗？** 🚀
