# Commerce License - 完整文档包

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📚 文档导航

| 文档 | 说明 |
|------|------|
| [Commerce License 核心指南](../contrib/ecommerce/commerce-license.md) | 模块基础使用 |
| [License API Reference](license-api-reference.md) | RESTful API 文档 |
| [License Activation Guide](license-activation-guide.md) | 激活管理流程 |
| [Subscription Plans Config](subscription-plans-config.md) | 订阅计划配置 |
| [License Validation Best Practices](license-validation-best-practices.md) | 验证最佳实践 |
| [SaaS Integration Examples](saas-integration-examples.md) | SaaS 集成示例 |
| [Enterprise Deployment](enterprise-deployment.md) | 企业级部署 |

---

## 🎯 快速开始

### 安装
```bash
composer require drupal/commerce_license
drush en commerce_license --yes
```

### 基本流程
1. 创建产品变体（License 类型）
2. 设置许可证生成规则
3. 配置订阅计划
4. 启用邮件通知模板

**详细教程**: 参见 [核心指南](../contrib/ecommerce/commerce-license.md)

---

## 📋 文档说明

本套件包含 7 个互补文档，覆盖从基础使用到高级集成的完整场景：

- **核心指南**: 所有新功能开发者必读
- **API 参考**: 后端集成必备
- **激活指南**: 管理员操作手册
- **订阅配置**: 计费专家文档
- **最佳实践**: 安全验证策略
- **SaaS 示例**: 实际代码参考
- **企业部署**: 大规模实施指南

---

*建议使用顺序：阅读核心指南 → 根据需求选择专题文档 → 参考示例代码*
