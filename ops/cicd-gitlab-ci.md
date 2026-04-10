# 🔧 GitLab CI 配置模板

**版本**: v1.0  
**Drupal**: 11.x  
**目标**: 生产级 GitLab CI 配置模板（Agent 可直接复制使用）

---

## 📝 完整配置模板

```yaml
# .gitlab-ci.yml - 生产级配置模板

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

# 验证阶段
validate:code-quality:
  stage: validate
  variables:
    PHPCS_STANDARD: Drupal,DrupalPractice
  script:
    - composer install --no-interaction --no-progress --prefer-dist
    - vendor/bin/phpcs --standard=Drupal,DrupalPractice web/modules/custom --report=checkstyle > reports/phpcs.xml
    - vendor/bin/phpstan analyse web/modules/custom --level=max --error-format=checkstyle > reports/phpstan.xml
    - composer audit --no-dev
  artifacts:
    reports:
      php_code_quality: reports/phpstan.xml
      code_quality: reports/phpcs.xml
      dependency_scanning: reports/sarif/dependency-scanning.sarif.json
  only:
    - develop
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == "develop"

# 构建阶段
build:dependencies:
  stage: build
  variables:
    COMPOSER_NO_INTERACTION: 1
    COMPOSER_OPTIMIZE_AUTOLOADER: 1
  script:
    - composer install --no-dev --optimize-autoloader
    - if [ -d "web/themes/custom" ]; then
        npm ci --prefix web/themes/custom;
        npm run build --prefix web/themes/custom;
      fi
  artifacts:
    paths:
      - vendor/
      - web/
    expire_in: 12 hours
  cache:
    key: "$CI_COMMIT_REF_SLUG"
    paths:
      - vendor/
      - node_modules/

# 单元测试
test:unit:
  stage: test
  services:
    - mysql:8.0
  variables:
    DB_URL: "mysql://${CI_MYSQL_USER}:${CI_MYSQL_PASSWORD}@mysql/${CI_MYSQL_DATABASE}"
  script:
    - composer install --no-interaction
    - vendor/bin/phpunit --testsuite=unit --coverage-text --coverage-clover=coverage/unit.xml
  dependencies:
    - build:dependencies
  artifacts:
    reports:
      code_coverage: coverage/unit.xml
    paths:
      - coverage/

# 功能测试
test:functional:
  stage: test
  services:
    - mysql:8.0
  variables:
    DB_URL: "mysql://${CI_MYSQL_USER}:${CI_MYSQL_PASSWORD}@mysql/${CI_MYSQL_DATABASE}"
  script:
    - composer install --no-interaction
    - vendor/bin/drush site:install standard \
        --db-url="$DB_URL" \
        --account-name=admin \
        --account-pass=admin \
        --site-name="CI Test" \
        --locale=en \
        -y
    - vendor/bin/phpunit --testsuite=functional --coverage-text --coverage-clover=coverage/functional.xml
  dependencies:
    - build:dependencies
  artifacts:
    reports:
      code_coverage: coverage/functional.xml
    paths:
      - coverage/

# 部署到开发环境
deploy:development:
  stage: deploy
  environment:
    name: development
    url: https://dev.example.com
  variables:
    SERVER_HOST: ${CI_DEV_SERVER}
    SERVER_USER: ${CI_DEV_USER}
    SERVER_PATH: ${CI_DEV_PATH}
  script:
    - apt-get update && apt-get install -y rsync openssh-client
    - rsync -avz --delete --exclude='.git' --exclude='sites/*/files' --exclude='sites/default/settings.php' . ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}
    - ssh ${SERVER_USER}@${SERVER_HOST} "
        cd ${SERVER_PATH} &&
        ./vendor/bin/drush updatedb --strict=0 -y &&
        ./vendor/bin/drush config:import -y &&
        ./vendor/bin/drush cache:rebuild &&
        ./vendor/bin/drush deploy:status
      "
  only:
    - develop
  when: on_success

# 部署到预发环境
deploy:staging:
  stage: deploy
  environment:
    name: staging
    url: https://staging.example.com
  variables:
    SERVER_HOST: ${CI_STAGING_SERVER}
    SERVER_USER: ${CI_STAGING_USER}
    SERVER_PATH: ${CI_STAGING_PATH}
  script:
    - apt-get update && apt-get install -y rsync openssh-client
    - rsync -avz --delete --exclude='.git' --exclude='sites/*/files' . ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}
    - ssh ${SERVER_USER}@${SERVER_HOST} "
        cd ${SERVER_PATH} &&
        ./vendor/bin/drush updatedb --strict=0 -y &&
        ./vendor/bin/drush config:import -y &&
        ./vendor/bin/drush cache:rebuild &&
        ./vendor/bin/drush deploy:status
      "
  when: manual
  only:
    - main

# 部署到生产环境
deploy:production:
  stage: deploy
  environment:
    name: production
    url: https://www.example.com
  variables:
    SERVER_HOST: ${CI_PROD_SERVER}
    SERVER_USER: ${CI_PROD_USER}
    SERVER_PATH: ${CI_PROD_PATH}
  script:
    - apt-get update && apt-get install -y rsync openssh-client
    - rsync -avz --delete --exclude='.git' --exclude='sites/*/files' . ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}
    - ssh ${SERVER_USER}@${SERVER_HOST} "
        cd ${SERVER_PATH} &&
        ./vendor/bin/drush updatedb --strict=0 -y &&
        ./vendor/bin/drush config:import -y &&
        ./vendor/bin/drush cache:rebuild &&
        ./vendor/bin/drush deploy:status
      "
  when: manual
  only:
    - main
  rules:
    - if: $CI_COMMIT_BRANCH == 'main' && $CI_MERGE_REQUEST_TARGET_BRANCH_NAME == 'main'
```

---

## 🔑 GitLab CI 变量配置

### 1. 数据库配置

```bash
# GitLab > Settings > CI/CD > Variables
CI_MYSQL_ROOT_PASSWORD: (加密值)
CI_MYSQL_DATABASE: drupal_ci
CI_MYSQL_USER: drupal_user
CI_MYSQL_PASSWORD: (加密值)
```

### 2. 服务器连接

```bash
# 开发环境
CI_DEV_SERVER: dev.example.com
CI_DEV_USER: www-data
CI_DEV_PATH: /var/www/html

# 预发环境
CI_STAGING_SERVER: staging.example.com
CI_STAGING_USER: www-data
CI_STAGING_PATH: /var/www/html

# 生产环境
CI_PROD_SERVER: www.example.com
CI_PROD_USER: www-data
CI_PROD_PATH: /var/www/html
```

### 3. SSH 密钥

```bash
# 为每个环境生成专用密钥
ssh-keygen -t ed25519 -C "deploy@prod" -f ~/.ssh/id_rsa_prod

# 添加到 GitLab 变量
CI_PROD_SSH_KEY: (SSH 公钥内容）
CI_STAGING_SSH_KEY: (SSH 公钥内容）
CI_DEV_SSH_KEY: (SSH 公钥内容）
```

---

## 🚀 GitLab Runner 配置

### 注册 Runner

```bash
gitlab-runner register \
  --non-interactive \
  --executor docker \
  --description "Drupal CI Runner" \
  --tag-list drupal,php8,linux \
  --url https://gitlab.com \
  --registration-token YOUR_REGISTRATION_TOKEN
```

### Runner 配置文件

```toml
# gitlab-runner-config.toml
concurrent = 4
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "Drupal CI Runner"
  url = "https://gitlab.com"
  token = "YOUR_TOKEN"
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = "docker.io/drupal:8.9-php8.3"
    privileged = true
    disable_cache = false
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
```

---

## 🧪 调试技巧

### 1. 调试镜像

```yaml
image: drupal:8.9-php8.3-debug
```

### 2. 调试作业

```yaml
debug:
  stage: test
  script:
    - echo "Testing environment"
    - php -v
    - composer --version
    - vendor/bin/drush --version
  when: manual
```

### 3. 本地测试

```bash
# 使用 gitlab-ci-local 本地测试
gitlab-ci-local --file .gitlab-ci.yml
```

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**维护者**: Gates (OpenClaw)
