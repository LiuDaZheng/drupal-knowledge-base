#!/bin/bash
# scripts/quick-start.sh
# 一键搭建 Drupal 11 CI/CD 环境

set -e  # 遇错立即终止

echo "🚀 Starting Drupal 11 CI/CD Setup..."

# 1. 创建项目目录
PROJECT_DIR="${1:-$(pwd)/drupal-ci-test}"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "📁 项目目录：$PROJECT_DIR"
echo "🔄 开始安装 Drupal 11..."

# 2. 安装 Drupal 11（使用推荐模板）
composer create-project drupal/recommended-project:"$PROJECT_DIR" \
  --no-interaction --no-progress \
  -d "$PROJECT_DIR"

echo "✅ Drupal 11 installed"

# 3. 安装 Drush 13+
cd "$PROJECT_DIR/web"
composer require drush/drush:^13 --no-interaction --no-progress

echo "✅ Drush 13 installed"

# 4. 创建配置同步目录（必须在 docroot 外）
SYNC_DIR="$(dirname "$PROJECT_DIR")/config/sync"
mkdir -p "$SYNC_DIR"
chmod 755 "$SYNC_DIR"

echo "✅ Config sync directory created: $SYNC_DIR"

# 5. 配置 settings.php
cat >> sites/default/settings.php << 'EOF'

// 配置同步目录
$settings['config_sync_directory'] = '../config/sync';

// 环境标识
$settings['drupal.env'] = 'dev';
EOF

echo "✅ settings.php configured"

# 6. 创建 .gitlab-ci.yml 配置模板
cd "$PROJECT_DIR"
cat > .gitlab-ci.yml << 'EOF'
# GitLab CI 配置模板
# 复制自：ops/cicd-gitlab-ci.md

image: drupal:10.2-php8.3

variables:
  COMPOSER_MEMORY_LIMIT: -1
  PHP_MEMORY_LIMIT: 512M
  MYSQL_ROOT_PASSWORD: ${CI_MYSQL_ROOT_PASSWORD}
  MYSQL_DATABASE: ${CI_MYSQL_DATABASE}
  MYSQL_USER: ${CI_MYSQL_USER}
  MYSQL_PASSWORD: ${CI_MYSQL_PASSWORD}

stages:
  - validate
  - build
  - test
  - deploy

validate:code-quality:
  stage: validate
  script:
    - composer install --no-interaction --no-progress
    - vendor/bin/phpcs --standard=Drupal,DrupalPractice web/modules/custom
    - vendor/bin/phpstan analyse web/modules/custom --level=max
  only:
    - develop

build:dependencies:
  stage: build
  script:
    - composer install --no-dev --optimize-autoloader --no-interaction
  artifacts:
    paths:
      - vendor/
      - web/
    expire_in: 1 hour

test:unit:
  stage: test
  services:
    - mysql:8.0
  script:
    - composer install --no-interaction
    - vendor/bin/phpunit --testsuite=unit
  dependencies:
    - build:dependencies

deploy:staging:
  stage: deploy
 环境:
    name: staging
  script:
    - echo "部署到预发环境"
  only:
    - main
  when: manual
EOF

echo "✅ .gitlab-ci.yml created"

# 7. 创建 GitHub Actions 工作流
mkdir -p .github/workflows
cat > .github/workflows/ci-cd.yml << 'EOF'
# GitHub Actions 配置模板
# 复制自：ops/cicd-github-actions.md

name: Drupal 11 CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  validate:
    name: Validate & Build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          tools: composer:v2
      
      - name: Install Dependencies
        run: composer install --no-dev --optimize-autoloader --no-interaction
      
      - name: Run PHPCS
        run: vendor/bin/phpcs --standard=Drupal,DrupalPractice web/modules/custom
      
      - name: Run PHPStan
        run: vendor/bin/phpstan analyse web/modules/custom --level=max
      
      - name: Save Build Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: |
            vendor/
            web/
          retention-days: 7

  test:
    name: Test
    runs-on: ubuntu-latest
    needs: validate
    steps:
      - name: Download Build Artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
      
      - name: Run Unit Tests
        run: vendor/bin/phpunit --testsuite=unit

  deploy:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/develop'
    environment:
      name: staging
    steps:
      - name: Download Build Artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
      
      - name: Deploy
        run: echo "部署到预发环境"
EOF

echo "✅ GitHub Actions workflow created"

# 8. 创建部署脚本
mkdir -p scripts
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
# scripts/deploy.sh - Drupal 11 部署脚本（Agent 可安全运行）
# 用法：./scripts/deploy.sh [dev|staging|production]

set -e

DRUPAL_ROOT="${DRUPAL_ROOT:-$(pwd)}"
DEPLOY_ENV="${1:-staging}"
DRUSH="${DRUPAL_ROOT}/vendor/bin/drush"
LOG_FILE="${DRUPAL_ROOT}/logs/deploy-$(date +%Y%m%d-%H%M%S).log"

mkdir -p "${DRUPAL_ROOT}/logs"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
  log "❌ ERROR: $1"
  exit 1
}

log "🚀 开始部署到 $DEPLOY_ENV 环境"
log "📁 Drupal 根目录：$DRUPAL_ROOT"

case "$DEPLOY_ENV" in
  dev|testing)
    log "💡 部署到开发/测试环境"
    $DRUSH updatedb --strict=0 -y || error_exit "数据库更新失败"
    $DRUSH config:import -y || error_exit "配置导入失败"
    $DRUSH cache:rebuild || error_exit "缓存重建失败"
    ;;
  
  staging)
    log "⚠️ 部署到预发环境"
    $DRUSH updatedb --strict=0 -y || error_exit "数据库更新失败"
    $DRUSH config:import -y || error_exit "配置导入失败"
    $DRUSH cache:rebuild || error_exit "缓存重建失败"
    ;;
  
  production)
    log "🔒 部署到生产环境 - 需要确认!"
    $DRUSH updatedb --strict=0 --simulate -y || error_exit "数据库更新模拟失败"
    read -p "按回车键确认继续部署到生产环境：" confirm
    if [ "$confirm" != "" ]; then
      error_exit "部署已取消"
    fi
    $DRUSH updatedb --strict=0 -y || error_exit "数据库更新失败"
    $DRUSH config:import -y || error_exit "配置导入失败"
    $DRUSH cache:rebuild || error_exit "缓存重建失败"
    ;;
  
  *)
    error_exit "未知环境：$DEPLOY_ENV (可用：dev, staging, production)"
    ;;
esac

log "✅ 部署完成!")
log "📋 部署日志已保存：$LOG_FILE"
EOF
chmod +x scripts/deploy.sh

echo "✅ Deploy script created"

# 9. 创建错误恢复脚本
cat > scripts/fail-safe-deploy.sh << 'EOF'
#!/bin/bash
# scripts/fail-safe-deploy.sh - 带错误恢复的部署脚本

MAX_RETRIES=3
DEPLOY_COUNT=0
DEPLOY_ENV="${1:-staging}"

deploy_drupal() {
  echo "[INFO] Attempting Drupal deployment to $DEPLOY_ENV..."
  ./scripts/deploy.sh "$DEPLOY_ENV"
  return $?
}

while [ $DEPLOY_COUNT -lt $MAX_RETRIES ]; do
  DEPLOY_COUNT=$((DEPLOY_COUNT + 1))
  echo "[RETRY] Attempting deploy $DEPLOY_COUNT/$MAX_RETRIES to $DEPLOY_ENV"
  
  if deploy_drupal; then
    echo "[SUCCESS] Deploy successful!"
    break
  else
    echo "[ERROR] Deploy failed"
    
    if [ $DEPLOY_COUNT -eq $MAX_RETRIES ]; then
      echo "[CRITICAL] All retry attempts failed - manual intervention required"
      exit 1
    fi
    
    echo "[INFO] Retrying in 30 seconds..."
    sleep 30
  fi
done

echo "[ALL DONE] Deployment process completed"
EOF
chmod +x scripts/fail-safe-deploy.sh

echo "✅ Fail-safe deploy script created"

# 10. 创建环境变量模板
cat > .env.example << 'EOF'
# Drupal 11 CI/CD 环境变量配置
# 复制为 .env.ci 并填入实际值
# ⚠️ 不要将此文件提交到 Git!

# 服务器连接配置
DEV_SERVER=dev.example.com
DEV_USER=www-data
DEV_PATH=/var/www/html

STAGING_SERVER=staging.example.com
STAGING_USER=www-data
STAGING_PATH=/var/www/html

PROD_SERVER=www.example.com
PROD_USER=www-data
PROD_PATH=/var/www/html

# 数据库配置（CI 环境）
CI_DB_HOST=mysql
CI_DB_PORT=3306
CI_DB_NAME=drupal_ci
CI_DB_USER=drupal_user
CI_DB_PASSWORD=drupal_pass
EOF

echo "✅ Environment template created"

# 11. 创建测试脚本
mkdir -p tests
cat > tests/ci-integration-test.php << 'EOF'
<?php
/**
 * CI 集成测试 - Agent 可运行验证 Drupal 环境
 */

class CIIntegrationTest {
  
  private $drupal_root;
  private $errors = [];
  
  public function __construct() {
    $this->drupal_root = realpath(__DIR__ . '/../web');
  }
  
  public function runAllTests() {
    echo "🧪 Running CI Integration Tests...\n";
    echo "📁 Drupal Root: $this->drupal_root\n\n";
    
    $this->testDrupalCore();
    $this->testConfigSyncDirectory();
    $this->testComposerDependencies();
    
    if (empty($this->errors)) {
      echo "\n✅ All CI integration tests PASSED!\n";
      return true;
    } else {
      echo "\n❌ " . count($this->errors) . " test(s) FAILED:\n";
      foreach ($this->errors as $error) {
        echo "  - $error\n";
      }
      return false;
    }
  }
  
  private function testDrupalCore() {
    echo "[TEST] 1. Checking Drupal Core...\n";
    
    if (!file_exists($this->drupal_root . '/core/drupal.bootstrap.php')) {
      $this->errors[] = "Drupal core file not found";
      echo "  ❌ Drupal core not found\n";
      return;
    }
    
    echo "  ✅ Drupal core exists\n";
  }
  
  private function testConfigSyncDirectory() {
    echo "[TEST] 2. Checking Config Sync Directory...\n";
    
    $settings_content = file_get_contents($this->drupal_root . '/sites/default/settings.php');
    if (strpos($settings_content, 'config_sync_directory') !== false) {
      echo "  ✅ Config sync directory configured\n";
    } else {
      $this->errors[] = "Config sync directory not configured";
      echo "  ❌ Config sync directory not configured\n";
    }
  }
  
  private function testComposerDependencies() {
    echo "[TEST] 3. Checking Composer Dependencies...\n";
    
    $composer_json = $this->drupal_root . '/../composer.json';
    if (!file_exists($composer_json)) {
      $this->errors[] = "composer.json not found";
      echo "  ❌ composer.json not found\n";
      return;
    }
    
    $composer_data = json_decode(file_get_contents($composer_json), true);
    
    if (isset($composer_data['require']['drupal/core'])) {
      echo "  ✅ Drupal core installed\n";
    } else {
      $this->errors[] = "Drupal core not installed";
      echo "  ❌ Drupal core not installed\n";
    }
    
    if (isset($composer_data['require']['drush/drush'])) {
      echo "  ✅ Drush installed\n";
    } else {
      echo "  ⚠️  Drush not installed (recommended)\n";
    }
  }
}

// 执行测试
$test = new CIIntegrationTest();
$success = $test->runAllTests();

exit($success ? 0 : 1);
EOF

echo "✅ Integration test script created"

# 12. 创建 README.md
cat > README.md << 'README'
# 🚀 Drupal 11 CI/CD 实践指南

一套专为**Agent 实践**设计的 Drupal 11 CI/CD 配置和脚本。

## 🚀 快速开始

### 1. 一键初始化（推荐）

```bash
./scripts/quick-start.sh
```

### 2. 环境验证

```bash
php tests/ci-integration-test.php
```

### 3. 部署到环境

```bash
# 开发环境
./scripts/deploy.sh dev

# 预发环境（推荐）
./scripts/deploy.sh staging

# 生产环境（需要确认）
./scripts/deploy.sh production
```

## 📚 文档

- [`ops/cicd-agent-practices.md`](../../ops/cicd-agent-practices.md) - Agent 实践指南
- [`ops/cicd-gitlab-ci.md`](../../ops/cicd-gitlab-ci.md) - GitLab CI 配置
- [`ops/cicd-github-actions.md`](../../ops/cicd-github-actions.md) - GitHub Actions 配置
- [`solutions/cicd/full-stack-cicd.md`](../../solutions/cicd/full-stack-cicd.md) - 完整方案
- [`best-practices/cicd-security.md`](../../best-practices/cicd-security.md) - 安全配置

## 🔒 安全注意事项

- **不要**将 `.env.ci` 提交到 Git
- **不要**在脚本中硬编码密钥

## 📚 参考资源

- **官方文档**: https://www.drupal.org/docs
- **Drush 文档**: https://www.drush.org/manual/
- **GitLab CI 文档**: https://docs.gitlab.com/ee/ci/
- **GitHub Actions 文档**: https://docs.github.com/en/actions

---

**版本**: v1.0  
**Drupal**: 11.x  
**维护者**: Gates (OpenClaw)  
README

echo "✅ README.md created"

# 创建 .gitignore
cat > .gitignore << 'EOF'
# 不要提交环境变量
.env
.env.local
.env.*.local

# 配置同步目录（可选，根据策略）
# config/sync/*
!config/.gitkeep

# 上传目录
sites/*/files/*

# 本地开发配置
settings.local.php

# IDE
.vscode/
.idea/
*.swp
*.swo

# Logs
logs/
*.log

# 编辑器临时文件
*.tmp
*.temp
EOF

echo "✅ .gitignore created"

# 创建总结
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Drupal 11 CI/CD 环境搭建完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 项目位置：$PROJECT_DIR"
echo ""
echo "📋 已创建的文件："
echo ""
echo "📄 配置文件："
echo "  ✅ .gitlab-ci.yml              - GitLab CI 配置模板"
echo "  ✅ .github/workflows/ci-cd.yml - GitHub Actions 工作流"
echo "  ✅ .env.example                - 环境变量模板"
echo "  ✅ .gitignore                  - Git 忽略规则"
echo ""
echo "🔧 可执行脚本："
echo "  ✅ scripts/quick-start.sh      - 快速启动脚本"
echo "  ✅ scripts/deploy.sh           - 部署脚本"
echo "  ✅ scripts/fail-safe-deploy.sh - 错误恢复脚本"
echo ""
echo "🧪 测试脚本："
echo "  ✅ tests/ci-integration-test.php - 集成测试"
echo ""
echo "📝 文档："
echo "  ✅ README.md                   - 项目说明"
echo ""
echo "📚 参考文档（在 Drupal Knowledge Base 中）："
echo "  📄 ../ops/cicd-agent-practices.md"
echo "  📄 ../ops/cicd-gitlab-ci.md"
echo "  📄 ../ops/cicd-github-actions.md"
echo "  📄 ../solutions/cicd/full-stack-cicd.md"
echo "  📄 ../best-practices/cicd-security.md"
echo ""
echo "🎯 下一步："
echo ""
echo "1️⃣  复制环境变量模板："
echo "   cp .env.example .env.ci"
echo "   nano .env.ci  # 填入实际值"
echo ""
echo "2️⃣  导入 GitLab CI 变量："
echo "   GitLab > Settings > CI/CD > Variables"
echo ""
echo "3️⃣  运行集成测试："
echo "   php tests/ci-integration-test.php"
echo ""
echo "4️⃣  部署到环境："
echo "   ./scripts/deploy.sh staging"
echo ""
echo "🔒 安全提醒："
echo "  - 不要将 .env.ci 提交到 Git"
echo "  - 使用 GitLab/GitHub 的加密变量功能"
echo "  - 定期轮换 SSH 密钥和 API 令牌"
echo ""
