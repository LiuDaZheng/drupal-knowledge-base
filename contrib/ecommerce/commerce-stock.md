---
name: commerce-stock
description: Complete guide to Commerce Stock for inventory management, stock levels tracking, and availability alerts.
---

# Commerce Stock - 库存管理 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Stock 是 Drupal Commerce 的核心扩展模块，提供实时库存跟踪、库存预警、缺货通知等完整的库存管理功能。该模块确保电商企业在销售过程中能够准确控制商品库存，避免超卖和缺货问题。

### 核心功能
- ✅ **实时库存跟踪** - 自动更新库存数量，支持多仓库
- ✅ **低库存预警** - 可配置的阈值触发系统通知
- ✅ **缺货自动通知** - 邮件或短信通知管理员补货
- ✅ **预订单支持** - 允许预售，自动扣减预留库存
- ✅ **多地点库存管理** - 支持多个仓库/门店独立库存
- ✅ **库存审计日志** - 所有库存变动的完整记录
- ✅ **安全库存设置** - 防止过度销售的缓冲库存
- ✅ **库存报告生成** - 周期性库存报表导出

### 适用场景
- 实体商品电商（服装、电子产品、家居等）
- 限量版商品销售（需要精确控制）
- 季节性商品（换季清仓库存管理）
- 需要库存预警的 B2B 业务
- 多仓库/多门店连锁经营
- 预售和预定系统

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装并配置
- PostgreSQL 12+ / MySQL 5.7+ (用于复杂查询)

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 添加依赖
composer require drupal/commerce_stock

# 启用模块
drush en commerce_stock --yes

# 执行数据库更新
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块到 sites/modules/contrib
drush dl commerce_stock

# 2. 启用模块
drush en commerce_stock --yes

# 3. 运行数据库更新
drush updatedb --yes

# 4. 验证安装
drush pm-info | grep stock
```

#### 方法 3: 使用 Drupal UI

1. 下载模块 ZIP 包
2. 解压到 `sites/all/modules/contrib/` 或对应目录
3. 访问 `/admin/modules`
4. 找到 "Commerce Stock" 模块
5. 勾选复选框
6. 点击 "Install" 按钮

---

## ⚙️ 基础配置

### 1. 启用模块

```bash
# 启用核心 Stock 模块
drush en commerce_stock --yes

# 启用相关子模块（如有）
drush en commerce_stock_alert --yes
```

### 2. 创建库存字段

通过内容类型管理界面添加库存字段：

```
路径：/admin/structure/content-type/manage/[product-type]/manage/fields
→ Add field
→ Field type: Integer
→ Widget: Number field
→ Machine name: field_stock_quantity
→ Label: Stock Quantity
→ Required: No (允许缺货商品)
```

或通过 Drush：

```bash
# 为产品内容类型添加库存字段
drush ciff:add-field product [product-type] field_stock_quantity integer \
  --label="Stock Quantity" \
  --widget=number_integer
```

### 3. 启用库存跟踪

```
路径：/admin/store/settings/inventory
```

| 选项 | 默认值 | 说明 |
|------|--------|------|
| Enable stock management | ✅ Enabled | 启用库存管理 |
| Track stock by SKU | ❌ Disabled | 按 SKU 跟踪（需模块支持） |
| Allow negative stock | ❌ No | 不允许负库存（禁止超卖） |
| Deduct on order placed | ✅ Yes | 下单即扣减库存 |
| Deduct on shipment | ❌ No | 发货时扣减（可选） |

### 4. 设置库存规则

| 规则项 | 值 | 说明 |
|--------|-----|------|
| Default Stock Level | 0 | 新商品的默认库存 |
| Low Stock Alert Threshold | 5 | 低于此数量触发警告 |
| Out of Stock Limit | 0 | 零库存判定 |
| Allow Backorders | No | 是否允许预售 |
| Restock Email Recipients | admin@example.com | 补货通知收件人 |
| Check Frequency | hourly | 库存检查频率 |

### 5. 配置库存警报

```
路径：/admin/config/store/inventory/alerts
```

#### 邮件通知设置
```yaml
notification_settings:
  - event: low_stock
    threshold: 5
    recipients: ['inventory@example.com', 'purchasing@example.com']
    template: default_stock_alert
  
  - event: out_of_stock
    threshold: 0
    recipients: ['inventory@example.com']
    template: critical_stock_alert
  
  - event: restock_complete
    threshold: null
    recipients: ['purchasing@example.com']
    template: stock_received
```

---

## 💻 代码示例

### 1. 库存查询 API

```php
use Drupal\commerce_stock\Entity\StockInterface;
use Drupal\commerce_product\Entity\ProductVariant;

/**
 * 获取商品可用库存
 */
function get_available_stock(ProductVariant $variant) {
  $stock = \Drupal::entityTypeManager()
    ->getStorage('stock_quantity')
    ->loadByProperties(['variant_id' => $variant->id()]);
  
  if ($stock) {
    $stock = reset($stock);
    return $stock->getAvailableQuantity(); // 返回可用数量（总库存 - 预留）
  }
  
  return 0;
}

/**
 * 检查库存充足性
 */
function is_stock_available(ProductVariant $variant, $quantity) {
  $available = get_available_stock($variant);
  return $available >= $quantity;
}
```

### 2. 修改库存量（在结账流程中）

```php
use Drupal\commerce_stock\Plugin\Commerce\Stock\StockAdjustment;

/**
 * 在订单提交后扣减库存
 */
public function deductStock(OrderInterface $order) {
  foreach ($order->getItems() as $orderItem) {
    $variant = $orderItem->getProductVariation();
    $quantity = $orderItem->getQuantity();
    
    // 查找对应的库存记录
    $stock = \Drupal::entityTypeManager()
      ->getStorage('stock_quantity')
      ->loadByProperties([
        'variant_id' => $variant->id(),
      ]);
    
    if (!empty($stock)) {
      $stock = reset($stock);
      
      // 扣减库存
      if ($stock->decreaseQuantity($quantity)) {
        // 记录调整
        \Drupal::service('commerce_stock.logger')
          ->info('Stock deducted: @variant @qty', [
            '@variant' => $variant->id(),
            '@qty' => $quantity,
          ]);
      }
    }
  }
}
```

### 3. 库存变更 hook

```php
/**
 * Hook implementation: stock_on_quantity_update
 * 当库存数量发生变更时触发
 */
function mymodule_stock_on_quantity_update(StockInterface $stock, $old_quantity, $new_quantity) {
  // 检查是否触发低库存预警
  if ($new_quantity <= 5 && $old_quantity > 5) {
    // 发送低库存邮件
    send_low_stock_notification($stock, $new_quantity);
  }
  
  // 检查是否从缺货恢复
  if ($new_quantity > 0 && $old_quantity == 0) {
    // 发送邮件通知
    send_restock_notification($stock, $new_quantity);
  }
  
  // 记录审计日志
  db_insert('stock_audit_log')
    ->fields([
      'stock_id' => $stock->id(),
      'old_quantity' => $old_quantity,
      'new_quantity' => $new_quantity,
      'changed' => REQUEST_TIME,
      'uid' => \Drupal::currentUser()->id(),
    ])
    ->execute();
}

/**
 * 发送低库存通知
 */
function send_low_stock_notification(StockInterface $stock, $quantity) {
  $product = $stock->getProduct();
  
  \Drupal::mail()
    ->send(
      'mymodule',
      'low_stock_notification',
      \Drupal user_by_id(0),
      [
        'product_name' => $product->getName(),
        'current_stock' => $quantity,
        'alert_threshold' => 5,
      ]
    );
}
```

### 4. 自定义库存规则

```php
namespace Drupal\mymodule\Plugin\Commerce\Stock;

use Drupal\commerce_stock\Plugin\Commerce\Stock\StockBase;
use Drupal\Core\Form\FormStateInterface;

/**
 * @StockPlugin(
 *   id = "custom_stock_rule",
 *   label = @Translation("Custom Stock Rule"),
 *   description = @Translation("Custom stock management rule")
 * )
 */
class CustomStockRule extends StockBase {
  
  public function buildConfigurationForm(array $form, FormStateInterface $form_state) {
    $form['max_reserved'] = [
      '#type' => 'number',
      '#title' => t('Maximum reserved quantity'),
      '#default_value' => $this->configuration['max_reserved'] ?? 0,
      '#description' => t('Maximum quantity that can be reserved without confirming order'),
    ];
    
    return $form;
  }
  
  public function saveConfigurationForm(array $form, FormStateInterface $form_state) {
    parent::saveConfigurationForm($form, $form_state);
    $this->configuration['max_reserved'] = $form['max_reserved']['#value'];
  }
  
  public function validateReservation(ProductVariantInterface $variant, $quantity) {
    $reserved = $this->getReservedQuantity($variant);
    $max_reserved = $this->configuration['max_reserved'] ?? 0;
    
    if ($reserved + $quantity > $max_reserved) {
      throw new \Exception(t('Cannot reserve more than @max items.', ['@max' => $max_reserved]));
    }
    
    return TRUE;
  }
}
```

---

## 📋 数据表结构

### stock_quantity
库存主表

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| id | INT | PRIMARY KEY | 自增 ID |
| variant_id | INT | FOREIGN KEY | 商品变体 ID |
| warehouse_id | INT | NULLABLE | 仓库 ID（多仓库模式） |
| total_quantity | INT | DEFAULT 0 | 总库存数量 |
| reserved_quantity | INT | DEFAULT 0 | 预留数量（待支付订单） |
| available_quantity | INT | GENERATED | 可用数量 (= total - reserved) |
| min_stock_level | INT | DEFAULT 0 | 最低库存水位线 |
| max_stock_level | INT | NULLABLE | 最高库存限制 |
| last_counted_at | DATETIME | NULLABLE | 最后盘点时间 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 更新时间 |

**索引**:
- `idx_variant` (variant_id, warehouse_id)
- `idx_available` (available_quantity) WHERE available_quantity > 0

### stock_adjustment_log
库存调整日志表

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| adjustment_id | BIGINT | PRIMARY KEY | 自增 ID |
| stock_id | INT | FOREIGN KEY | 关联 stock_quantity.id |
| variant_id | INT | NOT NULL | 商品变体 ID |
| previous_quantity | INT | NOT NULL | 调整前数量 |
| new_quantity | INT | NOT NULL | 调整后数量 |
| change_amount | INT | NOT NULL | 变化量（正数增加，负数减少） |
| reason | VARCHAR(50) | NOT NULL | 调整原因：sale/purchase_return/correction/damage |
| reference_entity_type | VARCHAR(50) | NULLABLE | 关联实体类型（如 commerce_order） |
| reference_entity_id | INT | NULLABLE | 关联实体 ID |
| uid | INT | NOT NULL | 操作者用户 ID |
| adjusted_at | DATETIME | NOT NULL | 调整时间 |
| notes | TEXT | NULLABLE | 备注说明 |

**常用原因码**:
- `sale` - 销售出库
- `purchase_receipt` - 采购入库
- `return` - 退货入库
- `adjustment` - 人工调整
- `damage` - 损毁报损
- `transfer_in` - 调拨入库
- `transfer_out` - 调拨出库

### stock_alert_log
库存警报日志表

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| alert_id | BIGINT | PRIMARY KEY | 自增 ID |
| stock_id | INT | NOT NULL | 关联 stock_quantity.id |
| alert_type | VARCHAR(20) | NOT NULL | 警报类型：low/out/reordered |
| threshold_value | INT | NOT NULL | 触发阈值 |
| current_value | INT | NOT NULL | 触发时实际值 |
| notification_sent | BOOLEAN | DEFAULT FALSE | 通知是否已发送 |
| notification_type | VARCHAR(20) | NULLABLE | 通知方式：email/sms/dashboard |
| sent_at | DATETIME | NULLABLE | 发送时间 |
| acknowledged_by | INT | NULLABLE | 确认人用户 ID |
| acknowledged_at | DATETIME | NULLABLE | 确认时间 |
| notes | TEXT | NULLABLE | 处理备注 |

**警报类型**:
- `low_stock` - 低库存预警
- `out_of_stock` - 完全缺货
- `restocked` - 已补货通知
- `overstock_warning` - 积压预警

### stock_audit_log
完整库存审计日志

| 字段名 | 数据类型 | 约束 | 说明 |
|--------|----------|------|------|
| audit_id | BIGINT | PRIMARY KEY | 自增 ID |
| stock_id | INT | NOT NULL | 关联 stock_quantity.id |
| action | VARCHAR(20) | NOT NULL | 操作类型：create/update/delete |
| old_values | JSON | NULLABLE | 修改前的值（JSON 对象） |
| new_values | JSON | NULLABLE | 修改后的值（JSON 对象） |
| ip_address | VARCHAR(45) | NULLABLE | 操作 IP 地址 |
| user_agent | VARCHAR(255) | NULLABLE | User-Agent |
| created_at | DATETIME | NOT NULL | 操作时间 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\commerce_stock\Kernel\StockTest;
use Drupal\commerce_stock\Entity\StockInterface;

class StockManagementTest extends KernelTestBase {
  
  protected static $modules = ['commerce_stock', 'commerce_product'];
  
  /**
   * Test: Stock deduction on order placement
   */
  public function testStockDeductionOnOrder() {
    // 1. 创建初始库存
    $stock = $this->createStock(100);
    
    // 2. 模拟订单创建（10 个商品）
    $order = $this->createOrderWithQuantity(10);
    
    // 3. 验证库存扣减
    $updated_stock = \Drupal::entityTypeManager()
      ->getStorage('stock_quantity')
      ->load($stock->id());
    
    $this->assertEquals(90, $updated_stock->getAvailableQuantity());
    $this->assertEquals(10, $updated_stock->getReservedQuantity());
  }
  
  /**
   * Test: Low stock alert trigger
   */
  public function testLowStockAlertTrigger() {
    // 1. 创建库存并设置阈值为 5
    $stock = $this->createStock(5, ['min_stock_level' => 5]);
    
    // 2. 扣减库存至 4
    $stock->decreaseQuantity(1);
    
    // 3. 验证警报被触发
    $alerts = \Drupal::entityTypeManager()
      ->getStorage('stock_alert')
      ->loadByProperties([
        'stock_id' => $stock->id(),
        'alert_type' => 'low_stock',
      ]);
    
    $this->assertNotEmpty($alerts, 'Low stock alert should be triggered');
  }
  
  /**
   * Test: Prevent overselling when stock is zero
   */
  public function testPreventOverselling() {
    // 1. 创建零库存商品
    $stock = $this->createStock(0);
    
    // 2. 尝试购买 1 个商品
    $order = $this->createOrderWithQuantity(1);
    
    // 3. 验证订单被阻止
    $this->assertFalse($order->canComplete(), 'Order should not complete with zero stock');
  }
  
  protected function createStock($quantity, array $settings = []) {
    $stock = \Drupal\commerce_stock\Entity\Stock::create([
      'variant_id' => $this->createProductVariant(),
      'total_quantity' => $quantity,
      'reserved_quantity' => 0,
    ] + $settings);
    $stock->save();
    return $stock;
  }
  
  protected function createOrderWithQuantity($quantity) {
    $order = $this->createTestOrder();
    // ... 添加订单项逻辑
    
    return $order;
  }
}
```

### 集成测试（Behat）

```gherkin
Feature: Stock Management
  As an administrator
  I want to manage product inventory
  So that I can prevent overselling and track stock levels

  Scenario: Customer orders more items than available stock
    Given I have a product with stock quantity of 5
    And a customer adds 10 items to cart
    When the customer attempts to checkout
    Then I should see an error message about insufficient stock
    And the order should not be placed

  Scenario: Low stock triggers email notification
    Given I have configured low stock alert threshold at 10
    And I have a product with stock quantity of 10
    When the stock is reduced to 9
    Then I should receive an email notification
    And a low stock alert record should exist in database

  Scenario: Restock completes removes alert
    Given there is a low stock alert for this product
    When the stock quantity is increased above threshold
    Then the alert status should change to "resolved"
    And a restock notification should be sent
```

---

## 📊 监控与日志

### 关键指标

| 指标名称 | 计算方式 | 报警阈值 |
|---------|---------|---------|
| **平均库存周转天数** | 库存总值 / 日均销售成本 | > 90 天警告 |
| **缺货率** | (缺货 SKU 数 / 总 SKU 数) × 100% | > 5% 警告 |
| **库存准确率** | 正确库存数 / 抽检总数 × 100% | < 98% 警告 |
| **低库存占比** | 低库存 SKU 数 / 总 SKU 数 × 100% | > 10% 警告 |
| **滞销品比例** | (>180 天无变动 / 总 SKU 数) × 100% | > 15% 警告 |

### 日志命令

```bash
# 实时查看库存相关日志
drush watch:tail stock

# 查看历史库存事件
drush watchdog-view stock --count=50

# 导出库存报告
drush export-stock-report > stock_report_$(date +%Y%m%d).csv

# 检查库存异常
drush sql-query "SELECT * FROM stock_alert_log WHERE notified_at > DATE_SUB(NOW(), INTERVAL 1 DAY)"

# 批量更新库存（导入 CSV）
drush php-script import_stock --root=/path/to/drupal
```

### 数据库查询示例

```sql
-- 查询低库存商品列表
SELECT 
  pv.name AS product_name,
  pq.sku,
  sq.available_quantity,
  sq.min_stock_level
FROM stock_quantity sq
JOIN product_variant pv ON sq.variant_id = pv.id
JOIN product q ON pv.product_id = q.id
WHERE sq.available_quantity <= sq.min_stock_level
ORDER BY sq.available_quantity ASC;

-- 查询最近 7 天的库存变动
SELECT 
  v.name AS product_name,
  al.adjusted_at,
  al.change_amount,
  CASE al.reason
    WHEN 'sale' THEN 'Sold'
    WHEN 'purchase_receipt' THEN 'Received'
    WHEN 'return' THEN 'Returned'
    WHEN 'adjustment' THEN 'Adjusted'
    ELSE al.reason
  END AS change_reason,
  u.name AS changed_by
FROM stock_adjustment_log al
JOIN product_variant v ON al.variant_id = v.id
JOIN users_field_data u ON al.uid = u.uid
WHERE al.adjusted_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY al.adjusted_at DESC;
```

---

## 🔗 参考链接

| 资源 | 链接 | 说明 |
|------|------|------|
| Drupal Commerce | https://www.drupal.org/project/commerce | 官方 Commerce 项目页面 |
| Commerce Stock Module | https://www.drupal.org/project/commerce_stock | Stock 模块官方文档 |
| Inventory Management Best Practices | https://www.inflowinventory.com/blog/inventory-management/ | 库存管理最佳实践 |
| FIFO vs LIFO Accounting | https://www.investopedia.com/terms/f/fifo.asp | 库存成本计算方法 |

---

## 🆘 常见问题

### Q1: 如何批量更新库存？

**答案**：可以通过以下几种方式：

**方法 A - UI 批量编辑**：
```
/admin/structure/product-type/manage/shop_product/manage/fields/field_stock_quantity
→ Bulk update all products
```

**方法 B - Drush 命令**：
```bash
drush php-eval "
\$query = db_select('stock_quantity', 'sq');
\$query->condition('warehouse_id', 1);
\$ids = \$query->fields('sq', ['id'])->execute();
foreach (\$ids as \$id) {
  \$stock = Stock::load(\$id);
  \$stock->setTotalQuantity(\$stock->getTotalQuantity() + 100);
  \$stock->save();
}"
```

**方法 C - CSV 导入**：
```sql
-- 准备 CSV 文件包含 sku,new_quantity
UPDATE product_variant pv
INNER JOIN stock_quantity sq ON pv.id = sq.variant_id
SET sq.total_quantity = CASE pv.sku
  WHEN 'PROD001' THEN 100
  WHEN 'PROD002' THEN 200
END
WHERE pv.sku IN ('PROD001', 'PROD002');
```

### Q2: 如何处理退货时的库存恢复？

**答案**：
```php
use Drupal\commerce_order\OrderInterface;
use Drupal\commerce_stock\Service\StockServiceInterface;

/**
 * 处理订单退款并恢复库存
 */
public function restoreStockOnRefund(OrderInterface $order) {
  $stock_service = \Drupal::service('commerce_stock.service');
  
  foreach ($order->getItems() as $item) {
    if ($item->getQuantity() > 0) {
      // 恢复已售出商品的库存
      $stock_service->increaseStock($item->getProductVariation(), $item->getQuantity(), 'refund');
      
      // 记录日志
      \Drupal::logger('commerce_stock')
        ->info('Stock restored for order :order_id', ['@order_id' => $order->id()]);
    }
  }
}
```

### Q3: 如何设置安全库存防止超卖？

**答案**：
```
/admin/store/settings/inventory
→ Enable safety stock buffer
→ Set buffer percentage: 10%
→ This reserves 10% of stock for emergencies
```

或在代码中：
```php
function getEffectiveStock(ProductVariant $variant) {
  $stock = get_total_stock($variant);
  $safety_buffer = $stock * 0.1; // 10% 安全库存
  return $stock - $safety_buffer;
}
```

### Q4: 如何实现多仓库库存同步？

**答案**：
```php
use Drupal\commerce_stock\Entity\StockInterface;

/**
 * 查询所有仓库的总库存
 */
function get_total_stock_across_warehouses(ProductVariant $variant) {
  $stocks = \Drupal::entityTypeManager()
    ->getStorage('stock_quantity')
    ->loadByProperties(['variant_id' => $variant->id()]);
  
  $total = 0;
  foreach ($stocks as $stock) {
    $total += $stock->getAvailableQuantity();
  }
  
  return $total;
}

/**
 * 库存预警：任何仓库低于阈值
 */
function check_multi_warehouse_stock(ProductVariant $variant, $threshold) {
  $stocks = load_all_warehouse_stocks($variant);
  $critical_warehouses = [];
  
  foreach ($stocks as $warehouse_id => $stock) {
    if ($stock->getAvailableQuantity() <= $threshold) {
      $critical_warehouses[] = [
        'warehouse_id' => $warehouse_id,
        'available' => $stock->getAvailableQuantity(),
      ];
    }
  }
  
  if (!empty($critical_warehouses)) {
    send_critical_alert($variant, $critical_warehouses);
  }
}
```

---

## 📈 最佳实践

### 1. 定期库存盘点

```yaml
# 自动化盘点计划
inventory_counting:
  high_value_items: daily      # 高价值商品每日盘点
  medium_value_items: weekly   # 中等价值商品每周盘点
  low_value_items: monthly     # 低价值商品每月盘点
  seasonal_promotion: before   # 促销活动前强制盘点
```

### 2. 库存预警分级

```yaml
alert_priority:
  critical:
    threshold: 0
    actions: ['email_admin', 'sms_admin', 'dashboard_flag']
  
  high:
    threshold: 5
    actions: ['email_inventory_team', 'dashboard_flag']
  
  normal:
    threshold: 20
    actions: ['dashboard_only']
```

### 3. 库存优化策略

| 策略 | 适用场景 | 效果 |
|------|---------|------|
| JIT (Just-in-Time) | 需求稳定商品 | 降低库存成本 |
| ABC 分类法 | 全品类管理 | 重点管理高价值商品 |
| EOQ (经济订货量) | 周期性补货 | 优化订货批量 |
| VMI (供应商管理库存) | 供应链整合 | 转移库存压力 |

---

**大正，commerce-stock.md 已补充完成，包含完整的内容。您有其他指令吗？** 🚀
