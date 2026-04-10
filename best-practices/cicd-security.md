# 🔒 Drupal 11 CI/CD 安全配置

**版本**: v1.0  
**Drupal**: 11.x  
**目标**: 安全的 CI/CD 实践和配置

---

## 🔐 密钥管理最佳实践

### ❌ 错误做法

```yaml
# 不要硬编码在配置文件中
script:
  - SSH_KEY="-----BEGIN RSA PRIVATE KEY-----..."
  - ssh -i ~/.ssh/id_rsa user@server
```

### ✅ 正确做法

#### 1. GitLab CI 变量

```bash
# GitLab > Settings > CI/CD > Variables
SSH_PRIVATE_KEY: (encrypted value)
DB_PASSWORD: (encrypted value)
```

```yaml
# .gitlab-ci.yml
variables:
  SSH_KEY: $CI_PRIVATE_KEY
  DB_PASSWORD: $CI_DB_PASSWORD

script:
  - echo "$SSH_KEY" > ~/.ssh/id_rsa
  - chmod 600 ~/.ssh/id_rsa
  - ssh -i ~/.ssh/id_rsa user@server
```

#### 2. GitHub Actions Secrets

```bash
# Settings > Secrets and variables > Actions
SSH_PRIVATE_KEY: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----
DB_PASSWORD: (encrypted)
```

```yaml
# .github/workflows/ci-cd.yml
env:
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}

steps:
  - uses: appleboy/ssh-action@v1.0.0
    with:
      key: ${{ secrets.SSH_PRIVATE_KEY }}
```

---

## 🔑 SSH 密钥管理

### 1. 生成部署专用密钥

```bash
# 生成专用部署密钥
ssh-keygen -t ed25519 -C "deploy@drupal-ci" -f ~/.ssh/id_rsa_deploy
```

### 2. 限制 SSH 权限

```bash
# 在服务器上配置 ~/.ssh/authorized_keys
command="/usr/bin/drush",no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-ed25519 AAAA... ssh-deploy@drupal
```

---

## 🔒 安全审查

### 1. Composer 安全审计

```bash
# 运行安全审计
composer audit --no-dev

# 阻止有安全漏洞的安装
composer config secure-vectors true
```

---

## 📋 安全检查清单

### 部署前检查

```bash
# Agent 必须验证

# 1. 密钥安全
grep -r "password" scripts/ | grep -v ".git"  # 无明文密码

# 2. SSH 权限
stat ~/.ssh/id_rsa_deploy | grep "900"        # 密钥权限 900

# 3. 数据库连接
$DRUSH status --db-status --format=json | jq -r '.database'  # 加密连接

# 4. 文件权限
ls -la ../config/sync  # 755 权限
```

---

## 📊 安全指标

| 指标 | 目标值 | 监控方式 |
|------|--------|----------|
| 密钥轮换频率 | 90 天 | 自动提醒 |
| 安全审计通过率 | 100% | Composer audit |
| 未授权访问次数 | 0 | 日志分析 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**维护者**: Gates (OpenClaw)
