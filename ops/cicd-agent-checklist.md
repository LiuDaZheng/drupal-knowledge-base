# 📋 Agent CI/CD 检查清单

**版本**: v1.0  
**更新**: 2026-04-08  
**目标**: 验证所有 CI/CD 组件正常工作

---

## 🎯 验证任务列表

### 1. 环境搭建验证

| 验证点 | Agent 命令 | 预期结果 | 状态 |
|--------|-----------|----------|------|
| Drupal 11 安装 | `composer create-project drupal/recommended-project:test` | 安装成功 | ⬜ |
| Composer 依赖 | `composer install --no-dev -o` | 无错误 | ⬜ |
| Drush 13+ 安装 | `drush --version` | 版本≥13 | ⬜ |
| 配置目录权限 | `chmod 755 ../config/sync` | 可写 | ⬜ |
| 数据库连接 | `drush status --db-status` | 连接成功 | ⬜ |

### 2. GitLab CI 验证

| 验证点 | Agent 命令 | 预期结果 | 状态 |
|--------|-----------|----------|------|
| .gitlab-ci.yml 语法 | `gitlab-ci-lint .gitlab-ci.yml` | 语法正确 | ⬜ |
| Runner 注册 | `gitlab-runner list` | Runner 正常 | ⬜ |
| Pipeline 触发 | `curl --request POST` | Pipeline 创建成功 | ⬜ |
| 测试作业运行 | `gitlab-runner exec docker test:unit` | 测试通过 | ⬜ |

### 3. GitHub Actions 验证

| 验证点 | Agent 命令 | 预期结果 | 状态 |
|--------|-----------|----------|------|
| Workflows 语法 | `actions/states/.github/workflows/ci-cd.yml` | 工作流正确 | ⬜ |
| 作业触发 | `gh workflow run ci-cd.yml` | Workflow 启动 | ⬜ |
| 环境变量 | `grep -r "env:" .github/workflows/` | 变量配置 | ⬜ |
| Secrets 加密 | `gh secret list` | 密钥存在 | ⬜ |

### 4. 部署脚本验证

| 验证点 | Agent 命令 | 预期结果 | 状态 |
|--------|-----------|----------|------|
| 脚本可执行 | `chmod +x scripts/deploy.sh && ./scripts/deploy.sh dev` | 部署成功 | ⬜ |
| 错误处理 | `./scripts/deploy.sh invalid_env` | 报错并退出 | ⬜ |
| 日志记录 | `grep -r "logs/deploy" .` | 日志生成 | ⬜ |
| 命令顺序 | `grep "drush updatedb" scripts/deploy.sh` | 正确顺序 | ⬜ |

### 5. 测试系统验证

| 验证点 | Agent 命令 | 预期结果 | 状态 |
|--------|-----------|----------|------|
| 单元测试 | `vendor/bin/phpunit --testsuite=unit` | 通过测试 | ⬜ |
| 功能测试 | `vendor/bin/phpunit --testsuite=functional` | 通过测试 | ⬜ |
| 代码质量 | `vendor/bin/phpcs --standard=Drupal` | 无错误 | ⬜ |
| PHPStan 检查 | `vendor/bin/phpstan analyse web/modules/custom` | 零问题 | ⬜ |

### 6. 缓存和配置验证

| 验证点 | Agent 命令 | 预期结果 | 状态 |
|--------|-----------|----------|------|
| 缓存清空 | `drush cache:rebuild` | 缓存清空 | ⬜ |
| 配置导入 | `drush config:import --dry-run` | 无变更 | ⬜ |
| 配置导出 | `drush config:export --diff` | 显示差异 | ⬜ |
| 数据库更新 | `drush updatedb --simulate` | 无错误 | ⬜ |

### 7. 安全配置验证

| 验证点 | Agent 命令 | 预期结果 | 状态 |
|--------|-----------|----------|------|
| SSH 密钥 | `ssh -T git@github.com` | 认证成功 | ⬜ |
| Git 凭证 | `git credential-helper list` | 凭证管理器 | ⬜ |
| 环境变量 | `grep -r "password" scripts/` | 无硬编码 | ⬜ |
| Composer 安全 | `composer audit` | 无漏洞 | ⬜ |

---

## 🔄 自动化验证脚本

使用 `tests/ci-integration-test.php` 自动验证所有组件：

```bash
# 运行完整测试
php tests/ci-integration-test.php
```

**预期输出**:
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

---

## 🎯 Agent 执行顺序

为确保一切正常工作，请按此顺序验证：

```bash
# 1. 创建项目
./scripts/quick-start.sh ~/test-drupal-ci

# 2. 进入项目
cd ~/test-drupal-ci

# 3. 运行集成测试
php tests/ci-integration-test.php

# 4. 验证 GitLab CI
gitlab-ci-lint .gitlab-ci.yml

# 5. 验证 GitHub Actions
gh workflow list

# 6. 测试部署脚本
./scripts/deploy.sh dev

# 7. 测试错误恢复
./scripts/fail-safe-deploy.sh staging
```

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**维护者**: Gates (OpenClaw)
