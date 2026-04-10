#!/bin/bash
# 链接有效性检查脚本
# 检查所有 Markdown 文件中的外部链接

cd "$(dirname "$0")/.."

echo "🔍 开始检查外部链接..."
echo ""

# 提取所有外部链接 (http/https)
grep -roh 'https\?://[^")[:space:]]*' . --include="*.md" 2>/dev/null | sort -u > /tmp/all_links.txt

total=$(wc -l < /tmp/all_links.txt)
echo "找到 $total 个唯一外部链接"
echo ""

# 检查每个链接
dead_links=()
working_links=()

while IFS= read -r link; do
    # 跳过本地链接和片段
    if [[ "$link" == *"#"* ]] || [[ "$link" == "file:"* ]]; then
        continue
    fi
    
    # 使用 curl 检查链接 (超时 5 秒)
    if curl -s --head --request GET --max-time 5 "$link" | grep -q "200 OK\|301\|302"; then
        working_links+=("$link")
        echo "✅ $link"
    else
        dead_links+=("$link")
        echo "❌ $link"
    fi
done < /tmp/all_links.txt

echo ""
echo "================================"
echo "📊 检查结果"
echo "================================"
echo "有效链接：${#working_links[@]}"
echo "死链：${#dead_links[@]}"

if [ ${#dead_links[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  死链列表:"
    printf '%s\n' "${dead_links[@]}"
fi

# 保存报告
mkdir -p docs
cat > docs/link-check-report.md << EOF
# 链接检查报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')

## 统计

- 总链接数: $total
- 有效链接: ${#working_links[@]}
- 死链: ${#dead_links[@]}

## 死链列表

$(if [ ${#dead_links[@]} -gt 0 ]; then printf '%s\n' "${dead_links[@]}"; else echo "无死链"; fi)

## 建议

$(if [ ${#dead_links[@]} -gt 0 ]; then echo "1. 更新或删除死链"; else echo "所有链接均有效"; fi)
EOF

echo ""
echo "📄 报告已保存到 docs/link-check-report.md"
