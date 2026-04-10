# Drupal 编码规范最佳实践

> **核心原则**: 代码质量决定可维护性

**Drupal 版本**: 10.x, 11.x, 12.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-07  
**参考标准**: Drupal Coding Standards

---

## 📖 Drupal 编码规范概述

### 1.1 为什么需要编码规范

**编码规范的作用**：
- 提高代码可读性
- 便于团队协作
- 降低维护成本
- 减少 Bug
- 提升代码质量

**Drupal 编码标准**：
- **PSR-12**: PHP 编码规范基础
- **Drupal Specific**: Drupal 专用规范
- **社区约定**: 社区通用实践

**来源**: [Drupal Coding Standards](https://www.drupal.org/docs/develop/standards)

### 1.2 代码风格目标

- **一致性** - 所有代码风格统一
- **清晰性** - 代码目的明确
- **简洁性** - 避免过度设计
- **可测试性** - 便于单元测试

---

## 🎯 命名规范

### 2.1 命名约定

#### 变量命名

**✅ 推荐**:
```php
// 小驼峰命名（camelCase）
$node_title
$user_name
$is_published
$items_array
```

**❌ 不推荐**:
```php
// 下划线命名（snake_case）- 避免使用
$node_title
$user_name

// 匈牙利命名法 - 避免使用
$strNode
$arrItems
```

#### 类命名

**✅ 推荐**:
```php
// 大驼峰命名（PascalCase）
namespace Drupal\example_module;

class ExampleController {
  public function exampleMethod() {
  }
}
```

**❌ 不推荐**:
```php
// 小写或下划线
class example_controller {
}
```

#### 函数命名

**✅ 推荐**:
```php
// 小驼峰命名
function example_load_node($nid) {
  return Node::load($nid);
}

// 钩子函数 (snake_case)
function example_module_cron() {
  // 钩子函数使用下划线命名
}
```

#### 常量命名

**✅ 推荐**:
```php
// 全大写下划线
const MAX_ITEMS = 100;
const DEFAULT_TIMEOUT = 30;
```

#### 文件命名

**✅ 推荐**:
```php
// 小写 + Snake_case
example_module.module
example_module.info.yml
example_module.services.yml
```

---

### 2.2 命名最佳实践

#### 有意义的名称

**✅ 推荐**:
```php
$user_id
$node_title
$is_active
$max_retry_attempts
```

**❌ 不推荐**:
```php
$a
$b
$c
$x  // 无意义的单字母
```

#### 避免保留字

**✅ 推荐**:
```php
class MyDataObject {
  protected $data;
}
```

**❌ 不推荐**:
```php
class Data {  // 避免与 Drupal 核心类冲突
  protected $data;
}
```

---

## 🏗️ 代码结构

### 3.1 模块结构

**推荐目录结构**：
```
example_module/
├── example_module.info.yml      # 模块配置文件
├── example_module.install       # 安装迁移文件
├── example_module.module        # 模块主文件
├── src/
│   ├── Controller/
│   │   └── ExampleController.php
│   ├── Plugin/
│   │   └── Block/
│   │       └── ExampleBlock.php
│   └── Entity/
│       └── ExampleEntity.php
├── config/
│   └── install/
│       └── example_module.settings.yml
├── templates/
│   └── example-block.html.twig
├── tests/
│   └── src/Functional/
│       └── ExampleTest.php
└── README.md
```

**源文件组织规则**：

| 文件夹 | 用途 | 命名规范 |
|--------|------|---------|
| `src/` | PHP 源代码 | PSR-4 命名空间 |
| `config/` | 配置导出 | snake_case |
| `templates/` | Twig 模板 | snake_case |
| `tests/` | 单元测试 | 与源码对应 |

#### PSR-4 命名空间

**✅ 推荐**:
```php
namespace Drupal\example_module;

use Drupal\node\Entity\Node;

class ExampleController {
  // 代码
}
```

**❌ 不推荐**:
```php
namespace Drupal;  // 避免与核心冲突
```

---

### 3.2 文件布局

#### 文件顶部注释

**✅ 推荐**:
```php
<?php

/**
 * @file
 * Example Module.
 *
 * Provides example functionality.
 *
 * @see hook_menu()
 * @see hook_help()
 */

namespace Drupal\example_module;
```

#### 导入语句

**✅ 推荐**:
```php
namespace Drupal\example_module;

use Drupal\Core\Entity\ContentEntityBase;
use Drupal\Core\Form\FormBase;
use Drupal\Core\Form\FormStateInterface;
```

**❌ 不推荐**:
```php
namespace Drupal\example_module;

use Drupal\Core\Entity\Entity;  // 避免过度导入
```

#### 使用 `use` 语句顺序

**✅ 推荐**:
```php
// 1. Drupal 核心类
use Drupal\Core\Entity\EntityInterface;

// 2. Drupal 模块类（按模块字母顺序）
use Drupal\example_module\Plugin\ExamplePlugin;

// 3. 第三方库
use Symfony\Component\HttpFoundation\Request;
```

---

## 📝 代码格式

### 4.1 缩进和换行

**✅ 推荐**:
```php
if ($condition) {
  // 4 个空格缩进
  $result = do_something();
  
  // 空行分隔逻辑块
  $another_result = do_another_thing();
}

// 函数之间空一行
function another_function() {
  // ...
}
```

**❌ 不推荐**:
```php
if($condition){  // 缺少空格
  $result=do_something();  // 缺少空格
   $another_result=do_another_thing();  // 错误缩进
}
```

#### 行宽限制

**✅ 推荐**：
```php
// 每行不超过 120 字符
if ($this->checkUserPermission() && $user->hasAccess('view') && $node->isPublished()) {
  $result = do_something();
}
```

**❌ 不推荐**:
```php
// 超过 120 字符的长行
if ($this->checkUserPermission() && $user->hasAccess('view') && $node->isPublished() && $entity->hasField()) {
  $result = do_something();
}
```

#### 数组格式

**✅ 推荐**：
```php
$array = [
  'key1' => 'value1',
  'key2' => 'value2',
];

$mixed_array = [
  'string' => 'value',
  123,
  true,
];
```

**❌ 不推荐**:
```php
// 单行数组
$array = ['key1' => 'value1', 'key2' => 'value2'];

// 混合格式
$array = [
  'key1' => 'value1',
  'key2' => 'value2',
];
```

---

### 4.2 控制结构

#### if/else 结构

**✅ 推荐**:
```php
if ($condition) {
  $result = $value1;
} elseif ($other_condition) {
  $result = $value2;
} else {
  $result = $value3;
}
```

**❌ 不推荐**:
```php
if($condition){  // 缺少空格
  $result=$value1;  // 缺少空格
}
elseif($other_condition){  // elseif 应换行
  $result=$value2;
}
```

#### switch 结构

**✅ 推荐**:
```php
switch ($status) {
  case 'active':
    $result = 'Active status';
    break;
  case 'inactive':
    $result = 'Inactive status';
    break;
  default:
    $result = 'Unknown status';
}
```

**❌ 不推荐**:
```php
switch($status){  // 缺少空格
  case'active':  // 缺少空格
    $result='Active status';
    break;
}
```

#### 循环结构

**✅ 推荐**:
```php
foreach ($items as $key => $item) {
  if ($item->isActive()) {
    print $item->label();
  }
}
```

**❌ 不推荐**:
```php
foreach($items as $key=>$item){  // 缺少空格
  if($item->isActive()){print $item->label();}  // 单行语句
}
```

---

## 🔒 安全编码

### 5.1 XSS 防护

#### 输出转义

**✅ 推荐**:
```php
// ✅ 使用 Twig 自动转义
{{ user_input }}

// ✅ 在 PHP 中转义
print check_plain($user_input);

// ✅ 过滤 HTML
print check_markup($user_input, 'full_html');
```

**❌ 不推荐**:
```php
// ❌ 直接输出不安全
print $user_input;

// ❌ 使用 unsafe_filter
print filter_xss($input);  // 旧 API，避免使用
```

#### 安全函数

```php
// 转义 HTML 实体
check_plain($string);

// 过滤 HTML
check_markup($string, $format);

// 转义 URL
drupal_encode_path($path);

// 转义 URL 查询参数
drupal_static_variable($key);
```

---

### 5.2 SQL 注入防护

#### 参数化查询

**✅ 推荐**:
```php
// ✅ 使用参数化查询
$query = "SELECT * FROM {node} WHERE status = :status";
$result = db_query($query, [':status' => 1]);

// 或使用 Query API
$query = \Drupal::entityQuery('node')
  ->condition('status', 1);
```

**❌ 不推荐**:
```php
// ❌ 字符串拼接（SQL 注入风险）
$query = "SELECT * FROM {node} WHERE status = '$status'";
$result = db_query($query);
```

#### 安全函数

```php
// 安全的数据库查询
db_query($query, $args);

// 安全的删除
db_delete('user')->condition('id', $uid)->execute();

// 安全的插入
db_insert('node')
  ->fields(['title' => $title, 'status' => 1])
  ->execute();
```

---

### 5.3 CSRF 防护

**✅ 推荐**:
```php
// 表单中自动包含 CSRF 令牌
$build['actions']['submit'] = [
  '#type' => 'submit',
  '#value' => t('Submit'),
];

// 验证表单令牌
if (!\Drupal::request()->hasToken('form_key')) {
  throw new \Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException();
}
```

---

## 🧪 测试代码

### 6.1 单元测试

**✅ 推荐**:
```php
namespace Drupal\Tests\example_module\Functional;

use Drupal\Tests\BrowserTestBase;

class ExampleFunctionalTest extends BrowserTestBase {
  protected static $modules = ['example_module'];
  
  public function testExampleFeature() {
    // 准备数据
    $node = \Drupal\node\Entity\Node::create([
      'title' => 'Test Node',
      'type' => 'article',
    ]);
    $node->save();
    
    // 测试功能
    $session = $this->getSession();
    $page = $session->getPage();
    
    // 断言
    $this->assertNotNull($node);
  }
}
```

**测试命名规范**:
```php
// 测试方法命名：testXXX()
public function testNodeLoad() {}
public function testUserAccess() {}
public function testConfiguration() {}
```

---

## 🔍 代码质量

### 7.1 静态分析

**使用 PHPStan**:
```bash
# 安装
composer require --dev phpstan/phpstan

# 配置
# phpstan.neon
parameters:
  level: 5  # 或根据团队需求调整
  paths:
    - src/

# 运行
vendor/bin/phpstan analyse
```

**使用 PHPCodeSniffer**:
```bash
# 安装 Drupal 编码标准
composer require --dev drupal/coder

# 运行
./vendor/bin/phpcs --standard=Drupal --ignore=vendor .
```

### 7.2 性能检查

**避免常见性能问题**:
```php
// ❌ 循环中执行数据库查询
foreach ($nodes as $node) {
  $related = db_query("SELECT * FROM {related} WHERE nid = ?", [$node->id()])
    ->fetchField();
}

// ✅ 批量查询
$node_ids = array_map(function($node) {
  return $node->id();
}, $nodes);

$related = db_query("SELECT * FROM {related} WHERE nid IN (:ids)", [
  ':ids' => $node_ids,
])->fetchAllKeyMap();
```

---

## 📚 文档

### 8.1 代码注释

**✅ 推荐**:
```php
/**
 * Load a node by ID.
 *
 * @param int $nid
 *   The node ID.
 * @return Node|null
 *   The node object, or NULL if not found.
 *
 * @see Node::load()
 */
function example_load_node($nid) {
  return Node::load($nid);
}
```

**注释类型**:
- `//` - 单行注释
- `/* */` - 多行注释（用于函数文档）
- `@param` - 参数说明
- `@return` - 返回值说明
- `@see` - 参考链接

---

## 🚀 开发工作流

### 9.1 版本控制

**Git 提交规范**:
```bash
# 提交信息格式
<type>: <subject>

# 类型
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式
refactor: 重构
test: 测试
chore: 维护

# 示例
feat: 添加用户自定义字段支持
fix: 修复节点加载时的缓存问题
docs: 更新 API 文档
```

**提交消息模板**:
```markdown
### Fixed
- 修复节点加载问题
- 修复缓存过期问题

### Added
- 新增自定义字段功能
- 新增单元测试

### Changed
- 重构代码结构
- 更新依赖版本
```

### 9.2 代码审查

**审查清单**:
- [ ] 代码符合 Drupal 编码规范
- [ ] 命名清晰易懂
- [ ] 注释完整准确
- [ ] 测试覆盖充分
- [ ] 安全性检查通过
- [ ] 性能优化到位
- [ ] 无重复代码
- [ ] 文档已更新

---

## 📊 常用检查命令

### 10.1 Drush 代码检查

```bash
# 检查代码风格
drush csh

# 运行静态分析
drush php:eval "phpstan analyse src/"

# 检查数据库更新
drush pm:update-status
```

### 10.2 Composer 检查

```bash
# 检查依赖
composer validate

# 检查安全漏洞
composer audit --no-dev

# 更新依赖
composer update
```

---

## 🔗 参考资源

### 官方文档
- [ Drupal Coding Standards](https://www.drupal.org/docs/develop/standards) - Drupal 编码规范
- [PSR-12](https://www.php-fig.org/psr/psr-12/) - PHP 编码规范
- [Drupal API Documentation](https://api.drupal.org/api/drupal/) - Drupal API 文档

### 工具
- [PHPStan](https://phpstan.org/) - 静态分析工具
- [PHPCS](https://github.com/squizlabs/PHP_CodeSniffer) - 代码风格检查
- [PHP CS Fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer) - 代码自动修复

**来源**: Drupal.org 官方文档 + 社区资源

---

## 📅 更新日志

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-07 | 初始化文档 |

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-07  
**维护**: OpenClaw

*所有编码规范均基于 Drupal.org 官方文档和 PSR-12 标准*
