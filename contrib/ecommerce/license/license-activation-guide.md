# Commerce License - 激活管理指南

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 概述

本文档提供完整的许可证激活管理流程指南，涵盖管理员操作、用户自助服务、批量分配等场景。

### 适用读者

- **系统管理员**: 负责许可证分配和管理
- **技术支持**: 处理激活问题
- **最终用户**: 激活自己的许可证
- **开发者**: 集成激活功能

---

## 🎯 核心概念

### 许可证生命周期

```
Pending (待分配) 
    ↓
[分配给用户]
    ↓
Active (已激活)
    ├── [使用期间...]
    ├── ↓ [过期] → Grace Period (宽限期)
    ├── ↓ [续费成功] → Active
    └── ↓ [反激活] → Inactive
```

### 激活限制模型

| 限制类型 | 说明 | 示例 |
|---------|------|------|
| **激活次数** | 最多可激活 N 次 | "激活 3 台设备" |
| **并发设备数** | 同一时间最多绑定 N 台设备 | "同时在线 2 台" |
| **用户绑定** | 只能由特定用户使用 | "仅限购买者" |
| **IP 限制** | 从特定 IP 范围激活 | "仅限企业网络" |

---

## 👤 用户激活流程

### 场景 1: 首次激活（邮箱获取密钥）

**步骤**:

1. **购买产品**
   - 用户在商店完成支付
   - 系统生成许可证并关联订单

2. **接收邮件**
   ```
   主题：您的软件许可证
   内容：
   您好 [姓名],
   
   感谢您购买 [产品名称]!
   
   许可证密钥：LIC-2026-A3F9-KL82
   激活次数：3 次
   有效期至：2027-04-01
   
   [激活许可证] https://yourstore.com/licenses/activate
   ```

3. **访问激活页面**
   ```
   /licenses/activate
   ```

4. **填写信息**
   ```
   许可证密钥：LIC-2026-A3F9-KL82
   账户邮箱：user@example.com
   密码：(如有账号则登录，无则注册)
   设备名称：Work Laptop
   ```

5. **提交激活**
   - 验证密钥有效性
   - 检查激活次数
   - 创建激活记录
   - 发送确认邮件

6. **下载软件/获取下载链接**

### 场景 2: 试用版激活

**区别点**:

- 试用期通常为 14-30 天
- 无需支付即可获取密钥
- 到期前会自动提醒续费
- 可能包含水印或功能限制

```yaml
trial_settings:
  duration_days: 30
  watermark_enabled: true
  feature_limitations:
    - export_to_pdf
    - batch_processing
  reminder_schedule:
    - days_before_expiry: 7
    - days_before_expiry: 3
    - days_before_expiry: 1
```

### 场景 3: 企业批量激活

**流程**:

1. **管理员上传 CSV**
   ```csv
   email,first_name,last_name,license_type,department
   john@example.com,John,Doe,Enterprise,IT
   jane@example.com,Jane,Smith,Professional,HR
   ```

2. **系统生成许可证**
   - 根据每行分配对应类型的许可证
   - 批量创建激活记录

3. **邮件分发**
   - 每个用户收到自己的许可证
   - 包含专属激活链接

4. **用户自行激活**
   - 点击邮件中的链接
   - 跳转到激活页面（已预填邮箱）
   - 输入密钥完成激活

---

## 🔧 管理员操作

### 1. 手动激活许可证

当自动激活失败时，管理员可介入：

**路径**: `/admin/commerce/licenses`

**步骤**:
```
1. 查找许可证：通过 key 或 customer_id
2. 点击进入详情页
3. 选择 "Force Activate"
4. 填写激活信息:
   - 用户 ID
   - 设备名称
   - IP 地址
5. 添加备注原因
6. 保存
```

**权限要求**: `administer license activations`

### 2. 批量重新分配许可证

当用户更换设备或离职时：

```bash
# Drush 命令方式
drush license:reassign \
  --license-key LIC-2026-A3F9-KL82 \
  --new-user 123 \
  --reason "Employee terminated" \
  --admin-note "Transfer to new developer"
```

**UI 方式**:
```
/admin/commerce/licenses/[id]/transfer
→ 选择新用户
→ 选择是否保留激活历史
→ 确认转移
```

### 3. 临时延长许可证有效期

适用于客户延期付款的情况：

```http
PATCH /api/v1/licenses/{id}
Content-Type: application/json
Authorization: Bearer <token>

{
  "action": "extend_grace_period",
  "extension_days": 7,
  "reason": "Payment processing delay",
  "auto_extend_enabled": false
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "new_expiration": "2026-04-15T23:59:59Z",
    "grace_period_end": "2026-04-10T23:59:59Z",
    "extended_by_days": 7
  }
}
```

### 4. 强制反激活（安全事件）

检测到异常使用时：

```http
POST /api/v1/licenses/{id}/force-deactivate
Content-Type: application/json
Authorization: Bearer <token>

{
  "reason": "Suspected unauthorized use",
  "notify_user": true,
  "block_all_devices": true,
  "notification_message": "Your license has been suspended due to suspicious activity. Contact support."
}
```

**注意**: 此操作会立即禁用该许可证的所有活动，用户无法再使用。

### 5. 撤销许可证密钥

如果密钥泄露到公共论坛：

```bash
# 吊销整个批次
drush license:invalidate-batch BATCH_20260408_1A2B3C

# 或者针对单个密钥
drush license:revoke LIC-2026-A3F9-KL82 --replacement-new-keys 10
```

---

## 🔍 激活诊断工具

### 检查激活状态

```bash
# 通过密钥查询
drush license:info LIC-2026-A3F9-KL82

# 输出示例：
License Key: LIC-2026-A3F9-KL82
Status: Active
Product: Pro Software Suite v2.0
Activation Limit: 3
Activations Used: 1
Max Devices: 2
Devices Used: 1
Issued: 2026-04-01 10:30:00
Expires: 2027-04-01 10:30:00
Customer: user@example.com
Order ID: 12345
Last Activated: 2026-04-08 13:30:00
Current Device: Work Laptop - Windows 11
```

### 查看激活历史

```bash
drush license:activations LIC-2026-A3F9-KL82 --history

# 输出：
Date                  Device                IP Address           Status
--------------------------------------------------------------------------------
2026-04-08 13:30:00   Work Laptop           192.168.1.100        Active
2026-04-01 09:15:00   Test Desktop          192.168.1.50         Deactivated
```

### 诊断激活失败

```bash
drush license:diagnose LIC-2026-A3F9-KL82 --user 456

# 可能的问题提示：
⚠️ Maximum activation limit reached (3/3)
💡 Suggestion: Deactivate an old device or contact admin
```

---

## 📱 移动端激活

### iOS/Android App 集成

```swift
// Swift 示例代码
func activateLicense(key: String, completion: @escaping (Result<ActivationStatus, Error>) -> Void) {
    // 1. 收集设备信息
    let deviceInfo = [
        "device_name": UIDevice.current.name,
        "device_os": "iOS \(UIDevice.current.systemVersion)",
        "mac_address": getDeviceMacAddress()
    ]
    
    // 2. 调用激活 API
    let endpoint = "https://api.yourcompany.com/api/v1/licenses/activate"
    
    AF.post(endpoint, parameters: [
        "license_key": key,
        "device_info": deviceInfo
    ]).responseJSON { response in
        switch response.result {
        case .success(let value):
            let status = ActivationStatus(from: value)
            completion(.success(status))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
```

### 桌面客户端集成

```javascript
// Electron.js 示例
const { BrowserWindow } = require('electron');

async function activateInClient(licenseKey) {
  const result = await fetch('https://api.yourcompany.com/api/v1/licenses/activate', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
      license_key: licenseKey,
      device_info: {
        device_name: process.platform + ' ' + os.hostname(),
        device_os: process.version,
        mac_address: await getMacAddress()
      }
    })
  });
  
  const data = await result.json();
  
  if (data.success) {
    saveActivationToElectronStorage(data.data);
    mainWindow.webContents.send('activation-success', data.data);
  } else {
    showErrorModal(data.errors);
  }
}
```

---

## ⚠️ 常见问题处理

### Q1: 用户说"我无法激活我的许可证"

**排查步骤**:

```
1. 验证密钥格式是否正确
   → 检查是否有空格或换行符

2. 检查许可证状态
   drush license:info KEY --status

3. 检查是否已到达激活上限
   → 查看 current_activations vs activation_limit

4. 检查是否过期
   → 查看 expires_at 字段

5. 检查是否与当前用户邮箱匹配
   → 如果是分配式许可证
```

### Q2: 如何帮助用户在多台设备上使用？

**方案 A - 清理旧设备**:
```
1. 登录用户账户
2. 访问 /my-licenses
3. 找到不使用的设备
4. 点击 "Deactivate"
5. 现在可以激活新设备
```

**方案 B - 管理员干预**:
```bash
# 移除所有旧激活
drush license:clear-activations LIC-KEY --keep-last 1

# 然后用户重新激活
```

### Q3: 用户购买了但没收到许可证邮件怎么办？

**找回流程**:

1. 进入 `/admin/commerce/orders/[order-id]`
2. 找到 License 商品项
3. 点击 "Resend License Email"
4. 或者手动生成密钥：

```bash
drush license:generate-for-order ORDER_ID --email user@email.com
```

---

## 🔐 安全最佳实践

### 1. 防止盗用

```yaml
security_settings:
  # IP 白名单
  ip_whitelist_enabled: true
  ip_whitelist_max_count: 5
  
  # 地理位置限制
  geo_blocking:
    enabled: true
    allowed_countries: ['US', 'CA', 'UK']
    blocked_countries: []
  
  # 激活冷却期
  activation_cooldown_hours: 24
  
  # 异常检测
  anomaly_detection:
    enable: true
    max_devices_per_day: 3
    alert_on_suspicious_activity: true
```

### 2. 监控可疑活动

```sql
-- 检测异常激活模式
SELECT uid, COUNT(*) as activation_count,
       GROUP_CONCAT(DISTINCT ip_address) as ips_used
FROM commerce_license_activation
WHERE activated_at >= DATE_SUB(NOW(), INTERVAL 1 DAY)
GROUP BY uid
HAVING activation_count > 5;

-- 发现跨国家快速激活
SELECT * FROM commerce_license_activation a
JOIN commerce_license l ON a.license_key_id = l.id
WHERE activated_at >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
AND ip_address NOT IN ('已知合法 IP')
ORDER BY activated_at DESC;
```

### 3. 定期审计

```bash
# 每周生成审计报告
drush license:audit-report \
  --date-from "$(date -d '7 days ago' +%Y-%m-%d)" \
  --format=html \
  --output=/var/reports/license-audit-$(date +%Y%m%d).html

# 报告包含:
# - 激活总量统计
# - 异常激活标识
# - 即将过期列表
# - 未使用的许可证
```

---

## 📊 报表和指标

### 管理员仪表盘指标

| 指标 | 计算公式 | 告警阈值 |
|------|---------|---------|
| **平均激活设备数** | SUM(devices_used)/COUNT(licenses) | > 3.0 |
| **未激活许可证率** | Pending/COUNT(licenses) | > 10% |
| **超额激活警告** | Activations ≥ Limits | > 5 个 |
| **即将过期数量** | Expires in < 7 days | > 100 |

### 导出报表

```bash
# CSV 格式
drush license:export \
  --format=csv \
  --fields=key,status,expires_at,activations_used \
  --output=licenses-export-202604.csv

# Excel 格式（需要 phpspreadsheet）
drush license:export \
  --format=xlsx \
  --with-charts \
  --output=license-summary.xlsx
```

---

*最后更新：2026-04-08 | 版本：v1.0*
