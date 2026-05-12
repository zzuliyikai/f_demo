---
name: translate
description: 自动化多语言翻译管理（使用Python扫描减少token消耗）
---

# translate (自动化版)

> 高效管理 NexOptim 项目的多语言翻译，使用Python自动化扫描减少token消耗

## ⚡ 自动化工作流（推荐）

当用户说"翻译"、"添加翻译"或类似指令时：

### 步骤 1：使用Python扫描（大幅减少token）

```bash
# 执行Python扫描脚本
cd /Users/yikai/workspace/flutter_workspace/nexoptim
python3 .claude/skills/translate/auto_full.py
```

或者使用MCP工具：
```bash
FLUTTER_WORKSPACE=. uv --directory tools/i18n-automan run i18n-automan scan
```

**输出示例：**
```json
{
  "missing_keys": ["相机工勘", "请输入货架编号", "绑定"],
  "total": 3
}
```

### 步骤 2：读取上下文（⚠️ 必须执行，保证翻译质量）

**⚠️ 重要：在生成翻译之前，必须先读取现有翻译！**

```bash
# 方式1：读取所有现有翻译（推荐）
FLUTTER_WORKSPACE=. uv --directory tools/i18n-automan run i18n-automan context

# 方式2：直接读取翻译文件
cat lib/localization/en_strings.dart
cat lib/localization/de_strings.dart
cat lib/localization/fr_strings.dart
cat lib/localization/ja_strings.dart
```

**上下文学习内容：**

1. **术语一致性表**（从现有翻译中提取）
   ```
   设备相关：
   - "设备" → Device (en), Gerät (de), Appareil (fr), デバイス (ja)

   操作相关：
   - "绑定" → Bind (en), Binden (de), Lier (fr), バインド (ja)
   - "解绑" → Unbind (en), Trennen (de), Dissocier (fr), バインド解除 (ja)

   状态相关：
   - "在线" → Online (en), Online (de), En ligne (fr), オンライン (ja)
   - "离线" → Offline (en), Offline (de), Hors ligne (fr), オフライン (ja)
   ```

2. **翻译风格学习**
   - 简洁性：UI文本简短
   - 正式度：专业但友好
   - 术语一致性：相同词汇相同翻译

3. **发现相似词汇**
   - 如果新词汇与现有词汇相似，优先复用翻译
   - 例如："绑定" 和 "绑定成功" 中的 "绑定" 使用相同翻译

**⚠️ 不跳过此步骤！**
- 没有上下文会导致翻译不一致
- 可能重复翻译已有词汇
- 破坏现有的术语体系

### 步骤 3：基于上下文生成翻译

基于扫描结果和上下文，为所有缺失的Key生成翻译：

**支持的语言：**
- 🇬🇧 `en` - English
- 🇩🇪 `de` - German (Deutsch)
- 🇫🇷 `fr` - French (Français)
- 🇯🇵 `ja` - Japanese (日本語)

**翻译原则：**
1. **复用现有术语** - 如果相似词汇已存在，优先复用
2. **保持简洁** - UI文本简短明了
3. **占位符** - 保留 `{name}`, `%d`, `{x}` 等
4. **语气一致** - 与现有翻译风格保持一致

### 步骤 4：批量更新翻译文件

使用MCP工具批量更新（一次性更新所有语言）：

```bash
# 为每种语言更新翻译
FLUTTER_WORKSPACE=. uv --directory tools/i18n-automan run i18n-automan update --lang en --data '[JSON数据]'
FLUTTER_WORKSPACE=. uv --directory tools/i18n-automan run i18n-automan update --lang de --data '[JSON数据]'
FLUTTER_WORKSPACE=. uv --directory tools/i18n-automan run i18n-automan update --lang fr --data '[JSON数据]'
FLUTTER_WORKSPACE=. uv --directory tools/i18n-automan run i18n-automan update --lang ja --data '[JSON数据]'
```

**JSON数据格式：**
```json
{
  "相机工勘": "Camera Survey",
  "请输入货架编号": "Please enter the shelf number",
  "绑定": "Bind"
}
```

### 步骤 5：格式化验证

```bash
dart format lib/localization/ --line-length 120
flutter analyze
```

## 📊 Token消耗对比

| 方式 | Token消耗 | 说明 |
|------|----------|------|
| **旧方式** | ~5000 tokens | 读取多个大文件 + 手动查找 |
| **新方式（Python）** | ~500 tokens | 只输出缺失的Key列表 |
| **节省** | **90%** | 自动化扫描 + 批量处理 |

## 🎯 常用功能

### 功能 1：检查缺失翻译

```bash
# 扫描并显示缺失的翻译
python3 .claude/skills/translate/auto_full.py
```

### 功能 2：查找未翻译的代码

扫描特定目录中未使用`.t`的硬编码中文：

```bash
# 查找所有未翻译的中文
cd lib/business_modules/camera_survey
grep -rn "[\u4e00-\u9fa5]" . | grep -v "\.t" | grep -v "//"
```

### 功能 3：批量翻译新模块

为整个新模块添加翻译：

1. 在代码中添加`.t`扩展
2. 运行扫描脚本
3. 生成所有翻译
4. 批量更新文件

## 📚 参考资源

### 现有术语表

参见 `helper.js` 中的常用翻译：
- 设备相关：Device, Gerät, Appareil, デバイス
- 操作相关：Save, Speichern, Enregistrer, 保存
- 状态相关：Online, Online, En ligne, オンライン

### 翻译文件位置

```
lib/localization/
├── zh_hans_strings.dart  # 中文简体（基准）
├── en_strings.dart       # 英语
├── de_strings.dart       # 德语
├── fr_strings.dart       # 法语
└── ja_strings.dart       # 日语
```

## 💡 最佳实践

### 1. 添加新功能时

```dart
// ✅ 正确：使用 .t 扩展
Text('相机工勘'.t)

// ❌ 错误：硬编码
Text('相机工勘')
```

### 2. 批量翻译流程

```bash
# 1. 代码中添加 .t
# 2. 运行扫描
python3 .claude/skills/translate/auto_full.py

# 3. AI生成翻译（自动）
# 4. 批量更新（自动）

# 5. 验证
dart format . --line-length 120
```

### 3. 术语一致性

优先复用现有翻译：
- "绑定" → "Bind" (不是 "Associate")
- "货架" → "Shelf" (不是 "Rack")
- "解绑" → "Unbind" (不是 "Disassociate")

## 🔧 故障排查

### 问题：扫描没有结果

**原因**：代码中没有使用`.t`扩展

**解决**：
```bash
# 检查是否使用了 .t
grep -r "\.t" lib/business_modules/your_module/
```

### 问题：翻译已存在但仍然显示缺失

**原因**：翻译文件中的Key使用了注释

**解决**：取消注释或添加新条目

```dart
// ❌ 被注释掉了
// "相机工勘": "",

// ✅ 正确格式
"相机工勘": "Camera Survey",
```

## 📝 工作流示例

### 示例：为相机工勘模块添加翻译

**步骤 1：代码中添加 `.t`**
```dart
appBar: AppBar(title: Text('相机工勘'.t))
hintText: '请输入货架编号'.t
```

**步骤 2：扫描**
```bash
python3 .claude/skills/translate/auto_full.py
# 输出: {"missing_keys": ["相机工勘", "请输入货架编号"], "total": 2}
```

**步骤 3：AI生成翻译**
基于上下文和术语表自动生成

**步骤 4：批量更新**
```bash
# 自动调用MCP工具更新所有语言文件
```

**步骤 5：验证**
```bash
dart format . --line-length 120
```

**总耗时**: ~2分钟
**Token消耗**: ~300 tokens（vs 旧方式 3000+ tokens）

---

**✨ 使用Python自动化扫描，效率提升10倍！**
