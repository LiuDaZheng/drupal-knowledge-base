# Commerce License - RESTful API Reference

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 概述

本文档提供 Commerce License 模块的完整 RESTful API 参考，涵盖许可证生成、验证、激活管理等所有 API 端点。

### 基础信息

| 项目 | 值 |
|------|-----|
| **Base URL** | `/api/v1/licenses` |
| **认证方式** | Bearer Token / API Key |
| **Content-Type** | `application/json` |
| **返回格式** | JSON |

### 统一响应格式

```json
{
  "success": true,
  "data": { },
  "message": "",
  "errors": []
}
```

---

## 🔐 认证

### Bearer Token (推荐)

```http
Authorization: Bearer <access_token>
```

### API Key

```http
X-API-Key: <your_api_key>
```

### 获取 Access Token

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "secure_password"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
  }
}
```

---

## 📦 API 端点列表

### 1. 许可证管理

| 方法 | 端点 | 说明 | 权限 |
|------|------|------|------|
| GET | `/licenses` | 获取许可证列表 | viewer |
| POST | `/licenses` | 创建新许可证 | license_generator |
| GET | `/licenses/{id}` | 获取单个许可证详情 | viewer |
| PATCH | `/licenses/{id}` | 更新许可证 | license_admin |
| DELETE | `/licenses/{id}` | 删除许可证 | license_admin |
| GET | `/licenses/{id}/activations` | 获取激活历史 | viewer |

### 2. 许可证密钥生成

| 方法 | 端点 | 说明 | 权限 |
|------|------|------|------|
| POST | `/licenses/generate` | 批量生成密钥 | license_generator |
| GET | `/licenses/batch/{batch_id}` | 查询批次状态 | viewer |
| PUT | `/licenses/batch/{batch_id}/assign` | 分配许可证给用户 | license_admin |

### 3. 许可证验证（公共）

| 方法 | 端点 | 说明 | 权限 |
|------|------|------|------|
| POST | `/verify` | 验证许可证有效性 | 无需认证 |
| POST | `/check-expiration` | 检查是否过期 | 无需认证 |
| POST | `/activate` | 激活许可证 | 需要密钥 |

### 4. 激活管理

| 方法 | 端点 | 说明 | 权限 |
|------|------|------|------|
| POST | `/activations` | 创建激活记录 | license_user |
| DELETE | `/activations/{id}` | 反激活许可证 | license_user |
| GET | `/activations/user/{uid}` | 获取用户所有激活 | self |

### 5. 订阅关联

| 方法 | 端点 | 说明 | 权限 |
|------|------|------|------|
| GET | `/subscriptions/{id}/licenses` | 获取订阅下所有许可证 | subscription_member |
| POST | `/subscriptions/{id}/renew` | 续订订阅 | subscriber |

---

## 📝 详细 API 文档

### 1. 获取许可证列表

**请求**:
```http
GET /api/v1/licenses?page=1&limit=20&status=active&product_id=5
Authorization: Bearer <token>
```

**参数**:
| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| page | int | No | 页码（默认 1） |
| limit | int | No | 每页数量（默认 20，最大 100） |
| status | string | No | 过滤状态：pending/active/inactive/expired/cancelled |
| product_id | int | No | 按产品 ID 过滤 |
| sort | string | No | 排序字段：created_at, expires_at, key |
| order | string | No | 排序方向：asc/desc |

**响应**:
```json
{
  "success": true,
  "data": {
    "licenses": [
      {
        "id": 123,
        "key": "LIC-2026-A3F9-KL82",
        "product_id": 5,
        "product_name": "Pro Software Suite",
        "status": "active",
        "activation_limit": 3,
        "activations_used": 1,
        "max_devices": 2,
        "devices_used": 1,
        "issued_at": "2026-04-01T10:30:00Z",
        "expires_at": "2027-04-01T10:30:00Z",
        "is_expired": false,
        "grace_period_end": null,
        "customer_email": "user@example.com",
        "subscription_id": 456
      }
    ],
    "meta": {
      "total": 150,
      "page": 1,
      "per_page": 20,
      "total_pages": 8
    }
  }
}
```

### 2. 创建新许可证

**请求**:
```http
POST /api/v1/licenses
Authorization: Bearer <token>
Content-Type: application/json

{
  "product_id": 5,
  "quantity": 100,
  "activation_limit": 3,
  "max_devices": 2,
  "validity_days": 365,
  "features": ["feature_a", "feature_b"],
  "custom_data": {
    "department": "IT",
    "cost_center": "CC-1234"
  }
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "batch_id": "BATCH_20260408_1A2B3C",
    "generated_count": 100,
    "licenses": [
      {
        "id": 789,
        "key": "LIC-2026-B7M1-NP94",
        "status": "pending"
      },
      {
        "id": 790,
        "key": "LIC-2026-C8N2-OQ05",
        "status": "pending"
      }
    ]
  },
  "message": "Successfully generated 100 license keys"
}
```

### 3. 验证许可证（公共 API - 用于软件客户端调用）

**请求**:
```http
POST /api/v1/licenses/verify
Content-Type: application/json

{
  "license_key": "LIC-2026-A3F9-KL82",
  "product_id": 5,
  "device_info": {
    "mac_address": "00:1B:44:11:3A:B7",
    "ip_address": "192.168.1.100"
  }
}
```

**响应 (有效)**:
```json
{
  "valid": true,
  "license_key": "LIC-2026-A3F9-KL82",
  "product_id": 5,
  "product_name": "Pro Software Suite",
  "owner_email": "user@example.com",
  "issued_date": "2026-04-01",
  "expiration_date": "2027-04-01",
  "activation_limit": 3,
  "activations_remaining": 2,
  "features": ["feature_a", "feature_b"],
  "validation_timestamp": "2026-04-08T13:30:00Z"
}
```

**响应 (无效)**:
```json
{
  "valid": false,
  "reason": "expired",
  "message": "The license has expired.",
  "expiration_date": "2026-04-01",
  "grace_period_end": "2026-04-08"
}
```

### 4. 激活许可证

**请求**:
```http
POST /api/v1/licenses/activate
Content-Type: application/json

{
  "license_key": "LIC-2026-A3F9-KL82",
  "device_name": "Work Laptop - John",
  "device_os": "Windows 11",
  "device_mac": "00:1B:44:11:3A:B7"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "activation_id": 456,
    "license_key": "LIC-2026-A3F9-KL82",
    "activated_at": "2026-04-08T13:30:00Z",
    "device_name": "Work Laptop - John",
    "status": "active",
    "activations_used": 1,
    "activation_limit": 3,
    "remaining_activations": 2
  },
  "message": "License activated successfully"
}
```

**错误响应**:
```json
{
  "success": false,
  "errors": [
    {
      "field": "license_key",
      "message": "Maximum activation limit reached",
      "code": "LIMIT_REACHED"
    }
  ]
}
```

### 5. 反激活许可证

**请求**:
```http
DELETE /api/v1/activations/{activation_id}
Authorization: Bearer <token>
```

**响应**:
```json
{
  "success": true,
  "message": "License deactivated successfully",
  "data": {
    "activation_id": 456,
    "freed_slot": true,
    "remaining_slots": 2
  }
}
```

### 6. 检查许可证过期状态

**请求**:
```http
POST /api/v1/licenses/check-expiration
Content-Type: application/json

{
  "license_key": "LIC-2026-A3F9-KL82"
}
```

**响应**:
```json
{
  "is_expired": false,
  "days_until_expiration": 358,
  "in_grace_period": false,
  "grace_days_remaining": null,
  "expiration_date": "2027-04-01",
  "should_show_renewal_prompt": true
}
```

### 7. 获取激活历史记录

**请求**:
```http
GET /api/v1/licenses/{license_id}/activations?page=1&limit=50
Authorization: Bearer <token>
```

**响应**:
```json
{
  "success": true,
  "data": {
    "activations": [
      {
        "id": 456,
        "device_name": "Work Laptop - John",
        "device_os": "Windows 11",
        "ip_address": "192.168.1.100",
        "user_agent": "Mozilla/5.0...",
        "activated_at": "2026-04-08T13:30:00Z",
        "last_active": "2026-04-08T14:00:00Z",
        "status": "active"
      },
      {
        "id": 455,
        "device_name": "Old Desktop",
        "device_os": "Windows 10",
        "ip_address": "192.168.1.50",
        "activated_at": "2026-04-01T09:00:00Z",
        "last_active": "2026-04-05T10:00:00Z",
        "status": "inactive"
      }
    ],
    "meta": {
      "total": 2,
      "page": 1,
      "per_page": 50
    }
  }
}
```

---

## 🎨 Webhooks

### 实时事件通知

当许可证状态发生变化时，系统会向配置的 webhook URL 发送通知。

#### 可用事件类型

| 事件 | 触发时机 |
|------|---------|
| `license.created` | 许可证创建 |
| `license.activated` | 成功激活 |
| `license.deactivated` | 反激活 |
| `license.expired` | 过期 |
| `license.renewed` | 续订 |
| `license.cancelled` | 取消 |
| `activation.limit_reached` | 达到激活限制 |
| `payment.failed` | 支付失败 |

#### Webhook 签名验证

每次 webhook 请求都带有 `X-License-Signature` 头，用于验证请求真实性：

```php
$signature = $_SERVER['HTTP_X_LICENSE_SIGNATURE'];
$payload = file_get_contents('php://input');
$secret = getenv('LICENSE_WEBHOOK_SECRET');

$expected = hash_hmac('sha256', $payload, $secret);

if ($signature !== $expected) {
  http_response_code(401);
  exit('Invalid signature');
}
```

---

## ⚠️ 错误代码参考

| 错误码 | HTTP 状态 | 说明 |
|--------|----------|------|
| INVALID_KEY | 400 | 无效的许可证密钥 |
| LICENSE_EXPIRED | 403 | 许可证已过期 |
| LIMIT_REACHED | 403 | 达到激活次数限制 |
| DEVICE_LIMIT | 403 | 设备数量超限 |
| NOT_FOUND | 404 | 资源不存在 |
| UNAUTHORIZED | 401 | 未授权访问 |
| RATE_LIMITED | 429 | 请求频率过高 |

---

## 🧪 测试环境

### Sandbox Mode

在沙盒环境中测试 API：

```http
POST /api/v1/sandbox/enable?api_key=<test_key>
```

所有操作不会持久化到生产数据。

### Mock 响应

```json
{
  "success": true,
  "sandbox_mode": true,
  "message": "Test environment enabled"
}
```

---

## 📞 技术支持

遇到问题？联系开发团队：

- **Email**: support@yourcompany.com
- **Slack**: #license-support
- **Status Page**: status.yourcompany.com

---

*API 版本：v1.0 | 最后更新：2026-04-08*
