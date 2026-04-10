# 🔧 GitHub Actions 配置模板

**版本**: v1.0  
**Drupal**: 11.x  
**目标**: 生产级 GitHub Actions 配置模板（Agent 可直接复制使用）

---

## 📝 完整配置模板

```yaml
# .github/workflows/ci-cd.yml

name: Drupal 11 CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deploy to environment'
        required: true
        default: 'staging'
        type: choice
        options:
        - staging
        - production

permissions:
  contents: read

env:
  PHP_VERSION: '8.2'
  DB_NAME: drupal_test
  DB_USER: drupal_user
  DB_PASSWORD: drupal_pass

jobs:
  validate:
    name: Validate & Build
    runs-on: ubuntu-latest
    outputs:
      build_artifact_path: ${{ steps.artifacts.outputs.path }}
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ env.PHP_VERSION }}
          tools: composer:v2
          extensions: mysql, gd, intl
          ini-values: memory_limit=512M
          coverage: none
      
      - name: Cache Composer packages
        uses: actions/cache@v4
        with:
          path: vendor
          key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
          restore-keys: ${{ runner.os }}-composer-
      
      - name: Install Dependencies
        run: composer install --no-dev --optimize-autoloader --no-interaction
      
      - name: Run PHPCS
        run: |
          vendor/bin/phpcs --standard=Drupal,DrupalPractice web/modules/custom --report=checkstyle | tee reports/phpcs.xml
        continue-on-error: true
      
      - name: Run PHPStan
        run: vendor/bin/phpstan analyse web/modules/custom --level=max
      
      - name: Upload Build Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: |
            vendor/
            web/
          retention-days: 7

  test:
    name: Test (Unit & Functional)
    runs-on: ubuntu-latest
    needs: validate
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: test_root
          MYSQL_DATABASE: ${{ env.DB_NAME }}
          MYSQL_USER: ${{ env.DB_USER }}
          MYSQL_PASSWORD: ${{ env.DB_PASSWORD }}
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3
        ports:
          - 3306:3306
    
    steps:
      - name: Download Build Artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
      
      - name: Run Unit Tests
        run: vendor/bin/phpunit --testsuite=unit --coverage-text
      
      - name: Run Functional Tests
        run: |
          vendor/bin/drush site:install standard \
            --db-url=mysql://${{ env.DB_USER }}:${{ env.DB_PASSWORD }}@127.0.0.1/drupal_test \
            --account-name=admin \
            --account-pass=admin \
            -y
          vendor/bin/phpunit --testsuite=functional

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/develop'
    environment:
      name: staging
      url: https://staging.example.com
    
    steps:
      - name: Download Build Artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
      
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.STAGING_SERVER }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            cd /var/www/html
            rsync -avz --delete --exclude='.git' --exclude='sites/*/files' ./ ${{ github.workspace }}/
            ./vendor/bin/drush updatedb -y
            ./vendor/bin/drush config:import -y
            ./vendor/bin/drush cache:rebuild

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://www.example.com
    
    steps:
      - name: Download Build Artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
      
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.PROD_SERVER }}
          username: ${{ secrets.PROD_USER }}
          key: ${{ secrets.PROD_SSH_KEY }}
          script: |
            cd /var/www/html
            rsync -avz --delete --exclude='.git' --exclude='sites/*/files' ./ ${{ github.workspace }}/
            ./vendor/bin/drush updatedb -y
            ./vendor/bin/drush config:import -y
            ./vendor/bin/drush cache:rebuild
```

---

## 🔑 GitHub Secrets 配置

### 1. SSH 密钥

```bash
# Settings > Secrets and variables > Actions > Secrets
STAGING_SSH_PRIVATE_KEY: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----

PROD_SSH_PRIVATE_KEY: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----
```

### 2. Server 配置

```bash
# Settings > Variables
STAGING_SERVER: staging.example.com
STAGING_USER: www-data

PROD_SERVER: www.example.com
PROD_USER: www-data
```

---

## 🚀 手动触发部署

### 使用 workflow_dispatch

```yaml
workflow_dispatch:
  inputs:
    environment:
      description: 'Deploy target'
      required: true
      default: 'staging'
      type: choice
      options:
      - staging
      - production
```

### Actions 界面触发

1. 进入 Actions 标签
2. 选择 "Drupal 11 CI/CD Pipeline"
3. 点击 "Run workflow"
4. 选择分支和环境
5. 点击 "Run workflow"

---

## 🧪 本地调试

### 使用 act 工具

```bash
# 安装 act
brew tap homebrew/services
brew install act

# 运行工作流
act push -s PROD_SSH_PRIVATE_KEY=$(cat ~/.ssh/id_rsa)
```

### 调试特定作业

```bash
act push --job validate
act push --job test
act push --job deploy-staging
```

---

## 📊 监控和日志

### 1. Workflow 日志

```bash
# 查看运行日志
gh run view RUN_ID --log
```

### 2. 性能分析

```yaml
- name: Performance Analysis
  run: |
    echo "Start: $(date +%s)"
    # ... deployment steps
    echo "End: $(date +%s)"
    echo "DURATION=$((END - START)) seconds"
```

---

## 🔒 安全最佳实践

### 1. 密钥管理

```yaml
# 使用 GitHub Secrets
env:
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
```

### 2. 最小权限

```yaml
permissions:
  contents: read
  # 不需要写入权限
```

### 3. 超时控制

```yaml
- name: Deploy
  uses: appleboy/ssh-action@v1.0.0
  with:
    timeout: 300s  # 5 分钟超时
```

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**维护者**: Gates (OpenClaw)
