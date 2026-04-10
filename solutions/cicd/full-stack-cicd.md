# 💼 Drupal 11 完整 CI/CD 解决方案

**版本**: v1.0  
**Drupal**: 11.x  
**目标**: 端到端 CI/CD 解决方案

---

## 🏗️ 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Development                              │
│  Developer → Git Repository → Pull Request                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Continuous Integration (CI)                    │
│  1. Validate: Code Quality                                  │
│  2. Build: Dependencies & Assets                            │
│  3. Test: Unit & Functional Tests                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│            Preview Environment (Ephemeral)                  │
│  Deploy temporary environment for review                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Continuous Deployment (CD)                     │
│  1. Deploy to Staging (auto/manual)                         │
│  2. Deploy to Production (manual approval)                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 Monitoring & Rollback                       │
│  Monitor → Alert → Rollback if needed                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 完整目录结构

```
my-drupal-project/
├── .gitlab-ci.yml              # GitLab CI/CD 配置
├── .github/workflows/
│   └── ci-cd.yml               # GitHub Actions 配置
├── composer.json               # Composer 配置
├── scripts/
│   ├── deploy.sh              # 部署脚本
│   ├── fail-safe-deploy.sh    # 错误恢复脚本
│   └── quick-start.sh         # 快速启动脚本
├── tests/
│   ├── ci-integration-test.php # 集成测试
│   └── functional/            # 功能测试
├── config/
│   └── sync/                  # 配置同步目录
├── .env.example              # 环境变量模板
├── .gitignore
└── README.md
```

---

## 🚀 部署脚本

### 1. 基本部署脚本

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

DRUPAL_ROOT="${DRUPAL_ROOT:-$(pwd)}"
DEPLOY_ENV="${1:-staging}"
DRUSH="$DRUPAL_ROOT/vendor/bin/drush"

deploy_drupal() {
  local env=$1
  
  echo "Deploying to $env environment..."
  
  # 正确的命令顺序
  $DRUSH updatedb --strict=0 -y || exit 1
  $DRUSH cache:rebuild || exit 1
  $DRUSH config:import -y || exit 1
  $DRUSH cache:rebuild || exit 1
  
  echo "Deployment to $env completed successfully!"
}

deploy_drupal "$DEPLOY_ENV"
```

### 2. 错误恢复脚本

```bash
#!/bin/bash
# scripts/fail-safe-deploy.sh

MAX_RETRIES=3
DEPLOY_COUNT=0

while [ $DEPLOY_COUNT -lt $MAX_RETRIES ]; do
  DEPLOY_COUNT=$((DEPLOY_COUNT + 1))
  
  if deploy_drupal; then
    echo "✅ Deployment successful!"
    break
  else
    echo "❌ Deployment failed, retrying ($DEPLOY_COUNT/$MAX_RETRIES)..."
    
    if [ $DEPLOY_COUNT -eq $MAX_RETRIES ]; then
      echo "❌ All retry attempts failed"
      exit 1
    fi
    
    sleep 30
  fi
done
```

---

## 🧪 测试策略

### 1. 单元测试

```bash
vendor/bin/phpunit --testsuite=unit
vendor/bin/phpunit --testsuite=unit --coverage-text --coverage-clover=coverage.xml
```

### 2. 功能测试

```bash
vendor/bin/phpunit --testsuite=functional
```

### 3. 代码质量

```bash
vendor/bin/phpcs --standard=Drupal,DrupalPractice web/modules/custom
vendor/bin/phpstan analyse web/modules/custom --level=max
composer audit --no-dev
```

---

## 🔒 安全最佳实践

### 1. 密钥管理

```yaml
# GitLab CI
variables:
  SSH_KEY_PATH: $CI_PRIVATE_KEY

# GitHub Actions
SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

### 2. 环境变量安全

```bash
# .env.example
DB_PASSWORD=${CI_DB_PASSWORD}

# ❌ 不要硬编码
# DB_PASSWORD="secret123"

# ✅ 正确做法
DB_PASSWORD="$CI_DB_PASSWORD"
```

---

## 📊 监控和日志

### 1. 部署日志

```bash
# 日志文件
/var/www/html/logs/deploy-YYYYMMDD-HHMMSS.log

# 记录日志
echo "[$(date)] Deployment started" >> $LOG_FILE
```

### 2. 指标收集

```bash
# 收集部署时间
START_TIME=$(date +%s)
# ... deployment steps
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
```

---

## 🐛 故障排查

### 常见问题

1. **数据库更新失败**: 检查数据库连接和权限
2. **配置导入冲突**: 使用 `config:compare` 比较配置
3. **缓存清除失败**: 清除 Symfony 缓存
4. **Composer 安装失败**: 清理缓存并重试

### 诊断步骤

```bash
drush status
drush status --db-status
drush config:status
tail -f /var/www/html/web/sites/default/files/logs/dblog.txt
```

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**维护者**: Gates (OpenClaw)
