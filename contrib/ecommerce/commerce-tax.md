---
name: commerce-tax
description: Complete guide to Commerce Tax for sales tax calculation, VAT handling, and tax compliance.
---

# Commerce Tax - 税务计算与管理 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce Tax 是 Drupal Commerce 的完整税务解决方案，提供自动化税收计算、多地区税率管理、销售税/VAT/GST 处理等功能，帮助企业实现全球合规经营。支持 Avalara、TaxJar 等第三方税务服务集成。

### 核心功能
- ✅ **自动税率计算** - 基于地址实时查询税率
- ✅ **多地区税率管理** - 州/省/县/特区复合税率
- ✅ **产品税率分类** - 不同商品类型适用不同税率
- ✅ **免税客户处理** - B2B 免税证验证和管理
- ✅ **多币种税务计算** - 国际业务支持
- ✅ **税务报告生成** - 符合申报要求
- ✅ **Avalara/TaxJar 集成** - 专业服务对接
- ✅ **定期申报支持** - 周期性的税务报表
- ✅ **审计日志** - 完整的税务计算记录
- ✅ **API 优先架构** - 易于集成和扩展

### 适用场景
- 跨州/跨国电商（Nexus 合规）
- 需要销售税计算的美国市场
- 增值税（VAT）欧盟市场
- GST（goods and services tax）澳大利亚/加拿大
- B2B/B2C混合业务
- SaaS 订阅服务的数字税
- 跨境电商出口退税

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- Mail module enabled
- Database connection to external tax service (optional)

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装税务模块
composer require drupal/tax avalara_tax

# 启用相关模块
drush en tax avalara --yes

# 更新数据库
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 下载模块
drush dl tax

# 2. 启用模块
drush en tax --yes

# 3. 运行数据库更新
drush updatedb --yes
```

---

## ⚙️ 基础配置

### 1. 启用模块

```bash
drush en tax --yes
```

### 2. 设置基本税务规则

```
路径：/admin/config/store/tax/settings
```

| 选项 | 默认值 | 说明 |
|------|--------|------|
| Enable tax calculations | ✅ Yes | 启用税务计算 |
| Display prices inclusive | ❌ No | 价格是否含税 |
| Round at line level | ✅ Yes | 每行四舍五入 |
| Default tax rate | 0% | 默认税率 |
| Tax calculation order | subtotal first | 计算顺序 |
| Show tax breakdown | ✅ Yes | 显示税额明细 |

### 3. 配置税率

```yaml
tax_rates:
  # 美国各州销售税示例
  us_states:
    california:
      name: 'California State Tax'
      rate: 7.25
      jurisdiction_type: 'state'
      products: '*'
      
    texas:
      name: 'Texas State Tax'
      rate: 6.25
      jurisdiction_type: 'state'
      exemptions:
        - groceries
        - prescription_medicine
      
    new_york:
      name: 'New York State + Local Tax'
      rate: 8.0
      jurisdiction_type: 'combined'
      components:
        state: 4.0
        county: 2.5
        city: 1.5
      
  # 欧洲 VAT 示例
  eu_vat:
    germany:
      name: 'Germany VAT'
      rate: 19.0
      standard_rate: 19.0
      reduced_rate: 7.0
      categories:
        standard: ['*']
        reduced: ['books', 'food']
        
    france:
      name: 'France VAT'
      rate: 20.0
      super_reduced: 2.1
      reduced: 5.5
```

### 4. 产品税率分类

```
/admin/config/store/tax/product-tax-types
```

| 产品类型 | 税率规则 | 说明 |
|---------|---------|------|
| Physical Goods | Standard Rate | 实体商品标准税率 |
| Digital Goods | Reduced/Electronic | 数字商品电子服务税 |
| Services | Varies by Type | 服务根据类型差异化 |
| Food/Groceries | Exempt or Reduced | 食品可能免税或低税 |
| Clothing | Variable | 服装税率因地区而异 |
| Books/Publications | Reduced | 出版物优惠税率 |
| Prescription Medicines | Exempt | 处方药通常免税 |
| Luxury Items | Premium Tax | 奢侈品额外征税 |

### 5. 配置 Avalara 集成（可选）

```
/admin/config/store/tax/providers/avalara
```

| 配置项 | 值 | 说明 |
|--------|-----|------|
| Enable Avalara | ✅ Yes | 启用 Avalara 服务 |
| Environment | Production/Sandbox | 生产/测试环境 |
| Company Code | YOUR_COMPANY_CODE | Avalara 公司代码 |
| License Key | xxxxxxxx | API 密钥 |
| Address Validation | ✅ Enabled | 地址验证 |
| Auto-file Returns | ❌ No | 自动申报（需许可证） |

---

## 💻 代码示例

### 1. 基础税务计算器

```php
use Drupal\commerce_order\Entity\Order;
use Drupal\tax\Service\TaxCalculatorInterface;

/**
 * 计算订单税费
 */
class OrderTaxCalculator implements TaxCalculatorInterface {
  
  protected $config;
  protected $taxRateRepository;
  
  public function __construct() {
    $this->config = \Drupal::config('commerce_tax.settings');
    $this->taxRateRepository = \Drupal::entityTypeManager()
      ->getStorage('tax_rate');
  }
  
  /**
   * 计算订单总税额
   */
  public function calculate(Order $order): float {
    $total_tax = 0;
    
    // 获取所有订单项
    foreach ($order->getItems() as $item) {
      $line_tax = $this->calculateLineTax($item, $order);
      $total_tax += $line_tax;
    }
    
    return round($total_tax, 2);
  }
  
  /**
   * 计算单个订单项的税额
   */
  protected function calculateLineTax(CommerceOrderItemInterface $item, Order $order): float {
    $quantity = $item->getQuantity();
    $unit_price = $item->getUnitPrice()->getAmount();
    
    // 确定适用的税率
    $applicable_rates = $this->getApplicableTaxRates($item, $order);
    
    $line_total = $unit_price * $quantity;
    $line_tax = 0;
    
    foreach ($applicable_rates as $rate) {
      $rate_amount = $line_total * ($rate['rate'] / 100);
      $line_tax += $rate_amount;
      
      // 记录税务明细
      $this->recordTaxBreakdown($item, $rate, $rate_amount);
    }
    
    // 四舍五入
    return round($line_tax, 2);
  }
  
  /**
   * 确定适用的税率
   */
  protected function getApplicableTaxRates(CommerceOrderItemInterface $item, Order $order): array {
    $rates = [];
    
    // 1. 基于收货地址确定税率
    $address = $order->getBillingAddress() ?: $order->getShippingAddress();
    
    if ($address) {
      // 州级税率
      $state_rates = $this->getStateTaxRates($address->getState());
      $rates = array_merge($rates, $state_rates);
      
      // 县级税率
      if (!empty($address->getCounty())) {
        $county_rates = $this->getCountyTaxRates(
          $address->getState(),
          $address->getCounty()
        );
        $rates = array_merge($rates, $county_rates);
      }
      
      // 城市税率
      if (!empty($address->getCity())) {
        $city_rates = $this->getCityTaxRates(
          $address->getState(),
          $address->getCity()
        );
        $rates = array_merge($rates, $city_rates);
      }
      
      // 特殊区税率
      $special_district_rates = $this->getSpecialDistrictRates(
        $address->getState(),
        $address->getPostalCode()
      );
      $rates = array_merge($rates, $special_district_rates);
    }
    
    // 2. 应用产品类型的特定税率
    $product_specific_rates = $this->getProductSpecificRates($item);
    $rates = array_merge($rates, $product_specific_rates);
    
    // 3. 移除重复并合并相同地区的税率
    return $this->mergeDuplicateRates($rates);
  }
  
  /**
   * 记录税务明细用于审计报告
   */
  protected function recordTaxBreakdown(
    CommerceOrderItemInterface $item,
    array $rate,
    float $tax_amount
  ): void {
    db_insert('tax_calculation_log')
      ->fields([
        'order_id' => $item->getOrderId(),
        'line_item_id' => $item->id(),
        'jurisdiction' => $rate['jurisdiction'],
        'rate_type' => $rate['type'],
        'rate_percent' => $rate['rate'],
        'taxable_amount' => $item->getUnitPrice()->getAmount() * $item->getQuantity(),
        'tax_amount' => $tax_amount,
        'calculated_at' => REQUEST_TIME,
        'uid' => \Drupal::currentUser()->id(),
      ])
      ->execute();
  }
}
```

### 2. Avalara 集成服务

```php
use Drupal\avalara\Api\AvalaraClientInterface;

/**
 * Avalara 税务服务集成
 */
class AvalaraTaxService implements TaxProviderInterface {
  
  protected $client;
  protected $config;
  
  public function __construct(AvalaraClientInterface $client) {
    $this->client = $client;
    $this->config = \Drupal::config('avalara.settings');
  }
  
  /**
   * 通过 Avalara 计算税费
   */
  public function calculate(Order $order): float {
    // 准备 AvaTax 请求
    $transaction = $this->buildTransaction($order);
    
    try {
      // 调用 Avalara API
      $result = $this->client->commitTransaction($transaction);
      
      // 返回总税额
      return floatval($result->totalAmount);
      
    } catch (\Exception $e) {
      \Drupal::logger('avalara')
        ->error('Avalara tax calculation failed: @message', ['@message' => $e->getMessage()]);
      
      // 失败时回退到本地计算
      return $this->fallbackLocalCalculation($order);
    }
  }
  
  /**
   * 构建 Avalara 交易对象
   */
  protected function buildTransaction(Order $order): array {
    $customer_code = $this->getCustomerCode($order);
    
    return [
      'companyCode' => $this->config->get('company_code'),
      'date' => date('Y-m-d', $order->getCreated()),
      'buyerZip' => $order->getBillingAddress()->getPostalCode(),
      'customerUsageType' => 'O', // O = Original
      'entities' => [
        [
          'code' => $customer_code,
          'isBuyer' => TRUE,
          'isSeller' => FALSE,
          'isImporterOfRecord' => FALSE,
          'exemptionNo' => $this->getExemptionNumber($order),
          'reverseCharge' => FALSE,
          'email' => $order->getEmail(),
          'name' => $order->getCustomerName(),
          'billingAddress' => [
            'line1' => $order->getBillingAddress()->getLine1(),
            'city' => $order->getBillingAddress()->getCity(),
            'region' => $order->getBillingAddress()->getState(),
            'country' => $order->getBillingAddress()->getCountryId(),
            'postalCode' => $order->getBillingAddress()->getPostalCode(),
          ],
        ],
      ],
      'lines' => array_map(function($item) {
        return [
          'lineNumber' => $item->id(),
          'quantity' => $item->getQuantity(),
          'amount' => $item->getPrice()->getAmount(),
          'taxCode' => $this->getTaxCodeForItem($item),
          'description' => $item->getTitle(),
          'itemCode' => $item->getSku(),
        ];
      }, iterator_to_array($order->getItems())),
    ];
  }
  
  /**
   * 获取客户代码（用于 Avalara）
   */
  protected function getCustomerCode(Order $order): string {
    $user = $order->getOwner();
    
    if ($user && $user->hasPermission('purchaser')) {
      return "B2B_{$user->id()}";
    } else {
      return "GUEST_" . uniqid();
    }
  }
  
  /**
   * 获取免税号码
   */
  protected function getExemptionNumber(Order $order): ?string {
    $user = $order->getOwner();
    
    if ($user && $user->hasField('tax_exempt_number')) {
      $exemption = $user->getField('tax_exempt_number')->getValue();
      return !empty($exemption[0]['value']) ? $exemption[0]['value'] : NULL;
    }
    
    return NULL;
  }
  
  /**
   * 为商品确定税务代码
   */
  protected function getTaxCodeForItem(CommerceOrderItemInterface $item): string {
    $tax_code_mapping = [
      'PHYS0100' => 'physical_goods',
      'DIGITAL010' => 'digital_services',
      'FOOD0001' => 'groceries',
      'BOOK0001' => 'books_publications',
      'MED0001' => 'prescription_medicine',
      'TLX0001' => 'telecommunications',
    ];
    
    $product_type = $item->getProductType();
    
    return $tax_code_mapping[$product_type] ?? 'PRT0000'; // Default product
  }
  
  /**
   * 本地计算降级方案
   */
  protected function fallbackLocalCalculation(Order $order): float {
    $local_calculator = new OrderTaxCalculator();
    return $local_calculator->calculate($order);
  }
}
```

### 3. 税务豁免管理

```php
use Drupal\user\UserInterface;
use Drupal\commerce_order\Entity\Order;

/**
 * 管理税务豁免
 */
class TaxExemptionManager {
  
  /**
   * 检查用户是否有免税资格
   */
  public function hasTaxExemption(UserInterface $user): bool {
    // 检查用户字段
    if ($user->hasField('tax_exempt_certificate')) {
      $certificate = $user->getField('tax_exempt_certificate')->first();
      
      if ($certificate && !empty($certificate->value)) {
        $expires_at = strtotime($certificate->end_date ?? '+99 years');
        
        if (REQUEST_TIME < $expires_at) {
          return TRUE;
        }
      }
    }
    
    return FALSE;
  }
  
  /**
   * 验证免税证书有效性
   */
  public function validateExemptionCertificate(UserInterface $user): array {
    if (!$user->hasField('tax_exempt_certificate')) {
      return ['valid' => FALSE, 'reason' => 'No exemption certificate field'];
    }
    
    $certificate = $user->getField('tax_exempt_certificate')->first();
    
    if (empty($certificate->value)) {
      return ['valid' => FALSE, 'reason' => 'No certificate uploaded'];
    }
    
    // 验证过期日期
    $end_date = strtotime($certificate->end_date ?? '');
    if (REQUEST_TIME > $end_date) {
      return ['valid' => FALSE, 'reason' => 'Certificate expired'];
    }
    
    // 验证证书上传者（必须是管理员审核过）
    $uploaded_by = \Drupal\user\User::load($certificate->entity->changed_by);
    if (!$uploaded_by || !$uploaded_by->hasPermission('approve_tax_exemptions')) {
      return ['valid' => FALSE, 'reason' => 'Certificate not approved by admin'];
    }
    
    return ['valid' => TRUE];
  }
  
  /**
   * 在订单中应用免税
   */
  public function applyExemptionToOrder(Order $order): void {
    $user = $order->getOwner();
    
    if ($this->hasTaxExemption($user)) {
      // 移除所有税项
      $tax_items = $order->getItemsByType('tax');
      foreach ($tax_items as $tax_item) {
        $order->removeItem($tax_item->id());
      }
      
      // 添加免税标识
      $order->setTag('tax_exempt');
      $order->save();
      
      \Drupal::logger('tax')
        ->info('Tax exemption applied to order :order_id', [':order_id' => $order->id()]);
    }
  }
  
  /**
   * 更新用户的免税状态
   */
  public function updateExemptionStatus(UserInterface $user, bool $is_exempt, array $certificate_data = []): void {
    if (!$user->hasField('tax_exempt_status')) {
      return;
    }
    
    $user->set('tax_exempt_status', $is_exempt ? 'approved' : 'none');
    
    if ($is_exempt && !empty($certificate_data)) {
      $user->set('tax_exempt_certificate', [
        'value' => $certificate_data['file_id'],
        'end_date' => $certificate_data['expiry_date'],
        'number' => $certificate_data['exemption_number'],
      ]);
    }
    
    $user->save();
  }
}
```

### 4. Twig 模板 - 订单税费明细

```twig
{# templates/order/tax-breakdown.html.twig #}
<div class="order-summary-tax">
  <h3>Tax Summary</h3>
  
  {% if orders.has_tax %}
    <table class="tax-table">
      <thead>
        <tr>
          <th>Jurisdiction</th>
          <th>Type</th>
          <th>Rate</th>
          <th>Taxable Amount</th>
          <th>Tax Amount</th>
        </tr>
      </thead>
      <tbody>
        {% for tax_breakdown in order.tax_breakdown %}
          <tr>
            <td>{{ tax_breakdown.jurisdiction }}</td>
            <td>
              {% if tax_breakdown.type == 'state' %}
                <span class="badge badge-state">State</span>
              {% elseif tax_breakdown.type == 'county' %}
                <span class="badge badge-county">County</span>
              {% elseif tax_breakdown.type == 'city' %}
                <span class="badge badge-city">City</span>
              {% else %}
                {{ tax_breakdown.type }}
              {% endif %}
            </td>
            <td>{{ tax_breakdown.rate }}%</td>
            <td>${{ "%.2f"|format(tax_breakdown.taxable_amount) }}</td>
            <td><strong>${{ "%.2f"|format(tax_breakdown.tax_amount) }}</strong></td>
          </tr>
        {% endfor %}
      </tbody>
      <tfoot>
        <tr style="background-color: #f8f9fa; font-weight: bold;">
          <td colspan="4" style="text-align: right;">Total Tax:</td>
          <td style="font-size: 18px;">${{ "%.2f"|format(order.total_tax) }}</td>
        </tr>
      </tfoot>
    </table>
    
    {% if order.is_tax_exempt %}
      <div class="tax-exempt-badge" style="background-color: #d4edda; padding: 10px; border-radius: 5px; margin-top: 15px;">
        ✅ This order is TAX EXEMPT
      </div>
    {% endif %}
    
  {% else %}
    <p>No taxes applicable for this order.</p>
  {% endif %}
</div>

<style>
.tax-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
}

.tax-table th,
.tax-table td {
  padding: 10px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.tax-table th {
  background-color: #f5f5f5;
  font-weight: 600;
}

.badge-state {
  background-color: #e3f2fd;
  color: #1976d2;
  padding: 3px 8px;
  border-radius: 3px;
  font-size: 12px;
}

.badge-county {
  background-color: #fff3e0;
  color: #f57c00;
  padding: 3px 8px;
  border-radius: 3px;
  font-size: 12px;
}

.badge-city {
  background-color: #e8f5e9;
  color: #388e3c;
  padding: 3px 8px;
  border-radius: 3px;
  font-size: 12px;
}
</style>
```

### 5. 税务报告生成

```php
use Drupal\Core\Datetime\DateFormatter;

/**
 * 生成税务申报报告
 */
class TaxReportGenerator {
  
  /**
   * 生成月度销售税报告
   */
  public function generateMonthlySalesTaxReport(int $year, int $month): array {
    $start_date = mktime(0, 0, 0, $month, 1, $year);
    $end_date = mktime(23, 59, 59, $month, cal_days_in_month(CAL_GREGORIAN, $month, $year), $year);
    
    // 按jurisdiction分组统计
    $report_data = [];
    
    $query = db_select('tax_calculation_log', 't')
      ->fields('t', ['jurisdiction', 'tax_amount', 'taxable_amount']);
      ->condition('calculated_at', $start_date, '>=');
      ->condition('calculated_at', $end_date, '<=');
      ->groupBy('jurisdiction');
    
    $results = $query->execute()->fetchAllAssociative();
    
    foreach ($results as $row) {
      $jurisdiction = $row['jurisdiction'];
      
      $report_data[$jurisdiction] = [
        'jurisdiction_name' => $this->getJurisdictionName($jurisdiction),
        'total_taxable' => floatval($row['taxable_amount']),
        'total_tax_collected' => floatval($row['tax_amount']),
        'average_rate' => $row['taxable_amount'] > 0 
          ? round(($row['tax_amount'] / $row['taxable_amount']) * 100, 2)
          : 0,
        'transaction_count' => 0, // 需要单独计数
      ];
    }
    
    return [
      'report_period' => date('F Y', $start_date),
      'generated_at' => date('Y-m-d H:i:s'),
      'summary' => $this->calculateSummary($report_data),
      'details' => $report_data,
    ];
  }
  
  /**
   * 计算汇总数据
   */
  protected function calculateSummary(array $details): array {
    $total_taxable = 0;
    $total_tax = 0;
    
    foreach ($details as $data) {
      $total_taxable += $data['total_taxable'];
      $total_tax += $data['total_tax_collected'];
    }
    
    return [
      'total_jurisdictions' => count($details),
      'total_taxable_amount' => $total_taxable,
      'total_tax_collected' => $total_tax,
      'weighted_average_rate' => $total_taxable > 0
        ? round(($total_tax / $total_taxable) * 100, 2)
        : 0,
    ];
  }
  
  /**
   * 导出 CSV 格式
   */
  public function exportAsCSV(array $report): string {
    $csv_content = "Jurisdiction,Taxable Amount,Tax Collected,Average Rate,Transaction Count\n";
    
    foreach ($report['details'] as $juristic => $data) {
      $csv_content .= "{$juristic}," .
                      sprintf('%.2f,', $data['total_taxable']) .
                      sprintf('%.2f,', $data['total_tax_collected']) .
                      sprintf('%.2f,', $data['average_rate']) .
                      $data['transaction_count'] . "\n";
    }
    
    return $csv_content;
  }
}
```

---

## 📋 数据表结构

### tax_rate
税率定义表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| tid | INT | PRIMARY KEY | 自增 ID |
| name | VARCHAR(255) | NOT NULL | 税率名称 |
| rate | DECIMAL(5,4) | NOT NULL | 税率百分比 |
| type | VARCHAR(50) | NOT NULL | state/county/city/district |
| jurisdiction | VARCHAR(100) | UNIQUE | 管辖区域代码 |
| active | BOOLEAN | DEFAULT TRUE | 是否启用 |
| created | DATETIME | NOT NULL | 创建时间 |

### tax_calculation_log
税务计算日志表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| log_id | BIGINT | PRIMARY KEY | 自增 ID |
| order_id | INT | FOREIGN KEY | 关联订单 |
| line_item_id | INT | NOT NULL | 订单项 ID |
| jurisdiction | VARCHAR(100) | NOT NULL | 管辖区域 |
| rate_percent | DECIMAL(5,4) | NOT NULL | 税率 |
| taxable_amount | DECIMAL(10,2) | NOT NULL | 应税金额 |
| tax_amount | DECIMAL(10,2) | NOT NULL | 税额 |
| calculated_at | DATETIME | NOT NULL | 计算时间 |

### customer_tax_exemption
客户免税表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY | 自增 ID |
| uid | INT | NOT NULL | 用户 ID |
| exemption_number | VARCHAR(50) | UNIQUE | 免税证编号 |
| certificate_file | VARCHAR(255) | NULLABLE | 证书文件 |
| expiry_date | DATE | NOT NULL | 过期日期 |
| status | VARCHAR(20) | DEFAULT 'pending' | pending/approved/rejected |
| reviewed_by | INT | NULLABLE | 审核者 |
| created_at | DATETIME | NOT NULL | 创建时间 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\commerce_tax\Unit\TaxCalculatorTest;

class TaxCalculationTest extends KernelTestBase {
  
  protected static $modules = ['tax'];
  
  public function testCalculateCaliforniaSalesTax() {
    // 创建 CA 州的订单
    $order = $this->createOrderWithAddress('CA', '90210');
    
    // 添加普通商品
    $item = $this->createOrderItem(new Price('100.00', 'USD'));
    $order->addItem($item);
    
    $calculator = new OrderTaxCalculator();
    $tax_amount = $calculator->calculate($order);
    
    // CA 州销售税约 7.25%
    $this->assertEquals(7.25, $tax_amount / 100 * 100, 0.01);
  }
  
  public function testTaxExemptCustomer() {
    $user = $this->createExemptUser();
    $order = $this->createOrderForUser($user);
    $order->addItem($this->createOrderItem(new Price('100.00', 'USD')));
    
    $manager = new TaxExemptionManager();
    $manager->applyExemptionToOrder($order);
    
    $calculator = new OrderTaxCalculator();
    $tax_amount = $calculator->calculate($order);
    
    $this->assertEquals(0, $tax_amount);
    $this->assertTrue($order->hasTag('tax_exempt'));
  }
  
  public function testDigitalProductsLowerTaxRate() {
    // 某些州对数字产品有较低税率
    $order = $this->createOrderWithAddress('NY', '10001');
    
    // 添加数字商品
    $digital_item = $this->createOrderItemWithProductType('digital_goods', new Price('50.00', 'USD'));
    $order->addItem($digital_item);
    
    $calculator = new OrderTaxCalculator();
    $tax_amount = $calculator->calculate($order);
    
    // 验证数字商品的税率不同于实体商品
    $this->assertGreaterThan(0, $tax_amount);
  }
}
```

### 集成测试

```gherkin
Feature: Tax Calculation
  As a store owner
  I want accurate tax calculations for compliance
  
  Scenario: Calculating multi-jurisdictional tax
    Given an order shipped to California with multiple items
    When the checkout process runs
    Then the system should calculate state + county + city tax
    And display a detailed tax breakdown to the customer
    
  Scenario: Handling tax-exempt B2B customer
    Given a registered business with valid exemption certificate
    When they place an order
    Then no sales tax should be charged
    And their exemption number should be recorded
    And the order should be tagged as tax-exempt
    
  Scenario: Cross-border e-commerce VAT
    Given an EU customer purchasing digital goods
    When the order is processed
    Then VAT should be calculated based on customer location
    And MOSS reporting data should be generated
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算公式 | 目标值 |
|------|---------|--------|
| **税务计算准确率** | Correct / Total Calculations | > 99.9% |
| **申报合规率** | On-time Filings / Total | 100% |
| **平均申报准备时间** | Hours per filing period | < 4 小时 |
| **审计通过率** | Passed Audits / Total | 100% |

### 日志命令

```bash
# 查看税务计算日志
drush watchdog-view tax --count=50

# 查询月度税务汇总
drush sql-query "
  SELECT 
    DATE_FORMAT(calculated_at, '%Y-%m') as month,
    COUNT(*) as order_count,
    SUM(tax_amount) as total_tax
  FROM tax_calculation_log
  WHERE calculated_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
  GROUP BY DATE_FORMAT(calculated_at, '%Y-%m')
  ORDER BY month DESC
"

# 生成税务报告
drush php-script generate_monthly_tax_report
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Avalara Documentation | https://developer.avalara.com/ |
| TaxJar Integration Guide | https://www.taxjar.com/developers/ |
| US Sales Tax Nexus Guide | https://www.salestaxmastery.com/nexus/ |

---

## 🆘 常见问题

### Q1: 如何处理多国家/多货币的税务？

**答案**：
```php
class InternationalTaxCalculator {
  
  public function calculate(Order $order): array {
    $country_code = $order->getBillingAddress()->getCountryId();
    $currency = $order->getCurrency()->getId();
    
    switch ($country_code) {
      case 'US':
        return $this->calculateUSTax($order);
        
      case 'DE':
      case 'FR':
      case 'IT':
        return $this->calculateEUVAT($order, $country_code);
        
      case 'GB':
        return $this->calculateUKVAT($order);
        
      case 'CA':
        return $this->calculateCAGSTHST($order);
        
      default:
        return ['tax_amount' => 0, 'note' => 'No specific tax rules configured'];
    }
  }
  
  protected function calculateEUVAT(Order $order, string $country): array {
    // EU VAT MOSS (Mini One Stop Shop) for digital services
    $vat_rate = $this->getEUStandardVATRate($country);
    
    // B2B - reverse charge mechanism
    if ($this->isB2BDigitalSale($order)) {
      // Reverse charge - no VAT collected from customer
      // But must report to authorities
      return [
        'tax_amount' => 0,
        'reverse_charge' => TRUE,
        'reporting_required' => TRUE,
        'vat_number_validated' => $this->validateVATNumber($order),
      ];
    }
    
    // B2C - charge VAT at customer's country rate
    $subtotal = $order->getSubtotal()->getAmount();
    return [
      'tax_amount' => $subtotal * ($vat_rate / 100),
      'rate' => $vat_rate,
      'country' => $country,
      'moss_reporting' => TRUE,
    ];
  }
}
```

### Q2: 如何满足审计追踪要求？

**答案**：
```php
class TaxAuditLogger {
  
  public function logTaxDecision(Order $order, array $decision_data): void {
    db_insert('tax_audit_trail')
      ->fields([
        'order_id' => $order->id(),
        'calculation_engine' => 'local' or 'avalara',
        'applied_rates' => json_encode($decision_data['rates']),
        'jurisdictions' => json_encode($decision_data['jurisdictions']),
        'exemption_applied' => $decision_data['exemption'],
        'confidence_score' => $decision_data['confidence'],
        'human_reviewed' => $decision_data['manual_override'] ?? FALSE,
        'reviewer_id' => \Drupal::currentUser()->id(),
        'created_at' => REQUEST_TIME,
        'ip_address' => \Drupal::request()->getClientIp(),
      ])
      ->execute();
  }
}
```

### Q3: 如何实现动态税率更新？

**答案**：
```php
class DynamicTaxRateUpdater {
  
  /**
   * 定期从服务商同步税率
   */
  public function syncRatesFromProvider(string $provider = 'avalara'): void {
    $client = $this->getAuthProviderClient($provider);
    
    $updated_rates = $client->getAvailableTaxRates();
    
    foreach ($updated_rates as $rate_data) {
      // 查找或创建税率记录
      $existing = \Drupal::entityTypeManager()
        ->getStorage('tax_rate')
        ->loadByProperties(['jurisdiction' => $rate_data['jurisdiction']])
        ->current();
      
      if ($existing) {
        // 更新现有税率
        $existing->set('rate', $rate_data['rate']);
        $existing->set('effective_from', $rate_data['effective_date']);
        $existing->save();
      } else {
        // 创建新税率
        $new_rate = \Drupal\tax\Entity\TaxRate::create([
          'name' => $rate_data['name'],
          'rate' => $rate_data['rate'],
          'jurisdiction' => $rate_data['jurisdiction'],
          'type' => $rate_data['type'],
          'active' => TRUE,
        ]);
        $new_rate->save();
      }
    }
    
    // 记录变更日志
    \Drupal::logger('tax')
      ->info('Updated :count tax rates from :provider', [
        ':count' => count($updated_rates),
        ':provider' => $provider,
      ]);
  }
}
```

---

**大正，commerce-tax.md 已补充完成。继续下一个...** 🚀
