# Commerce License - 验证最佳实践

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 概述

本文档介绍如何安全、高效地实现许可证验证机制，保护软件免受盗版和滥用，同时提供优秀的用户体验。

### 核心目标

1. **安全性** - 防止未授权访问
2. **可用性** - 不影响正常用户使用
3. **容错性** - 离线场景 gracefully 处理
4. **用户体验** - 最小化干扰和摩擦

---

## 🔐 验证策略模型

### 策略对比矩阵

| 验证方式 | 安全性 | 离线支持 | 用户影响 | 推荐场景 |
|---------|--------|---------|---------|---------|
| **仅在线验证** | ⭐⭐⭐⭐⭐ | ❌ | 高 (需持续联网) | SaaS 平台 |
| **混合验证 (在线 + 离线)** | ⭐⭐⭐⭐ | ✅ | 中 (定期在线检查) | 桌面软件 |
| **本地验证为主** | ⭐⭐⭐ | ✅ | 低 (首次激活在线) | 零售许可证 |
| **无验证** | ⭐ | ✅ | 无 | 开源项目 |

### 推荐的混合模式

```yaml
validation_strategy:
  primary: online_check
  fallback: offline_license_file
  
  online_policy:
    initial_activation: required
    periodic_recheck_interval: 7_days
    grace_period_after_failure: 14_days
    
  offline_policy:
    license_file_expiry: 30_days
    max_offline_days: 60
    cryptographic_signature: true
```

---

## 💻 验证实现方案

### 方案 1: RESTful API 在线验证（推荐）

#### 客户端集成代码

```javascript
// JavaScript/TypeScript 示例
class LicenseValidator {
  constructor(config) {
    this.apiBaseUrl = config.apiBaseUrl || 'https://api.yourstore.com';
    this.licenseKey = localStorage.getItem('license_key');
    this.lastCheckTime = parseInt(localStorage.getItem('last_validation') || '0');
    this.checkInterval = config.checkInterval || 604800000; // 7 days in ms
  }

  /**
   * 执行许可证验证
   */
  async validate() {
    try {
      // 检查是否需要验证
      if (!this.shouldCheck()) {
        console.log('Validation not needed, using cached result');
        return this.getCachedResult();
      }

      const response = await fetch(`${this.apiBaseUrl}/api/v1/licenses/verify`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Device-ID': this.getDeviceId(),
        },
        body: JSON.stringify({
          license_key: this.licenseKey,
          product_id: this.productId,
          device_info: this.getDeviceInfo(),
        }),
      });

      const data = await response.json();

      if (data.valid) {
        this.saveValidationResult(data);
        return { success: true, data };
      } else {
        this.handleValidationFailure(data);
        return { success: false, reason: data.reason };
      }
    } catch (error) {
      console.error('Validation error:', error);
      return this.handleNetworkError(error);
    }
  }

  /**
   * 决定是否需要进行验证
   */
  shouldCheck() {
    const now = Date.now();
    const cacheValidUntil = this.lastCheckTime + this.checkInterval;
    
    return now > cacheValidUntil;
  }

  /**
   * 保存验证结果（带时间戳）
   */
  saveValidationResult(verificationData) {
    const result = {
      valid: verificationData.valid,
      timestamp: Date.now(),
      expirationDate: verificationData.expiration_date,
      features: verificationData.features,
    };

    localStorage.setItem('license_validation', JSON.stringify(result));
    localStorage.setItem('last_validation', Date.now().toString());
  }

  /**
   * 获取缓存的验证结果
   */
  getCachedResult() {
    const cached = localStorage.getItem('license_validation');
    if (!cached) return null;

    const result = JSON.parse(cached);
    
    // 验证缓存是否过期
    if (result.expirationDate && new Date(result.expirationDate) < new Date()) {
      return null; // 已过期，需要重新验证
    }

    return { success: result.valid, data: result };
  }

  /**
   * 处理网络错误（降级到离线模式）
   */
  handleNetworkError(error) {
    console.warn('Network error, attempting offline validation');
    
    // 尝试使用离线许可证文件
    const offlineResult = this.validateOffline();
    
    if (offlineResult.success) {
      console.log('Offline validation succeeded');
      return offlineResult;
    }

    // 如果离线也失败，根据策略决定
    return this.handleGracePeriod();
  }

  /**
   * 离线许可证验证
   */
  validateOffline() {
    // 从加密的本地文件读取
    const offlineLicense = this.getOfflineLicenseFile();
    
    if (!offlineLicense) {
      return { success: false, reason: 'offline_license_missing' };
    }

    // 验证签名和时间戳
    if (!this.verifyOfflineSignature(offlineLicense)) {
      return { success: false, reason: 'invalid_signature' };
    }

    // 检查是否过期
    if (this.isOfflineLicenseExpired(offlineLicense)) {
      return { success: false, reason: 'offline_expired' };
    }

    return { 
      success: true, 
      data: {
        valid: true,
        offline_mode: true,
        expires_in_days: this.calculateOfflineExpiryDays(offlineLicense),
      }
    };
  }

  getDeviceId() {
    let deviceId = localStorage.getItem('device_id');
    if (!deviceId) {
      deviceId = crypto.randomUUID();
      localStorage.setItem('device_id', deviceId);
    }
    return deviceId;
  }

  getDeviceInfo() {
    return {
      platform: navigator.platform,
      browser: navigator.userAgent,
      language: navigator.language,
      screen_resolution: `${screen.width}x${screen.height}`,
    };
  }
}

// 使用示例
const validator = new LicenseValidator({
  apiBaseUrl: 'https://yourstore.com',
  productId: 5,
});

// 在应用启动时验证
validator.validate().then(result => {
  if (result.success) {
    initializeApp(result.data.features);
  } else {
    showLicenseBlockedScreen(result.reason);
  }
});
```

#### 服务端验证逻辑

```php
<?php

namespace Drupal\license\Service;

use Drupal\Core\Controller\ControllerBase;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;

/**
 * 许可证验证控制器
 */
class LicenseVerificationController extends ControllerBase {
  
  /**
   * 公共验证端点（无需认证）
   */
  public function verify(Request $request): JsonResponse {
    $input = json_decode($request->getContent(), TRUE);
    
    // 验证请求格式
    if (!$this->validateRequest($input)) {
      throw new BadRequestHttpException('Invalid request format');
    }
    
    $license_key = $input['license_key'];
    $product_id = $input['product_id'];
    $device_info = $input['device_info'] ?? [];
    $ip_address = $request->getClientIp();
    
    // 查询许可证
    $license = $this->loadLicenseByKey($license_key);
    
    if (!$license) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'invalid_key',
        'message' => 'The license key provided is invalid.',
      ], 404);
    }
    
    // 检查产品匹配
    if ($license->getProductId() != $product_id) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'product_mismatch',
        'message' => 'This license does not apply to the requested product.',
      ], 403);
    }
    
    // 检查许可证状态
    if (!$this->isLicenseActive($license)) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => $this->getStatusReason($license->getStatus()),
        'details' => $this->getStatusDetails($license),
      ], 403);
    }
    
    // 检查过期
    if ($license->isExpired()) {
      $response = [
        'valid' => FALSE,
        'reason' => 'expired',
        'expiration_date' => $license->getExpiresAt(),
      ];
      
      // 检查宽限期
      if ($license->isInGracePeriod()) {
        $response['grace_period_end'] = $license->getGracePeriodEnd();
        $response['warning'] = 'License expired but still in grace period';
      }
      
      return JsonResponse($response, 403);
    }
    
    // 检查激活限制
    if ($license->hasReachedActivationLimit()) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'activation_limit_reached',
        'activations_used' => $license->getActivationsUsed(),
        'activation_limit' => $license->getActivationLimit(),
        'suggestion' => 'Please deactivate an old device or contact support',
      ], 403);
    }
    
    // 检查设备数量限制
    if ($license->hasReachedDeviceLimit()) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'device_limit_reached',
        'devices_used' => $license->getDevicesUsed(),
        'max_devices' => $license->getMaxDevices(),
      ], 403);
    }
    
    // 所有检查通过
    $responseData = [
      'valid' => TRUE,
      'license_key' => $license->getKey(),
      'product_name' => $license->getProductName(),
      'owner_email' => $license->getCustomerEmail(),
      'issued_date' => date('Y-m-d', $license->getIssuedAt()),
      'expiration_date' => date('Y-m-d', $license->getExpiresAt()),
      'features' => $license->getFeatures(),
      'activation_limit' => $license->getActivationLimit(),
      'activations_remaining' => $license->getActivationLimit() - $license->getActivationsUsed(),
      'validation_timestamp' => date('Y-m-d H:i:s'),
    ];
    
    // 记录验证日志
    $this->logValidationAttempt($license, $ip_address, TRUE, NULL);
    
    return JsonResponse($responseData);
  }
  
  /**
   * 验证离线许可证文件
   */
  public function verifyOffline(Request $request): JsonResponse {
    $input = json_decode($request->getContent(), TRUE);
    
    if (!isset($input['encrypted_license']) || !isset($input['signature'])) {
      throw new BadRequestHttpException('Missing required fields');
    }
    
    $encrypted_license = base64_decode($input['encrypted_license']);
    $signature = $input['signature'];
    
    // 解密
    $decrypted = $this->decryptLicense($encrypted_license);
    
    // 验证签名
    if (!$this->verifySignature($decrypted, $signature)) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'invalid_signature',
      ], 403);
    }
    
    // 解析许可证数据
    $license_data = json_decode($decrypted, TRUE);
    
    // 检查是否过期
    $now = time();
    if ($now > $license_data['expires_at']) {
      return JsonResponse([
        'valid' => FALSE,
        'reason' => 'offline_expired',
        'expired_date' => date('Y-m-d', $license_data['expires_at']),
      ], 403);
    }
    
    // 检查 IP 白名单（可选）
    if (!empty($license_data['allowed_ips'])) {
      $current_ip = $_SERVER['REMOTE_ADDR'];
      if (!in_array($current_ip, $license_data['allowed_ips'])) {
        return JsonResponse([
          'valid' => FALSE,
          'reason' => 'ip_not_allowed',
        ], 403);
      }
    }
    
    return JsonResponse([
      'valid' => TRUE,
      'offline_mode' => TRUE,
      'expires_in_hours' => floor(($license_data['expires_at'] - $now) / 3600),
      'can_use' => TRUE,
    ]);
  }
  
  /**
   * 记录验证尝试到数据库
   */
  protected function logValidationAttempt($license, $ip_address, $success, $error_reason): void {
    db_insert('license_validation_log')
      ->fields([
        'license_key_id' => $license->id(),
        'ip_address' => $ip_address,
        'validation_successful' => $success ? 1 : 0,
        'error_reason' => $error_reason ?? '',
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
        'created_at' => REQUEST_TIME,
      ])
      ->execute();
  }
  
  protected function validateRequest(array $input): bool {
    return isset($input['license_key']) && 
           isset($input['product_id']) &&
           strlen($input['license_key']) >= 10;
  }
  
  protected function loadLicenseByKey(string $key) {
    $query = \Drupal::entityQuery('license_key')
      ->condition('key', $key)
      ->accessCheck(FALSE);
    
    $ids = $query->execute();
    
    if (empty($ids)) {
      return NULL;
    }
    
    return \Drupal\license\Entity\LicenseKey::load(reset($ids));
  }
}
```

---

### 方案 2: 离线许可证文件（适用于完全离线环境）

#### 生成离线许可证

```php
<?php

namespace Drupal\license\Service;

use OpenSSLAsymmetricKey;

/**
 * 离线许可证生成器
 */
class OfflineLicenseGenerator {
  
  private $privateKey;
  private $publicKey;
  
  public function __construct() {
    // 加载私钥
    $this->privateKey = openssl_pkey_get_private(file_get_contents('/path/to/private.key'));
  }
  
  /**
   * 生成离线许可证文件
   */
  public function generateOfflineLicense(array $license_data): string {
    $timestamp = time();
    $expires_at = $timestamp + (30 * DAY); // 30天有效期
    
    // 构建许可证内容
    $license_content = [
      'license_key' => $license_data['key'],
      'product_id' => $license_data['product_id'],
      'customer_email' => $license_data['customer_email'],
      'issued_at' => $timestamp,
      'expires_at' => $expires_at,
      'features' => $license_data['features'] ?? [],
      'ip_whitelist' => $license_data['ip_whitelist'] ?? [],
    ];
    
    // 序列化为 JSON
    $json_data = json_encode($license_content, JSON_PRETTY_PRINT);
    
    // 使用 RSA 签名
    $signature = '';
    openssl_sign($json_data, $signature, $this->privateKey, OPENSSL_ALGO_SHA256);
    
    // Base64 编码
    $encoded_data = base64_encode($json_data);
    $encoded_signature = base64_encode($signature);
    
    // 返回组合字符串
    return $encoded_data . ':::' . $encoded_signature;
  }
  
  /**
   * 导出为下载文件
   */
  public function downloadOfflineLicense(array $license_data, string $filename = 'license.dat'): void {
    $license_content = $this->generateOfflineLicense($license_data);
    
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    header('Content-Length: ' . strlen($license_content));
    
    echo $license_content;
    exit;
  }
}
```

#### 客户端验证离线文件

```javascript
// 使用 Web Crypto API 验证签名
async function verifyOfflineLicense(encodedData, publicKeyPem) {
  try {
    // 分离数据和签名
    const [encodedDataPart, encodedSignature] = encodedData.split(';;;');
    const data = atob(encodedDataPart);
    const signature = Uint8Array.from(atob(encodedSignature), c => c.charCodeAt(0));
    
    // 导入公钥
    const publicKey = await crypto.subtle.importKey(
      'spki',
      pemToDer(publicKeyPem),
      {
        name: 'RSASSA-PKCS1-v1_5',
        hash: 'SHA-256',
      },
      true,
      ['verify']
    );
    
    // 验证签名
    const isValid = await crypto.subtle.verify(
      { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
      publicKey,
      signature,
      Uint8Array.from(JSON.parse(data).split('').map(c => c.charCodeAt(0)))
    );
    
    return {
      valid: isValid,
      data: isValid ? JSON.parse(data) : null
    };
  } catch (error) {
    console.error('Offline license verification failed:', error);
    return { valid: false, error: error.message };
  }
}

// 辅助函数：PEM 转 DER
function pemToDer(pem) {
  const b64 = pem.replace(/-----BEGIN PUBLIC KEY-----|-----END PUBLIC KEY-----|\s/g, '');
  return Uint8Array.from(atob(b64), c => c.charCodeAt(0));
}
```

---

## 🔒 安全加固措施

### 1. 防暴力破解

```php
/**
 * 防止暴力枚举密钥
 */
class RateLimiter {
  
  public function checkRateLimit($identifier, $max_attempts = 10, $window_minutes = 15): bool {
    $cache_key = "license_validation_rate_limit_{$identifier}";
    
    $attempts = \Drupal::cache('dynamic_page_cache')->get($cache_key);
    
    if (!$attempts) {
      return TRUE;
    }
    
    // 清理过期的尝试记录
    $now = REQUEST_TIME;
    $cutoff = $now - ($window_minutes * 60);
    
    $attempts = array_filter($attempts, fn($time) => $time > $cutoff);
    
    if (count($attempts) >= $max_attempts) {
      \Drupal::logger('security')
        ->warning('Rate limit exceeded for license validation: @identifier', [
          ':identifier' => $identifier,
        ]);
      
      return FALSE;
    }
    
    // 添加新的尝试记录
    $attempts[] = $now;
    \Drupal::cache('dynamic_page_cache')
      ->set($cache_key, $attempts, $now + ($window_minutes * 60));
    
    return TRUE;
  }
}
```

### 2. IP 地址限制

```yaml
# settings.php
$config['license.validation.ip_restrictions'] = [
  'enabled' => TRUE,
  'whitelist_file' => '/var/config/license_ip_whitelist.txt',
  'blacklist_enabled' => TRUE,
  'block_suspicious_countries' => TRUE,
];
```

### 3. Device Fingerprinting

```javascript
/**
 * 生成立法设备指纹用于异常检测
 */
function generateDeviceFingerprint() {
  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  ctx.textBaseline = 'top';
  ctx.font = '14px Arial';
  ctx.fillText('fingerprint', 2, 2);
  
  const fingerprint = [
    navigator.userAgent,
    navigator.language,
    screen.colorDepth,
    screen.pixelDepth,
    canvas.toDataURL(),
    Intl.DateTimeFormat().resolvedOptions().timeZone,
    new Date().getTimezoneOffset(),
  ].join('|');
  
  return btoa(fingerprint);
}
```

---

## 🛡️ 审计与监控

### 可疑活动检测

```sql
-- 检测异常登录模式
SELECT 
  l.key,
  COUNT(*) as validation_count,
  GROUP_CONCAT(DISTINCT ip_address) as ips,
  MAX(created_at) as last_attempt
FROM license_validation_log l
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY l.key
HAVING validation_count > 50 OR LENGTH(ips) > 100;

-- 检测设备冲突
SELECT 
  license_id,
  user_id,
  COUNT(DISTINCT ip_address) as unique_ips,
  COUNT(DISTINCT device_fingerprint) as unique_devices
FROM license_activations a
WHERE activated_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY license_id, user_id
HAVING unique_ips > 10 OR unique_devices > 5;
```

### 审计报表生成

```bash
#!/bin/bash
# license-audit-report.sh

REPORT_DATE=$(date +%Y%m%d)
OUTPUT_FILE="/var/reports/license-audit-${REPORT_DATE}.html"

drush sql-query "
  SELECT 
    DATE_FORMAT(created_at, '%Y-%m-%d') as date,
    COUNT(*) as total_validations,
    SUM(CASE WHEN validation_successful = 1 THEN 1 ELSE 0 END) as successful,
    SUM(CASE WHEN validation_successful = 0 THEN 1 ELSE 0 END) as failed,
    ROUND(SUM(CASE WHEN validation_successful = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as success_rate
  FROM license_validation_log
  WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
  GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d')
  ORDER BY date DESC
" --format=json | jq '.' > audit_data.json

# 生成 HTML 报告
echo "Audit report generated: $OUTPUT_FILE"
```

---

*最后更新：2026-04-08 | 版本：v1.0*
