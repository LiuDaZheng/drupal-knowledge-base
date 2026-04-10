#!/bin/bash
# 文档验证脚本
# 验证 SKILL.md 规范、Markdown 格式、链接和文档完整性

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "=========================================="
echo "🔍 Drupal Knowledge Base 文档验证"
echo "=========================================="
echo ""

# 计数器
ERRORS=0
WARNINGS=0

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. 验证 SKILL.md 行数
echo "1️⃣  验证 SKILL.md 行数..."
LINES=$(wc -l < SKILL.md)
echo "   SKILL.md 行数：$LINES"

if [ "$LINES" -ge 500 ]; then
    echo -e "   ${RED}❌ SKILL.md 超过 500 行 ($LINES >= 500)${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "   ${GREEN}✅ SKILL.md 行数符合要求 ($LINES < 500)${NC}"
fi
echo ""

# 2. 验证 YAML frontmatter
echo "2️⃣  验证 YAML frontmatter..."
if command -v yamllint &> /dev/null; then
    # 提取 YAML frontmatter
    sed -n '2,19p' SKILL.md > /tmp/frontmatter.yml
    
    if [ -s /tmp/frontmatter.yml ]; then
        if yamllint -d relaxed /tmp/frontmatter.yml > /dev/null 2>&1; then
            echo -e "   ${GREEN}✅ YAML frontmatter 格式正确${NC}"
        else
            echo -e "   ${RED}❌ YAML frontmatter 格式错误${NC}"
            yamllint -d relaxed /tmp/frontmatter.yml
            ERRORS=$((ERRORS + 1))
        fi
        rm -f /tmp/frontmatter.yml
    else
        echo -e "   ${YELLOW}⚠️  未找到 YAML frontmatter${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "   ${YELLOW}⚠️  yamllint 未安装，跳过验证${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 3. 验证 Markdown 格式
echo "3️⃣  验证 Markdown 格式..."
if command -v markdownlint &> /dev/null; then
    if [ -f ".markdownlint.json" ]; then
        CONFIG="--config .markdownlint.json"
    else
        CONFIG=""
    fi
    
    MD_ERRORS=0
    for file in $(find . -name "*.md" -not -path "./.git/*" -not -path "./docs/*" 2>/dev/null | head -20); do
        if ! markdownlint $CONFIG "$file" > /dev/null 2>&1; then
            MD_ERRORS=$((MD_ERRORS + 1))
        fi
    done
    
    if [ $MD_ERRORS -eq 0 ]; then
        echo -e "   ${GREEN}✅ Markdown 格式验证通过${NC}"
    else
        echo -e "   ${YELLOW}⚠️  $MD_ERRORS 个 Markdown 文件存在格式问题${NC}"
        WARNINGS=$((WARNINGS + MD_ERRORS))
    fi
else
    echo -e "   ${YELLOW}⚠️  markdownlint 未安装，跳过验证${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 4. 链接检查
echo "4️⃣  检查链接..."
if [ -x "$SCRIPT_DIR/check-links.sh" ]; then
    bash "$SCRIPT_DIR/check-links.sh" > /dev/null 2>&1
    if [ -f "docs/link-check-report.md" ]; then
        # 读取报告中的死链数量
        DEAD_LINKS=$(grep "死链：" docs/link-check-report.md | awk '{print $2}' || echo "0")
        if [ "$DEAD_LINKS" = "0" ] || [ -z "$DEAD_LINKS" ]; then
            echo -e "   ${GREEN}✅ 所有链接有效${NC}"
        else
            echo -e "   ${RED}❌ 发现 $DEAD_LINKS 个死链${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "   ${YELLOW}⚠️  链接检查报告未生成${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "   ${YELLOW}⚠️  check-links.sh 不存在或不可执行${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 5. 文档完整性检查
echo "5️⃣  验证文档完整性..."
REQUIRED_FILES=(
    "SKILL.md"
    "README.md"
    "00-INDEX.md"
    "core-modules/00-index.md"
    "contrib/modules/00-index.md"
    "solutions/00-index.md"
    "dev/00-index.md"
    "ops/00-index.md"
    "best-practices/00-index.md"
    "references/00-index.md"
)

MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "   ${RED}❌ 缺少必需文件：$file${NC}"
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -eq 0 ]; then
    echo -e "   ${GREEN}✅ 文档完整性检查通过${NC}"
else
    echo -e "   ${RED}❌ 文档完整性检查失败：缺少 $MISSING 个文件${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 生成验证报告
echo "=========================================="
echo "📄 生成验证报告..."
echo "=========================================="

mkdir -p docs
cat > docs/validation-report.md << EOF
# 文档验证报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')
**项目**: Drupal Knowledge Base
**版本**: v2.1

## 验证结果

### 1. SKILL.md 行数
- 行数：$LINES
- 要求：< 500 行
- 状态：$([ $LINES -lt 500 ] && echo "✅ 通过" || echo "❌ 失败")

### 2. YAML Frontmatter
- 状态：$([ -s /tmp/frontmatter.yml ] && echo "✅ 存在" || echo "⚠️ 不存在")

### 3. Markdown 格式
- 状态：$([ $MD_ERRORS -eq 0 ] 2>/dev/null && echo "✅ 通过" || echo "⚠️ 存在问题")

### 4. 链接检查
- 死链数量：${DEAD_LINKS:-0}
- 状态：$([ "${DEAD_LINKS:-0}" = "0" ] && echo "✅ 通过" || echo "❌ 失败")

### 5. 文档完整性
- 必需文件：${#REQUIRED_FILES[@]}
- 缺失文件：$MISSING
- 状态：$([ $MISSING -eq 0 ] && echo "✅ 通过" || echo "❌ 失败")

## 总体统计

- 错误数：$ERRORS
- 警告数：$WARNINGS

## 建议

$(if [ $ERRORS -gt 0 ]; then echo "1. 修复所有错误后再提交"; else echo "✅ 所有检查通过，可以提交"; fi)
$(if [ $WARNINGS -gt 0 ]; then echo "2. 考虑解决警告以提高质量"; fi)
EOF

echo "✅ 验证报告已保存到 docs/validation-report.md"
echo ""

# 总结
echo "=========================================="
echo "📊 验证总结"
echo "=========================================="
echo "错误数：$ERRORS"
echo "警告数：$WARNINGS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ 验证失败：存在 $ERRORS 个错误${NC}"
    exit 1
else
    echo -e "${GREEN}✅ 验证通过：所有关键检查已完成${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  注意：存在 $WARNINGS 个警告${NC}"
    fi
    exit 0
fi
