# Drupal 运维最佳实践

> 来源：Drupal 官方文档 (drupal.org/docs)  
> 最后更新：2026-04-10  
> 适用版本：Drupal 8/9/10/11

---

## 目录

1. [性能优化](#1-性能优化)
2. [安全加固](#2-安全加固)
3. [备份恢复](#3-备份恢复)
4. [监控日志](#4-监控日志)

---

## 1. 性能优化

### 1.1 缓存配置

**核心原则**：
- Drupal 内置多层缓存系统
- 合理使用缓存可显著提升性能
- 不同环境使用不同缓存策略

**缓存层级**：

| 层级 | 说明 | 配置位置 |
|------|------|---------|
| 页面缓存 | 整页缓存 | 性能配置页面 |
| 块缓存 | 块级缓存 | 块配置 |
| 实体缓存 | 节点/用户等实体 | 实体 API |
| 视图缓存 | Views 查询结果 | Views 配置 |
| 数据缓存 | 通用数据存储 | Cache API |

**生产环境配置**：

```yaml
# sites/default/settings.php
$settings['cache']['bins']['default'] = 'cache.backend.database';
$settings['cache']['bins']['discovery'] = 'cache.backend.database';
$settings['cache']['bins']['config'] = 'cache.backend.database';

# 启用页面缓存
$settings['cache']['bins']['page'] = 'cache.backend.null';

# 使用 Redis（推荐）
$settings['redis.connection']['host'] = '127.0.0.1';
$settings['redis.connection']['port'] = 6379;
$settings['cache']['bins']['default'] = 'cache.backend.redis';
```

**最佳实践**：

1. **开发环境**：禁用页面缓存，启用 Twig 调试
2. **生产环境**：启用所有缓存，使用外部缓存后端
3. **缓存清除**：使用 Drush 命令批量清除
4. **缓存策略**：根据内容更新频率设置缓存时间

**Drush 缓存命令**：
```bash
# 清除所有缓存
drush cr

# 清除特定缓存
drush cache:rebuild css-js
drush cache:rebuild twig

# 查看缓存统计
drush cache-stats
```

**验证方法**：
```bash
# 检查缓存是否启用
drush config:get system.performance cache

# 测试页面缓存
curl -I https://example.com
# 查看 X-Drupal-Cache 响应头
```

**参考**：
- https://www.drupal.org/docs/7/managing-site-performance-and-scalability/caching-to-improve-performance/caching-overview

---

### 1.2 数据库优化

**核心原则**：
- 优化数据库查询是性能关键
- 使用索引加速查询
- 定期维护数据库

**优化策略**：

| 策略 | 说明 | 影响 |
|------|------|------|
| 查询优化 | 减少复杂查询 | 高 |
| 索引添加 | 加速常用查询 | 高 |
| 表维护 | 定期优化表 | 中 |
| 连接池 | 复用数据库连接 | 中 |
| 读写分离 | 分离读写操作 | 高 |

**MySQL 优化配置**：
```ini
# /etc/my.cnf 或 /etc/mysql/my.cnf
[mysqld]
# 内存配置
innodb_buffer_pool_size = 1G
key_buffer_size = 256M

# 连接配置
max_connections = 200
thread_cache_size = 50

# 查询缓存
query_cache_type = 1
query_cache_size = 64M

# 日志配置
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

**Drupal 特定优化**：

1. **禁用无用模块**：减少数据库表和操作
2. **优化 Views**：为 Views 查询添加索引
3. **批量操作**：使用批处理 API 处理大量数据
4. **延迟加载**：按需加载数据

**监控查询**：
```sql
-- 查看慢查询
SELECT * FROM mysql.slow_log;

-- 分析查询
EXPLAIN SELECT * FROM node WHERE status = 1;

-- 优化表
OPTIMIZE TABLE node;
OPTIMIZE TABLE users;
```

**Drush 数据库命令**：
```bash
# 数据库备份
drush sql-dump > backup.sql

# 数据库恢复
drush sql-cli < backup.sql

# 执行 SQL
drush sql-query "SELECT COUNT(*) FROM node;"
```

**参考**：
- https://www.drupal.org/docs/7/managing-site-performance-and-scalability/optimizing-drupal-to-load-faster-server-mysql-caching-theming-html

---

### 1.3 CDN 配置

**核心原则**：
- CDN 将静态资源分发到边缘节点
- 减少源服务器负载
- 提升全球访问速度

**CDN 优势**：

| 优势 | 说明 |
|------|------|
| 降低延迟 | 资源从最近的节点提供 |
| 减少带宽 | 静态资源由 CDN 承担 |
| 提升可用性 | 分布式架构提高容错 |
| 安全性 | DDoS 防护和 WAF |

**配置方法**：

**方法 1：使用 CDN 模块**
```bash
# 安装 CDN 模块
drush en cdn -y

# 配置 CDN URL
drush config:set cdn.settings cdn_api_url "https://cdn.example.com"
```

**方法 2：手动配置**
```php
// sites/default/settings.php
$settings['file_private_path'] = '/var/www/files/private';
$settings['file_public_path'] = 'sites/default/files';

// CDN URL 配置
$GLOBALS['conf']['cdn']['url'] = 'https://cdn.example.com';
```

**方法 3：使用 Reverse Proxy**
```php
// sites/default/settings.php
$settings['reverse_proxy'] = TRUE;
$settings['reverse_proxy_addresses'] = ['127.0.0.1'];
$settings['page_cache_invoke_hooks'] = FALSE;
```

**最佳实践**：

1. **静态资源**：CSS、JS、图片使用 CDN
2. **缓存头**：设置合适的 Cache-Control 头
3. **版本化**：使用文件版本避免缓存问题
4. **失效策略**：配置 CDN 缓存失效规则

**验证方法**：
```bash
# 检查资源是否从 CDN 加载
curl -I https://example.com/sites/default/files/image.jpg
# 查看响应头中的 CDN 信息

# 测试全球访问速度
# 使用 webpagetest.org 或 gtmetrix.com
```

**参考**：
- https://www.drupal.org/docs/administering-a-drupal-site/managing-site-performance-and-scalability/content-delivery-network-cdn

---

### 1.4 图片优化

**核心原则**：
- 图片是页面最大负载来源
- 使用合适的图片格式和尺寸
- 启用懒加载

**优化策略**：

| 策略 | 工具/模块 | 效果 |
|------|----------|------|
| 格式转换 | WebP 模块 | 减少 30% 体积 |
| 尺寸优化 | Image Styles | 按需生成 |
| 懒加载 | Lazyload 模块 | 提升首屏速度 |
| 压缩 | Image Optimize | 减少体积 |
| CDN 分发 | CDN + 图片 | 全球加速 |

**Image Styles 配置**：

```php
// 编程方式创建图片样式
$style = ImageStyle::create([
  'name' => 'optimized_large',
  'label' => 'Optimized Large',
  'effects' => [
    [
      'name' => 'image_scale_and_crop',
      'data' => ['width' => 1200, 'height' => 800],
    ],
    [
      'name' => 'image_webp',
      'data' => ['quality' => 80],
    ],
  ],
]);
$style->save();
```

**推荐模块**：

| 模块 | 用途 |
|------|------|
| Image Optimize | 自动优化上传的图片 |
| WebP | 生成 WebP 格式图片 |
| Lazyload | 图片懒加载 |
| Responsive Images | 响应式图片 |
| Imageinfo Cache | 预生成图片样式 |

**最佳实践**：

1. **上传前优化**：限制上传尺寸和质量
2. **多尺寸生成**：为不同场景生成多种尺寸
3. **WebP 优先**：支持 WebP 的浏览器优先使用
4. **懒加载**：视口外图片延迟加载

**验证方法**：
```bash
# 检查图片大小
ls -lh sites/default/files/styles/large/public/

# 测试图片加载速度
# 使用 Chrome DevTools Network 面板
```

**参考**：
- https://www.drupal.org/project/optipic
- https://www.drupal.org/project/imageinfo_cache

---

### 1.5 页面加载优化

**核心原则**：
- 减少 HTTP 请求数
- 压缩传输数据
- 优化渲染路径

**优化清单**：

| 优化项 | 方法 | 预期提升 |
|--------|------|---------|
| CSS/JS 聚合 | 启用核心聚合 | 20-40% |
| Gzip 压缩 | 服务器配置 | 60-80% |
| HTTP/2 | 升级服务器 | 10-30% |
| 关键 CSS | 内联关键样式 | 10-20% |
| 延迟加载 | 非关键资源延迟 | 10-30% |

**Drupal 配置**：
```php
// sites/default/settings.php
// 启用 CSS/JS 聚合
$config['system.performance']['css']['preprocess'] = 1;
$config['system.performance']['js']['preprocess'] = 1;

// 启用页面缓存
$config['system.performance']['cache']['page']['max_age'] = 900;
```

**服务器配置（Nginx）**：
```nginx
# Gzip 压缩
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

# HTTP/2
listen 443 ssl http2;

# 静态资源缓存
location ~* \.(jpg|jpeg|png|gif|ico|css|js|pdf|txt)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

**性能测试工具**：

| 工具 | 用途 |
|------|------|
| Google PageSpeed Insights | 性能评分 |
| GTmetrix | 详细性能分析 |
| WebPageTest | 全球多地测试 |
| Lighthouse | Chrome 内置工具 |

**验证方法**：
```bash
# 使用 curl 测试加载时间
curl -w "@curl-format.txt" -o /dev/null -s https://example.com

# curl-format.txt 内容：
# time_namelookup:  %{time_namelookup}\n
# time_connect:     %{time_connect}\n
# time_starttransfer: %{time_starttransfer}\n
# time_total:       %{time_total}\n
```

**参考**：
- https://www.drupal.org/docs/7/managing-site-performance-and-scalability/optimizing-drupal-to-load-faster-server-mysql-caching-theming-html

---

## 2. 安全加固

### 2.1 权限配置

**核心原则**：
- 最小权限原则
- 定期审查权限
- 分离管理角色

**默认角色**：

| 角色 | 说明 | 权限建议 |
|------|------|---------|
| Anonymous | 匿名用户 | 仅查看公开内容 |
| Authenticated | 认证用户 | 基础交互权限 |
| Administrator | 管理员 | 完整管理权限 |

**权限配置最佳实践**：

1. **审查默认权限**：
   - 访问 People → Permissions
   - 确保匿名用户和认证用户仅有必要权限
   - 移除不必要的危险权限（如"administer users"）

2. **创建自定义角色**：
   ```bash
   # 使用 Drush 创建角色
   drush role:create 'content_editor' 'Content Editor'
   drush role:addperm 'content_editor' 'create article content'
   drush role:addperm 'content_editor' 'edit own article content'
   ```

3. **权限审计**：
   ```bash
   # 列出所有角色
   drush role:list

   # 列出角色权限
   drush role:list --format=yaml
   ```

**高风险权限**：

| 权限 | 风险 | 建议 |
|------|------|------|
| Administer users | 高 | 仅限超级管理员 |
| Bypass node access | 高 | 谨慎分配 |
| Administer permissions | 高 | 仅限超级管理员 |
| Execute PHP code | 极高 | 永远不要分配 |

**参考**：
- https://www.drupal.org/docs/administering-a-drupal-site/security-in-drupal/secure-configuration-for-site-builders

---

### 2.2 用户安全

**核心原则**：
- 强密码策略
- 限制登录尝试
- 监控异常行为

**密码策略**：

| 要求 | 配置方法 |
|------|---------|
| 最小长度 | 用户配置中设置 |
| 复杂度 | Password Policy 模块 |
| 历史记录 | 防止重用旧密码 |
| 过期策略 | 定期强制更改 |

**推荐模块**：

| 模块 | 用途 |
|------|------|
| Password Policy | 密码策略管理 |
| Login Security | 登录安全控制 |
| Two-factor Authentication | 双因素认证 |
| Security Kit | 综合安全工具 |

**配置示例**：
```php
// sites/default/settings.php
// 限制登录尝试
$settings['user_login_security'] = [
  'max_attempts' => 5,
  'lockout_time' => 300, // 5 分钟
];

// 强制 HTTPS
$settings['https'] = TRUE;
$ini['session.cookie_secure'] = 1;
```

**最佳实践**：

1. **启用双因素认证**：管理员必须使用 2FA
2. **会话管理**：设置合理的会话超时
3. **IP 限制**：管理后台限制 IP 访问
4. **审计日志**：记录所有管理操作

**验证方法**：
```bash
# 检查用户角色
drush user:info --role=administrator

# 查看最近登录
drush sql-query "SELECT name, login FROM users_field_data ORDER BY login DESC LIMIT 10;"
```

**参考**：
- https://www.drupal.org/docs/administering-a-drupal-site/security-in-drupal/authentication-improvements

---

### 2.3 表单安全

**核心原则**：
- 所有表单必须有 CSRF 保护
- 输入验证和清理
- 防止自动化提交

**CSRF 保护**：

Drupal 核心自动为表单添加 CSRF 令牌：

```php
// 表单构建器自动处理
$form['#token'] = \Drupal::csrfToken()->get();

// 验证令牌
if (!\Drupal::csrfToken()->validate($token)) {
  throw new \Drupal\Core\Session\AccessDeniedHttpException();
}
```

**输入验证**：

```php
// 使用 Drupal API 清理输入
$form['title'] = [
  '#type' => 'textfield',
  '#title' => $this->t('Title'),
  '#required' => TRUE,
  '#maxlength' => 255,
  '#element_validate' => ['::validateTitle'],
];

public function validateTitle(&$element, FormStateInterface $form_state) {
  $value = trim($element['#value']);
  if (strlen($value) < 3) {
    $form_state->setError($element, 'Title must be at least 3 characters.');
  }
  // 清理 HTML
  $value = \Drupal\Component\Utility\Xss::filter($value);
  $form_state->setValue($element, $value);
}
```

**防垃圾邮件**：

| 方法 | 模块 | 说明 |
|------|------|------|
| CAPTCHA | CAPTCHA | 图像验证 |
| Honeypot | Honeypot | 隐藏字段检测 |
| reCAPTCHA | reCAPTCHA | Google 验证 |
| Mollom | Mollom | 内容分析 |

**最佳实践**：

1. **始终使用表单 API**：不要手动构建表单 HTML
2. **验证所有输入**：客户端验证 + 服务器端验证
3. **限制提交频率**：防止暴力提交
4. **日志异常**：记录可疑的表单提交

**参考**：
- https://www.drupal.org/docs/administering-a-drupal-site/security-in-drupal

---

### 2.4 文件上传安全

**核心原则**：
- 限制可上传的文件类型
- 扫描上传的文件
- 隔离存储上传文件

**配置方法**：

**1. 文件类型限制**：
```php
// 在字段配置中
$form['upload'] = [
  '#type' => 'file',
  '#title' => $this->t('Upload'),
  '#upload_validators' => [
    'file_validate_extensions' => ['jpg png gif pdf'],
    'file_validate_size' => [5 * 1024 * 1024], // 5MB
  ],
];
```

**2. 文件权限配置**：
```php
// sites/default/settings.php
// 私有文件路径
$settings['file_private_path'] = '/var/www/files/private';

// 临时文件路径
$settings['file_temp_path'] = '/var/www/files/tmp';
```

**3. 文件验证**：
```php
use Drupal\Component\Utility\Bytes;
use Drupal\Component\Utility\Environment;

// 验证文件扩展名
$allowed_extensions = ['jpg', 'jpeg', 'png', 'gif', 'pdf'];
if (!Environment::isExecutable($file_name)) {
  // 拒绝可执行文件
}

// 验证 MIME 类型
$file_info = getimagesize($file_path);
if ($file_info === FALSE) {
  // 不是有效的图片
}
```

**最佳实践**：

1. **白名单策略**：只允许明确列出的扩展名
2. **重命名文件**：使用随机文件名存储
3. **隔离存储**：上传文件放在 Web 根目录外
4. **扫描病毒**：集成病毒扫描服务
5. **权限设置**：上传目录权限 755，文件 644

**目录权限**：
```bash
# 设置正确的权限
chmod 755 sites/default/files
chmod 644 sites/default/files/*
chown -R www-data:www-data sites/default/files
```

**参考**：
- https://www.drupal.org/docs/administering-a-drupal-site/security-in-drupal/securing-file-permissions-and-ownership

---

### 2.5 定期更新

**核心原则**：
- 及时应用安全更新
- 订阅安全公告
- 测试后部署

**更新策略**：

| 类型 | 频率 | 说明 |
|------|------|------|
| 核心更新 | 每月 | 跟随 Drupal 发布周期 |
| 模块更新 | 每周 | 关注安全公告 |
| 主题更新 | 每月 | 跟随模块更新 |
| 依赖更新 | 每月 | Composer 依赖 |

**安全公告订阅**：

1. **Drupal 安全团队**：https://www.drupal.org/security
2. **RSS 订阅**：https://www.drupal.org/security/rss.xml
3. **Twitter**：@DrupalSecurity
4. **邮件列表**：Drupal Security Team

**更新流程**：

```bash
# 1. 备份站点
drush sql-dump > backup-$(date +%Y%m%d).sql
rsync -av sites/default/files/ backup/files/

# 2. 检查可用更新
drush updb -n  # 数据库更新预览
drush pm:update -n  # 代码更新预览

# 3. 应用更新（测试环境）
drush updb -y
drush pm:update -y
drush cr

# 4. 测试功能
# 5. 部署到生产环境
```

**Composer 更新**：
```bash
# 检查过时依赖
composer outdated

# 更新 Drupal 核心
composer update drupal/core --with-dependencies

# 更新所有依赖
composer update

# 检查安全漏洞
composer audit
```

**最佳实践**：

1. **维护更新日志**：记录所有更新
2. **测试环境先行**：先在测试环境验证
3. **回滚计划**：准备快速回滚方案
4. **监控异常**：更新后密切监控

**参考**：
- https://www.drupal.org/docs/updating-drupal
- https://www.drupal.org/security

---

## 3. 备份恢复

### 3.1 数据库备份

**核心原则**：
- 定期自动备份
- 多地点存储
- 定期测试恢复

**备份方法**：

**方法 1：Drush**
```bash
# 完整备份
drush sql-dump --result-file=backup-$(date +%Y%m%d-%H%M%S).sql

# 仅结构
drush sql-dump --structure-tables-key=all --result-file=structure.sql

# 压缩备份
drush sql-dump --gzip --result-file=backup.sql.gz
```

**方法 2：mysqldump**
```bash
# 完整备份
mysqldump -u [user] -p [database] > backup.sql

# 压缩备份
mysqldump -u [user] -p [database] | gzip > backup.sql.gz

# 仅特定表
mysqldump -u [user] -p [database] node users > partial.sql
```

**方法 3：Backup and Migrate 模块**
```bash
# 启用模块
drush en backup_migrate -y

# 创建备份
drush bam-backup

# 配置自动备份
# 访问 /admin/config/development/backup_migrate
```

**备份策略**：

| 频率 | 保留策略 | 存储位置 |
|------|---------|---------|
| 每小时 | 保留 24 个 | 本地 + 云 |
| 每天 | 保留 7 个 | 本地 + 云 + 离线 |
| 每周 | 保留 4 个 | 云 + 离线 |
| 每月 | 保留 12 个 | 离线 |

**自动化脚本**：
```bash
#!/bin/bash
# backup-database.sh

BACKUP_DIR="/var/backups/drupal"
DATE=$(date +%Y%m%d-%H%M%S)
DB_NAME="drupal"
DB_USER="drupal"

# 创建备份
mysqldump -u $DB_USER -p $DB_NAME | gzip > $BACKUP_DIR/db-$DATE.sql.gz

# 删除 7 天前的备份
find $BACKUP_DIR -name "db-*.sql.gz" -mtime +7 -delete

# 同步到远程存储
rsync -av $BACKUP_DIR/ user@backup-server:/backups/drupal/
```

**参考**：
- https://www.drupal.org/docs/updating-drupal/how-to-back-up-your-drupal-site
- https://www.drupal.org/project/backup_migrate

---

### 3.2 文件备份

**核心原则**：
- 备份所有用户文件
- 包含配置文件
- 版本控制代码

**备份内容**：

| 目录 | 内容 | 备份频率 |
|------|------|---------|
| sites/default/files | 用户上传文件 | 每天 |
| sites/default/settings.php | 站点配置 | 每次变更 |
| modules/custom | 自定义模块 | 版本控制 |
| themes/custom | 自定义主题 | 版本控制 |

**备份脚本**：
```bash
#!/bin/bash
# backup-files.sh

DRUPAL_ROOT="/var/www/drupal"
BACKUP_DIR="/var/backups/drupal"
DATE=$(date +%Y%m%d-%H%M%S)

# 备份文件目录
tar -czf $BACKUP_DIR/files-$DATE.tar.gz \
  $DRUPAL_ROOT/sites/default/files

# 备份配置文件
cp $DRUPAL_ROOT/sites/default/settings.php \
   $BACKUP_DIR/settings-$DATE.php

# 备份 services.yml
cp $DRUPAL_ROOT/sites/default/services.yml \
   $BACKUP_DIR/services-$DATE.yml

# 删除 30 天前的备份
find $BACKUP_DIR -name "files-*.tar.gz" -mtime +30 -delete
```

**版本控制**：
```bash
# Git 仓库结构
.gitignore
# 忽略的文件
sites/default/files/
sites/default/settings.php
vendor/
node_modules/

# 纳入版本控制的文件
composer.json
composer.lock
modules/custom/
themes/custom/
sites/default/services.yml
```

**云存储同步**：
```bash
# 使用 AWS S3
aws s3 sync /var/backups/drupal s3://my-bucket/drupal-backups/

# 使用 Google Cloud
gsutil -m rsync -r /var/backups/drupal gs://my-bucket/drupal-backups/

# 使用 Rclone
rclone sync /var/backups/drupal remote:drupal-backups
```

**参考**：
- https://www.drupal.org/docs/7/site-building-best-practices/backup-your-database-and-files

---

### 3.3 恢复流程

**核心原则**：
- 文档化恢复步骤
- 定期演练
- 最小化停机时间

**数据库恢复**：

```bash
# 方法 1：Drush
drush sql-cli < backup.sql

# 方法 2：MySQL
mysql -u [user] -p [database] < backup.sql

# 方法 3：压缩备份
gunzip < backup.sql.gz | mysql -u [user] -p [database]
```

**文件恢复**：
```bash
# 恢复文件目录
tar -xzf files-backup.tar.gz -C /var/www/drupal/sites/default/

# 恢复配置文件
cp settings-backup.php /var/www/drupal/sites/default/settings.php

# 设置权限
chown -R www-data:www-data /var/www/drupal/sites/default/files
chmod -R 755 /var/www/drupal/sites/default/files
```

**完整恢复流程**：

1. **准备环境**：
   ```bash
   # 创建新数据库
   mysql -u root -p
   CREATE DATABASE drupal;
   GRANT ALL ON drupal.* TO 'drupal'@'localhost';
   ```

2. **恢复数据库**：
   ```bash
   drush sql-cli < latest-backup.sql
   ```

3. **恢复文件**：
   ```bash
   tar -xzf files-backup.tar.gz -C sites/default/
   ```

4. **更新配置**：
   ```bash
   # 修改 settings.php 中的数据库连接
   # 更新 $settings['hash_salt']
   ```

5. **清除缓存**：
   ```bash
   drush cr
   ```

6. **验证站点**：
   ```bash
   drush status
   drush pm:list
   ```

**参考**：
- https://www.drupal.org/docs/7/backing-up-and-migrating-a-site/restoring-a-database-backup-command-line

---

### 3.4 灾难恢复计划

**核心原则**：
- 定义 RTO（恢复时间目标）
- 定义 RPO（恢复点目标）
- 定期测试计划

**灾难恢复计划模板**：

| 项目 | 目标 | 策略 |
|------|------|------|
| RTO | 4 小时 | 热备站点 |
| RPO | 1 小时 | 每小时备份 |
| 备份频率 | 每小时 | 自动备份 |
| 备份保留 | 30 天 | 滚动删除 |
| 测试频率 | 每季度 | 完整演练 |

**应急联系人**：

| 角色 | 姓名 | 联系方式 | 职责 |
|------|------|---------|------|
| 技术负责人 | | | 决策和协调 |
| 系统管理员 | | | 服务器恢复 |
| 数据库管理员 | | | 数据库恢复 |
| 开发人员 | | | 应用修复 |

**恢复优先级**：

1. **P0 - 关键服务**（0-1 小时）：
   - 数据库恢复
   - 核心文件恢复
   - 基本功能验证

2. **P1 - 重要服务**（1-4 小时）：
   - 完整文件恢复
   - 配置恢复
   - 集成测试

3. **P2 - 次要服务**（4-24 小时）：
   - 历史数据恢复
   - 日志恢复
   - 完整验证

**测试计划**：

```bash
# 季度恢复测试脚本
#!/bin/bash
# disaster-recovery-test.sh

echo "开始灾难恢复测试..."

# 1. 准备测试环境
# 2. 从备份恢复
# 3. 验证功能
# 4. 记录结果
# 5. 清理测试环境

echo "测试完成"
```

**文档要求**：

- [ ] 恢复步骤文档化
- [ ] 联系人列表最新
- [ ] 备份位置记录
- [ ] 测试报告存档
- [ ] 改进措施跟踪

**参考**：
- https://www.drupal.org/docs/user_guide/en/prevent-backups.html

---

## 4. 监控日志

### 4.1 系统监控

**监控指标**：

| 指标 | 阈值 | 告警级别 |
|------|------|---------|
| CPU 使用率 | > 80% | 警告 |
| 内存使用率 | > 85% | 警告 |
| 磁盘使用率 | > 90% | 严重 |
| 响应时间 | > 3s | 警告 |
| 错误率 | > 1% | 严重 |

**监控工具**：

| 工具 | 用途 | 成本 |
|------|------|------|
| New Relic | 应用性能监控 | 付费 |
| Datadog | 全栈监控 | 付费 |
| Prometheus + Grafana | 开源监控 | 免费 |
| Nagios | 基础设施监控 | 免费 |

**Drupal 监控模块**：

| 模块 | 功能 |
|------|------|
| Syslog | 系统日志记录 |
| Database Logging | 数据库日志 |
| Status Report | 状态报告 |
| Requirements | 系统要求检查 |

**配置示例**：
```php
// sites/default/settings.php
// 启用 Syslog
$config['syslog.settings']['ident'] = 'drupal';
$config['syslog.settings']['facility'] = LOG_LOCAL0;
```

**参考**：
- https://www.drupal.org/docs/administering-a-drupal-site/monitoring-and-maintenance

---

### 4.2 日志分析

**日志位置**：

| 日志类型 | 位置 |
|---------|------|
| Drupal 日志 | admin/reports/dblog |
| PHP 错误日志 | /var/log/php/error.log |
| Web 服务器日志 | /var/log/nginx/access.log |
| 数据库日志 | /var/log/mysql/error.log |
| Syslog | /var/log/syslog 或 /var/log/messages |

**日志分析命令**：
```bash
# 查看最近的 Drupal 错误
drush watchdog:show --type=error --count=50

# 查看特定类型的日志
drush watchdog:show --type=php

# 清除日志
drush watchdog:delete all

# 分析访问日志
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20

# 查找 404 错误
grep " 404 " /var/log/nginx/access.log | wc -l

# 查找慢请求
grep -E "[1-9][0-9]{2}ms" /var/log/nginx/access.log
```

**日志告警规则**：

```yaml
# Prometheus 告警规则
groups:
  - name: drupal
    rules:
      - alert: HighErrorRate
        expr: rate(drupal_errors_total[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          
      - alert: SiteDown
        expr: probe_success{job="drupal"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Drupal site is down"
```

**最佳实践**：

1. **集中日志**：使用 ELK 栈或类似工具
2. **日志轮转**：防止日志文件过大
3. **敏感信息**：避免记录敏感数据
4. **实时告警**：配置关键指标告警

**参考**：
- https://www.drupal.org/docs/administering-a-drupal-site/logging-and-monitoring

---

## 附录：运维检查清单

### 日常检查

- [ ] 检查站点可用性
- [ ] 查看错误日志
- [ ] 监控资源使用
- [ ] 验证备份完成
- [ ] 检查安全更新

### 每周检查

- [ ] 审查用户账户
- [ ] 分析性能指标
- [ ] 清理临时文件
- [ ] 更新模块（测试环境）
- [ ] 审查访问日志

### 每月检查

- [ ] 完整备份测试
- [ ] 安全审计
- [ ] 性能基准测试
- [ ] 容量规划
- [ ] 文档更新

### 每季度检查

- [ ] 灾难恢复演练
- [ ] 代码审查
- [ ] 依赖更新
- [ ] 策略审查
- [ ] 培训更新

---

*文档来源：Drupal 官方文档 (https://www.drupal.org/docs)*
