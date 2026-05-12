#!/bin/bash
# 快速翻译扫描脚本（带上下文学习）

set -e

WORKSPACE="${FLUTTER_WORKSPACE:-.}"
cd "$WORKSPACE"

echo "🔍 正在扫描缺失的翻译..."
echo ""

# 方式1：使用完整版Python脚本（推荐，自动读取上下文）
if [ -f ".claude/skills/translate/auto_full.py" ]; then
    python3 .claude/skills/translate/auto_full.py
    exit 0
fi

# 方式2：使用基础版Python脚本
if [ -f ".claude/skills/translate/auto_translate.py" ]; then
    python3 .claude/skills/translate/auto_translate.py
    exit 0
fi

# 方式3：使用MCP工具
if command -v uv &> /dev/null; then
    echo "📚 使用MCP工具扫描（包含上下文）..."
    uv --directory tools/i18n-automan run i18n-automan scan 2>/dev/null || {
        echo "⚠️  MCP工具运行失败，使用备用方案..."
        # 备用方案：使用grep扫描
        echo "📊 使用grep扫描 .t 字符串..."

        grep -rh "\.t" lib/business_modules/ lib/widgets/ 2>/dev/null | \
            grep -o '"[^"]*"' | \
            tr -d '"' | \
            sort -u | \
            jq -R -s -c 'split("\n")[:-1]'
    }
    exit 0
fi

# 方式4：纯grep扫描
echo "📊 使用grep扫描 .t 字符串..."

find lib/business_modules/ lib/widgets/ -name "*.dart" -type f 2>/dev/null | \
    xargs grep -h "\.t" 2>/dev/null | \
    grep -o '"[^"]*"' | \
    tr -d '"' | \
    sort -u | \
    while read key; do
        # 检查是否已存在于中文翻译文件
        if ! grep -q "\"$key\":" lib/localization/zh_hans_strings.dart 2>/dev/null; then
            echo "$key"
        fi
    done

echo ""
echo "✅ 扫描完成！"
