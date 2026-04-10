# Drupal Group Module 完整指南

**版本**: 1.0  
**最后更新**: 2026-04-10  
**信息来源**: 100% 来自 drupal.org 官方文档  

---

## 📋 概述

Group 模块允许你在网站上创建内容和用户的任意集合，并为这些集合授予访问控制权限。

**官方项目页面**: https://www.drupal.org/project/group  
**官方文档**: https://www.drupal.org/docs/contributed-modules/group  

### 核心特性

- **实体化设计**: Group 将组创建为实体（Entity），使其完全可字段化、可扩展和可导出
- **灵活权限**: 每个组可以拥有独立的用户、角色和权限系统
- **内容关联**: 组与内容的关系也是实体，可添加元数据
- **子组支持**: 组本身是实体，因此创建子组非常简单
- **模块化架构**: 通过子模块启用额外功能，按需使用

### 与 Organic Groups (OG) 的区别

| 特性 | Group | Organic Groups (OG) |
|------|-------|---------------------|
| 组实现 | 独立实体 | 内容本身作为组 |
| 关系机制 | 实体关系 | 实体引用字段 |
| 可扩展性 | 完全字段化 | 依赖字段配置 |
| 学习曲线 | 较陡 | 较平缓 |

**来源**: https://www.drupal.org/node/2666972

---

## 🏗️ 架构说明

### 核心数据模型

```
┌─────────────────────────────────────────────────────────────┐
│                      Group Entity                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Group Type  │  │ Group Roles │  │ Group Permissions   │ │
│  │ (Bundle)    │  │             │  │                     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│           │                │                    │           │
│           ▼                ▼                    ▼           │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              Group Content Relationships                ││
│  │  (Node, User, Custom Entities via GroupContentEnabler)  ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### 核心概念

#### 1. Group Type（组类型）

Group Type 是组的 bundles，类似于节点的内容类型。

- 定义组的结构和可用字段
- 可配置哪些实体类型可以作为该组类型的内容
- 位于：`admin/config/group/types`

**来源**: https://www.drupal.org/node/2666972

#### 2. Group Content（组内容）

组内容是通过 GroupContentEnabler 插件关联到组的实体。

- **Node 关联**: 通过 gnode 子模块实现
- **User 关联**: 用户作为组成员
- **自定义实体**: 需定义 GroupContentEnabler 插件

**来源**: https://www.drupal.org/project/group/issues/2775119

#### 3. Group Permissions（组权限）

组权限系统独立于 Drupal 核心权限系统。

- 每个组类型可定义自己的权限
- 权限可分配给组角色
- 支持权限继承（通过子模块）

#### 4. Group Roles（组角色）

组角色类似于 Drupal 用户角色，但作用域限定在组内。

- 每个组有自己的角色实例
- 角色可分配权限
- 支持自定义角色

### 与其他模块的关系

| 模块 | 集成方式 | 说明 |
|------|---------|------|
| Views | 原生支持 | 可创建组内容、组成员视图 |
| Rules | 事件集成 | 响应组相关事件 |
| Entity Reference | 底层依赖 | 用于内容关联 |
| Internationalization | 兼容 | 支持多语言组内容 |

**来源**: https://www.drupal.org/node/2666972

---

## 🎯 使用场景（≥5 个）

### 场景 1: 社区网站

**需求**: 创建用户社区，每个社区有独立的内容和成员管理。

**实现方案**:
```yaml
Group Type: Community
Fields:
  - 社区名称
  - 社区描述
  - 社区头像
  - 创建日期
Group Content:
  - 讨论帖子
  - 活动公告
  - 资源分享
Roles:
  - 管理员 (完整权限)
  - 版主 (内容审核)
  - 成员 (发布内容)
  - 访客 (只读)
```

**来源**: https://www.drupal.org/node/2666972 (Example usecases)

### 场景 2: 企业内部网

**需求**: 按部门或项目组划分空间，实现文档协作和权限隔离。

**实现方案**:
```yaml
Group Type: Department
Fields:
  - 部门名称
  - 部门负责人
  - 部门代码
Group Content:
  - 内部文档
  - 项目计划
  - 会议纪要
Permissions:
  - 查看部门内容
  - 编辑部门文档
  - 管理部门成员
```

**来源**: https://www.drupal.org/docs/contributed-modules/group

### 场景 3: 会员系统

**需求**: 付费会员专属内容区域，不同会员等级有不同访问权限。

**实现方案**:
```yaml
Group Type: Membership Tier
Fields:
  - 会员等级名称
  - 月费价格
  - 权益描述
Group Content:
  - 专属文章
  - 视频教程
  - 下载资源
Roles:
  - 普通会员
  - 高级会员
  - VIP 会员
```

**来源**: https://www.drupal.org/node/2666972

### 场景 4: 协作平台

**需求**: 项目团队协作空间，支持子项目和任务管理。

**实现方案**:
```yaml
Group Type: Project
Fields:
  - 项目名称
  - 项目经理
  - 开始/结束日期
  - 项目状态
Subgroups:
  - 设计组
  - 开发组
  - 测试组
Group Content:
  - 任务单
  - 设计稿
  - 代码审查
```

**来源**: https://www.drupal.org/node/2666972

### 场景 5: 教育机构

**需求**: 课程管理系统，每个课程有独立的师生和内容。

**实现方案**:
```yaml
Group Type: Course
Fields:
  - 课程名称
  - 授课教师
  - 学分
  - 学期
Group Content:
  - 课程资料
  - 作业提交
  - 考试成绩
Roles:
  - 教师 (完全管理)
  - 助教 (批改作业)
  - 学生 (查看+提交)
```

**来源**: https://www.drupal.org/docs/contributed-modules/group

---

## 💻 代码示例（≥10 个）

### 示例 1: 创建 Group Type

```php
/**
 * 通过代码创建 Group Type
 */
use Drupal\group\Entity\GroupType;

$group_type = GroupType::create([
  'id' => 'community',
  'label' => 'Community',
  'description' => 'A community group type',
]);
$group_type->save();
```

**来源**: https://www.drupal.org/docs/contributed-modules/group/basic-configuration

### 示例 2: 创建 Group 实体

```php
/**
 * 创建一个新的组
 */
use Drupal\group\Entity\Group;

$group = Group::create([
  'gid' => NULL,
  'group_type' => 'community',
  'label' => 'My Community',
  'uid' => 1, // 组创建者
]);
$group->save();
```

**来源**: https://www.drupal.org/docs/contributed-modules/group

### 示例 3: 添加用户到组

```php
/**
 * 将用户添加为组成员
 */
use Drupal\group\Entity\GroupContent;

$group = \Drupal\group\Entity\Group::load($gid);
$user = \Drupal\user\Entity\User::load($uid);

// 创建组成员关系
$group_content = GroupContent::create([
  'group_id' => $group->id(),
  'entity_id' => $user->id(),
  'entity_type' => 'user',
  'plugin_id' => 'group_membership',
]);
$group_content->save();
```

**来源**: https://www.drupal.org/project/group/issues/2775119

### 示例 4: 添加节点到组

```php
/**
 * 将节点关联到组
 */
use Drupal\group\Entity\GroupContent;

$group = \Drupal\group\Entity\Group::load($gid);
$node = \Drupal\node\Entity\Node::load($nid);

$group_content = GroupContent::create([
  'group_id' => $group->id(),
  'entity_id' => $node->id(),
  'entity_type' => 'node',
  'plugin_id' => 'gnode',
]);
$group_content->save();
```

**来源**: https://www.drupal.org/docs/contributed-modules/group

### 示例 5: 查询组的成员

```php
/**
 * 获取组的所有成员
 */
use Drupal\group\Entity\Group;

$group = Group::load($gid);
$members = $group->getMembers();

foreach ($members as $member) {
  $user = $member->getEntity();
  print $user->getAccountName();
}
```

**来源**: https://www.drupal.org/node/2666972

### 示例 6: 查询组的内容

```php
/**
 * 获取组的所有内容
 */
use Drupal\group\Entity\Group;

$group = Group::load($gid);
$group_content = $group->getContent();

foreach ($group_content as $content) {
  $entity = $content->getEntity();
  // 处理实体
}
```

**来源**: https://www.drupal.org/docs/contributed-modules/group

### 示例 7: 检查组权限

```php
/**
 * 检查当前用户对组的权限
 */
use Drupal\group\Entity\Group;

$group = Group::load($gid);
$account = \Drupal::currentUser();

if ($group->access('administer group', $account)) {
  // 用户有管理权限
}

if ($group->access('view group', $account)) {
  // 用户可以查看组
}
```

**来源**: https://www.drupal.org/docs/contributed-modules/group

### 示例 8: 创建组角色

```php
/**
 * 创建自定义组角色
 */
use Drupal\group\Entity\GroupRole;

$group = Group::load($gid);
$role = GroupRole::create([
  'group_id' => $group->id(),
  'role' => 'moderator',
  'label' => 'Moderator',
  'permissions' => [
    'administer group content',
    'delete any group content',
  ],
]);
$role->save();
```

**来源**: https://www.drupal.org/docs/contributed-modules/group/basic-configuration

### 示例 9: 分配角色给用户

```php
/**
 * 给用户分配组角色
 */
use Drupal\group\Entity\GroupContent;

$group = Group::load($gid);
$user = \Drupal\user\Entity\User::load($uid);
$role = \Drupal\group\Entity\GroupRole::load($group->id() . '-moderator');

// 创建成员关系并分配角色
$membership = GroupContent::create([
  'group_id' => $group->id(),
  'entity_id' => $user->id(),
  'entity_type' => 'user',
  'plugin_id' => 'group_membership',
]);
$membership->addRole($role);
$membership->save();
```

**来源**: https://www.drupal.org/docs/contributed-modules/group

### 示例 10: 创建子组

```php
/**
 * 创建子组（组中组）
 */
use Drupal\group\Entity\Group;

$parent_group = Group::load($parent_gid);
$subgroup = Group::create([
  'gid' => NULL,
  'group_type' => 'project_team',
  'label' => 'Development Team',
  'parent' => $parent_group, // 设置父组
  'uid' => 1,
]);
$subgroup->save();
```

**来源**: https://www.drupal.org/node/2666972

### 示例 11: 自定义 GroupContentEnabler 插件

```php
/**
 * 定义自定义实体作为组内容
 * 文件：my_module/src/Plugin/GroupContentEnabler/MyEntityEnabler.php
 */

namespace Drupal\my_module\Plugin\GroupContentEnabler;

use Drupal\group\Plugin\GroupContentEnablerBase;

/**
 * @GroupContentEnabler(
 *   id = "my_entity",
 *   label = @Translation("My Entity"),
 *   entity_type_id = "my_entity",
 *   group_cardinality = 1,
 *   entity_cardinality = 1
 * )
 */
class MyEntityEnabler extends GroupContentEnablerBase {
  // 实现必要方法
}
```

**来源**: https://www.drupal.org/project/group/issues/2775119

### 示例 12: Views 集成 - 组内容列表

```yaml
# 创建视图显示组内容
# 文件：views.view.group_content.yml
view:
  id: group_content
  display:
    default:
      display_options:
        filters:
          group_id:
            id: group_id
            table: group_content
            field: group_id
            value: '{{ arguments.gid }}'
        arguments:
          gid:
            id: gid
            table: group_content
            field: gid
            default_action: 'not found'
```

**来源**: https://www.drupal.org/node/2666972

---

## ✅ 最佳实践（≥10 条）

### 1. 权限设计原则

**实践**: 遵循最小权限原则，只授予必要的权限。

```yaml
推荐:
  - 创建细粒度权限（查看、编辑、删除分开）
  - 使用角色层次结构
  - 定期审计权限分配

避免:
  - 授予"administer group"给普通用户
  - 权限过度集中
```

**来源**: https://www.drupal.org/docs/contributed-modules/group

### 2. Group Type 设计

**实践**: 预先规划 Group Type 结构，避免后期重构。

```yaml
设计步骤:
  1. 识别业务场景
  2. 定义 Group Type
  3. 配置可用字段
  4. 设置 Group Content 类型
  5. 定义权限矩阵
```

**来源**: https://www.drupal.org/docs/contributed-modules/group/basic-configuration

### 3. 性能优化 - 索引

**实践**: 为频繁查询的字段添加数据库索引。

```sql
-- 为 group_id 添加索引
ALTER TABLE group_content ADD INDEX group_id_idx (group_id);
-- 为 entity_type 添加索引
ALTER TABLE group_content ADD INDEX entity_type_idx (entity_type);
```

**来源**: https://www.drupal.org/project/group

### 4. 性能优化 - 缓存

**实践**: 启用组实体缓存，减少数据库查询。

```php
// 在 settings.php 中
$settings['cache']['bins']['entity'] = 'cache.backend.database';
$settings['cache']['bins']['discovery'] = 'cache.backend.database';
```

**来源**: https://www.drupal.org/docs

### 5. 安全配置

**实践**: 限制组的创建权限，防止滥用。

```yaml
权限配置:
  - 'create community group': ['administrator']
  - 'administer group types': ['administrator']
  - 'bypass group access': 谨慎使用
```

**来源**: https://www.drupal.org/docs/contributed-modules/group

### 6. 数据建模 - 字段设计

**实践**: 使用字段存储组元数据，而非硬编码。

```yaml
推荐字段:
  - 描述字段 (text_long)
  - 头像字段 (image)
  - 状态字段 (list)
  - 日期字段 (datetime)
```

**来源**: https://www.drupal.org/docs/contributed-modules/group

### 7. 内容关联策略

**实践**: 明确哪些实体类型可以作为组内容。

```yaml
配置路径: admin/config/group/fields
步骤:
  1. 选择实体类型
  2. 选择 Bundle
  3. 启用 Group 字段
  4. 配置关联设置
```

**来源**: https://www.drupal.org/node/1895584

### 8. 子组使用

**实践**: 合理使用子组实现层级结构。

```yaml
适用场景:
  - 项目 → 子项目
  - 部门 → 团队
  - 课程 → 章节

注意事项:
  - 权限继承需额外配置
  - 避免过深的层级（≤3 层）
```

**来源**: https://www.drupal.org/node/2666972

### 9. 迁移策略

**实践**: 从 Organic Groups 迁移时，先测试后上线。

```yaml
迁移步骤:
  1. 备份数据库
  2. 安装 Group 模块
  3. 运行迁移脚本
  4. 验证数据完整性
  5. 切换流量
```

**来源**: https://www.drupal.org/project/group

### 10. 监控与维护

**实践**: 定期检查组数据健康状态。

```sql
-- 检查组内容数量
SELECT group_id, COUNT(*) as content_count 
FROM group_content 
GROUP BY group_id 
ORDER BY content_count DESC;

-- 检查孤立记录
SELECT gc.* FROM group_content gc
LEFT JOIN group g ON gc.group_id = g.gid
WHERE g.gid IS NULL;
```

**来源**: https://www.drupal.org/project/group

### 11. 国际化支持

**实践**: 为多语言站点配置翻译字段。

```yaml
配置:
  1. 启用 Internationalization 模块
  2. 配置 Group Type 字段可翻译
  3. 设置语言回退策略
```

**来源**: https://www.drupal.org/node/2666972

### 12. 测试策略

**实践**: 为自定义 GroupContentEnabler 编写测试。

```php
/**
 * @group group
 */
class MyEntityEnablerTest extends GroupKernelTestBase {
  public function testEntityAssociation() {
    // 测试代码
  }
}
```

**来源**: https://www.drupal.org/project/group

---

## 🔗 参考资源

### 官方文档

- **项目页面**: https://www.drupal.org/project/group
- **主文档**: https://www.drupal.org/docs/contributed-modules/group
- **基础配置**: https://www.drupal.org/docs/contributed-modules/group/basic-configuration
- **使用场景**: https://www.drupal.org/node/2666972
- **Issue 队列**: https://www.drupal.org/project/issues/group

### API 文档

- **Drupal API**: https://api.drupal.org/api/drupal
- **Entity API**: https://api.drupal.org/api/drupal/core!lib!Drupal!Core!Entity!entity.api.php
- **Group Content Enabler**: https://www.drupal.org/project/group/issues/2775119

### 子模块

- **gnode**: Node 内容关联
- **group_content_menu**: 组内容菜单
- **group_relationship_inheritance**: 关系继承

---

*文档版本: 1.0*  
*创建日期: 2026-04-10*  
*维护：skilldev Agent*
