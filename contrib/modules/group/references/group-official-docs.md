# Group Module 官方文档索引

**最后更新**: 2026-04-10  
**信息来源**: 100% drupal.org 官方资源  

---

## 📚 核心文档

### 项目页面

| 资源 | URL | 说明 |
|------|-----|------|
| 项目主页 | https://www.drupal.org/project/group | 下载、版本信息、统计数据 |
| Issue 队列 | https://www.drupal.org/project/issues/group | Bug 报告、功能请求 |
| 生态系统 | https://www.drupal.org/project/group/ecosystem | 相关子模块和扩展 |

### 官方文档

| 资源 | URL | 说明 |
|------|-----|------|
| 主文档 | https://www.drupal.org/docs/contributed-modules/group | 完整文档入口 |
| 基础配置 | https://www.drupal.org/docs/contributed-modules/group/basic-configuration | 创建组类型、组、角色 |
| 使用场景 | https://www.drupal.org/node/2666972 | 示例用例和最佳实践 |
| 额外资源 | https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-archive/contrib-modules-for-building-the-site-functionality/social-networking-and-collaboration/group/additional-resources | 教程、演示 |
| 如何贡献 | https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-archive/contrib-modules-for-building-the-site-functionality/social-networking-and-collaboration/group/how-to-contribute | 贡献指南 |

### 版本文档

| 版本 | URL | 说明 |
|------|-----|------|
| Drupal 7.x | https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-archive/contrib-modules-for-building-the-site-functionality/social-networking-and-collaboration/group/group-7x-1x | Drupal 7 版本 |
| Drupal 8.x+ | https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-archive/contrib-modules-for-building-the-site-functionality/social-networking-and-collaboration/group/group-8x-1x | Drupal 8/9/10/11 版本 |

---

## 🔧 API 参考

### 核心 API

| 资源 | URL | 说明 |
|------|-----|------|
| Entity API | https://api.drupal.org/api/drupal/core!lib!Drupal!Core!Entity!entity.api.php | 实体 API 文档 |
| User API | https://api.drupal.org/api/drupal/core!core.api.php/group/user_api | 用户、角色、权限 API |
| Group Entity | https://api.drupal.org/api/drupal/group | Group 模块 API |

### 插件系统

| 资源 | URL | 说明 |
|------|-----|------|
| GroupContentEnabler | https://www.drupal.org/project/group/issues/2775119 | 自定义实体关联插件 |
| Group Plugin API | https://api.drupal.org/api/drupal/group | 组插件系统 |

---

## 📦 子模块

### 官方子模块

| 模块 | 项目页面 | 说明 |
|------|---------|------|
| gnode | https://www.drupal.org/project/group | Node 内容关联 |
| group_content_menu | https://www.drupal.org/project/group_content_menu | 组内容菜单导航 |
| group_relationship_inheritance | https://www.drupal.org/project/group_relationship_inheritance | 关系权限继承 |

### 社区扩展

| 模块 | 项目页面 | 说明 |
|------|---------|------|
| Group Private Content | https://www.drupal.org/project/group_private_content | 私有内容控制 |
| Group Invite | https://www.drupal.org/project/group_invite | 邀请成员 |
| Group Default Roles | https://www.drupal.org/project/group_default_roles | 默认角色分配 |

---

## 🛠️ 配置路径

### 管理界面

| 功能 | 路径 | 说明 |
|------|------|------|
| Group Types | `/admin/config/group/types` | 管理组类型 |
| Group Fields | `/admin/config/group/fields` | 配置实体关联 |
| Groups List | `/admin/structure/group` | 管理所有组 |
| Permissions | `/admin/people/permissions/group` | 组权限配置 |

### 用户界面

| 功能 | 路径 | 说明 |
|------|------|------|
| My Groups | `/group` | 用户加入的组列表 |
| Create Group | `/group/add` | 创建新组 |
| Group Content | `/group/{gid}/content` | 组内容列表 |
| Group Members | `/group/{gid}/members` | 组成员列表 |

---

## 📖 学习资源

### 官方教程

| 资源 | URL | 类型 |
|------|-----|------|
| Group vs OG 对比 | https://www.drupal.org/docs/extending-drupal/contributed-modules/comparison-of-contributed-modules/comparison-of-group-modules | 文档 |
| 实体类型使用 | https://www.drupal.org/node/1895584 | 教程 |
| Group 页面说明 | https://www.drupal.org/docs/8/modules/group/pages-that-the-group-module-provides | 参考 |

### 社区资源

| 资源 | URL | 类型 |
|------|-----|------|
| Drupal Stack Exchange | https://drupal.stackexchange.com/questions/tagged/group | Q&A |
| Drupal Forum | https://www.drupal.org/forum/support/module-development | 论坛 |
| GitHub | https://github.com/drupal/group | 代码仓库 |

---

## 🔍 故障排查

### 常见问题

| 问题 | 解决方案链接 |
|------|------------|
| 实体无法关联到组 | https://www.drupal.org/node/1895584 |
| 权限不生效 | https://www.drupal.org/project/issues/group |
| 迁移自 OG | https://www.drupal.org/project/group |

### Issue 队列分类

- **Bug 报告**: https://www.drupal.org/project/issues/group?categories=Bug%20report
- **功能请求**: https://www.drupal.org/project/issues/group?categories=Feature%20request
- **支持请求**: https://www.drupal.org/project/issues/group?categories=Support%20request

---

*索引版本: 1.0*  
*创建日期: 2026-04-10*  
*维护：skilldev Agent*
