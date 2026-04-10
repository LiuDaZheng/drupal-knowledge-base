# Drupal 开发最佳实践

> 来源：Drupal 官方文档 (drupal.org/docs)  
> 最后更新：2026-04-10  
> 适用版本：Drupal 8/9/10/11

---

## 目录

1. [编码标准](#1-编码标准)
2. [模块开发最佳实践](#2-模块开发最佳实践)
3. [主题开发最佳实践](#3-主题开发最佳实践)
4. [代码审查清单](#4-代码审查清单)

---

## 1. 编码标准

### 1.1 PHP 编码标准

**核心原则**：
- Drupal 编码标准适用于 Drupal 核心及其贡献模块中的所有代码
- PHP 标准通过 PHP_CodeSniffer 强制执行
- 规则来自 PHP_CodeSniffer 项目、Drupal coder 项目和 Slevomat

**关键要求**：

| 类别 | 要求 |
|------|------|
| **命名规范** | 使用 US English 拼写（comments, names） |
| **文件组织** | 每个类一个文件，文件名与类名匹配 |
| **缩进** | 使用 2 个空格，不使用制表符 |
| **控制结构** | 大括号必须与控制结构在同一行 |
| **文档注释** | 所有函数、类、方法必须有 docblock |

**验证方法**：
```bash
# 安装 Drupal Coder
composer require drupal/coder --dev

# 运行代码检查
phpcs --standard=Drupal /path/to/module

# 自动修复
phpcbf --standard=Drupal /path/to/module
```

**参考**：
- https://www.drupal.org/docs/develop/standards/php
- https://www.drupal.org/project/coder

---

### 1.2 JavaScript 编码标准

**核心原则**：
- 使用 ESLint 强制执行 Drupal JavaScript 编码标准
- 遵循现代 ES6+ 语法规范
- 与 Drupal.behaviors 模式集成

**关键要求**：

| 类别 | 要求 |
|------|------|
| **变量声明** | 使用 const/let，避免 var |
| **命名** | 使用 camelCase 命名变量和函数 |
| **缩进** | 2 个空格 |
| **引号** | 使用单引号 |
| **分号** | 必须使用分号 |

**验证方法**：
```bash
# 安装 ESLint 配置
npm install eslint @drupal/eslint-config --save-dev

# 运行检查
npx eslint /path/to/js/files
```

**参考**：
- https://www.drupal.org/docs/develop/standards/javascript-coding-standards

---

### 1.3 CSS 编码标准

**核心原则**：
- 遵循 SMACSS 架构原则
- 使用 BEM 命名约定
- 支持 CSS 预处理器（Sass）

**关键要求**：

| 类别 | 要求 |
|------|------|
| **选择器** | 使用类选择器，避免 ID 选择器 |
| **命名** | 使用连字符分隔的小写字母（kebab-case） |
| **缩进** | 2 个空格 |
| **属性顺序** | 按逻辑分组（定位、盒模型、排版等） |
| **颜色** | 使用十六进制小写（#fff） |

**验证方法**：
```bash
# 安装 Stylelint
npm install stylelint stylelint-config-drupal --save-dev

# 运行检查
npx stylelint /path/to/css/files
```

**参考**：
- https://www.drupal.org/docs/develop/standards/css

---

### 1.4 Twig 模板规范

**核心原则**：
- Twig 模板使用 {# #} 注释标记
- 遵循 Drupal API 文档标准
- 使用 Twig-CS-Fixer 自动修复

**关键要求**：

| 类别 | 要求 |
|------|------|
| **文档块** | 模板顶部必须有 docblock（与 PHPTemplate 相同） |
| **变量命名** | 使用下划线分隔的小写字母 |
| **过滤器** | 使用管道符号 (|) 应用过滤器 |
| **宏** | 合理使用宏来复用代码 |
| **转义** | 默认启用自动转义，使用 |raw 需谨慎 |

**验证方法**：
```bash
# 安装 Twig-CS-Fixer
composer require vincentlanglet/twig-cs-fixer --dev

# 运行检查
vendor/bin/twig-cs-fixer lint /path/to/templates
```

**参考**：
- https://www.drupal.org/docs/develop/coding-standards/twig-coding-standards
- https://github.com/VincentLanglet/Twig-CS-Fixer

---

## 2. 模块开发最佳实践

### 2.1 模块结构

**标准模块结构**：
```
my_module/
├── my_module.info.yml          # 模块信息
├── my_module.routing.yml       # 路由定义
├── my_module.services.yml      # 服务定义
├── my_module.permissions.yml   # 权限定义
├── src/
│   ├── Controller/             # 控制器
│   ├── Plugin/                 # 插件
│   ├── Form/                   # 表单
│   └── EventSubscriber/        # 事件订阅器
├── config/
│   └── schema/                 # 配置模式
├── templates/                  # Twig 模板
└── my_module.module            # Hook 实现
```

**最佳实践**：

1. **模块命名**：使用小写字母和下划线，前缀避免冲突
2. **信息文件**：完整填写 .info.yml 所有字段
3. **依赖声明**：明确声明所有模块依赖
4. **版本兼容**：指定 core_version_requirement

**示例**：
```yaml
# my_module.info.yml
name: My Module
type: module
description: 'Provides custom functionality.'
core_version_requirement: ^10 || ^11
package: Custom
dependencies:
  - drupal:node
  - drupal:views
```

**参考**：
- https://www.drupal.org/docs/develop/creating-modules

---

### 2.2 Hook 使用

**核心原则**：
- Hook 允许模块与 Drupal 核心及其他模块交互
- 每个 hook 实现必须放在 .module 文件或相应的 .inc 文件中
- 使用 hook_help() 提供文档

**常用 Hook 列表**：

| Hook | 用途 | 文件位置 |
|------|------|---------|
| hook_install() | 模块安装时执行 | .module |
| hook_uninstall() | 模块卸载时执行 | .module |
| hook_menu() | 定义菜单项（D7） | .module |
| hook_form_alter() | 修改表单 | .module |
| hook_node_insert() | 节点创建后 | .module |
| hook_entity_presave() | 实体保存前 | .module |
| hook_theme() | 注册主题钩子 | .module |
| hook_permission() | 定义权限 | .module |

**最佳实践**：

1. **命名规范**：函数名必须是 `模块名_hook 名`
2. **文档完整**：每个 hook 实现必须有 docblock
3. **性能考虑**：避免在频繁调用的 hook 中执行重操作
4. **模块化**：将大型 hook 拆分到 .inc 文件

**示例**：
```php
/**
 * Implements hook_install().
 */
function my_module_install() {
  // 安装时的初始化逻辑
  \Drupal::messenger()->addStatus('My module installed successfully.');
}

/**
 * Implements hook_form_alter().
 */
function my_module_form_alter(&$form, \Drupal\Core\Form\FormStateInterface $form_state, $form_id) {
  if ($form_id == 'node_article_form') {
    // 修改文章表单
    $form['custom_field'] = [
      '#type' => 'textfield',
      '#title' => $this->t('Custom Field'),
    ];
  }
}
```

**参考**：
- https://www.drupal.org/docs/develop/creating-modules/understanding-hooks
- https://api.drupal.org/api/drupal/includes%21module.inc/group/hooks/7.x

---

### 2.3 Plugin 系统

**核心原则**：
- Plugin 系统用于扩展 Drupal 并添加新功能
- 允许模块定义新的插件类型
- 比传统 hook 更面向对象

**常见插件类型**：

| 插件类型 | 用途 | 注解 |
|---------|------|------|
| Block | 创建块 | @Block |
| Field | 自定义字段 | @FieldType |
| FieldFormatter | 字段格式化 | @FieldFormatter |
| FieldWidget | 字段小部件 | @FieldWidget |
| Views Style | Views 显示样式 | @ViewsStyle |
| Menu Link | 菜单链接 | @MenuLinkDefault |

**最佳实践**：

1. **命名空间**：使用正确的 PSR-4 命名空间
2. **注解完整**：提供完整的插件注解
3. **依赖注入**：使用依赖注入获取服务
4. **配置实体**：为可配置插件提供配置实体

**示例**：
```php
/**
 * Provides a 'My Block' block.
 *
 * @Block(
 *   id = "my_block",
 *   admin_label = @Translation("My Block"),
 *   category = @Translation("Custom")
 * )
 */
class MyBlock extends BlockBase {
  public function build() {
    return [
      '#markup' => $this->t('Hello, Drupal!'),
      '#cache' => [
        'max-age' => 0,
      ],
    ];
  }
}
```

**参考**：
- https://www.drupal.org/docs/develop/creating-modules/plugins

---

### 2.4 配置管理

**核心原则**：
- 使用配置实体管理系统设置
- 默认配置放在 config/install/ 目录
- 配置模式定义在 config/schema/ 目录

**最佳实践**：

1. **配置分离**：将配置与代码分离
2. **默认配置**：提供合理的默认值
3. **配置模式**：为所有配置定义 schema
4. **可导出性**：确保配置可通过配置管理导出

**目录结构**：
```
my_module/
├── config/
│   ├── install/
│   │   └── my_module.settings.yml
│   └── schema/
│       └── my_module.schema.yml
```

**示例**：
```yaml
# config/install/my_module.settings.yml
enabled: true
max_items: 10
cache_timeout: 3600
```

```yaml
# config/schema/my_module.schema.yml
my_module.settings:
  type: config_object
  label: 'My Module settings'
  mapping:
    enabled:
      type: boolean
      label: 'Enable module'
    max_items:
      type: integer
      label: 'Maximum items'
    cache_timeout:
      type: integer
      label: 'Cache timeout'
```

**参考**：
- https://www.drupal.org/docs/develop/creating-modules/defining-and-using-your-own-configuration-in-drupal

---

### 2.5 测试编写

**核心原则**：
- 使用 PHPUnit 编写单元测试和内核测试
- 使用 Simpletest/BrowserTest 编写功能测试
- 测试覆盖率应达到 80% 以上

**测试类型**：

| 类型 | 命名空间 | 用途 |
|------|---------|------|
| 单元测试 | \Tests\Unit | 测试单个类/方法 |
| 内核测试 | \Tests\Kernel | 测试 Drupal API |
| 功能测试 | \Tests\ExistingSite | 测试完整功能 |
| JavaScript 测试 | Nightwatch | 测试前端交互 |

**最佳实践**：

1. **测试命名**：Test 类必须以 Test 结尾
2. **断言清晰**：每个测试只验证一个行为
3. **数据清理**：测试后清理测试数据
4. **CI 集成**：在 CI/CD 中自动运行测试

**示例**：
```php
/**
 * Tests the MyBlock plugin.
 *
 * @group my_module
 */
class MyBlockTest extends KernelTestBase {
  public function testBlockBuild() {
    $block = $this->container->get('plugin.manager.block')
      ->createInstance('my_block');
    $result = $block->build();
    $this->assertStringContainsString('Hello, Drupal!', $result['#markup']);
  }
}
```

**参考**：
- https://www.drupal.org/docs/develop/testing

---

## 3. 主题开发最佳实践

### 3.1 主题结构

**标准主题结构**：
```
my_theme/
├── my_theme.info.yml         # 主题信息
├── my_theme.libraries.yml    # 库定义
├── my_theme.breakpoints.yml  # 响应式断点
├── my_theme.config.yml       # 主题配置
├── templates/                # Twig 模板
│   ├── layout/
│   ├── regions/
│   ├── blocks/
│   ├── content/
│   └── form/
├── css/
│   ├── base/
│   ├── components/
│   └── layout/
└── js/
    └── scripts.js
```

**最佳实践**：

1. **基础主题**：使用稳定（stable）或清晰（claro）作为基础
2. **信息完整**：填写 .info.yml 所有必要字段
3. **库管理**：使用 libraries.yml 管理资源
4. **模板继承**：合理覆盖核心模板

**示例**：
```yaml
# my_theme.info.yml
name: My Theme
type: theme
description: 'A custom Drupal theme.'
core_version_requirement: ^10 || ^11
base theme: stable
regions:
  header: Header
  content: Content
  footer: Footer
libraries:
  - my_theme/global-styling
```

**参考**：
- https://www.drupal.org/docs/develop/theming-drupal

---

### 3.2 Twig 调试

**调试配置**：

在 `sites/default/services.yml` 中启用 Twig 调试：
```yaml
parameters:
  twig.config:
    debug: true
    auto_reload: true
    cache: false
```

**调试技巧**：

1. **模板调试**：查看 HTML 注释中的模板建议
2. **变量打印**：使用 {{ dump(variable) }} 检查变量
3. **上下文检查**：使用 {{ _context }} 查看所有可用变量
4. **模板定位**：使用开发者工具定位模板文件

**调试输出示例**：
```html
<!-- THEME DEBUG -->
<!-- CALL: theme('node') -->
<!-- FILE NAME SUGGESTIONS:
   * node--article.html.twig
   * node--2.html.twig
   x node.html.twig
-->
<!-- BEGIN OUTPUT from 'core/modules/node/templates/node.html.twig' -->
```

**最佳实践**：

1. **开发环境**：仅在开发环境启用调试
2. **性能影响**：生产环境禁用调试
3. **安全考虑**：调试模式可能暴露敏感信息

**参考**：
- https://www.drupal.org/docs/develop/theming-drupal/twig-in-drupal/debugging-twig-templates
- https://www.drupal.org/docs/develop/theming-drupal/twig-in-drupal/locating-template-files-with-debugging

---

### 3.3 库管理

**核心原则**：
- 使用 libraries.yml 定义 CSS/JS 资源
- 支持依赖管理
- 支持条件加载

**库定义示例**：
```yaml
# my_theme.libraries.yml
global-styling:
  version: 1.0
  css:
    theme:
      css/base/reset.css: {}
      css/components/buttons.css: {}
      css/layout/grid.css: {}
  js:
    js/scripts.js: {}
  dependencies:
    - core/drupal
    - core/jquery

admin-only:
  version: 1.0
  css:
    theme:
      css/admin.css: {}
  js:
    js/admin.js: {}
```

**附加库方法**：

```php
// 在 preprocess 函数中
function my_theme_preprocess_page(&$variables) {
  $variables['#attached']['library'][] = 'my_theme/global-styling';
}

// 在控制器中
return [
  '#attached' => [
    'library' => ['my_theme/global-styling'],
  ],
];
```

**最佳实践**：

1. **按需加载**：仅加载页面需要的资源
2. **依赖声明**：明确声明库依赖
3. **版本管理**：使用版本号管理缓存
4. **聚合优化**：启用 CSS/JS 聚合

**参考**：
- https://www.drupal.org/docs/develop/theming-drupal/adding-stylesheets-css-and-javascript-to-your-drupal-theme

---

### 3.4 响应式设计

**核心原则**：
- 使用移动优先（mobile-first）方法
- 定义断点配置文件
- 支持多种设备尺寸

**断点配置**：
```yaml
# my_theme.breakpoints.yml
my_theme.mobile:
  label: Mobile
  mediaQuery: '(max-width: 599px)'
  weight: 0
  multipliers:
    - 1x
    - 2x

my_theme.tablet:
  label: Tablet
  mediaQuery: '(min-width: 600px) and (max-width: 1023px)'
  weight: 1
  multipliers:
    - 1x
    - 2x

my_theme.desktop:
  label: Desktop
  mediaQuery: '(min-width: 1024px)'
  weight: 2
  multipliers:
    - 1x
    - 2x
```

**最佳实践**：

1. **移动优先**：从小屏幕开始设计
2. **断点合理**：基于内容而非设备定义断点
3. **图片响应**：使用 srcset 和 sizes 属性
4. **测试覆盖**：在多种设备上测试

**CSS 示例**：
```css
/* 移动优先 */
.container {
  padding: 1rem;
}

/* 平板 */
@media (min-width: 600px) {
  .container {
    padding: 2rem;
  }
}

/* 桌面 */
@media (min-width: 1024px) {
  .container {
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

**参考**：
- https://www.drupal.org/docs/develop/theming-drupal/responsive-theming

---

## 4. 代码审查清单

### 4.1 代码质量检查

- [ ] 代码符合 Drupal 编码标准
- [ ] 所有函数/类/方法有完整的文档注释
- [ ] 变量命名清晰且有意义
- [ ] 没有硬编码的字符串（使用 t() 翻译）
- [ ] 没有 PHP 警告或错误
- [ ] 代码通过 phpcs 检查

### 4.2 安全性检查

- [ ] 所有用户输入已清理和验证
- [ ] 使用 Drupal API 进行数据库查询（防止 SQL 注入）
- [ ] 输出已转义（防止 XSS）
- [ ] 表单有 CSRF 令牌
- [ ] 权限检查正确实现
- [ ] 文件上传有安全限制

### 4.3 性能检查

- [ ] 数据库查询有适当索引
- [ ] 使用缓存 API
- [ ] 避免在循环中执行查询
- [ ] 资源文件已聚合
- [ ] 图片已优化
- [ ] 没有不必要的依赖

### 4.4 可维护性检查

- [ ] 代码模块化，职责分离
- [ ] 遵循 DRY 原则
- [ ] 配置与代码分离
- [ ] 有单元测试覆盖
- [ ] 有使用文档
- [ ] 版本控制提交信息清晰

### 4.5 兼容性检查

- [ ] 支持指定的 Drupal 核心版本
- [ ] 与依赖模块兼容
- [ ] 支持多语言
- [ ] 符合无障碍标准（WCAG）
- [ ] 响应式设计正常工作
- [ ] 跨浏览器测试通过

---

## 附录：工具推荐

### 开发工具

| 工具 | 用途 | 安装 |
|------|------|------|
| PHP_CodeSniffer | PHP 代码检查 | `composer require drupal/coder --dev` |
| ESLint | JavaScript 检查 | `npm install eslint @drupal/eslint-config` |
| Stylelint | CSS 检查 | `npm install stylelint stylelint-config-drupal` |
| Twig-CS-Fixer | Twig 检查 | `composer require vincentlanglet/twig-cs-fixer` |
| Drupal Check | 静态分析 | `composer require phpstan/phpstan` |

### 调试工具

| 工具 | 用途 |
|------|------|
| Devel | 开发辅助模块 |
| Webprofiler | 性能分析 |
| Twig Debug | 模板调试 |
| Kint | 变量调试 |

---

*文档来源：Drupal 官方文档 (https://www.drupal.org/docs)*
