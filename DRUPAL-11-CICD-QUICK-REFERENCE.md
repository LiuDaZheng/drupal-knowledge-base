# 🚀 Drupal 11 CI/CD 快速参考

**版本**: v1.0  
**Drupal**: 11.x  
**生成日期**: 2026-04-08

---

## 📋 一键命令清单

### 初始化项目
```bash
~/.openclaw/skills/drupal-knowledge-base/scripts/quick-start.sh ~/my-project
# 一键创建 Drupal 11 项目 + CI/CD 配置
```

### 部署环境
```bash
./scripts/deploy.sh dev        # 开发环境
./scripts/deploy.sh staging    # 预发环境（推荐）
./scripts/deploy.sh production # 生产环境（需要确认）
```

### 错误恢复
```bash
./scripts/fail-safe-deploy.sh staging  # 带重试的部署
```

### 验证环境
```bash
php tests/ci-integration-test.php  # 环境测试
# 预期输出：All CI integration tests PASSED!
```

---

## 🔧 Drush 命令顺序（必须严格遵守）

```bash
# 正确的部署顺序
1. drush updatedb --strict=0   # 数据库更新（必须最先）
2. drush cache:rebuild         # 清除缓存
3. drush config:import         # 导入配置
4. drush cache:rebuild         # 再次清除缓存
```

**为什么是这个顺序？**
- `updatedb` → 修改数据库 schema
- `cache:rebuild` → 让更新生效  
- `config:import` → 同步配置
- `cache:rebuild` → 让配置生效

---

## 📦 配置模板

### GitLab CI
```bash
# 复制模板
cp ~/.openclaw/skills/drupal-knowledge-base/.gitlab-ci.yml.template .gitlab-ci.yml

# 或查看完整配置
cat ~/.openclaw/skills/drupal-knowledge-base/ops/cicd-gitlab-ci.md
```

### GitHub Actions
```bash
# 复制模板
mkdir -p .github/workflows
cp ~/.openclaw/skills/drupal-knowledge-base/.github.workflows-ci-cd.yml.template .github/workflows/ci-cd.yml

# 或查看完整配置
cat ~/.openclaw/skills/drupal-knowledge-base/ops/cicd-github-actions.md
```

### 环境变量
```bash
# 复制模板
cp ~/.openclaw/skills/drupal-knowledge-base/.env.ci.example .env.ci

# ⚠️ 不要提交到 Git！
```

---

## 🎯 常见命令速查

### 环境检查
```bash
drush status
drush status --db-status
drush status --fields=version
```

### 配置管理
```bash
drush config:status
drush config:import
drush config:export
drush config:diff
```

### 缓存管理
```bash
drush cache:rebuild
drush cache:clear all
drush cache:status
```

### 数据库操作
```bash
drush updatedb --simulate
drush sql-query "SELECT COUNT(*) FROM {system}"
drush sql-dump > backup.sql
```

---

## 🔒 安全检查清单

```bash
# Agent 部署前必须验证
grep -r "password" scripts/ | grep -v ".git"   # 无硬编码密码
stat ~/.ssh/id_rsa | grep "800"                # 密钥权限
ls -la ../config/sync | grep "755"             # 配置目录权限
composer audit --no-dev                        # Composer 安全审计
```

---

## 📊 环境状态机

```
develop → staging (自动部署)
main → production (手动部署)
```

---

## 🐛 常见问题速查

### 数据库更新失败
```bash
# 检查连接
drush status --db-status

# 模拟运行
drush updatedb --simulate
```

### 配置导入冲突
```bash
# 查看差异
drush config:compare

# 强制导入（谨慎使用）
drush config:import --force
```

### 缓存问题
```bash
# 清除缓存
drush cache:rebuild
```

---

## 🔑 常用配置

### GitLab CI 变量
```bash
CI_MYSQL_ROOT_PASSWORD
CI_MYSQL_DATABASE
CI_MYSQL_USER
CI_MYSQL_PASSWORD
CI_DEV_SERVER
CI_STAGING_SERVER
CI_PROD_SERVER
```

### GitHub Secrets
```bash
DB_PASSWORD
STAGING_SERVER
PROD_SERVER
STAGING_SSH_PRIVATE_KEY
PROD_SSH_PRIVATE_KEY
```

---

## 📚 文档索引

| 用途 | 文档 |
|------|------|
| Agent 实践 | [`ops/cicd-agent-practices.md`](../ops/cicd-agent-practices.md) |
| GitLab CI | [`ops/cicd-gitlab-ci.md`](../ops/cicd-gitlab-ci.md) |
| GitHub Actions | [`ops/cicd-github-actions.md`](../ops/cicd-github-actions.md) |
| 部署策略 | [`ops/cicd-deployment-strategies.md`](../ops/cicd-deployment-strategies.md) |
| Drush 命令 | [`dev/cicd-drush-commands.md`](../dev/cicd-drush-commands.md) |
| 完整方案 | [`solutions/cicd/full-stack-cicd.md`](../solutions/cicd/full-stack-cicd.md) |
| 安全配置 | [`best-practices/cicd-security.md`](../best-practices/cicd-security.md) |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**维护者**: Gates (OpenClaw)
