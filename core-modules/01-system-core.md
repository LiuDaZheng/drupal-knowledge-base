---
name: drupal-system-core
description: Complete guide to Drupal System Core module. Covers site administration, API, services, cron, and system configuration for Drupal 11.
---

# Drupal System Core 模块完整指南

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-04  

---

## 📖 模块概述

### 简介
**System Core** 是 Drupal 最基础、最重要的核心模块之一。它提供了网站的基本功能、系统设置、API 接口和服务管理。

### 核心功能
- ✅ 站点设置与维护
- ✅ 系统 API 与服务容器
- ✅ cron 定时任务管理
- ✅ 文件与媒体管理
- ✅ 缓存系统配置
- ✅ 安全设置
- ✅ 性能优化

### 适用范围
- 所有 Drupal 站点必备
- 系统管理员必学
- 开发者基础配置
- 运维人员必备技能

---

## 🚀 安装与启用

### 默认状态
- ✅ **已内建**: System Core 是 Drupal 11 的核心模块，无需额外安装
- ⚡ **自动启用**: 在新建站点时自动启用

### 检查状态
```bash
# 查看模块状态
drush status --name=system

# 确认启用
drush pm-info system

# 通过 UI 查看
# 访问 /admin/modules
# 找到"System"并确认已勾选
```

---

## ⚙️ 核心配置

### 1. 站点设置

#### 基本配置
```bash
# 访问站点设置
# /admin/config/system/site

# 或使用 drush
drush site:set --site-name="我的站点" --site-mail="admin@example.com"
```

**关键设置**:
| 设置项 | 说明 | 建议值 |
|--------|------|--------|
| 站点名称 | 网站标题 | 清晰易记 |
| 站点邮箱 | 系统邮件地址 | admin@yourdomain.com |
| 站点描述 | 网站简介 | 50 字以内 |
| 默认时区 | 系统时区 | 根据用户需求 |

#### 维护模式
```bash
# 启用维护模式
drush svc-maintenance

# 禁用维护模式
drush svc-maintenance off

# UI: /admin/config/system/site-maintenance
```

### 2. API 与服务容器

#### 服务配置文件
```yaml
# sites/default/services.yml
services:
  # 缓存服务
  cache.default:
    class: Drupal\Core\Cache\CacheBackendInterface
    factory: cache.factory
  
  # 数据库服务
  database.connection:
    class: Drupal\Component\Database\Database
    arguments: ['@database.connection.driver']
  
  # 文件系统服务
  file_system:
    class: Drupal\Core\File\FileSystemInterface
    factory: file_system.factory
```

#### 服务示例
```php
// 获取服务容器
$service_container = \Drupal::serviceContainer();

// 获取数据库服务
$db = \Drupal::database();

// 获取缓存服务
$cache = \Drupal::cache('default');

// 获取文件系统服务
$fs = \Drupal::service('file_system');

// 获取时间服务
$time = \Drupal::time();
```

### 3. Cron 定时任务

#### 配置 Cron
```bash
# 手动运行 Cron
drush cron

# UI: /admin/config/system/cron
```

**Cron 配置**:
| 配置项 | 说明 | 推荐 |
|--------|------|------|
| 运行频率 | 定时任务执行间隔 | 每 30 分钟 |
| 邮件发送 | Cron 完成后邮件通知 | 关闭 |
| 保留日志 | 保留日志天数 | 30 天 |

**Cron 脚本示例**:
```bash
#!/bin/bash
# 运行 Drupal Cron
cd /var/www/html
php cron.php --uri=example.com
```

**Crond 配置** (Linux):
```
# 每 30 分钟运行一次
*/30 * * * * /usr/bin/php /var/www/html/cron.php --uri=example.com >> /var/log/drupal-cron.log 2>&1
```

### 4. 缓存系统

#### 缓存类型
| 缓存类型 | 说明 | 默认启用 |
|----------|------|----------|
| 页面缓存 | 完整页面缓存 | ✅ |
| 块缓存 | 区块缓存 | ✅ |
| 动态页面缓存 | 动态页面缓存 | ✅ |
| 样式表缓存 | CSS 压缩缓存 | ✅ |
| JavaScript 缓存 | JS 合并缓存 | ✅ |

#### 缓存配置
```bash
# 清除所有缓存
drush cc all

# 清除特定缓存
drush cc config

# UI: /admin/config/development/configuration/sync

# 配置缓存
#sites/default/services.yml
# 修改缓存相关配置
```

### 5. 文件系统

#### 文件目录配置
```yaml
# sites/default/default.settings.php
$config_directories['sync'] = '../config/sync';
$file_private_path = 'sites/default/files/private';
$file_public_path = 'sites/default/files';
```

**文件路径**:
```
sites/default/files/          # 公共文件
sites/default/files/private/  # 私有文件
sites/default/private/        # 私钥和配置
config/sync/                   # 配置导出
```

#### 文件上传限制
```bash
# 设置最大上传大小
# /admin/config/media/file-settings

# drush 命令
drush variable-set file_max_filesize 10485760  # 10MB
```

### 6. 安全配置

#### 安全设置
```bash
# 启用 HTTPS
# /admin/config/system/https

# 配置安全响应头
drush config-set system.site secure_page 1
```

**安全建议**:
1. ✅ 启用 HTTPS
2. ✅ 定期更新模块
3. ✅ 设置复杂密码
4. ✅ 限制访问权限
5. ✅ 配置防火墙
6. ✅ 启用 CAPTCHA

#### 访问控制
```yaml
# .htaccess (Apache)
Order Deny,Allow
Deny from all
Allow from x.x.x.x/24  # 允许特定 IP

# Nginx 配置
location ~* \.(git|svn|log|env) {
    deny all;
}
```

---

## 💻 开发示例

### 1. 访问系统服务
```php
// 获取数据库连接
$db = \Drupal::database();

// 执行查询
$users = $db->select('users', 'u')
  ->fields('u', ['uid'])
  ->condition('status', 1)
  ->execute()
  ->fetchAll(\PDO::FETCH_COLUMN);

// 插入数据
$db->insert('users')
  ->fields([
    'name' => 'John Doe',
    'mail' => 'john@example.com',
    'status' => 1,
  ])
  ->execute();
```

### 2. 缓存操作
```php
// 获取缓存服务
$cache = \Drupal::cache('default');

// 保存缓存数据
$cache->set('my_cache_key', 'cache value', Cache::PERMANENT);

// 获取缓存数据
$data = $cache->get('my_cache_key');

// 清除缓存
$cache->invalidateTags(['my-tag']);
```

### 3. 文件系统操作
```php
use Drupal\Core\File\FileSystemInterface;

/**
 * 上传文件到公共目录
 */
function upload_file($file, $destination) {
  $file_system = \Drupal::service('file_system');
  $destination_dir = $destination ?? 'public://temp';
  
  // 确保目录存在
  $file_system->prepareDirectory($destination_dir, FileSystemInterface::CREATE_DIRECTORY);
  
  // 移动文件
  $target = $file_system->realpath($destination_dir);
  $uri = $file->getFileUri();
  $file_id = \Drupal::entityTypeManager()->getStorage('file');
  $file_entity = $file_id->load($file->id());
  
  $file_system->copy($uri, $target . '/' . $file_entity->getFilename());
  
  return $target . '/' . $file_entity->getFilename();
}
```

### 4. Cron 定时任务
```php
/**
 * 实现 Hooks - cron 功能
 */
function mymodule_cron() {
  // 定时任务逻辑
  db_select('my_table', 't')
    ->fields('t', ['id'])
    ->condition('status', 0)
    ->condition('created', time() - 86400, '<')
    ->execute()
    ->fetchAll();
  
  // 更新状态
}

/**
 * 添加后台任务
 */
function mymodule_cron_batch() {
  $operations = [];
  // 添加需要批处理的任务
  $operations[] = ['mymodule_process_item', [123]];
  
  return $operations;
}
```

---

## 🎯 最佳实践

### 1. 性能优化

#### 启用静态缓存
```yaml
# sites/default/services.yml
parameters:
  kernel.debug: false  # 禁用调试模式
  service_debug_mode: 0
```

#### 优化数据库查询
```php
// 避免频繁的查询
// 错误: 在循环中进行数据库查询
foreach ($items as $item) {
  $result = db_query('SELECT * FROM table WHERE id = :id', ['id' => $item['id']]);
}

// 正确: 批量查询
$ids = array_column($items, 'id');
$result = db_query('SELECT * FROM table WHERE id IN (:in)', [':in' => $ids]);
```

### 2. 安全配置

#### 启用安全响应头
```yaml
# .htaccess
<IfModule mod_headers.c>
  Header set X-Content-Type-Options "nosniff"
  Header set X-Frame-Options "SAMEORIGIN"
  Header set X-XSS-Protection "1; mode=block"
</IfModule>
```

#### 限制文件访问
```php
// 私有文件保护
use Drupal\Core\File\FileSystemInterface;
use Drupal\Core\StreamWrapper\StreamWrapperManager;

$stream_wrapper_manager = \Drupal::service('stream_wrapper_manager');
$private_wrapper = $stream_wrapper_manager->getViaScheme('private');
```

### 3. 维护建议

#### 定期维护任务
- ✅ 每周运行一次 Cron
- ✅ 每月清理无用文件
- ✅ 每季度更新模块
- ✅ 半年进行数据库优化

#### 监控脚本
```bash
#!/bin/bash
# 检查 Drupal 健康状态
# 访问站点检查
curl -I https://example.com | head -1

# 检查缓存大小
du -sh sites/default/files/cache

# 检查日志文件
tail -n 50 watchdog.log

# 检查文件权限
find sites/default/files -type f -perm 077 | wc -l
```

---

## 📊 常见问题 (FAQ)

### Q1: 如何快速恢复缓存？
**A**:
```bash
# 清除所有缓存
drush cc all

# 清除配置缓存
drush cc config

# UI: /admin/config/development/configuration/full-sync
```

### Q2: Cron 不执行怎么办？
**A**:
1. 检查 cron 是否启用: `/admin/config/system/cron`
2. 检查 cron 设置频率
3. 手动运行: `drush cron`
4. 检查服务器定时任务配置

### Q3: 如何优化站点性能？
**A**:
- 启用所有缓存
- 压缩 CSS/JS
- 使用 CDN
- 优化数据库查询
- 启用 OPcache
- 使用页面缓存

### Q4: 文件上传失败怎么办？
**A**:
1. 检查 PHP 配置 (`upload_max_filesize`)
2. 检查文件权限
3. 检查磁盘空间
4. 查看错误日志

### Q5: 如何查看系统服务？
**A**:
```bash
# 查看所有服务
drush service-list

# 查看特定服务
drush service-list --name=database

# UI: /admin/modules/services
```

---

## 🔄 模块依赖关系

### System Core 核心依赖
```
System Core
├── Database (数据库)
├── Cache (缓存)
├── Entity (实体)
├── Config (配置)
└── File (文件系统)
```

### 其他模块依赖 System Core
```
Node
├── System Core (必需)
├── Field (可选)
└── Views (可选)

User
├── System Core (必需)
└── Access (必需)

Views
├── System Core (必需)
├── Entity (必需)
└── Config (必需)
```

---

## 🔗 相关链接

- [Drupal System Module 官方文档](https://api.drupal.org/api/drupal/modules!system!system.api.php)
- [Drupal API 参考](https://api.drupal.org/api/drupal/!drupal.api.php)
- [Drupal 服务容器指南](https://www.drupal.org/docs/8/api/dependency-injection-and-service-container)
- [Drupal 缓存系统](https://www.drupal.org/docs/8/api/cache-system)
- [Drupal 文件系统 API](https://api.drupal.org/api/drupal/core!lib!Drupal!Core!File!FileSystem.php)

---

## 📝 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| 1.0 | 2026-04-04 | 初始化文档 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-04

---

*下一篇*: [Node 内容系统](core-modules/02-node.md)  
*返回*: [核心模块索引](core-modules/00-index.md)
