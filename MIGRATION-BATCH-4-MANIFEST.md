# Migration Batch 4 Manifest

**迁移批次**: Batch 4  
**日期**: 2026-04-12  
**来源分支**: renew  
**目标分支**: feature/migrate-batch-4  
**合并目标**: renew-v2  

---

## 迁移文件清单

| 序号 | 文件路径 | 行数 | 状态 |
|------|----------|------|------|
| 1 | core-modules/05-config.md | 1200 | ✅ 已迁移 |
| 2 | core-modules/06-views.md | 789 | ✅ 已迁移 |
| 3 | core-modules/07-entity.md | 1365 | ✅ 已迁移 |
| 4 | core-modules/08-layout-builder.md | 659 | ✅ 已迁移 |
| 5 | core-modules/09-media.md | 817 | ✅ 已迁移 |

**总计**: 5 个文件，4830 行

---

## 迁移原则

- ✅ 绝对没有删除或简化任何内容
- ✅ 只进行物理位置移动
- ✅ 保持内容完整性和原有结构
- ✅ 每个文件已验证行数与原始文件一致

---

## 验证记录

```bash
# 原始文件行数 (renew 分支)
core-modules/05-config.md: 1200 行
core-modules/06-views.md: 789 行
core-modules/07-entity.md: 1365 行
core-modules/08-layout-builder.md: 659 行
core-modules/09-media.md: 817 行

# 迁移后文件行数 (feature/migrate-batch-4 分支)
core-modules/05-config.md: 1200 行 ✅
core-modules/06-views.md: 789 行 ✅
core-modules/07-entity.md: 1365 行 ✅
core-modules/08-layout-builder.md: 659 行 ✅
core-modules/09-media.md: 817 行 ✅
```

---

## CI/CD 状态

- [ ] 代码提交
- [ ] 推送到 GitHub
- [ ] PR 创建
- [ ] CI/CD 检查
- [ ] PR 合并

---

**生成时间**: 2026-04-12 14:46 GMT+8
