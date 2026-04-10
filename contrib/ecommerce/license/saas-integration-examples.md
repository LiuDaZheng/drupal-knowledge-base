# Commerce License - SaaS 集成示例

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 概述

本文档提供完整的 SaaS（Software as a Service）集成代码示例，展示如何将 Drupal Commerce License 模块与各种 SaaS 平台、API 和前端框架进行集成。

### 适用场景

- **自托管软件** + 云服务订阅
- **多租户应用**许可证管理
- **混合云部署**验证机制
- **微服务架构**中的许可证服务
- **第三方平台**集成（Slack, Teams 等）

---

## 🏗️ 架构模式

### 推荐架构：许可证作为独立微服务

```
┌─────────────┐      ┌──────────────────┐      ┌──────────────┐
│   Frontend  │      │   License Micro  │      │   Backend    │
│   (React)   │◄────►│     Service      │◄────►│  (Drupal)    │
│             │      │                  │      │              │
└─────────────┘      └──────────────────┘      └──────────────┘
       ▲                      │                        │
       │                      ▼                        ▼
       │              ┌──────────────┐          ┌──────────────┐
       │              │  PostgreSQL  │          │  Redis Cache │
       │              │  (Primary)   │          │              │
       │              └──────────────┘          └──────────────┘
       │                      │
       │                      ▼
       │              ┌──────────────┐
       │              │   Stripe/    │
       │              │   Payment    │
       │              └──────────────┘
       │
       ▼
┌─────────────┐
│  Email/NLP  │
│  Notification│
└─────────────┘
```

---

## 💻 集成示例

### 示例 1: React 前端完整集成

#### LicenseManager Hook

```jsx
// src/hooks/useLicenseManager.js
import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';

const API_BASE_URL = process.env.REACT_APP_LICENSE_API;

export function useLicenseManager() {
  const [licenseKey, setLicenseKey] = useState(localStorage.getItem('license_key') || '');
  const [isLicensed, setIsLicensed] = useState(false);
  const [validationStatus, setValidationStatus] = useState('checking'); // checking/valid/invalid/expired
  const [licenseData, setLicenseData] = useState(null);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  /**
   * 验证许可证
   */
  const validateLicense = useCallback(async (key, deviceId) => {
    try {
      setError(null);
      setValidationStatus('checking');

      const response = await fetch(`${API_BASE_URL}/api/v1/licenses/verify`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Device-ID': deviceId || generateDeviceId(),
        },
        body: JSON.stringify({
          license_key: key,
          product_id: 5, // 你的产品 ID
        }),
      });

      const data = await response.json();

      if (!data.success && !data.valid) {
        throw new Error(data.errors?.[0]?.message || 'Invalid license key');
      }

      setLicenseData(data.data);
      setIsLicensed(true);
      setValidationStatus('valid');
      
      // 缓存结果
      localStorage.setItem('license_key', key);
      localStorage.setItem('last_validation', Date.now().toString());
      localStorage.setItem('license_data', JSON.stringify(data.data));

      return true;
    } catch (err) {
      console.error('License validation failed:', err);
      setError(err.message);
      setValidationStatus('invalid');
      return false;
    }
  }, []);

  /**
   * 检查许可证状态（自动从缓存恢复或重新验证）
   */
  const checkLicenseStatus = useCallback(async () => {
    const cachedKey = localStorage.getItem('license_key');
    const lastCheck = parseInt(localStorage.getItem('last_validation') || '0');
    
    // 如果缓存有效（7 天内），直接使用
    if (cachedKey && Date.now() - lastCheck < 7 * 24 * 60 * 60 * 1000) {
      const cachedData = localStorage.getItem('license_data');
      if (cachedData) {
        const data = JSON.parse(cachedData);
        if (!isExpired(data.expiration_date)) {
          setLicenseData(data);
          setIsLicensed(true);
          setValidationStatus('valid');
          return true;
        }
      }
    }

    // 需要重新验证
    if (cachedKey) {
      return validateLicense(cachedKey);
    }

    setValidationStatus('expired');
    return false;
  }, [validateLicense]);

  /**
   * 激活新许可证
   */
  const activateLicense = useCallback(async (key, deviceName) => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/v1/licenses/activate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${getAuthToken()}`,
        },
        body: JSON.stringify({
          license_key: key,
          device_name: deviceName || getDeviceName(),
        }),
      });

      const data = await response.json();

      if (!data.success) {
        throw new Error(data.errors?.[0]?.message || 'Activation failed');
      }

      // 保存激活信息
      localStorage.setItem('activation_id', data.data.activation_id);
      localStorage.setItem('activated_at', Date.now().toString());

      return true;
    } catch (err) {
      setError(err.message);
      return false;
    }
  }, []);

  /**
   * 反激活设备
   */
  const deactivateLicense = useCallback(async (activationId) => {
    try {
      const response = await fetch(
        `${API_BASE_URL}/api/v1/activations/${activationId}`,
        {
          method: 'DELETE',
          headers: {
            'Authorization': `Bearer ${getAuthToken()}`,
          },
        }
      );

      const data = await response.json();

      if (!data.success) {
        throw new Error('Deactivation failed');
      }

      return true;
    } catch (err) {
      setError(err.message);
      return false;
    }
  }, []);

  /**
   * 续订许可证
   */
  const renewLicense = useCallback(async () => {
    try {
      const response = await fetch(
        `${API_BASE_URL}/api/v1/licenses/renew`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${getAuthToken()}`,
            'Content-Type': 'application/json',
          },
        }
      );

      const data = await response.json();

      if (!data.success) {
        throw new Error(data.message || 'Renewal failed');
      }

      // 更新本地数据
      setLicenseData(data.data);
      localStorage.setItem('last_validation', Date.now().toString());

      return true;
    } catch (err) {
      setError(err.message);
      return false;
    }
  }, []);

  // 首次加载时检查许可证
  useEffect(() => {
    if (!licenseKey) return;

    checkLicenseStatus();
  }, [licenseKey, checkLicenseStatus]);

  return {
    licenseKey,
    setLicenseKey,
    isLicensed,
    validationStatus,
    licenseData,
    error,
    validateLicense,
    activateLicense,
    deactivateLicense,
    renewLicense,
    refreshStatus: checkLicenseStatus,
  };
}

// 辅助函数
function generateDeviceId() {
  let id = localStorage.getItem('device_id');
  if (!id) {
    id = crypto.randomUUID();
    localStorage.setItem('device_id', id);
  }
  return id;
}

function getAuthToken() {
  return localStorage.getItem('auth_token') || '';
}

function isExpired(expirationDate) {
  return new Date(expirationDate) < new Date();
}

function getDeviceName() {
  if (navigator.webdriver) return 'Automated Test';
  return `${navigator.platform} ${navigator.userAgent}`.substring(0, 100);
}
```

#### LicenseActivationForm 组件

```jsx
// src/components/LicenseActivationForm.jsx
import React, { useState } from 'react';
import { useLicenseManager } from '../hooks/useLicenseManager';
import './LicenseActivationForm.css';

export function LicenseActivationForm({ onSuccess }) {
  const [key, setKey] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  const { activateLicense, validateLicense } = useLicenseManager();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      // 第一步：验证密钥
      const isValid = await validateLicense(key.trim());
      
      if (!isValid) {
        setError('Invalid license key. Please check and try again.');
        setLoading(false);
        return;
      }

      // 第二步：激活
      const deviceName = `${navigator.platform} (${new Date().toLocaleDateString()})`;
      const activated = await activateLicense(key.trim(), deviceName);

      if (activated) {
        onSuccess?.({ key: key.trim() });
      } else {
        setError('Failed to activate license. Please contact support.');
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="license-activation-form">
      <h2>Activate Your License</h2>
      
      {error && (
        <div className="alert alert-error">
          {error}
          <button onClick={() => setError(null)}>&times;</button>
        </div>
      )}

      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="license-key">License Key</label>
          <input
            type="text"
            id="license-key"
            value={key}
            onChange={(e) => setKey(e.target.value)}
            placeholder="LIC-2026-XXXX-XXXX"
            disabled={loading}
            required
          />
          <small>Enter the license key you received via email</small>
        </div>

        <button 
          type="submit" 
          className={`btn btn-primary ${loading ? 'loading' : ''}`}
          disabled={loading || !key.trim()}
        >
          {loading ? (
            <>
              <span className="spinner"></span>
              Activating...
            </>
          ) : (
            'Activate License'
          )}
        </button>
      </form>

      <div className="activation-hints">
        <p><strong>Don't have a license?</strong> <a href="/purchase">Purchase now</a></p>
        <p>Need help? <a href="/support/contact">Contact Support</a></p>
      </div>
    </div>
  );
}

export default LicenseActivationForm;
```

#### LicenseDashboard 组件

```jsx
// src/components/LicenseDashboard.jsx
import React from 'react';
import { useLicenseManager } from '../hooks/useLicenseManager';
import { formatDistanceToNow } from 'date-fns';

export function LicenseDashboard() {
  const { 
    licenseData, 
    validationStatus, 
    deactivateLicense, 
    renewLicense,
    setLicenseKey,
    refreshStatus 
  } = useLicenseManager();

  if (validationStatus === 'checking') {
    return <div className="loading">Checking license status...</div>;
  }

  if (validationStatus === 'invalid' || validationStatus === 'expired') {
    return (
      <div className="license-expired">
        <h2>License Required</h2>
        <p>Your license has expired or is invalid. Please activate or renew.</p>
        <button onClick={() => setLicenseKey('')} className="btn btn-secondary">
          Activate New License
        </button>
      </div>
    );
  }

  if (!licenseData) {
    return null;
  }

  return (
    <div className="license-dashboard">
      <header className="dashboard-header">
        <h1>License Management</h1>
        <div className={`status-badge ${validationStatus}`}>
          {validationStatus === 'valid' && '✓ Licensed'}
          {validationStatus === 'expired' && '⚠ Expired'}
          {validationStatus === 'in_grace' && '⏰ In Grace Period'}
        </div>
      </header>

      <div className="license-details-card">
        <div className="license-key-display">
          <label>License Key</label>
          <code>{licenseData.license_key}</code>
          <button 
            className="btn-copy"
            onClick={() => navigator.clipboard.writeText(licenseData.license_key)}
          >
            Copy
          </button>
        </div>

        <table className="info-table">
          <tbody>
            <tr>
              <th>Product</th>
              <td>{licenseData.product_name}</td>
            </tr>
            <tr>
              <th>Owner</th>
              <td>{licenseData.owner_email}</td>
            </tr>
            <tr>
              <th>Issued</th>
              <td>{formatDistanceToNow(new Date(licenseData.issued_date), { addSuffix: true })}</td>
            </tr>
            <tr>
              <th>Expires</th>
              <td>
                {new Date(licenseData.expiration_date).toLocaleDateString()}
                <br/>
                {formatDistanceToNow(new Date(licenseData.expiration_date), { addSuffix: true })}
              </td>
            </tr>
            <tr>
              <th>Features</th>
              <td>
                <ul className="features-list">
                  {licenseData.features.map((feature, idx) => (
                    <li key={idx}>{feature}</li>
                  ))}
                </ul>
              </td>
            </tr>
            <tr>
              <th>Activations</th>
              <td>
                {licenseData.activations_used} / {licenseData.activation_limit}
                {licenseData.activations_remaining > 0 && (
                  <span className="remaining">
                    ({licenseData.activations_remaining} remaining)
                  </span>
                )}
              </td>
            </tr>
          </tbody>
        </table>

        <div className="actions">
          <button 
            className="btn btn-secondary"
            onClick={() => window.open(`/licenses/${licenseData.id}/renew`, '_blank')}
          >
            🔁 Renew License
          </button>
          
          <button 
            className="btn btn-outline-danger"
            onClick={() => handleDeactivate()}
            disabled={licenseData.activations_used <= 1}
          >
            ❌ Deactivate
          </button>

          <button 
            className="btn btn-link"
            onClick={refreshStatus}
          >
            Refresh Status
          </button>
        </div>
      </div>
    </div>
  );
}

function handleDeactivate() {
  // 实际实现会调用 API
  if (window.confirm('Deactivating will free up an activation slot. Continue?')) {
    // 执行反激活逻辑
  }
}

export default LicenseDashboard;
```

---

### 示例 2: Electron 桌面应用集成

```javascript
// main.js (Electron Main Process)
const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
  });

  mainWindow.loadFile(path.join(__dirname, 'renderer/index.html'));
}

// 许可证管理服务
class LicenseService {
  constructor() {
    this.cachePath = path.join(app.getPath('appData'), 'your-app', 'license_cache.json');
    this.offlineKeyPath = path.join(app.getPath('appData'), 'your-app', 'offline_license.key');
  }

  async validateOnline() {
    const licenseKey = this.getStoredKey();
    if (!licenseKey) return { valid: false, reason: 'no_key' };

    try {
      const response = await fetch('https://api.yourstore.com/api/v1/licenses/verify', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Device-ID': this.getDeviceId(),
        },
        body: JSON.stringify({
          license_key: licenseKey,
          product_id: 5,
        }),
      });

      const data = await response.json();

      if (data.valid) {
        this.cacheValidationResult(data.data);
        return { valid: true, data: data.data };
      }

      return { valid: false, reason: data.reason, details: data };
    } catch (error) {
      // 网络错误，尝试离线验证
      return this.validateOffline();
    }
  }

  validateOffline() {
    const offlineLicense = this.readOfflineLicense();
    
    if (!offlineLicense) {
      return { valid: false, reason: 'offline_missing' };
    }

    const now = Date.now() / 1000;
    if (now > offlineLicense.expires_at) {
      return { valid: false, reason: 'offline_expired', expires: offlineLicense.expires_at };
    }

    return {
      valid: true,
      offline_mode: true,
      expires_in_hours: Math.floor((offlineLicense.expires_at - now) / 3600),
    };
  }

  cacheValidationResult(data) {
    const cache = {
      ...data,
      cached_at: Date.now(),
    };

    fs.writeFileSync(this.cachePath, JSON.stringify(cache, null, 2));
  }

  readCachedResult() {
    try {
      if (!fs.existsSync(this.cachePath)) return null;

      const cache = JSON.parse(fs.readFileSync(this.cachePath, 'utf8'));
      
      // 检查缓存有效期（7 天）
      if (Date.now() - cache.cached_at > 7 * 24 * 60 * 60 * 1000) {
        return null;
      }

      // 检查是否过期
      if (cache.expiration_date && new Date(cache.expiration_date) < new Date()) {
        return null;
      }

      return cache;
    } catch (error) {
      console.error('Error reading cache:', error);
      return null;
    }
  }

  getStoredKey() {
    const keyPath = path.join(app.getPath('appData'), 'your-app', 'license_key.txt');
    if (!fs.existsSync(keyPath)) return null;
    return fs.readFileSync(keyPath, 'utf8').trim();
  }

  storeKey(key) {
    const dir = path.dirname(this.cachePath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

    fs.writeFileSync(path.join(app.getPath('appData'), 'your-app', 'license_key.txt'), key);
  }

  getDeviceId() {
    let deviceId = this.getConfig('device_id');
    if (!deviceId) {
      deviceId = crypto.randomUUID();
      this.setConfig('device_id', deviceId);
    }
    return deviceId;
  }

  getConfig(key) {
    const configPath = path.join(app.getPath('appData'), 'your-app', 'config.json');
    if (!fs.existsSync(configPath)) return null;
    
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    return config[key];
  }

  setConfig(key, value) {
    const configPath = path.join(app.getPath('appData'), 'your-app', 'config.json');
    let config = {};
    
    if (fs.existsSync(configPath)) {
      config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    }

    config[key] = value;
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  }

  readOfflineLicense() {
    if (!fs.existsSync(this.offlineKeyPath)) return null;
    
    const content = fs.readFileSync(this.offlineKeyPath, 'utf8').trim();
    const [encodedData, signature] = content.split(';;;');
    
    // 这里应该验证签名
    const data = JSON.parse(Buffer.from(encodedData, 'base64').toString('utf8'));
    return data;
  }

  generateOfflineLicense(licenseData) {
    const now = Date.now();
    const expiresAt = now + (30 * 24 * 60 * 60 * 1000); // 30 days
    
    const offlineData = {
      license_key: licenseData.key,
      product_id: licenseData.product_id,
      issued_at: now,
      expires_at: expiresAt,
      features: licenseData.features,
    };

    const json = JSON.stringify(offlineData);
    const encrypted = Buffer.from(json).toString('base64');
    
    // TODO: 使用 RSA 加密和签名
    const signature = 'SIGNATURE_PLACEHOLDER';
    
    const result = `${encrypted};;;${signature}`;
    
    const dir = path.dirname(this.offlineKeyPath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    
    fs.writeFileSync(this.offlineKeyPath, result);
    return result;
  }
}

// IPC Handlers
const licenseService = new LicenseService();

ipcMain.handle('validate-license', async () => {
  return licenseService.validateOnline();
});

ipcMain.handle('store-license-key', (event, key) => {
  licenseService.storeKey(key);
  return true;
});

ipcMain.handle('generate-offline-license', async (event, licenseData) => {
  return licenseService.generateOfflineLicense(licenseData);
});

ipcMain.handle('check-offline-license', () => {
  return licenseService.validateOffline();
});

app.whenReady().then(createWindow);
```

---

*更多集成示例将在后续更新...*
