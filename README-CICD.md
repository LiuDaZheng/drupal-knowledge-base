# 🚀 Drupal 11 CI/CD Agent 实践指南

一套专为**Agent 实践**设计的 Drupal 11 CI/CD 配置和脚本。

> ⚠️ **重要**: 所有脚本和配置都可以 **copy-paste 直接运行**

---

## 🚀 快速开始

### 1. 一键初始化

```bash
./scripts/quick-start.sh ~/drupal-project
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

### 4. 错误恢复部署

```bash
./scripts/fail-safe-deploy.sh staging
```

---

## 📚 完整文档

### 核心文档

| 文档 | Agent 使用方式 |
|------|----------------|
| [`ops/cicd-agent-practices.md`](ops/cicd-agent-practices.md) | 理解 CI/CD 核心概念 |
| [`ops/cicd-deployment-strategies.md`](ops/cicd-deployment-strategies.md) | 了解部署流程 |
| [`ops/cicd-gitlab-ci.md`](ops/cicd-gitlab-ci.md) | 复制配置使用 |
| [`ops/cicd-github-actions.md`](ops/cicd-github-actions.md) | 复制配置使用 |
| [`ops/cicd-agent-checklist.md`](ops/cicd-agent-checklist.md) | 验证流程 |

### 配置模板

- `.gitlab-ci.yml.template` - GitLab CI 配置模板
- `.github.workflows-ci-cd.yml.template` - GitHub Actions 工作流模板

### 可执行文件

- `scripts/quick-start.sh` - 快速启动脚本
- `scripts/deploy.sh` - 部署脚本
- `scripts/fail-safe-deploy.sh` - 错误恢复脚本
- `tests/ci-integration-test.php` - 集成测试脚本

### 参考文档

- [`dev/cicd-drush-commands.md`](dev/cicd-drush-commands.md) - Drush 命令指南
- [`solutions/cicd/full-stack-cicd.md`](solutions/cicd/full-stack-cicd.md) - 完整方案
- [`best-practices/cicd-security.md`](best-practices/cicd-security.md) - 安全配置

---

## ⚙️ 环境配置

### 1. 复制环境变量模板

```bash
cp .env.ci.example .env.ci
```

### 2. 编辑环境变量

```bash
nano .env.ci
```

### 3. 导入到 CI 平台

#### GitLab CI

```
GitLab > Settings > CI/CD > Variables
```

#### GitHub Actions

```
Settings > Secrets and variables > Actions > Secrets
```

---

## 🧪 运行验证

### 集成测试

```bash
php tests/ci-integration-test.php
```

**预期输出**：
```
🧪 Running CI Integration Tests...
✅ Drupal Core installed
✅ Config sync directory configured
✅ Composer dependencies are installed
✅ All CI integration tests PASSED!
```

---

## 🔒 安全注意事项

- **不要**将 `.env.ci` 提交到 Git
- **不要**在脚本中硬编码密钥
- **始终**使用 GitLab/GitHub 的变量加密功能
- **定期**轮换 SSH 密钥和 API 令牌
- **遵循** [最佳安全实践](best-practices/cicd-security.md)

---

## 📚 参考资源

- **官方文档**: https://www.drupal.org/docs
- **Drush 文档**: https://www.drush.org/manual/
- **GitLab CI 文档**: https://docs.gitlab.com/ee/ci/
- **GitHub Actions 文档**: https://docs.github.com/en/actions
- **Pantheon CI/CD**: https://pantheon.io/learning-center/drupal/ci-cd
- **Acquia CI/CD**: https://docs.acquia.com/drupal-starter-kits/cicd-delivery-pipeline

---

**版本**: v1.0  
**Drupal**: 11.x  
**License**: MIT  
**维护者**: Gates (OpenClaw)

---

## 📊 验证方法

所有验证都在以下文件中实现：

1. **集成测试**: `tests/ci-integration-test.php`
2. **Agent 清单**: `ops/cicd-agent-checklist.md`
3. **部署脚本**: `scripts/deploy.sh`
4. **错误恢复**: `scripts/fail-safe-deploy.sh`

Agent 可以直接运行这些脚本进行验证。
