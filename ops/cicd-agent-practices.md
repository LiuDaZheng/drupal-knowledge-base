# 🚀 Drupal 11 CI/CD Agent 实践指南

**版本**: v1.0  
**Drupal**: 11.x  
**目标**: Agent 可执行、可验证、可重复部署

---

## 🧠 Agent 理解要点

### 1. 核心概念（Agent 必须理解）

#### 只读 docroot
```bash
# Agent 必须知道：生产环境的 docroot 是只读的
# 所有构建必须提前完成（在 CI runner 中完成）
# 错误：在部署脚本中运行 npm build
# 正确：在 CI 构建阶段运行 npm build，部署时只同步文件
```

#### 配置同步目录
```bash
# Agent 必须知道：配置目录必须在 docroot 以外
# 这是 Drupal 的安全要求
$settings['config_sync_directory'] = '../config/sync';
```

#### Composer ICP (Install Composer Project)
```bash
# Agent 必须知道：Drupal 11 使用 ICP 工作流
# 所有内容模块必须包含在代码库中
# 错误：使用 drush pm-install 安装模块
# 正确：使用 composer require drupal/module_name 安装
```

### 2. 部署命令顺序（Agent 必须严格按此顺序）

```bash
# 正确的部署顺序
1. drush updatedb --strict=0   # 数据库更新（必须在配置导入之前）
2. drush cache:rebuild         # 重建缓存（让更新生效）
3. drush config:import         # 导入配置（使用已更新的数据库）
4. drush cache:rebuild         # 再次重建缓存（让配置生效）
```

**为什么是这个顺序？**
- `updatedb` 会修改数据库 schema
- `cache:rebuild` 清除缓存，让更新后的数据库表生效
- `config:import` 从文件同步配置到数据库
- 再次 `cache:rebuild` 确保所有配置生效

### 3. 环境状态机（Agent 必须理解）

```
dev (开发) → staging (预发) → production (生产)

Agent 部署逻辑：
- dev 分支：部署到 dev 环境（自动）
- develop 分支：部署到 staging 环境（自动）
- main 分支：部署到 production 环境（手动确认）
```

---

## 📦 Agent 可用资源

### 1. 可复制的配置模板

**GitLab CI 配置**: 复制 `.gitlab-ci.yml` 配置模板并替换变量

**GitHub Actions 配置**: 复制 `.github/workflows/ci-cd.yml` 配置模板

**环境变量模板**: 复制 `.env.example` 并填入实际值

### 2. 可执行的部署脚本

- `./scripts/deploy.sh dev` - 一键部署到开发环境
- `./scripts/deploy.sh staging` - 一键部署到预发环境
- `./scripts/deploy.sh production` - 一键部署到生产环境（需要确认）
- `./scripts/fail-safe-deploy.sh staging` - 带错误恢复的部署

### 3. 可运行的测试脚本

- `php tests/ci-integration-test.php` - 集成测试（验证环境）
- `vendor/bin/phpunit --testsuite=unit` - 单元测试
- `vendor/bin/phpunit --testsuite=functional` - 功能测试
- `vendor/bin/phpcs --standard=Drupal,DrupalPractice web/modules/custom` - 代码质量检查
- `vendor/bin/phpstan analyse web/modules/custom --level=max` - PHPStan 静态分析

---

## 🎯 Agent 实践流程

### 场景 1：新环境快速部署

```bash
# 1. 创建 Docker 容器
docker run -d \
  --name drupal-ci \
  -v $(pwd):/var/www/html \
  -e DRUSH_SHELL_COMPLETION=0 \
  drupal:8.9-php8.0 \
  /bin/bash

# 2. 进入容器
docker exec -it drupal-ci /bin/bash

# 3. 初始化项目
composer create-project drupal/recommended-project web

# 4. 安装 Drush
cd web && composer require drush/drush:^13

# 5. 配置环境
cat >> sites/default/settings.php << 'EOF'
$settings['config_sync_directory'] = '../config/sync';
EOF

# 6. 运行测试
./vendor/bin/drush status

# 完成！
```

### 场景 2：自动部署流程

```bash
# Agent 需要实现的自动化部署逻辑

# 1. 检查触发来源
if [ "$CI_EVENT_NAME" = "push" ]; then
  TARGET_ENV=$(determine_target_env)
  
  # 2. 执行部署
  echo "正在部署到 $TARGET_ENV..."
  deploy_to_env $TARGET_ENV
  
  # 3. 验证部署结果
  if verify_deployment_success; then
    echo "✅ 部署成功"
  else
    echo "❌ 部署失败，尝试重新部署"
    retry_deploy $TARGET_ENV
  fi
fi
```

### 场景 3：错误恢复

```bash
# 使用 fail-safe-deploy.sh（已包含重试逻辑）

DEPLOY_COUNT=0
MAX_RETRIES=3

while [ $DEPLOY_COUNT -lt $MAX_RETRIES ]; do
  echo "尝试部署 $((DEPLOY_COUNT + 1))/$MAX_RETRIES"
  
  if deploy_drupal; then
    echo "部署成功"
    break
  else
    echo "部署失败，30 秒后重试..."
    sleep 30
    DEPLOY_COUNT=$((DEPLOY_COUNT + 1))
  fi
done

if [ $DEPLOY_COUNT -eq $MAX_RETRIES ]; then
  error_exit "超过最大重试次数，需要人工介入"
fi
```

---

## 🔒 Agent 安全注意事项

### 1. 密钥管理

**错误做法** ❌：
```bash
# 不要将密钥写入脚本
SSH_KEY="-----BEGIN RSA PRIVATE KEY-----..."
echo "$SSH_KEY" > ~/.ssh/id_rsa
```

**正确做法** ✅：
```bash
# 使用 GitLab CI 变量
# 在 GitLab Settings > CI/CD > Variables 添加：
# STAGING_SSH_KEY: (加密值)
# 然后在脚本中使用：
ssh -i "$STAGING_SSH_KEY" user@server.com
```

### 2. 环境变量安全

**错误做法** ❌：
```bash
DB_PASSWORD="secret123"
```

**正确做法** ✅：
```bash
# 从 GitLab CI 变量读取
export DB_PASSWORD="$CI_DB_PASSWORD"
```

### 3. 数据库连接

**必须验证**：
```bash
# 验证数据库连接
$DRUSH status --db-status --format=json | jq -r '.database.db-hostname'

# 验证连接状态
$DRUSH test:phpunit:prepare
```

---

## 📊 Agent 监控与日志

### 1. 日志文件位置

```bash
# 部署日志
/var/www/html/logs/deploy-YYYYMMDD-HHMMSS.log

# CI 日志
.gitlab-ci.log
.github/runs/

# DRUSH 日志
$DRUSH logging
```

### 2. 状态报告格式

```json
{
  "timestamp": "2026-04-08T10:00:00Z",
  "agent_id": "agent-001",
  "deployment": {
    "environment": "staging",
    "version": "11.0.5",
    "duration": "120s",
    "success": true
  },
  "tests": {
    "unit": "passed",
    "functional": "passed",
    "code_quality": "clean"
  }
}
```

---

## 🧪 Agent 可执行的自动化测试

### 测试 1：环境验证（必须执行）

```bash
php tests/ci-integration-test.php
```

**预期输出**：
```
🧪 Running CI Integration Tests...
✅ Drupal version: 11.0.5
✅ Drush version: Drush Command Line Tool 13.3.0
✅ Config sync directory: /tmp/drupal-ci-test/config/sync
✅ All required Composer packages are installed
✅ Database connection: mysql://127.0.0.1
✅ Cache system working

✅ All CI integration tests PASSED!
```

### 测试 2：部署脚本验证

```bash
# 测试 dev 环境部署
./scripts/deploy.sh dev

# 预期：无错误，数据库更新、配置导入、缓存重建都成功
```

### 测试 3：错误恢复验证

```bash
# 测试 fail-safe 部署（故意创建一个错误）
# 然后在日志中检查重试逻辑是否正常工作
cat logs/deploy-*.log
```

---

## 📋 Agent 执行清单

Agent 在执行 CI/CD 任务前，必须验证以下所有点：

### 预部署检查清单

```bash
# Agent 必须验证（按顺序）

# 1. 环境设置
test -d $DRUPAL_ROOT              # Drupal 目录存在
test -x $DRUSH                    # Drush 可执行
test -w $SYNC_DIR                 # 配置目录可写
test -f $DRUPAL_ROOT/web/sites/default/settings.php  # settings.php 存在

# 2. 数据库连接
$DRUSH status --db-status         # 数据库连接正常

# 3. 代码质量
vendor/bin/phpcs --standard=Drupal,DrupalPractice web/modules/custom  # 代码符合规范
vendor/bin/phpstan analyse web/modules/custom                              # PHPStan 无问题

# 4. 测试通过
vendor/bin/phpunit --testsuite=unit          # 单元测试通过
vendor/bin/phpunit --testsuite=functional    # 功能测试通过

# 5. 安全验证
grep -r "password" scripts/ | grep -v ".git"  # 无硬编码密码
composer audit                                     # 无安全漏洞
```

### 部署后检查清单

```bash
# Agent 必须验证（部署后执行）

# 1. Drupal 状态
$DRUSH status                              # Drupal 运行正常
$DRUSH cache:status                        # 缓存系统正常工作
$DRUSH cron:status                         # 定时任务正常

# 2. 配置状态
$DRUSH config:status                       # 配置无差异
$DRUSH config:status --format=json         # JSON 格式验证

# 3. 数据库状态
$DRUSH updatedb --simulate                 # 无待执行的数据库更新
$DRUSH sql-query "SELECT COUNT(*) FROM {system}";  # 系统表正常

# 4. 性能验证
$DRUSH clear-crons                           # 清除缓存
$DRUSH cron:run                             # 运行 cron

# 5. 日志检查
cat $LOG_FILE | grep -i error             # 无错误日志
```

---

## 🎯 Agent 最佳实践

### 1. 使用 JSON 格式输出

Agent 必须能够解析 JSON 格式的输出：

```bash
# 使用 --format=json 替代默认的人类可读格式
$DRUSH status --format=json | jq '.system.version'
$DRUSH config:export --diff --format=json

# 这样可以方便 Agent 提取和处理数据
```

### 2. 错误码处理

Agent 必须检查返回值：

```bash
$DRUSH updatedb
if [ $? -ne 0 ]; then
  echo "❌ 数据库更新失败"
  exit 1
fi
```

### 3. 超时控制

Agent 必须设置超时：

```bash
# 使用 timeouts 防止无限等待
timeout 300s $DRUSH updatedb
```

### 4. 日志记录

Agent 必须记录所有操作：

```bash
exec >> "$LOG_FILE" 2>&1
echo "[$(date)] 开始部署到 $TARGET_ENV"
```

---

## 📖 参考资源

- **官方文档**: https://www.drupal.org/docs
- **Drush 文档**: https://www.drush.org/manual/
- **GitLab CI 文档**: https://docs.gitlab.com/ee/ci/
- **GitHub Actions 文档**: https://docs.github.com/en/actions

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**维护者**: Gates (OpenClaw)
