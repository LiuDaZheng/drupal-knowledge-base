# Commerce License - 企业级部署指南

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 概述

本文档提供 License 模块在大型企业和复杂生产环境中的部署指南，涵盖高可用架构、负载均衡、灾难恢复等企业级需求。

### 适用场景

- **大型企业应用** - 多站点、多租户
- **高并发系统** - 每秒数千次请求
- **合规要求严格** - SOC2, ISO27001, GDPR
- **混合云环境** - AWS + On-Premises
- **全球业务** - 多地区部署

---

## 🏗️ 架构模式

### 推荐企业架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Global Load Balancer                      │
│                   (AWS Route53 / CloudFlare)                │
└───────────────────────┬─────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   US-East   │  │  US-West    │  │  EU-Central │
│   Region A  │  │   Region B  │  │   Region C  │
├─────────────┤  ├─────────────┤  ├─────────────┤
│ Drupal App  │  │ Drupal App  │  │ Drupal App  │
│ Instances   │  │ Instances   │  │ Instances   │
├─────────────┤  ├─────────────┤  ├─────────────┤
│ Redis Cache │  │ Redis Cache │  │ Redis Cache │
├─────────────┤  ├─────────────┤  ├─────────────┤
│ PostgreSQL  │◄─┤  PG Cluster │◄─┤  PostgreSQL │
│ Primary     │  │ Replicas    │  │ Primary     │
└─────────────┘  └─────────────┘  └─────────────┘
        │                  │                  │
        └──────────────────┴──────────────────┘
                        │
                        ▼
            ┌─────────────────────┐
            │ Central License DB  │
            │ (Cross-region sync) │
            └─────────────────────┘
```

---

## 🔧 配置指南

### 1. 数据库优化

#### PostgreSQL 主从复制配置

```sql
-- postgresql.conf
wal_level = replica
max_wal_senders = 10
wal_keep_size = 1GB
hot_standby = on

-- streaming_replica.conf
primary_conninfo = 'host=db-master port=5432 user=replicator password=***'
restore_command = 'cp /var/lib/postgresql/wal_archive/%f %p'
standby_mode = 'on'
```

#### 许可证表优化

```sql
-- 添加分区以提高查询性能
CREATE TABLE license_activations_2026q1 PARTITION OF license_activations
FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');

-- 创建索引
CREATE INDEX idx_license_key_active ON license_keys(key) WHERE status = 'active';
CREATE INDEX idx_activation_timestamp ON license_activations(activated_at DESC);

-- 定期清理旧数据
VACUUM ANALYZE license_activations;
```

#### 连接池配置

```yaml
# config/database.yml
production:
  pool: <%= ENV['DB_POOL'] || 25 %>
  timeout: 5000
  checkout_timeout: 10
  
# .env.production
DB_POOL=50
MAX_CONNECTIONS=100
```

---

### 2. Redis 缓存集群

```bash
# redis.conf
maxmemory 4gb
maxmemory-policy allkeys-lru
cluster-enabled yes
cluster-node-timeout 5000

# 启动 Redis 集群
redis-cli --cluster create \
  10.0.1.10:6379 10.0.1.11:6379 10.0.1.12:6379 \
  --cluster-replicas 1
```

#### License 缓存键设计

```php
<?php

namespace Drupal\license\Cache;

/**
 * License cache key manager
 */
class LicenseCacheKeys {
  
  const LICENSE_BY_KEY = 'license:by_key:{}';
  const LICENSE_BY_PRODUCT = 'license:by_product:{}';
  const VALIDATION_RESULT = 'validation:result:{}';
  const ACTIVATIONS_COUNT = 'activations:count:{}';
  
  /**
   * 生成许可证密钥的缓存键
   */
  public static function forKey(string $key): string {
    return sprintf(self::LICENSE_BY_KEY, hash('sha256', $key));
  }
  
  /**
   * 生成产品所有许可证的缓存键
   */
  public static function byProduct(int $productId): string {
    return sprintf(self::LICENSE_BY_PRODUCT, $productId);
  }
  
  /**
   * 验证结果缓存 TTL（秒）
   */
  public static function getValidationTtl(): int {
    // 普通用户：1 小时
    // VIP 用户：4 小时
    // 企业客户：6 小时
    return HOUR;
  }
}

// 使用示例
use Drupal\license\Cache\LicenseCacheKeys as LCK;

$cacheKey = LCK::forKey($inputKey);
$cached = \Drupal::cache('license_data')->get($cacheKey);

if (!$cached) {
  // 数据库查询
  $license = \Drupal::entityTypeManager()
    ->getStorage('license_key')
    ->loadByProperties(['key' => $key])
    ->current();
  
  // 缓存 1 小时
  \Drupal::cache('license_data')
    ->set($cacheKey, $license, REQUEST_TIME + LCK::getValidationTtl());
}
```

---

### 3. API Rate Limiting

```php
<?php

namespace Drupal\license\Plugin\Routing;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Drupal\Core\EventSubscriber\MainConfigurationUpdateSubscriber;

/**
 * 许可证验证速率限制器
 */
class RateLimiterSubscriber implements \Symfony\Component\EventDispatcher\EventSubscriberInterface {
  
  protected $rateLimitService;
  
  public function __construct(RateLimitService $rateLimitService) {
    $this->rateLimitService = $rateLimitService;
  }
  
  public static function getSubscribedEvents() {
    return [
      'kernel.request' => ['onKernelRequest', 100],
    ];
  }
  
  public function onKernelRequest(RequestEvent $event) {
    $request = $event->getRequest();
    
    // 仅限制验证端点
    if ($request->attributes->get('_route') !== 'api.license.verify') {
      return;
    }
    
    // 获取客户端标识
    $identifier = $this->getClientIdentifier($request);
    
    // 检查是否超过速率限制
    if (!$this->rateLimitService->allowRequest($identifier)) {
      $response = new Response(
        json_encode([
          'success' => false,
          'error' => 'rate_limit_exceeded',
          'retry_after' => 60,
        ]),
        429,
        ['Content-Type' => 'application/json']
      );
      
      $event->setResponse($response);
    }
  }
  
  protected function getClientIdentifier(Request $request): string {
    // 认证用户使用用户 ID
    if (\Drupal::currentUser()->isAuthenticated()) {
      return 'user_' . \Drupal::currentUser()->id();
    }
    
    // 匿名用户使用 IP + User Agent
    $ip = $request->getClientIp();
    $ua = substr(hash('sha256', $request->headers->get('User-Agent')), 0, 16);
    
    return "anon_{$ip}_{$ua}";
  }
}

// RateLimitService 实现
class RateLimitService {
  
  protected $redis;
  
  public function __construct(\Redis $redis) {
    $this->redis = $redis;
  }
  
  public function allowRequest(string $identifier, int $limit = 100, int $window = 3600): bool {
    $key = "ratelimit:license_verify:{$identifier}";
    
    $current = $this->redis->incr($key);
    
    if ($current === 1) {
      $this->redis->expire($key, $window);
    }
    
    return $current <= $limit;
  }
}
```

---

### 4. 监控与告警

#### Prometheus Metrics Export

```php
<?php

namespace Drupal\license\Metrics;

use Prometheus\CollectorRegistry;
use Prometheus\Storage\Redis;

/**
 * License metrics collector
 */
class LicenseMetricsCollector {
  
  protected $registry;
  
  public function __construct(CollectorRegistry $registry) {
    $this->registry = $registry;
  }
  
  /**
   * 记录许可证验证指标
   */
  public function recordValidationAttempt(bool $success, string $reason = ''): void {
    $this->registry->getCounter(
      'license_validation_total',
      'Total number of license validation attempts'
    )
      ->labels(['success' => $success ? 'true' : 'false', 'reason' => $reason])
      ->inc();
    
    // 响应时间直方图
    $this->registry->getHistogram(
      'license_validation_duration_seconds',
      'License validation duration in seconds'
    )
      ->observe(microtime(true) - $_SERVER['REQUEST_TIME_FLOAT']);
  }
  
  /**
   * 当前活跃许可证数量
   */
  public function reportActiveLicenses(): void {
    $count = db_select('license_keys', 'l')
      ->condition('status', 'active')
      ->countQuery()
      ->execute()
      ->fetchField();
    
    $this->registry->getGauge(
      'license_active_total',
      'Number of active licenses'
    )->set($count);
  }
  
  /**
   * 即将过期的许可证数量
   */
  public function reportExpiringSoon(int $days = 30): void {
    $query = db_select('license_keys', 'l');
    $query->fields('l', ['id']);
    $query->condition('status', 'active');
    $query->condition('expires_at', REQUEST_TIME + ($days * DAY), '<');
    $query->condition('expires_at', REQUEST_TIME, '>');
    
    $count = $query->countQuery()->execute()->fetchField();
    
    $this->registry->getGauge(
      'license_expiring_soon',
      'Number of licenses expiring soon'
    )->set($count);
  }
}

// Cron 定时任务
function license_metrics_cron() {
  $collector = \Drupal::service('license.metrics_collector');
  
  $collector->reportActiveLicenses();
  $collector->reportExpiringSoon(7);  // 7 天内过期
  $collector->reportExpiringSoon(30); // 30 天内过期
}
```

#### Grafana Dashboard JSON

```json
{
  "dashboard": {
    "title": "License Management Dashboard",
    "panels": [
      {
        "title": "Validations per Hour",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(license_validation_total[5m])",
            "legendFormat": "{{success}} - {{reason}}"
          }
        ],
        "yAxes": [{"label": "Validations/sec"}]
      },
      {
        "title": "Active Licenses",
        "type": "stat",
        "targets": [
          {
            "expr": "license_active_total"
          }
        ]
      },
      {
        "title": "Validation Response Time",
        "type": "histogram",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(license_validation_duration_seconds_bucket[5m]))"
          }
        ]
      },
      {
        "title": "Expiring Soon (7 days)",
        "type": "gauge",
        "targets": [
          {
            "expr": "license_expiring_soon{period=\"7d\"}"
          }
        ]
      }
    ]
  }
}
```

---

### 5. 灾难恢复

#### 备份策略

```bash
#!/bin/bash
# license-backup.sh

# 数据库备份
PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -U $DB_USER \
  -d drupal_production \
  -F c \
  -b \
  -z \
  -f "/backups/license_backup_$(date +%Y%m%d_%H%M%S).dump"

# 文件备份
tar -czf "/backups/license_files_$(date +%Y%m%d_%H%M%S).tar.gz" \
  /var/www/html/sites/default/files/licenses \
  /var/www/html/sites/default/private/licensing

# 保留最近 30 天的备份
find /backups -name "*.dump" -mtime +30 -delete
find /backups -name "*.tar.gz" -mtime +30 -delete

# 上传到 S3
aws s3 cp /backups/license_backup_*.dump s3://your-bucket/backups/
aws s3 cp /backups/license_files_*.tar.gz s3://your-bucket/backups/
```

#### 故障转移流程

```yaml
# failover-procedure.md

## 主要故障切换步骤

1. 检测失败：
   - Health check 连续 3 次失败
   - 数据库连接超时 > 5s

2. 切换 DNS:
   - Route53 health check 触发自动 Failover
   - 切换到备用区域

3. 验证服务:
   - API 端点响应正常
   - 数据库同步延迟 < 1s
   - 缓存集群健康

4. 通知团队:
   - Slack #incidents 频道
   - PagerDuty 警报

5. 回滚计划:
   - 如果主区域恢复，24 小时后手动切回
   - 数据一致性检查通过后再切换
```

---

### 6. 安全加固

#### 网络隔离配置

```yaml
# kubernetes/networkpolicy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: license-service-isolation
spec:
  podSelector:
    matchLabels:
      app: license-service
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: api-gateway
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 5432  # PostgreSQL
    - protocol: TCP
      port: 6379  # Redis
```

#### 加密配置

```php
<?php

$config['license.encryption'] = [
  'algorithm' => 'AES-256-GCM',
  'key_derivation' => 'PBKDF2',
  'iterations' => 100000,
  'storage' => 'vault',
  'vault_address' => 'https://vault.internal:8200',
  'vault_token_path' => '/var/run/secrets/vault/token',
];

// 使用 Vault 密钥加密敏感数据
class LicenseEncryptionService {
  
  public function encryptSensitiveData(array $data): string {
    $secret = $this->getVaultSecret('license/master-key');
    
    $iv = random_bytes(12);
    $tag = '';
    $encrypted = openssl_encrypt(
      json_encode($data),
      'aes-256-gcm',
      $secret,
      OPENSSL_RAW_DATA,
      $iv,
      $tag
    );
    
    return base64_encode($iv . $tag . $encrypted);
  }
}
```

---

*最后更新：2026-04-08 | 版本：v1.0*
