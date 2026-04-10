# Drupal 主题开发速查表 (Advanced Theme Cheatsheet)

**版本**: v1.0  
**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  

---

## 📖 基础速查

### 主题开发核心文件

| 文件 | 说明 | 必需 |
|------|------|------|
| `.info.yml` | 主题描述配置 | ✅ |
| `.libraries.yml` | 资源库定义 | ✅ |
| `.theme` | 预处理函数 | ⚠️ |
| `templates/page.html.twig` | 页面模板 | ✅ |
| `screenshot.png` | 主题预览图 | ⚠️ |

### 常用 Drupal 命令

```bash
# 主题管理
drush pm:list --type=theme
drush theme:install mytheme
drush theme:uninstall mytheme
drush config-set system.theme.default mytheme

# 缓存管理
drush cr               # 清除所有缓存
drush cache:rebuild    # 重新构建缓存
drush cache:clear twig # 清除 Twig 缓存

# 主题信息
drush php-eval "print_r(drupal_get_theme()->getInfo());"
drush php-eval "print_r(\Drupal::service('theme.registry')->getInfo());"

# 调试
drush twig:debug:on    # 启用 Twig 调试
drush twig:debug:off   # 关闭 Twig 调试
```

---

## 🏗️ 主题文件结构

### 标准主题结构

```
mytheme/
├── mytheme.info.yml          # ✅ 必需
├── mytheme.libraries.yml     # ✅ 必需
├── mytheme.theme             # 🎨 可选
├── mytheme.routing.yml       # 🎨 可选
├── screenshot.png            # ⚠️ 推荐
├── css/
│   ├── style.css            # 主样式
│   ├── responsive.css       # 响应式样式
│   └── print.css            # 打印样式
├── js/
│   └── scripts.js           # 主 JavaScript
├── templates/
│   ├── page.html.twig       # 页面模板
│   ├── node.html.twig       # 节点模板
│   ├── block.html.twig      # 区块模板
│   └── ...                  # 其他模板
├── layouts/
│   └── layouts.yml          # 布局定义
└── assets/
    ├── fonts/
    ├── images/
    └── icons/
```

---

## 📝 配置文件模板

### .info.yml 模板

```yaml
name: 'My Theme'
type: theme
description: 'Custom Drupal 11 theme'
core_version_requirement: ^11

base theme: stable  # 继承的基础主题

dependencies:
  - drupal:node
  - drupal:system

stylesheets:
  - css/style.css
  - css/responsive.css

scripts:
  - js/scripts.js

features:
  - node_styling
  - comment_styling

version: '1.0.0'
package: Custom Themes
```

### .libraries.yml 模板

```yaml
# 全局资源
global:
  version: 1.0.0
  css:
    theme:
      css/style.css: { weight: -10 }
  js:
    js/scripts.js: { weight: 10 }

# 特定页面
homepage:
  version: 1.0.0
  css:
    theme:
      css/homepage.css: { weight: 0 }
```

---

## 🎨 Twig 模板优先级

### 页面模板优先级
```
1. page.html.twig
2. page--[node-type].html.twig
3. page--[view-mode].html.twig
4. page--[theme].html.twig
```

### 节点模板优先级
```
1. node--[node-type]--[view-mode].html.twig
2. node--[node-type].html.twig
3. node--[view-mode].html.twig
4. node.html.twig
```

### 段落模板优先级
```
1. paragraph--[type]--[view-mode].html.twig
2. paragraph--[type].html.twig
3. paragraph--[view-mode].html.twig
4. paragraph.html.twig
```

### 区块模板优先级
```
1. block--[plugin-id].html.twig
2. block.html.twig
```

---

## 🔧 预处理函数

### page.html.twig 变量
```php
/**
 * 实现 hook_preprocess_page()
 */
function mytheme_preprocess_page(&$variables) {
  $variables['site_name'] = 'My Site';
  $variables['year'] = date('Y');
  
  // 添加 CSS 类
  $variables['attributes']->addClass('theme-mytheme');
  
  // 条件性类名
  $user = \Drupal::currentUser();
  if ($user->isAuthenticated()) {
    $variables['attributes']->addClass('logged-in');
  }
  
  // 缓存设置
  $variables['#cache']['tags'] = ['page'];
  $variables['#cache']['contexts'] = ['languages:language_interface'];
}
```

### node.html.twig 变量
```php
function mytheme_preprocess_node(&$variables) {
  $node = $variables['node'];
  
  $variables['author_name'] = $node->getOwner()->getDisplayName();
  $variables['author_picture'] = $node->getOwner()->getPicture()->uri->value;
  $variables['date'] = format_date($node->getChangedTime(), 'short');
  $variables['tags'] = $node->get('field_tags')->getValue();
  
  // 缓存
  $variables['#cache']['keys'] = ['node', $node->id()];
}
```

### 全局预处理
```php
/**
 * 实现 hook_preprocess_HOOK()
 */
function mytheme_preprocess_HOOK(&$variables) {
  // 添加变量
  $variables['mytheme_global_var'] = get_global_setting();
}

/**
 * 辅助函数
 */
function get_global_setting() {
  return \Drupal::config('mytheme.settings')->get('global_setting');
}
```

---

## 📚 常用 Twig 模板

### 基础页面模板
```twig
{# page.html.twig #}
<div{{ attributes }}>
  {{ page.top }}
  
  <header class="site-header">
    {{ page.header }}
  </header>
  
  <div class="main-wrapper">
    <nav class="primary-menu">
      {{ primary_menu }}
    </nav>
    
    <main class="page-content" role="main" id="main-content">
      {% if title %}<h1>{{ title }}</h1>{% endif %}
      {{ page.content }}
    </main>
  </div>
  
  {{ page.bottom }}
  {{ page.footer }}
</div>

{{ page_bottom }}
```

### 基础节点模板
```twig
{# node.html.twig #}
<article{{ attributes }}>
  
  {% if title_prefix %}<div class="title-prefix">{{ title_prefix }}</div>{% endif %}
  
  {% if title %}
  <h2{{ title_attributes }}>
    <a href="{{ url }}">{{ title }}</a>
  </h2>
  {% endif %}
  
  {% if title_suffix %}<div class="title-suffix">{{ title_suffix }}</div>{% endif %}
  
  <div class="node-meta">
    {% if author_picture %}<div class="author-picture">{{ author_picture }}</div>{% endif %}
    {% if name %}<span class="author">{{ author_name }}</span>{% endif %}
    {% if date %}<time>{{ date }}</time>{% endif %}
  </div>
  
  <div class="node-content">
    {{ content }}
  </div>
  
</article>
```

---

## 🎨 CSS 和 JavaScript

### 添加资源到特定页面

```yaml
# mytheme.libraries.yml
my-page-style:
  version: 1.0.0
  css:
    theme:
      css/my-page.css: {}
```

在预处理中应用：
```php
function mytheme_preprocess_page(&$variables) {
  $route = \Drupal::request()->getRouteName();
  
  if ($route == 'node.page') {
    \Drupal::service('asset.incollector')->add('mytheme.my-page-style');
  }
}
```

### 条件性加载资源
```php
// 只在特定页面加载
function mytheme_init() {
  $route = \Drupal::request()->getRouteName();
  
  if ($route == 'home') {
    $libraries = [
      'mytheme/homepage-style',
      'mytheme/homepage-script',
    ];
  }
}
```

---

## 🏗️ 布局定义

### layouts.yml 示例
```yaml
my-custom-layout:
  label: 'My Custom Layout'
  path: layouts/my-custom-layout
  template: layout--my-custom-layout
  library: mytheme/my-custom-layout
  icon: paths/assets/icons/layout-my-custom.svg
  regions:
    first:
      label: First column
    second:
      label: Second column
```

### 自定义布局模板
```twig
{# layout--my-custom-layout.html.twig #}
<div class="layout layout--my-custom-layout">
  
  <div class="layout__region layout__region--first">
    {{ content.first }}
  </div>
  
  <div class="layout__region layout__region--second">
    {{ content.second }}
  </div>
  
</div>
```

---

## 💻 调试技巧

### Twig 调试
```yaml
# services.yml
twig.config:
  debug: true
  auto_reload: true
  cache: false
```

### 查看模板建议
```bash
# 启用 Twig 调试后，查看页面源码
# 会显示所有可用的模板建议
```

### 使用 Mix 模块
```bash
drush mix:enable  # 启用 Mix
drush mix:disable # 禁用 Mix
```

### 清除缓存和重载
```bash
drush cr         # 清除所有缓存
drush cache:rebuild # 重新构建缓存
```

---

## 📊 主题开发检查清单

### 创建主题
- [ ] 创建 .info.yml 文件
- [ ] 创建 .libraries.yml 文件
- [ ] 创建 templates 目录
- [ ] 创建基础模板 (page.html.twig 等)
- [ ] 创建 .theme 文件
- [ ] 添加 CSS/JS 资源
- [ ] 添加 screenshot.png
- [ ] 测试主题功能

### 主题配置
- [ ] 设置主题依赖
- [ ] 配置样式表和脚本
- [ ] 定义资源库
- [ ] 创建预处理函数
- [ ] 设置缓存标签和上下文

### 主题调试
- [ ] 启用 Twig 调试
- [ ] 检查模板建议
- [ ] 验证资源加载
- [ ] 测试响应式设计
- [ ] 检查无障碍访问

---

## 🔗 参考资源

### 官方文档
- [Twig in Drupal](https://www.drupal.org/docs/develop/theming-drupal/twig-in-drupal)
- [Theme API](https://www.drupal.org/docs/develop/theming-drupal)
- [Layout API](https://www.drupal.org/docs/drupal-apis/layout-api)

### 社区资源
- [Drupal.org Theming Forum](https://www.drupal.org/forum/section/6)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/drupal-theming)
- [Drupalize.me](https://drupalize.me/topic/theming-drupal)

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-08

*此速查表涵盖 Drupal 主题开发的核心内容，可作为日常开发参考*
