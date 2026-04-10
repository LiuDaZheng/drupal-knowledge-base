# Drupal 主题开发知识库 (Drupal Theming Knowledge Base)

**Drupal 版本**: 11.x  
**状态**: 活跃维护  
**更新时间**: 2026-04-08  
**维护**: OpenClaw Marvin  

---

## 📚 目录结构

```
theming/
├── README.md                    # 本文件 - 知识库索引
├── 00-introduction.md           # 主题开发入门
├── 01-base-themes.md            # 基础主题和子主题
└── ADVANCE-THEMING-CHEATSHEET.md # 高级主题速查表
```

---

## 📖 知识模块概览

### 1. 主题开发入门 ✅ (00-introduction.md)

**内容**:
- Drupal 主题系统介绍
- 主题文件结构
- 快速开始指南
- 核心文件说明
- Twig 模板命名约定
- 开发环境配置
- 最佳实践

**适用人群**: 主题开发初学者

---

### 2. 基础主题和子主题 ✅ (01-base-themes.md)

**内容**:
- 主题层级结构
- 基础主题开发
- Stable/Classy/Olivia 主题介绍
- 创建自定义基础主题
- 子主题开发指南
- 主题最佳实践
- Sub-theme vs Custom Theme

**适用人群**: 需要快速开发或深度定制的主题开发者

---

### 3. 高级主题速查表 ✅ (ADVANCE-THEMING-CHEATSHEET.md)

**内容**:
- 基础速查表
- 主题文件结构速查
- 配置文件模板
- Twig 模板优先级速查
- 预处理函数速查
- 常用 Twig 模板
- CSS 和 JavaScript 管理
- 布局定义
- 调试技巧
- 检查清单

**适用人群**: 需要快速参考的主题开发者

---

## 🎯 学习路径

### 新手路径 (0-1 个月)

1. **主题开发入门** (00-introduction.md)
   - 了解主题系统
   - 学习文件结构
   - 创建第一个主题

2. **主题快速入门**
   - 阅读基础主题介绍
   - 尝试创建子主题

3. **实践练习**
   - 覆盖模板文件
   - 添加自定义 CSS/JS

---

### 进阶路径 (1-3 个月)

4. **基础主题开发** (01-base-themes.md)
   - 理解主题继承
   - 创建自定义基础主题

5. **主题定制**
   - 深入学习预处理函数
   - Master Twig 模板

6. **高级主题技术**
   - 布局定义
   - 自定义区块主题

---

### 高级路径 (3-6 个月)

7. **高级主题开发**
   - Paragraphs 主题定制
   - Layout Builder 主题定制
   - Commerce 主题定制

8. **性能优化**
   - 资源优化
   - 性能分析
   - 无障碍访问 (WCAG)

9. **项目实战**
   - 实际项目开发
   - 团队协作
   - 代码审查

---

## 📊 模块依赖图

```
Drupal Theming Knowledge Base
│
├── 00-introduction.md (基础入门)
│   ├── 主题系统介绍
│   ├── 快速开始
│   └── 最佳实践
│
├── 01-base-themes.md (进阶学习)
│   ├── 基础主题
│   ├── 子主题开发
│   └── 主题策略选择
│
├── ADVANCE-THEMING-CHEATSHEET.md (实战参考)
│   ├── 速查表
│   ├── 模板示例
│   └── 实用技巧
│
└── Solutions 模块
    ├── theme-customizations.md (主题定制)
        ├── Paragraphs 主题
        ├── Layout Builder 主题
        └── Commerce 主题
```

---

## 🎨 主题开发关键概念

### 核心概念

| 概念 | 说明 | 对应文档 |
|------|------|---------|
| **Twig Templates** | 模板引擎 | 00-introduction.md |
| **Theme Hooks** | 主题钩子 | 01-base-themes.md |
| **Preprocessing** | 预处理函数 | ADVANCE-THEMING-CHEATSHEET.md |
| **Libraries** | 资源库系统 | 00-introduction.md |
| **Sub-themes** | 子主题 | 01-base-themes.md |
| **Base Themes** | 基础主题 | 01-base-themes.md |

---

## 🔗 主题开发资源

### 核心资源
- [Drupal.org - Theming](https://www.drupal.org/docs/develop/theming-drupal)
- [Twig in Drupal](https://www.drupal.org/docs/develop/theming-drupal/twig-in-drupal)
- [Theme API](https://www.drupal.org/docs/develop/theming-drupal)

### 社区资源
- [Drupalize.me Theming Course](https://drupalize.me/topic/theming-drupal)
- [Stack Overflow - Theming](https://stackoverflow.com/questions/tagged/drupal-theming)
- [Drupal.org Theming Forum](https://www.drupal.org/forum/section/6)

### 工具和模块
- [Mix Module](https://www.drupal.org/project/mix)
- [Twig Suggester](https://www.drupal.org/project/twigsuggest)
- [Devel Module](https://www.drupal.org/project/devel)

---

## 📝 使用指南

### 快速开始

1. **初学者**
   - 从 `00-introduction.md` 开始
   - 理解主题系统基础
   - 创建第一个自定义主题

2. **进阶者**
   - 阅读 `01-base-themes.md`
   - 了解主题继承关系
   - 学习子主题开发技巧

3. **实战开发者**
   - 使用 `ADVANCE-THEMING-CHEATSHEET.md`
   - 快速查找模板和函数
   - 参考最佳实践和优化技巧

### 主题定制

对于特定主题的定制需求：
- **Paragraphs**: 参考 `solutions/theme-customizations.md`
- **Layout Builder**: 参考 `solutions/theme-customizations.md`
- **Commerce**: 参考 `solutions/theme-customizations.md`

---

## 📅 更新日期

| 日期 | 更新内容 |
|------|---------|
| 2026-04-08 | 初始化主题开发知识库 |
| 2026-04-08 | 添加主题基础模块 |
| 2026-04-08 | 添加高级主题速查表 |

---

## 🎯 目标受众

| 用户类型 | 适合内容 |
|---------|---------|
| **主题开发新手** | 00-introduction.md |
| **进阶开发者** | 01-base-themes.md |
| **实战开发者** | ADVANCE-THEMING-CHEATSHEET.md |
| **主题定制专家** | solutions/theme-customizations.md |

---

## 📚 相关技能模块

- [`drupal-theme-development`](../core-modules/15-theme-development.md) - 主题开发完整指南
- [`drupal-paragrapghs-theme`](../contrib/modules/paragraphs-theme.md) - Paragraphs 主题
- [`drupal-layout-builder-theme`](../contrib/modules/layout-builder-theme.md) - Layout Builder 主题
- [`drupal-commerce-theme`](../solutions/commerce-theme.md) - Commerce 主题

---

## 🔧 维护和更新

### 文档维护策略

1. **核心内容** - 实时更新，跟随 Drupal 发布
2. **最佳实践** - 每季度更新，融入社区反馈
3. **模板示例** - 每月检查，更新失效示例
4. **参考资源** - 每月验证，更新失效链接

### 更新频率

- **主题文档**: 每周检查
- **模板示例**: 每月测试
- **参考资源**: 每月更新

---

## 📄 许可协议

本知识库遵循 Drupal 社区许可协议，可自由使用和修改。

---

**文档版本**: v1.0  
**状态**: 活跃维护  
**最后更新**: 2026-04-08

---

*欢迎贡献！请遵循文档一致性原则，保持格式和风格统一*
