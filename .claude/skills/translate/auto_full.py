#!/usr/bin/env python3
"""
完整自动化翻译脚本 - 扫描、读取上下文、生成翻译建议
"""

import os
import re
import json
import sys
from pathlib import Path
from collections import defaultdict

WORKSPACE = os.getenv("FLUTTER_WORKSPACE", os.getcwd())


def scan_t_strings():
    """扫描所有 .t 字符串"""
    found_keys = set()
    pattern = re.compile(r'^.*?["\']([^"\']+)["\']\.t', re.MULTILINE)

    lib_path = os.path.join(WORKSPACE, "lib")
    if not os.path.exists(lib_path):
        return []

    for root, dirs, files in os.walk(lib_path):
        if "localization" in root:
            continue

        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        matches = pattern.findall(content)
                        for match in matches:
                            if '\n' not in match and len(match) <= 100:
                                found_keys.add(match)
                except Exception as e:
                    print(f"警告: 无法读取 {file_path}: {e}", file=sys.stderr)

    return sorted(list(found_keys))


def get_existing_keys():
    """从中文翻译文件获取已存在的键"""
    zh_file = os.path.join(WORKSPACE, "lib", "localization", "zh_hans_strings.dart")
    existing_keys = set()

    if not os.path.exists(zh_file):
        return existing_keys

    with open(zh_file, 'r', encoding='utf-8') as f:
        content = f.read()
        pattern = re.compile(r'["\']([^"\']+)["\']:\s*["\']')
        existing_keys = set(pattern.findall(content))

    return existing_keys


def read_translation_context():
    """读取所有翻译文件作为上下文"""
    context = {
        'zh': {},
        'en': {},
        'de': {},
        'fr': {},
        'ja': {}
    }

    lang_files = {
        'zh': 'zh_hans_strings.dart',
        'en': 'en_strings.dart',
        'de': 'de_strings.dart',
        'fr': 'fr_strings.dart',
        'ja': 'ja_strings.dart'
    }

    for lang, filename in lang_files.items():
        file_path = os.path.join(WORKSPACE, "lib", "localization", filename)
        if not os.path.exists(file_path):
            continue

        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            pattern = re.compile(r'["\']([^"\']+)["\']:\s*["\']([^"\']*)["\']')
            matches = pattern.findall(content)

            for key, value in matches:
                context[lang][key] = value

    return context


def find_similar_keys(key, context, top_n=5):
    """查找相似的翻译key"""
    similar = []

    for existing_key in context['zh'].keys():
        # 检查是否包含相同词汇
        if key in existing_key or existing_key in key:
            similar.append({
                'key': existing_key,
                'zh': existing_key,
                'en': context['en'].get(existing_key, ''),
                'de': context['de'].get(existing_key, ''),
                'fr': context['fr'].get(existing_key, ''),
                'ja': context['ja'].get(existing_key, '')
            })

    return sorted(similar, key=lambda x: len(x['key']))[:top_n]


def main():
    """主函数"""
    print("🔍 步骤 1：扫描代码中的 .t 字符串...", file=sys.stderr)

    # 步骤1：扫描
    all_keys = scan_t_strings()

    if not all_keys:
        print("⚠️  未找到任何 .t 字符串", file=sys.stderr)
        return

    # 步骤2：获取已存在的键
    existing_keys = get_existing_keys()
    missing_keys = [key for key in all_keys if key not in existing_keys]

    # 步骤3：读取上下文
    print("📚 步骤 2：读取现有翻译上下文...", file=sys.stderr)
    context = read_translation_context()
    total_translations = sum(len(v) for v in context.values())
    print(f"✅ 已加载 {total_translations} 条翻译（5种语言）", file=sys.stderr)

    # 步骤4：分析缺失的翻译
    if not missing_keys:
        print("✅ 所有翻译都已存在！", file=sys.stderr)
        print(f"📊 总计: {len(all_keys)} 个翻译", file=sys.stderr)
        return

    print(f"📊 发现 {len(missing_keys)} 条缺失的翻译:", file=sys.stderr)
    for i, key in enumerate(missing_keys, 1):
        similar = find_similar_keys(key, context)
        print(f"\n  {i}. {key}", file=sys.stderr)
        if similar:
            print(f"     💡 找到 {len(similar)} 个相似词汇可参考:", file=sys.stderr)
            for sim in similar[:2]:
                print(f"        - {sim['zh']}", file=sys.stderr)
                print(f"          EN: {sim['en']}", file=sys.stderr)

    # 输出完整结果
    result = {
        'missing_keys': missing_keys,
        'total': len(missing_keys),
        'existing_count': len(all_keys),
        'context_summary': {
            'total_translations': total_translations,
            'lang_counts': {
                lang: len(translations)
                for lang, translations in context.items()
            }
        }
    }

    print("\n" + "="*70, file=sys.stderr)
    print("📋 完整分析报告（JSON格式）", file=sys.stderr)
    print("="*70 + "\n", file=sys.stderr)

    # 输出便于AI处理的JSON
    output = {
        'scan_result': result,
        'context_sample': {
            'sample_translations': list(context['zh'].items())[:10],  # 示例
            'total_translations': total_translations
        }
    }

    print(json.dumps(output, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
