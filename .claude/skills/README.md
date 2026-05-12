# NexOptim Skills 目录

这个目录包含 Claude Code 的 skill 定义文件，用于在 NexOptim 项目中提高开发效率。

## 📁 目录结构

```
.claude/skills/
├── README.md                    # 本文件
│
├── example-skill/               # 示例技能
│   └── SKILL.md                # Skill 定义和说明
│
├── generate-module/             # 业务模块生成器
│   ├── SKILL.md                # Skill 定义和说明（必需）
│   ├── helper.js               # 辅助脚本（模板和工具函数）
│   └── assets/                 # 相关资源（代码模板等）
│
└── translate/                   # 翻译管理
    ├── SKILL.md                # Skill 定义和说明（必需）
    ├── helper.js               # 辅助脚本（翻译工具和词汇表）
    └── assets/                 # 相关资源（翻译文件等）
```

每个 skill 都有独立的目录，包含：
- **SKILL.md** - Skill 的主要定义文件（必需），必须使用大写 SKILL.md
- **helper.js** - 辅助脚本，提供工具函数和代码模板（可选）
- **assets/** - 相关资源文件（可选）

## 🎯 可用的 Skills

### 1. **example-skill** - 示例技能

**目录**：`example-skill/`

一个简单的示例技能，用于测试技能系统是否工作。

**使用方法**：
```
使用 example-skill
```

---

### 2. **generate-module** - 业务模块生成器

**目录**：`generate-module/`

快速创建符合项目架构规范的新业务模块。

**功能**：
- ✅ 生成 State、Cubit、Repository、Page 文件
- ✅ 自动配置路由和依赖注入
- ✅ 支持 Mock 数据模式
- ✅ 遵循项目 BLoC/Cubit 架构规范

**使用方法**：
```
使用 generate-module skill 创建一个设备管理模块
```

**详细文档**：查看 `generate-module/SKILL.md`

---

### 3. **translate** - 翻译管理

**目录**：`translate/`

管理项目的多语言翻译，支持中文、英语、德语、法语、日语。

**功能**：
- ✅ 添加新翻译到所有语言文件
- ✅ 检查缺失的翻译
- ✅ 批量翻译多个文本
- ✅ 查找代码中的未翻译文本
- ✅ 包含常用术语翻译对照表

**使用方法**：
```
使用 translate skill 添加翻译：设备列表
使用 translate skill 检查翻译完整性
使用 translate skill 扫描代码查找未翻译文本
```

**详细文档**：查看 `translate/SKILL.md`

---

## 🚀 使用方式

### 方式 1：明确指定 skill
```
使用 [skill-name] skill [描述你的需求]

示例：
使用 generate-module skill 创建一个用户管理模块
使用 translate skill 添加翻译：设备列表
```

### 方式 2：自然描述需求
直接描述你想做什么，AI 会自动选择合适的 skill：
```
创建一个设备管理模块
添加翻译：设备列表
检查翻译完整性
```

### 方式 3：提供详细信息
提供更多细节可以获得更准确的结果：
- 功能名称和数据字段
- 需要的操作和交互
- 设计图路径（如果有）
- 特殊需求说明

## 📖 学习资源

- **项目架构**：查看项目根目录的 `CLAUDE.md`
- **现有模块**：参考 `lib/business_modules/` 中的现有实现
- **翻译系统**：查看 `lib/localization/` 了解项目翻译机制

## 🔧 添加新 Skill

如果要添加新的 skill，按以下结构创建：

```
.claude/skills/
└── your-skill/              ← 技能目录（kebab-case 命名）
    ├── SKILL.md             ← 必需：必须大写
    ├── helper.js            ← 可选：辅助脚本
    ├── assets/              ← 可选：资源文件
    ├── templates/           ← 可选：代码模板
    └── scripts/             ← 可选：执行脚本
```

### SKILL.md 文件格式

**SKILL.md** 必须包含 YAML frontmatter（在文件开头）：

```markdown
---
name: your-skill-name           # 必需：技能名称（小写字母、数字、连字符，最多64字符）
description: 单行描述           # 必需：必须是单行！多行会破坏解析器
---

# 技能标题

这里是技能的详细说明文档...
```

### 关键要求

#### ✅ name 字段规则
- 只能包含：小写字母、数字、连字符（`-`）
- 最多 64 个字符
- 示例：`my-skill`、`code-helper`、`translate-v2`

#### ✅ description 字段规则
- **必须是单行**（这是最常见的错误！）
- 不能换行
- 简洁描述技能功能
- 示例：`管理多语言翻译，支持添加翻译和检查缺失`

#### ✅ 文件名规则
- 必须叫 `SKILL.md`（不是 `skill.md` 或其他）
- 大写的 `SKILL`

**SKILL.md** 文件应该包含：
1. YAML frontmatter（必需的 name 和 description）
2. Skill 描述和功能说明
3. 使用方法和步骤
4. 代码模板或示例
5. 注意事项和最佳实践

## 💡 提示

- 每个 skill 都是独立的，可以单独使用或组合使用
- Skill 可以共享 assets（如通用模板、配置文件等）
- 建议定期更新 SKILL.md 以反映最新的项目规范
- 遇到问题时，查看对应 skill 目录下的 `SKILL.md` 获取详细帮助
- 创建 skill 后，使用 `/skills` 命令验证是否正确加载

---

**需要帮助？**
- 查看各个 skill 目录下的 `SKILL.md` 获取详细文档
- 查看项目根目录的 `CLAUDE.md` 了解项目架构
- 随时告诉我你需要什么样的新 skill！
