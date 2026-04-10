# 🔄 Drupal 11 CI/CD 部署策略

**版本**: v1.0  
**Drupal**: 11.x  
**目标**: 多环境部署策略和最佳实践

---

## 📐 环境分层设计

### 1. Development (开发环境)

**特点**:
- 最接近本地开发环境
- 自动更新（每次 push 到 develop）
- 快速迭代，快速失败

**配置**:
```yaml
dev:
  url: https://dev.example.com
  ssh_host: dev-server.example.com
  ssh_user: www-data
  auto_deploy: true
  trigger_branches: [develop]
```

### 2. Staging (预发环境)

**特点**:
- 接近生产环境的配置
- 用于 QA 和最终测试
- 需要人工确认才能部署

**配置**:
```yaml
staging:
  url: https://staging.example.com
  ssh_host: staging-server.example.com
  ssh_user: www-data
  auto_deploy: false
  trigger_branches: [main]
  require_approval: true
```

### 3. Production (生产环境)

**特点**:
- 与真实用户环境完全一致
- 严格的部署流程
- 需要双人确认和审批

**配置**:
```yaml
production:
  url: https://www.example.com
  ssh_host: prod-server.example.com
  ssh_user: www-data
  auto_deploy: false
  trigger_branches: [main]
  require_approval: true
  require_dual_signoff: true
```

---

## 🔄 Pipeline 阶段设计

### Stage 1: Validate（验证阶段）

**目标**: 在构建之前确保代码质量

**作业**:
```yaml
validate:code-quality:
  stage: validate
  script:
    # 编码风格检查
    - vendor/bin/phpcs --standard=Drupal,DrupalPractice web/modules/custom
    
    # 静态分析
    - vendor/bin/phpstan analyse web/modules/custom --level=max
    
    # 安全扫描
    - composer audit
    
    # 生成报告
    - vendor/bin/phpcs --report=checkstyle > reports/phpcs.xml
    - vendor/bin/phpstan analyse web/modules/custom --error-format=github > reports/phpstan.log
```

### Stage 2: Build（构建阶段）

**目标**: 准备生产就绪的代码包

**作业**:
```yaml
build:dependencies:
  stage: build
  script:
    # 安装生产依赖
    - composer install --no-dev --optimize-autoloader --no-interaction
    
    # 构建主题资产
    - npm ci --prefix web/themes/custom/mytheme
    - npm run build --prefix web/themes/custom/mytheme
    
  artifacts:
    paths:
      - vendor/
      - web/
    expire_in: 1 hour
```

### Stage 3: Test（测试阶段）

**目标**: 确保代码在各种条件下都能正常工作

**作业**:
```yaml
test:unit:
  stage: test
  services:
    - mysql:8.0
  script:
    - vendor/bin/phpunit --testsuite=unit --coverage-text
    
test:functional:
  stage: test
  services:
    - mysql:8.0
  script:
    - vendor/bin/drush site:install standard --db-url=mysql://drupal_user:drupal_pass@mysql/drupal_ci -y
    - vendor/bin/phpunit --testsuite=functional

test:javascript:
  stage: test
  script:
    - npm test --prefix web/themes/custom/mytheme
```

### Stage 4: Deploy（部署阶段）

**目标**: 将测试通过的代码部署到目标环境

**作业**:
```yaml
deploy:staging:
  stage: deploy
  environment:
    name: staging
    url: https://staging.example.com
  script:
    - rsync -avz --delete --exclude='.git' --exclude='sites/*/files' ./ staging-server:/var/www/html
    - ssh staging-server "cd /var/www/html && ./vendor/bin/drush updatedb -y && ./vendor/bin/drush config:import -y && ./vendor/bin/drush cache:rebuild"
  only:
    - develop
  when: on_success

deploy:production:
  stage: deploy
  environment:
    name: production
    url: https://www.example.com
  script:
    - rsync -avz --delete --exclude='.git' --exclude='sites/*/files' ./ prod-server:/var/www/html
    - ssh prod-server "cd /var/www/html && ./vendor/bin/drush updatedb -y && ./vendor/bin/drush config:import -y && ./vendor/bin/drush cache:rebuild"
  when: manual
  only:
    - main
```

---

## 🎯 部署模式

### 1. 蓝绿部署

**特点**:
- 两套环境同时运行（Blue 和 Green）
- 切换路由实现零停机部署
- 可快速回滚

**流程**:
```
1. Blue 环境正在运行
2. 部署到 Green 环境
3. 验证 Green 环境
4. 切换到 Green 环境（路由切换）
5. 监控 Green 环境
6. 如果问题，切回 Blue 环境
```

### 2. 金丝雀部署

**特点**:
- 逐步将流量切换到新版本
- 降低部署风险
- 可以观察新版本表现

**流程**:
```
1. 5% 流量到新版本
2. 观察错误率和性能
3. 10% -> 25% -> 50% -> 100%
4. 每阶段观察 15-30 分钟
5. 如果问题，立即回滚
```

### 3. 滚动部署

**特点**:
- 逐步替换服务器
- 保持服务可用性
- 适合有负载均衡的环境

**流程**:
```
1. 替换第一台服务器
2. 验证健康检查
3. 替换下一台
4. 重复直到所有服务器更新
5. 负载均衡自动处理
```

---

## 🔧 配置管理策略

### 1. 配置同步目录

**必须在 docroot 外**:
```bash
# 正确的配置
$settings['config_sync_directory'] = '../config/sync';

# 目录权限
chmod 755 ../config/sync
```

**配置导出**:
```bash
# 导出所有配置
drush config:export --ync
```

**配置导入**:
```bash
# 导入所有配置
drush config:import
```

### 2. 数据库迁移策略

**正确的顺序**:
```bash
1. drush updatedb --strict=0   # 数据库更新（必须在配置导入之前）
2. drush cache:rebuild         # 重建缓存（让更新生效）
3. drush config:import         # 导入配置（使用已更新的数据库）
4. drush cache:rebuild         # 再次重建缓存（让配置生效）
```

---

## 📊 部署监控指标

| 指标 | 目标值 | 监控方式 |
|------|--------|----------|
| 构建时间 | < 10 min | GitLab CI 日志 |
| 测试覆盖率 | > 80% | PHPUnit 报告 |
| 部署成功率 | > 95% | 部署日志 |
| 回滚时间 | < 5 min | 回滚日志 |
| 故障恢复时间 | < 30 min | 监控告警 |

---

## 🚨 回滚策略

### 1. 自动回滚条件

- 部署后错误率 > 5%
- 响应时间 > 3 秒
- 数据库更新失败
- 配置导入冲突

### 2. 回滚步骤

```bash
# 1. 回滚代码
git checkout <previous-commit>

# 2. 恢复数据库备份
$DRUSH sql-dump | mysql drupal_prod

# 3. 重新部署
$DRUSH config:import
$DRUSH cache:rebuild

# 4. 验证
$DRUSH status
$DRUSH deploy:status
```

---

## 📋 部署检查清单

### 部署前验证

```bash
# Agent 必须验证

# 1. 代码质量
$DRUSH phpcs --standard=Drupal,DrupalPractice web/modules/custom

# 2. 性能检查
$DRUSH status

# 3. 安全扫描
composer audit --no-dev

# 4. 配置同步
$DRUSH config:status

# 5. 数据库健康
$DRUSH sql-query "SELECT COUNT(*) FROM {system}"
```

### 部署后验证

```bash
# Agent 必须验证

# 1. Drupal 运行状态
$DRUSH status --format=json | jq '.core.version'

# 2. 缓存系统
$DRUSH cache:rebuild --quiet

# 3. 配置一致性
$DRUSH config:status --format=json | jq 'length'

# 4. 错误日志
$DRUSH watch:db | head -20

# 5. 健康检查
curl -f https://example.com/health
```

---

## 🔑 密钥管理

### 环境特定密钥

**不要在配置中硬编码**:
```bash
# ❌ 错误
ssh-key: "-----BEGIN RSA PRIVATE KEY-----..."

# ✅ 正确
ssh-key: $SSH_PRIVATE_KEY  # 从 GitLab CI 变量读取
```

### 密钥轮换策略

- 每 90 天轮换一次
- 部署前轮换
- 安全事件后立即轮换

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**维护者**: Gates (OpenClaw)
