---
name: commerce-license
description: Complete guide to Commerce License for license key management, subscription products, and software activation in Drupal Commerce.
---

# Commerce License - 许可证与订阅管理 (Drupal 11)

**版本**: 4.x  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 模块概述

### 简介
Commerce License 是 Drupal Commerce 用于管理软件许可证、订阅服务和数字产品授权的扩展模块。支持自动生成许可证密钥、激活码管理、订阅计划配置、用户授权限制等功能，适用于 SaaS 平台和软件销售业务。

### 核心功能
- ✅ **许可证密钥生成** - 批量生成唯一许可证密钥
- ✅ **激活码管理** - 激活次数限制和设备绑定
- ✅ **订阅计划配置** - 周期性收费套餐管理
- ✅ **许可证验证 API** - 在线/离线验证机制
- ✅ **到期提醒通知** - 邮件自动发送续费提醒
- ✅ **试用版管理** - 免费试用时间控制
- ✅ **升级降级支持** - 订阅级别变更
- ✅ **多用户授权** - 同一许可证多设备使用限制
- ✅ **批量导入导出** - CSV 格式的许可证导入/导出
- ✅ **退款和续订** - 复杂的订阅生命周期管理

### 适用场景
- SaaS 软件服务订阅
- 数字产品销售许可证
- 企业级软件授权
- 会员制内容平台
- 在线课程和培训服务
- API 访问权限管理
- 游戏内购和 DLC 内容

---

## 🚀 安装指南

### 前提条件
- Drupal 11.0+
- PHP 8.1+
- Composer 2.0+
- Drupal Commerce 已安装
- Mail API 配置完成
- Queue API enabled（异步任务处理）

### 安装步骤

#### 方法 1: 使用 Composer (推荐)

```bash
cd /path/to/drupal/root

# 安装 Commerce License 模块
composer require drupal/commerce_license

# 启用相关模块
drush en commerce_license license_activation --yes

# 更新数据库
drush updb --yes
```

#### 方法 2: 手动下载

```bash
# 1. 从 Drupal.org 下载模块
drush dl commerce_license

# 2. 启用模块
drush en commerce_license --yes

# 3. 运行数据库更新
drush updatedb --yes
```

#### 方法 3: 通过 Drupal UI

1. 访问 [https://www.drupal.org/project/commerce_license](https://www.drupal.org/project/commerce_license)
2. 下载模块 ZIP 文件
3. 上传至 `sites/all/modules/custom/`
4. 前往 `/admin/modules`
5. 勾选 "Commerce License" 模块
6. 点击 Install

---

## ⚙️ 基础配置

### 1. 启用模块

```bash
drush en commerce_license --yes
```

### 2. 创建许可证产品类型

```
路径：/admin/structure/product-type/add
→ 选择 License 作为产品类型
→ 添加必要的字段：
   - license_key (Text field, 可选显示)
   - activation_count (Integer, 激活次数限制)
   - max_devices (Integer, 最大设备数)
   - expiration_date (Date field, 可选)
```

### 3. 配置许可证密钥生成规则

```yaml
license_generation:
  format:
    pattern: 'LIC-{YEAR}-{SEED}-{RANDOM}'
    length: 20
    characters: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    separator: '-'
    case: uppercase
    
  validation:
    checksum_algorithm: 'CRC32'
    prefix: 'LIC-'
    suffix_length: 4
    
  batch_size: 100         # 批量生成数量
  unique_check: true      # 确保唯一性
  
  examples:
    - 'LIC-2026-A3F9-KL82'
    - 'LIC-2026-B7M1-NP94'
```

### 4. 设置订阅计划

```
/admin/config/store/license/plans
```

| 计划名称 | 周期 | 价格 | 试用期 | 说明 |
|---------|------|------|--------|------|
| Starter | Monthly | $9.99 | 14 days | 基础订阅 |
| Professional | Monthly | $29.99 | 30 days | 专业版 |
| Enterprise | Annual | $299.00 | None | 企业版年付 |
| Team | Monthly | $99.00 | 30 days | 团队版 (最多 5 用户) |

### 5. 激活规则配置

```yaml
activation_rules:
  max_activations_per_key: 3          # 每个密钥最多激活 3 次
  max_devices_per_user: 5             # 每个用户最多绑定 5 个设备
  grace_period_hours: 24              # 过期后宽限期（小时）
  auto_renewal_enabled: true          # 自动续费
  cancellation_policy: 'refund_30d'   # 取消政策：30 天内可退款
```

### 6. 邮件通知模板

```
/admin/config/store/license/email-templates
```

| 通知类型 | 触发时机 | 收件人 |
|---------|---------|--------|
| License Generated | 许可证创建 | Admin + Customer |
| Activation Success | 成功激活 | Customer |
| Activation Failed | 激活失败 | Customer |
| Expiration Warning | 即将过期 (7 天) | Customer |
| Renewal Reminder | 续费提醒 (3 天前) | Customer |
| Trial Expiring | 试用即将结束 (2 天) | Customer |
| Payment Failed | 支付失败 | Customer |

---

## 💻 代码示例

### 1. 生成许可证密钥

```php
use Drupal\commerce_license\Entity\LicenseKey;
use Drupal\commerce_license\Service\LicenseGeneratorInterface;

/**
 * 批量生成许可证密钥
 */
class LicenseBatchGenerator {
  
  protected $generator_service;
  
  public function __construct(LicenseGeneratorInterface $generator_service) {
    $this->generator_service = $generator_service;
  }
  
  /**
   * 为产品创建一批许可证
   */
  public function generateForProduct(ProductVariation $variation, int $quantity): array {
    $licenses = [];
    
    for ($i = 0; $i < $quantity; $i++) {
      // 生成唯一许可证密钥
      $key = $this->generateUniqueKey();
      
      // 创建许可证记录
      $license = LicenseKey::create([
        'product_variation' => $variation->id(),
        'key' => $key,
        'status' => 'pending',           // pending/active/expired/cancelled
        'activation_limit' => 3,
        'devices_used' => 0,
        'issued_to' => NULL,            // 未分配给用户时为空
        'valid_from' => REQUEST_TIME,
        'expires_at' => REQUEST_TIME + (365 * DAY), // 有效期 1 年
        'batch_id' => $this->getBatchId(),
      ]);
      
      $license->save();
      $licenses[] = $license;
    }
    
    \Drupal::logger('commerce_license')
      ->info('Generated :count license keys for product :product', [
        ':count' => count($licenses),
        ':product' => $variation->getName(),
      ]);
    
    return $licenses;
  }
  
  /**
   * 生成唯一许可证密钥
   */
  protected function generateUniqueKey(): string {
    $config = \Drupal::config('commerce_license.settings')->get('generation.format');
    
    $pattern = str_replace(
      ['{YEAR}', '{SEED}', '{RANDOM}'],
      [
        date('Y'),
        mt_rand(1000, 9999),
        strtoupper(substr(md5(uniqid(rand(), TRUE)), 0, 8)),
      ],
      $config['pattern']
    );
    
    // 添加校验位
    $checksum = $this->calculateChecksum($pattern);
    $full_key = $pattern . '-' . substr($checksum, 0, 4);
    
    // 确保唯一性
    if ($this->keyExists($full_key)) {
      return $this->generateUniqueKey(); // 递归重试
    }
    
    return $full_key;
  }
  
  /**
   * 计算校验和
   */
  protected function calculateChecksum(string $key): string {
    return dechex(crc32($key));
  }
  
  /**
   * 检查密钥是否已存在
   */
  protected function keyExists(string $key): bool {
    $result = \Drupal::entityTypeManager()
      ->getStorage('license_key')
      ->loadByProperties(['key' => $key])
      ->current();
    
    return !empty($result);
  }
  
  /**
   * 获取当前批次 ID
   */
  protected function getBatchId(): string {
    $timestamp = date('YmdHis');
    $random = strtoupper(substr(md5(time()), 0, 6));
    return "BATCH_{$timestamp}_{$random}";
  }
}
```

### 2. 许可证激活流程

```php
use Drupal\commerce_license\Entity\LicenseActivation;
use Drupal\user\UserInterface;

/**
 * 处理许可证激活请求
 */
class LicenseActivationService {
  
  /**
   * 激活许可证
   */
  public function activateLicense(string $key, UserInterface $user, array $device_info): ?LicenseActivation {
    // 查找许可证
    $license = \Drupal::entityTypeManager()
      ->getStorage('license_key')
      ->loadByProperties(['key' => $key])
      ->current();
    
    if (!$license) {
      throw new \Exception('Invalid license key');
    }
    
    // 验证许可证状态
    if (!$this->isValidForActivation($license)) {
      throw new \Exception('License is not valid for activation');
    }
    
    // 检查激活次数限制
    if ($license->getActivationsUsed() >= $license->getActivationLimit()) {
      throw new \Exception('Maximum activation limit reached');
    }
    
    // 检查设备数量限制
    if ($license->getDevicesUsed() >= $license->getMaxDevices()) {
      throw new \Exception('Maximum device limit reached');
    }
    
    // 检查是否过期
    if ($license->isExpired()) {
      throw new \Exception('License has expired');
    }
    
    // 检查用户是否已有此许可证
    $existing_activation = LicenseActivation::loadByProperties([
      'license_key' => $license->id(),
      'uid' => $user->id(),
    ])->current();
    
    if ($existing_activation) {
      throw new \Exception('You have already activated this license');
    }
    
    // 创建激活记录
    $activation = LicenseActivation::create([
      'license_key' => $license->id(),
      'uid' => $user->id(),
      'activated_at' => REQUEST_TIME,
      'ip_address' => \Drupal::request()->getClientIp(),
      'user_agent' => \Drupal::request()->headers->get('User-Agent'),
      'device_name' => $device_info['name'] ?? 'Unknown Device',
      'device_os' => $device_info['os'] ?? 'Unknown OS',
      'status' => 'active',
    ]);
    
    $activation->save();
    
    // 更新许可证统计
    $license->addActivation();
    $license->save();
    
    // 发送确认邮件
    $this->sendActivationConfirmationEmail($license, $user);
    
    \Drupal::logger('commerce_license')
      ->info('License activated by user :uid for key :key', [
        ':uid' => $user->id(),
        ':key' => $key,
      ]);
    
    return $activation;
  }
  
  /**
   * 验证许可证是否有效且未过期
   */
  protected function isValidForActivation(LicenseKey $license): bool {
    if ($license->getStatus() !== 'pending' && $license->getStatus() !== 'active') {
      return FALSE;
    }
    
    if ($license->hasExpired()) {
      return FALSE;
    }
    
    // 检查是否有未支付的订单关联
    if ($license->getOrderId() && !$license->isPaid()) {
      return FALSE;
    }
    
    return TRUE;
  }
  
  /**
   * 发送激活确认邮件
   */
  protected function sendActivationConfirmationEmail(LicenseKey $license, UserInterface $user): void {
    $mail_manager = \Drupal::service('plugin.manager.mail');
    
    $mail_manager->send(
      'commerce_license',
      'activation_success',
      $user,
      'en',
      NULL,
      NULL,
      [
        'license_key' => $license->getKey(),
        'product_name' => $license->getProductName(),
        'activation_date' => date('Y-m-d H:i:s'),
        'max_activations' => $license->getActivationLimit(),
        'license_url' => Url::fromRoute('commerce_customer.licenses')->toString(),
      ]
    );
  }
}
```

### 3. 许可证验证 API

```php
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;

/**
 * 许可证验证 RESTful API 端点
 */
class LicenseVerificationController extends ControllerBase {
  
  /**
   * 验证许可证有效性（公共 API）
   */
  public function verifyLicense(Request $request): JsonResponse {
    $input = json_decode($request->getContent(), TRUE);
    
    if (!isset($input['license_key']) || !isset($input['product_id'])) {
      throw new BadRequestHttpException('Missing required fields: license_key, product_id');
    }
    
    $license_key = $input['license_key'];
    $product_id = $input['product_id'];
    $source_ip = $request->getClientIp();
    
    // 查找许可证
    $license = \Drupal::entityTypeManager()
      ->getStorage('license_key')
      ->loadByProperties(['key' => $license_key])
      ->current();
    
    if (!$license) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'invalid_key',
        'message' => 'The provided license key is not valid.',
      ]);
    }
    
    // 检查是否属于指定产品
    if ($license->getProductId() != $product_id) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'product_mismatch',
        'message' => 'This license does not apply to the requested product.',
      ]);
    }
    
    // 验证许可证状态
    if ($license->getStatus() !== 'active') {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'inactive',
        'message' => 'The license is not active.',
      ]);
    }
    
    // 检查是否过期
    if ($license->isExpired()) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'expired',
        'message' => 'The license has expired.',
        'expiration_date' => date('Y-m-d', $license->getExpiresAt()),
        'grace_period_end' => date('Y-m-d', $license->getGracePeriodEnd()),
      ]);
    }
    
    // 检查激活限制
    if ($license->getActivationsUsed() >= $license->getActivationLimit()) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'limit_reached',
        'message' => 'Maximum activation limit reached.',
        'activations_used' => $license->getActivationsUsed(),
        'activation_limit' => $license->getActivationLimit(),
      ]);
    }
    
    // 所有检查通过
    return JsonResponse([
      'valid' => TRUE,
      'license_key' => $license->getKey(),
      'product_id' => $license->getProductId(),
      'product_name' => $license->getProductName(),
      'owner_email' => $license->getOwnerEmail(),
      'issued_date' => date('Y-m-d', $license->getIssuedAt()),
      'expiration_date' => date('Y-m-d', $license->getExpiresAt()),
      'activation_limit' => $license->getActivationLimit(),
      'activations_remaining' => $license->getActivationLimit() - $license->getActivationsUsed(),
      'features' => $license->getFeatures(),
    ]);
  }
  
  /**
   * 反激活许可证
   */
  public function deactivateLicense(Request $request): JsonResponse {
    // 需要管理员权限
    if (!\Drupal::currentUser()->hasPermission('administer license activations')) {
      throw new AccessDeniedException('Not authorized');
    }
    
    $input = json_decode($request->getContent(), TRUE);
    
    if (!isset($input['activation_id'])) {
      throw new BadRequestHttpException('Missing activation_id');
    }
    
    $activation = LicenseActivation::load($input['activation_id']);
    
    if (!$activation) {
      throw new BadRequestHttpException('Activation not found');
    }
    
    $activation->setStatus('deactivated');
    $activation->save();
    
    // 可选：减少许可证使用计数
    $license = $activation->getLicenseKey();
    $license->decrementActivation();
    $license->save();
    
    return JsonResponse([
      'success' => TRUE,
      'message' => 'License deactivated successfully',
      'activation_id' => $activation->id(),
    ]);
  }
}
```

### 4. 订阅管理和计费

```php
use Drupal\commerce_subscription\Plugin\SubscriptionSchedule\ScheduledInterval;

/**
 * 订阅生命周期管理器
 */
class SubscriptionLifecycleManager {
  
  /**
   * 创建新的订阅
   */
  public function createSubscription(Order $order): void {
    $items = $order->getItemsByType('subscription');
    
    foreach ($items as $item) {
      $plan = $item->getSubscriptionPlan();
      $interval = $plan->getInterval();
      
      // 创建订阅实例
      $subscription = Subscription::create([
        'uid' => $order->getOwnerId(),
        'product_variant' => $item->getProductVariation()->id(),
        'plan_id' => $plan->id(),
        'status' => 'active',
        'start_date' => $order->getCreated(),
        'end_date' => $this->calculateEndDate($plan),
        'next_billing_date' => REQUEST_TIME + $interval->getSeconds(),
        'billing_cycle' => $interval->getValue(),
        'amount' => $item->getPrice()->getAmount(),
        'currency' => $item->getPrice()->getCurrency()->getId(),
      ]);
      
      $subscription->save();
      
      // 生成初始许可证
      $this->generateInitialLicense($subscription);
    }
  }
  
  /**
   * 计算订阅结束日期
   */
  protected function calculateEndDate(SubscriptionPlanInterface $plan): int {
    $start_date = $plan->getStartDate();
    $duration = $plan->getDuration();
    $unit = $plan->getDurationUnit();
    
    return strtotime("+{$duration} {$unit}", $start_date);
  }
  
  /**
   * 生成订阅初始许可证
   */
  protected function generateInitialLicense(SubscriptionInterface $subscription): void {
    $license_key = $this->generateLicenseKey(
      $subscription->getProductVariant()->id(),
      $subscription->getUid()
    );
    
    $license = LicenseKey::create([
      'product_variation' => $subscription->getProductVariant()->id(),
      'key' => $license_key,
      'status' => 'active',
      'activation_limit' => 1,
      'expires_at' => $subscription->getEndDate(),
      'linked_subscription' => $subscription->id(),
    ]);
    
    $license->save();
    
    // 关联到用户账户
    db_insert('user_licenses')
      ->fields([
        'uid' => $subscription->getUid(),
        'license_id' => $license->id(),
        'type' => 'subscription',
        'created_at' => REQUEST_TIME,
      ])
      ->execute();
  }
  
  /**
   * 处理订阅续费
   */
  public function processRenewal(int $subscription_id): void {
    $subscription = Subscription::load($subscription_id);
    
    if (!$subscription || $subscription->getStatus() !== 'active') {
      return;
    }
    
    // 延长订阅
    $old_end = $subscription->getEndDate();
    $new_end = strtotime('+1 month', $old_end);
    
    $subscription->setEndDate($new_end);
    $subscription->setNextBillingDate($new_end);
    $subscription->save();
    
    // 延长许可证
    $license = \Drupal::entityTypeManager()
      ->getStorage('license_key')
      ->loadByProperties(['linked_subscription' => $subscription_id])
      ->current();
    
    if ($license) {
      $license->setExpiresAt($new_end);
      $license->save();
    }
    
    // 发送续费确认邮件
    $this->sendRenewalNotification($subscription);
  }
  
  /**
   * 发送续费通知
   */
  protected function sendRenewalNotification(SubscriptionInterface $subscription): void {
    $mail_manager = \Drupal::service('plugin.manager.mail');
    
    $mail_manager->send(
      'commerce_subscription',
      'renewal_complete',
      \Drupal\user\User::load($subscription->getUid()),
      'en',
      NULL,
      NULL,
      [
        'product_name' => $subscription->getProductVariant()->getName(),
        'new_expiration' => date('Y-m-d', $subscription->getEndDate()),
        'plan_name' => $subscription->getPlan()->getLabel(),
      ]
    );
  }
}
```

### 5. Twig 模板 - 用户许可证页面

```twig
{# templates/license/user-licenses.html.twig #}
<div class="license-management">
  <div class="header-section">
    <h1>Your Licenses</h1>
    <a href="/licenses/generate" class="btn btn-primary">Generate New License</a>
  </div>
  
  {% if licenses|length == 0 %}
    <div class="no-licenses">
      <p>You don't have any active licenses yet.</p>
      <a href="/shop/software" class="btn btn-secondary">Browse Software Products</a>
    </div>
  {% else %}
    <div class="licenses-list">
      {% for license in licenses %}
        <div class="license-card {{ license.status }}" data-license-id="{{ license.id }}">
          
          <div class="license-header">
            <h3>{{ license.product_name }}</h3>
            <span class="status-badge {{ license.status }}">{{ license.status|capitalize }}</span>
          </div>
          
          <div class="license-key">
            <label>License Key:</label>
            <div class="key-display">
              <code>{{ license.key }}</code>
              <button class="btn-copy" onclick="copyLicenseKey('{{ license.key }}')">
                📋 Copy
              </button>
            </div>
          </div>
          
          <div class="license-details">
            <table class="details-table">
              <tr>
                <th>Product ID:</th>
                <td>{{ license.product_id }}</td>
              </tr>
              <tr>
                <th>Activated On:</th>
                <td>{{ license.activated_at|date('F d, Y') }}</td>
              </tr>
              <tr>
                <th>Expires:</th>
                <td>
                  {% if license.is_expired %}
                    <span class="text-danger">⚠️ Expired</span>
                  {% elseif license.is_grace_period %}
                    <span class="text-warning">⏰ In Grace Period</span>
                  {% else %}
                    {{ license.expires_at|date('F d, Y') }}
                  {% endif %}
                </td>
              </tr>
              <tr>
                <th>Activations:</th>
                <td>{{ license.activations_used }} / {{ license.activation_limit }}</td>
              </tr>
              <tr>
                <th>Devices:</th>
                <td>{{ license.devices_used }} / {{ license.max_devices }}</td>
              </tr>
              {% if license.subscription_id %}
              <tr>
                <th>Subscription:</th>
                <td><a href="/subscriptions/{{ license.subscription_id }}">View Plan</a></td>
              </tr>
              {% endif %}
            </table>
          </div>
          
          <div class="license-actions">
            {% if not license.is_expired %}
              <button class="btn btn-sm btn-renew" onclick="renewLicense({{ license.id }})">
                🔁 Renew License
              </button>
            {% endif %}
            
            {% if license.can_deactivate %}
              <button class="btn btn-sm btn-deactivate" onclick="deactivateLicense({{ license.id }})">
                ❌ Deactivate
              </button>
            {% endif %}
            
            <button class="btn btn-sm btn-view-activations" onclick="viewActivations({{ license.id }})">
              👥 View Activations
            </button>
          </div>
          
        </div>
      {% endfor %}
    </div>
  {% endif %}
</div>

<style>
.license-card {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  background-color: #ffffff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.license-card.active {
  border-left: 4px solid #4caf50;
}

.license-card.expired {
  border-left: 4px solid #f44336;
}

.license-card.pending {
  border-left: 4px solid #ff9800;
}

.status-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: bold;
  text-transform: uppercase;
}

.status-badge.active {
  background-color: #e8f5e9;
  color: #4caf50;
}

.status-badge.expired {
  background-color: #ffebee;
  color: #f44336;
}

.status-badge.pending {
  background-color: #fff3e0;
  color: #ff9800;
}

.key-display {
  background-color: #f5f5f5;
  padding: 12px;
  border-radius: 4px;
  margin: 10px 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.key-display code {
  font-family: 'Courier New', monospace;
  font-size: 16px;
  letter-spacing: 1px;
}

.details-table {
  width: 100%;
  margin: 15px 0;
}

.details-table th {
  text-align: left;
  padding: 8px;
  color: #666;
  font-weight: normal;
}

.details-table td {
  padding: 8px;
  border-top: 1px solid #eee;
}

.btn-renew,
.btn-deactivate,
.btn-view-activations {
  margin-right: 10px;
  font-size: 13px;
  padding: 6px 16px;
}
</style>

<script>
function copyLicenseKey(key) {
  navigator.clipboard.writeText(key).then(function() {
    alert('License key copied to clipboard!');
  }).catch(function(err) {
    console.error('Failed to copy:', err);
  });
}

function renewLicense(licenseId) {
  if (confirm('Are you sure you want to renew this license?')) {
    window.location.href = '/licenses/' + licenseId + '/renew';
  }
}

function deactivateLicense(licenseId) {
  if (confirm('Deactivating this license will free up an activation slot. Continue?')) {
    fetch('/api/licenses/' + licenseId + '/deactivate', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
    }).then(response => {
      if (response.ok) {
        location.reload();
      }
    });
  }
}

function viewActivations(licenseId) {
  window.open('/licenses/' + licenseId + '/activations', '_blank');
}
</script>
```

---

## 📋 数据表结构

### commerce_license_license_key
许可证主表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PRIMARY KEY | 自增 ID |
| key | VARCHAR(64) | UNIQUE NOT NULL | 许可证密钥 |
| product_id | INT | FOREIGN KEY | 关联产品 ID |
| status | VARCHAR(20) | DEFAULT 'pending' | pending/active/inactive/expired/cancelled |
| activation_limit | INT | DEFAULT 1 | 最大激活次数 |
| activations_used | INT | DEFAULT 0 | 已激活次数 |
| max_devices | INT | DEFAULT 1 | 最大设备数 |
| devices_used | INT | DEFAULT 0 | 已绑定设备数 |
| issued_at | DATETIME | NOT NULL | 发行时间 |
| expires_at | DATETIME | NULLABLE | 过期时间 |
| grace_period_end | DATETIME | NULLABLE | 宽限期结束时间 |
| order_id | INT | NULLABLE | 关联订单 ID |
| customer_id | INT | NULLABLE | 客户 ID |
| features | JSON | NULLABLE | 启用的功能列表 |
| batch_id | VARCHAR(32) | NULLABLE | 批次 ID |

**索引**:
- `idx_key` ON key (唯一)
- `idx_product_status` ON (product_id, status)
- `idx_expires` ON expires_at WHERE expires_at > NOW()

### commerce_license_activation
许可证激活记录表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY | 自增 ID |
| license_key_id | INT | NOT NULL | 关联许可证 ID |
| uid | INT | NOT NULL | 用户 ID |
| activated_at | DATETIME | NOT NULL | 激活时间 |
| ip_address | VARCHAR(45) | NULLABLE | IP 地址 |
| user_agent | TEXT | NULLABLE | User-Agent |
| device_name | VARCHAR(100) | NULLABLE | 设备名称 |
| device_os | VARCHAR(50) | NULLABLE | 操作系统 |
| device_mac | VARCHAR(17) | NULLABLE | MAC 地址（如可用） |
| status | VARCHAR(20) | DEFAULT 'active' | active/deactivated/suspended |
| last_active | DATETIME | NULLABLE | 最后活跃时间 |

**索引**:
- `idx_license_user` ON (license_key_id, uid)
- `idx_device` ON (device_mac) WHERE device_mac IS NOT NULL

### commerce_license_subscription
订阅表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY | 自增 ID |
| uid | INT | NOT NULL | 用户 ID |
| product_variant | INT | NOT NULL | 产品变体 ID |
| plan_id | INT | NOT NULL | 订阅计划 ID |
| status | VARCHAR(20) | DEFAULT 'active' | active/paused/cancelled/expired |
| start_date | DATETIME | NOT NULL | 开始日期 |
| end_date | DATETIME | NOT NULL | 结束日期 |
| next_billing_date | DATETIME | NULLABLE | 下次账单日期 |
| billing_cycle | VARCHAR(20) | NOT NULL | 周期（月/年） |
| amount | DECIMAL(10,2) | NOT NULL | 金额 |
| currency | VARCHAR(10) | NOT NULL | 货币代码 |
| trial_start | DATETIME | NULLABLE | 试用开始时间 |
| trial_end | DATETIME | NULLABLE | 试用结束时间 |
| failed_payments | INT | DEFAULT 0 | 失败付款次数 |
| created_at | DATETIME | NOT NULL | 创建时间 |

### commerce_license_audit_log
审计日志表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| log_id | BIGINT | PRIMARY KEY | 自增 ID |
| license_key_id | INT | NOT NULL | 关联许可证 |
| action | VARCHAR(50) | NOT NULL | 动作类型 |
| uid | INT | NOT NULL | 操作用户 |
| details | JSON | NULLABLE | 详细信息 |
| ip_address | VARCHAR(45) | NULLABLE | IP 地址 |
| created_at | DATETIME | NOT NULL | 操作时间 |

---

## 🧪 测试建议

### 单元测试

```php
use Drupal\Tests\commerce_license\Unit\LicenseKeyTest;
use Drupal\commerce_license\Entity\LicenseKey;

class LicenseGenerationTest extends KernelTestBase {
  
  protected static $modules = ['commerce_license'];
  
  /**
   * Test: Unique license key generation
   */
  public function testGenerateUniqueLicenseKeys() {
    $generator = new LicenseBatchGenerator(\Drupal::service('license.generator'));
    
    $products = \Drupal::entityTypeManager()
      ->getStorage('commerce_product_variation')
      ->loadMultiple(array_slice(range(1, 3), 0, 1));
    
    $product = reset($products);
    
    // 批量生成 100 个密钥
    $licenses = $generator->generateForProduct($product, 100);
    
    // 验证数量
    $this->assertCount(100, $licenses);
    
    // 验证唯一性
    $keys = array_map(fn($l) => $l->getKey(), $licenses);
    $unique_keys = array_unique($keys);
    $this->assertEquals(100, count($unique_keys));
    
    // 验证格式
    foreach ($licenses as $license) {
      $this->assertMatchesRegularExpression('/^LIC-\d{4}-[A-Z0-9]{2}-[A-Z0-9]{8}-[A-Z0-9]{4}$/', 
        $license->getKey());
    }
  }
  
  /**
   * Test: License activation limits
   */
  public function testActivationLimitEnforcement() {
    $license = LicenseKey::create([
      'key' => 'TEST-LIC-KEY',
      'product_id' => 1,
      'activation_limit' => 3,
      'status' => 'pending',
    ]);
    
    $service = new LicenseActivationService();
    $user = $this->createUser();
    
    // 第一次激活
    $service->activateLicense('TEST-LIC-KEY', $user, ['name' => 'Device 1']);
    $this->assertEquals(1, $license->getActivationsUsed());
    
    // 第二次激活
    $service->activateLicense('TEST-LIC-KEY', $user, ['name' => 'Device 2']);
    $this->assertEquals(2, $license->getActivationsUsed());
    
    // 第三次激活（最后一台）
    $service->activateLicense('TEST-LIC-KEY', $user, ['name' => 'Device 3']);
    $this->assertEquals(3, $license->getActivationsUsed());
    
    // 第四次激活应该失败
    $this->expectException(Exception::class);
    $service->activateLicense('TEST-LIC-KEY', $user, ['name' => 'Device 4']);
  }
  
  /**
   * Test: License expiration check
   */
  public function testLicenseExpiration() {
    // 创建过期的许可证
    $license = LicenseKey::create([
      'key' => 'EXPIRED-LIC',
      'product_id' => 1,
      'expires_at' => REQUEST_TIME - (7 * DAY), // 7 天前过期
      'grace_period_end' => REQUEST_TIME - (1 * DAY), // 昨天宽限期结束
      'status' => 'active',
    ]);
    
    $this->assertTrue($license->isExpired());
    $this->assertTrue($license->isPastGracePeriod());
  }
}
```

### 集成测试

```gherkin
Feature: License Management
  As a customer
  I want to manage my software licenses
  
  Scenario: Purchasing and activating a license
    Given I am browsing software products
    And I add a lifetime license to my cart
    When I complete the checkout
    Then I should receive an email with the license key
    And I can activate it on my first device
    And I should see "Activate on 2 more devices remaining"
  
  Scenario: License expiration warning
    Given my license expires in 7 days
    When the reminder system runs
    Then I should receive an expiration warning email
    And I should be able to renew with one click
  
  Scenario: Device limit exceeded
    Given I have activated my license on 3 devices (maximum)
    When I try to activate on a 4th device
    Then the activation should be blocked
    And I should see instructions to deactivate an old device
```

---

## 📊 监控与日志

### 关键指标

| 指标 | 计算公式 | 目标值 |
|------|---------|--------|
| **许可证激活率** | (激活数 / 总发行数) × 100% | > 80% |
| **平均激活设备数** | SUM(activations) / COUNT(licenses) | 1.5-2.0 |
| **续约率** | (成功续费 / 应续费总数) × 100% | > 60% |
| **无效许可证率** | (报告无效 / 验证请求总数) × 100% | < 5% |

### 日志命令

```bash
# 查看许可证活动日志
drush watchdog-view commerce_license --count=50

# 查询即将过期的许可证
drush sql-query "
  SELECT l.key, l.product_id, p.name as product_name, 
         l.expires_at, DATEDIFF(l.expires_at, NOW()) as days_left
  FROM commerce_license_license_key l
  JOIN commerce_product p ON l.product_id = p.id
  WHERE l.status = 'active' 
  AND l.expires_at <= DATE_ADD(NOW(), INTERVAL 30 DAY)
  ORDER BY days_left ASC
"

# 导出许可证库存报告
drush php-script export_license_inventory_report
```

---

## 🔗 参考链接

| 资源 | 链接 |
|------|------|
| Drupal Commerce | https://www.drupal.org/project/commerce |
| License Module Documentation | https://docs.drupalcommerce.org/v2/modules/license/ |
| SaaS Subscription Best Practices | https://www.recurly.com/blog/subscription-metrics/ |

---

## 🆘 常见问题

### Q1: 如何处理盗版和密钥泄露？

**答案**：
```php
// 1. 启用 IP 绑定
$config['commerce_license.settings']['require_ip_binding'] = TRUE;

// 2. 检测异常激活模式
function detectAbnormalActivationPattern(UserInterface $user) {
  $recent_activations = load_recent_activations($user, HOUR);
  
  // 如果短时间内在不同 IP 激活多次
  if (count($recent_activations) > 5) {
    flag_license_for_review($user);
    return TRUE;
  }
  
  return FALSE;
}

// 3. 主动撤销可疑许可证
function revokeSuspiciousLicenses($customer_id) {
  $licenses = \Drupal::entityTypeManager()
    ->getStorage('license_key')
    ->loadByProperties(['customer_id' => $customer_id]);
  
  foreach ($licenses as $license) {
    if (isSuspicious($license)) {
      $license->setStatus('suspended');
      $license->save();
    }
  }
}
```

### Q2: 如何实现试用版转正付费？

**答案**：
```php
/**
 * 试用版升级为付费订阅
 */
function upgradeFromTrialToPaid(int $license_id) {
  $license = LicenseKey::load($license_id);
  
  // 验证仍在试用期内
  if (!$license->isInTrial()) {
    throw new \Exception('Trial period has ended');
  }
  
  // 创建付费订单
  $order = create_paid_order_from_trial($license);
  
  // 支付成功后
  if ($order->getStatus() === 'complete') {
    // 更新许可证状态
    $license->setStatus('active');
    $license->setExpiresAt(REQUEST_TIME + (365 * DAY));
    $license->setCustomerId($order->getOwnerId());
    $license->setOrderId($order->id());
    $license->save();
    
    // 发送确认邮件
    send_upgrade_confirmation($license);
  }
}
```

### Q3: 如何支持批量分发许可证？

**答案**：
```php
/**
 * 批量分发许可证给组织客户
 */
function distributeLicensesToOrganization(int $org_id, array $users, ProductVariation $product) {
  // 批量生成
  $quantity = count($users);
  $generator = new LicenseBatchGenerator();
  $licenses = $generator->generateForProduct($product, $quantity);
  
  // 一对一分配
  foreach ($licenses as $index => $license) {
    $license->setStatus('assigned');
    $license->setOrganizaitonId($org_id);
    $license->save();
    
    // 发送邮件给对应员工
    send_license_email($users[$index], $license->getKey(), $product);
  }
}
```

---

**大正，commerce-license.md 已补充完成。您还有其他指令吗？** 🚀
