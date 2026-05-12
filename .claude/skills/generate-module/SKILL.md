---
name: generate-module
description: 引导用户创建新功能，从需求收集到代码生成的完整流程，采用多 Agent 协作架构
---

# generate-module

> 帮助用户在 handylink 项目中快速创建符合架构规范的新业务模块，采用多 Agent 协作架构

## 使用方法

当用户输入 `/generate-module`、`/new-feature`、`/新建功能` 或描述需要创建新功能时激活。

---

## 多 Agent 协作架构

本 Skill 采用 4 个子 Agent 协作完成模块生成，主 Agent 作为协调者调度各子 Agent：

| 角色 | 子 Agent 类型 | 职责 | 输入文档 | 输出文档 | 激活步骤 |
|------|-------------|------|---------|---------|---------|
| 产品 Agent | `general-purpose` | 读取产品文档，提取结构化需求 | `docs/requirements/{name}.md` | `docs/output/{name}_product_analysis.md` | 步骤 1 |
| 主 Agent | — | 澄清缺失信息，与用户交互确认 | `docs/output/{name}_product_analysis.md` | 更新产品分析文档 | 步骤 1.5（强制） |
| 架构师 Agent | `Plan` | 分析需求，设计模块架构 | `docs/output/{name}_product_analysis.md` | `docs/output/{name}_architecture.md` | 步骤 2 |
| 开发者 Agent | `general-purpose` | 生成代码文件、配置路由和依赖注入 | `docs/output/{name}_architecture.md` | 代码文件 | 步骤 3-5 |
| 测试 Agent | `general-purpose` | 生成测试用例、执行自动化测试 | `docs/output/{name}_product_analysis.md` | `docs/output/{name}_test_report.md` + 测试代码 | 步骤 6-7 |

**文档流转链**：
```
用户提供文件                          Agent 产出
─────────────                        ─────────
需求文档 ──→ 产品分析文档 ──→ 澄清步骤（确认缺失 + 读取接口文档 + 读取设计图）
                                       │
                                       ↓ 更新产品分析文档
                                       │
                              ┌────────┤
                              ↓        ↓
                       架构设计文档   测试用例 + 测试报告
                              │
                              ↓
                         代码文件（Repo基于真实接口，Page基于设计图）
```

**项目文档目录结构**：
```
docs/
├── requirements/                ← 用户输入：需求文档（PRD）
│   └─ {feature_name}/
├── designs/                     ← 用户输入：设计图（Agent 自动创建子目录）
│   └─ {feature_name}/
│       ├─ page_main.png
│       ├─ page_detail.png
│       └─ ...
├── api/                         ← 用户输入：接口文档（Agent 自动创建子目录）
│   └─ {feature_name}/
│       ├─ api_spec.md
│       ├─ swagger.json
│       └─ ...
├── output/                      ← Agent 产出（按 feature_name 组织）
│   └─ {feature_name}/
│       ├─ {feature_name}_product_analysis.md
│       ├─ {feature_name}_architecture.md
│       ├─ {feature_name}_test_report.md
│       ├─ designs/              ← 归档的设计图
│       └─ api/                  ← 归档的接口文档
```

**说明**：步骤 1 确定 feature_name 后，主 Agent 自动创建 `docs/designs/{feature_name}/` 和 `docs/api/{feature_name}/` 子目录，用户将文件放入即可。流程结束后 Agent 自动将设计图和接口文档归档到 `docs/output/{feature_name}/` 下。

---

## 快速开始

**核心流程**：
1. 产品 Agent 读取需求 → 1.5. 澄清步骤（与用户交互确认缺失信息 + 读取接口文档 + 读取设计图） → 2. 架构师 Agent 设计架构 → 3-5. 开发者 Agent 生成代码 → 6-7. 测试 Agent 生成并执行测试 → 8. 归档用户输入文档

**详细文档**：
- 📖 [完整流程指南](./docs/guide.md)
- 📝 [代码模板说明](./docs/templates.md)
- ✅ [检查清单](./docs/checklist.md)
- 🔧 [架构参考](./docs/architecture.md)

---

## 步骤 1：产品 Agent — 读取产品文档并生成产品分析文档

**Spawn 子 Agent**：`subagent_type: "general-purpose"`

让用户提供产品经理给出的需求文档路径（如：`docs/requirements/xxx.md`），然后 Spawn 产品 Agent，让其读取文档并生成结构化产品分析文档。

### Agent Prompt 模板
```
你是产品 Agent，负责从产品需求文档中提取结构化信息并生成产品分析文档。

请执行以下任务：

1. 读取产品需求文档：{文档路径}

2. 从文档中提取以下信息：
   - 功能名称（如：环境传感器、设备列表）
   - 功能描述（解决什么问题）
   - 数据字段（State 属性列表，如：温度、湿度、状态）
   - 需要的操作（如：加载、刷新、删除、设置）
   - 页面类型（列表页、详情页、单页面）
   - 设计图（文档中包含的图片路径，如有）
   - 模块位置（默认 lib/business_modules/{feature_name}/）

3. 如果文档中信息不完整，请标注缺失部分

4. 将分析结果写入文档：docs/output/{feature_name}/{feature_name}_product_analysis.md

文档格式要求：
# {功能名称} - 产品需求分析

## 功能名称
{提取的功能名称}

## 功能描述
{功能描述}

## 数据字段
| 字段名 | 类型 | 说明 |
|--------|------|------|
| ...    | ...  | ...  |

## 操作列表
| 操作名 | 说明 | 触发条件 |
|--------|------|----------|
| ...    | ...  | ...      |

## 页面类型
{页面类型}

## 设计图
{暂空，在澄清步骤中由用户提供路径后填充}

### 设计图路径
| 页面名称 | 设计图路径 | 说明 |
|----------|-----------|------|
| ...      | ...       | ...  |

## 模块位置
lib/business_modules/{feature_name}/

## 业务规则
{从文档中提取的业务规则和约束}

## 缺失信息
{如有缺失，列出需要补充的内容}

## API 接口
{暂空，在澄清步骤中由用户提供后填充}

### 接口列表
| 接口名称 | 请求方法 | URL | 说明 |
|----------|----------|-----|------|
| ...      | ...      | ... | ...  |

### 请求参数
| 接口 | 参数名 | 类型 | 必填 | 说明 |
|------|--------|------|------|------|
| ...  | ...    | ...  | ...  | ...  |

### 响应数据结构
| 接口 | 字段名 | 类型 | 说明 |
|------|--------|------|------|
| ...  | ...    | ...  | ...  |

### 错误码
| 接口 | 错误码 | 说明 | 处理方式 |
|------|--------|------|----------|
| ...  | ...    | ...  | ...      |
```

**后续处理**：主 Agent 收到产品 Agent 完成通知后：

1. 读取生成的 `docs/output/{feature_name}/{feature_name}_product_analysis.md`
2. 自动创建 `docs/designs/{feature_name}/` 和 `docs/api/{feature_name}/` 子目录，方便用户后续放置设计图和接口文档
3. **进入澄清步骤（见下方）**：将产品分析文档中的缺失信息和关键歧义点整理后向用户逐一询问，直到用户确认所有疑问已解决，或用户明确指示「继续下一步」

---

## 步骤 1.5：澄清步骤 — 向用户确认缺失信息并收集 API 接口和设计图

**此步骤为强制步骤，不可跳过。** 主 Agent 必须在完成步骤 1 后执行此步骤，只有当用户明确表示「继续」或「下一步」时才可进入步骤 2。

### 执行流程

1. **读取产品分析文档**：读取 `docs/output/{feature_name}/{feature_name}_product_analysis.md`，重点关注「缺失信息」、「API 接口」和「设计图」章节

2. **整理澄清问题**：将产品分析文档中标注的缺失信息转化为具体的、可回答的问题，逐一向用户提问。例如：
    - 缺失信息：「挂钩导轨识别的接口规则未明确」 → 问题：「挂钩导轨识别是通过什么接口/字段判断的？API 返回什么数据标识导轨为挂钩类型？」
    - 缺失信息：「保存修改的批量提交逻辑未明确」 → 问题：「保存修改时是逐层逐条提交还是一次性批量提交？部分失败时是否需要回滚？」

3. **收集 API 接口信息**：向用户询问接口文档路径（如 `docs/api/xxx.md`），然后：
    - 使用 Read 工具读取接口文档，自动解析接口列表、请求参数、响应数据结构、错误码
    - 将解析结果更新到产品分析文档的「API 接口」章节中
    - 如果接口文档信息不完整，向用户追问缺失部分

4. **收集设计图信息**：向用户询问设计图文件路径（如 `docs/designs/xxx.png`），然后：
    - 使用 Read 工具读取每个设计图文件，自动识别：
        - UI 元素布局（导航栏、列表、卡片、按钮等）
        - 交互元素（可点击区域、输入框、开关等）
        - 视觉风格（间距、字体大小、颜色等）
    - 将识别结果更新到产品分析文档的「设计图」章节中

5. **逐项向用户询问**：使用 AskUserQuestion 工具向用户提问，每轮最多 4 个问题。用户回答后：
    - 将用户回答补充到产品分析文档中（更新「缺失信息」章节，将已解答的条目移至「已确认信息」章节）
    - 将用户提供的 API 接口信息更新到「API 接口」章节
    - 将用户提供的设计图信息更新到「设计图」章节
    - 如果用户回答引入了新的疑问，继续追问直到无歧义

6. **确认完成**：当所有缺失信息、API 接口信息和设计图信息都已澄清，向用户展示澄清总结，并询问「所有疑问已澄清，是否进入架构师设计步骤？」用户确认后才启动步骤 2

7. **强制跳过条件**：仅当用户明确说「继续」「下一步」「跳过」时，才可跳过剩余澄清问题直接进入步骤 2。主 Agent 不可自行决定跳过

### 澄清问题格式

每个问题应包含：
- **背景**：简述该信息为何重要（对架构/代码的影响）
- **具体问题**：明确可回答的问题
- **建议选项**（如有）：提供 2-4 个可能的方案供用户选择

示例：
```
背景：挂钩导轨识别是抽屉自动弹出的触发条件，直接影响 Repo 接口设计和 Cubit 逻辑。
问题：录入导轨 ID 后，系统如何判断该导轨是否为挂钩导轨？
选项：
A. API 返回 railType 字段（如 "hook"/"normal"）
B. API 返回 isHookRail 布尔字段
C. 通过导轨 ID 前缀规则判断（如以 "H" 开头为挂钩导轨）
D. 其他（请说明）
```

---

## 步骤 2：架构师 Agent — 设计模块架构并生成架构设计文档

**Spawn 子 Agent**：`subagent_type: "Plan"`

将产品分析文档路径传递给架构师 Agent，让其读取文档并设计模块架构方案。

### Agent Prompt 模板
```
你是架构师 Agent，负责为 NexOptim Flutter 项目设计模块架构。

请执行以下任务：

1. 读取产品分析文档：docs/output/{feature_name}/{feature_name}_product_analysis.md

2. 根据产品需求设计模块架构方案

项目架构规范：
- 使用 Cubit + State 状态管理，继承 BaseCubit 和 BaseState
- 使用 Repository 模式：抽象 Repo + RepoImpl + MockRepo
- 路由配置在 lib/main_frame/router.dart
- 依赖注入在 lib/main_frame/repo_providers.dart
- 所有文本使用 .t 扩展（国际化）
- 使用 pattern matching：if (result case Success(:final data))
- 使用不可变状态：copy() 和 nextState()
- 行长度：120 字符

参考模板文件目录：.claude/skills/generate-module/templates/
参考已有模块目录：lib/business_modules/ 下的现有模块作为架构参考

3. 将架构方案写入文档：docs/output/{feature_name}/{feature_name}_architecture.md

文档格式要求：
# {功能名称} - 架构设计文档

## 模块文件结构
| 文件名 | 职责 | 对应模板 |
|--------|------|----------|
| ...    | ...  | ...      |

## State 字段设计
| 字段名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| ...    | ...  | ...    | ...  |

## Cubit 方法设计
| 方法名 | 参数 | 返回值 | 说明 |
|--------|------|--------|------|
| ...    | ...  | ...    | ...  |

## Repo 接口设计
| 方法名 | 参数 | 返回类型 | 说明 |
|--------|------|----------|------|
| ...    | ...  | ...      | ...  |

## Repo 接口详细设计（基于 API 接口）
### 接口映射
| Repo 方法 | 对应 API | 请求方法 | URL |
|-----------|----------|----------|-----|
| ...       | ...      | ...      | ... |

### 请求参数映射
| Repo 方法 | API 参数名 | Repo 参数名 | 类型 | 必填 |
|-----------|-----------|-------------|------|------|
| ...       | ...       | ...         | ...  | ...  |

### 响应数据映射
| Repo 方法 | API 响应字段 | State 字段 | 类型 | 转换逻辑 |
|-----------|-------------|-----------|------|----------|
| ...       | ...         | ...       | ...  | ...      |

### 错误处理
| API 错误码 | Cubit 处理方式 | 用户提示 |
|-----------|---------------|----------|
| ...       | ...           | ...      |

## 路由配置
- 路由名称：/{route_name}
- 路由文件修改：lib/main_frame/router.dart
- 具体配置代码

## 依赖注入配置
- 注册文件修改：lib/main_frame/repo_providers.dart
- 具体注册代码

## 页面 UI 结构（基于设计图）
- 读取产品分析文档中的设计图路径，使用 Read 工具查看每张设计图
- 基于设计图识别的 UI 元素描述组件树结构
- 基于设计图识别的交互元素描述关键交互
- 页面组件树结构
- 关键交互说明
```

**后续处理**：主 Agent 收到架构师 Agent 完成通知后，将架构设计文档路径传递给开发者 Agent。

---

## 步骤 3-5：开发者 Agent — 根据架构设计文档生成代码

**Spawn 子 Agent**：`subagent_type: "general-purpose"`

将架构设计文档路径传递给开发者 Agent，让其读取文档并执行代码生成。

### Agent Prompt 模板
```
你是开发者 Agent，负责根据架构设计文档生成代码并配置路由和依赖注入。

请执行以下任务：

1. 读取架构设计文档：docs/output/{feature_name}/{feature_name}_architecture.md

2. 读取模板文件目录 .claude/skills/generate-module/templates/ 中的模板文件

3. **生成代码文件**：根据架构文档中的文件结构设计，使用模板替换占位符后生成到以下目录：
   lib/business_modules/{feature_name}/
   - {feature_name}_state.dart
   - {feature_name}_cubit.dart
   - {feature_name}_repo.dart（包含 RepoImpl 和 MockRepo）
   - {feature_name}_page.dart

4. **基于 API 接口生成 Repo 实现**：根据架构文档中「Repo 接口详细设计」章节：
   - 为每个 Repo 方法编写真实的 API 调用代码（使用项目中的 HTTP 请求工具类）
   - 将 API 响应字段映射为 State 字段，编写数据转换逻辑
   - 实现错误处理：根据架构文档中的错误码映射表，在 Cubit 层处理 API 错误
   - MockRepo 中的数据应与 API 响应结构一致，便于开发调试

5. **基于设计图生成 Page 实现**：根据架构文档中「页面 UI 结构」章节：
   - 读取产品分析文档中的设计图路径，使用 Read 工具查看每张设计图
   - 根据设计图中的 UI 布局生成对应的 Widget 组件树
   - 根据设计图中的交互元素实现对应的交互逻辑（点击、滑动等）
   - 尽量还原设计图的视觉风格（间距、字体、颜色等）

4. **配置路由**：根据架构文档中的路由配置，在 lib/main_frame/router.dart 中添加路由

5. **注册 Repository**：根据架构文档中的依赖注入配置，在 lib/main_frame/repo_providers.dart 中添加注册

6. **检查验证**：运行以下命令并修复所有问题：
   dart format . --line-length 120
   flutter analyze

项目代码规范：
- 所有文本使用 .t 扩展（国际化）
- 继承 BaseCubit 和 BaseState
- 使用 pattern matching：if (result case Success(:final data))
- 使用不可变状态：copy() 和 nextState()
- 行长度：120 字符
```

---

## 步骤 6-7：测试 Agent — 根据产品分析文档生成测试并执行

**Spawn 子 Agent**：`subagent_type: "general-purpose"`

将产品分析文档路径传递给测试 Agent，让其读取文档、生成测试用例、执行自动化测试，并输出测试报告。

### Agent Prompt 模板
```
你是测试 Agent，负责根据产品需求分析文档编写测试用例、执行自动化测试，并输出测试报告。

请执行以下任务：

1. **读取产品分析文档**：docs/output/{feature_name}/{feature_name}_product_analysis.md，从中提取所有功能场景和业务规则

2. **读取已生成的模块代码**：lib/business_modules/{feature_name}/ 目录下的所有文件，了解代码实现

3. **推导测试场景**：根据产品分析文档中的数据字段、操作列表、业务规则，推导出：
   - 正向测试场景（正常流程）
   - 反向测试场景（异常/失败流程）
   - 边界测试场景（空数据、极限值等）

4. **生成测试文件**：读取模板 .claude/skills/generate-module/templates/ 中的测试模板，生成到 test/business_modules/{feature_name}/ 目录下
   - {feature_name}_cubit_test.dart：验证每个操作的状态变化
   - {feature_name}_repo_test.dart：验证接口返回数据
   - {feature_name}_page_test.dart：验证页面渲染和交互

5. **执行自动化测试**：按顺序执行
   - flutter test test/business_modules/{feature_name}/{feature_name}_cubit_test.dart
   - flutter test test/business_modules/{feature_name}/{feature_name}_repo_test.dart
   - flutter test test/business_modules/{feature_name}/{feature_name}_page_test.dart

6. **修复失败测试**：如有测试失败，分析原因并修复代码或测试用例，重新执行直到全部通过

7. **生成测试报告**：将测试结果写入 docs/output/{feature_name}/{feature_name}_test_report.md

报告格式要求：
# {功能名称} - 测试报告

## 测试概览
| 测试类型 | 文件 | 用例数 | 通过 | 失败 |
|----------|------|--------|------|------|
| Cubit    | ...  | ...    | ...  | ...  |
| Repo     | ...  | ...    | ...  | ...  |
| Widget   | ...  | ...    | ...  | ...  |

## 测试场景覆盖
### 正向测试
- {场景列表}

### 反向测试
- {场景列表}

### 边界测试
- {场景列表}

## 失败测试修复记录
| 原始失败原因 | 修复方式 | 修复后结果 |
|-------------|----------|-----------|
| ...         | ...      | ...       |

## 结论
{测试整体结论}
```

---

## 关键规范

### 命名规范
- **模块目录**：kebab-case（`device_list`、`environment_sensor`）
- **类名**：PascalCase（`DeviceListPage`、`EnvironmentSensorCubit`）
- **变量/方法**：camelCase（`loadData`、`refreshData`）
- **路由**：kebab-case（`/device-list`、`/environment-sensor`）

### 文档输出规范
- 步骤 1 确定 feature_name 后，主 Agent 自动创建 `docs/designs/{feature_name}/` 和 `docs/api/{feature_name}/` 子目录
- 用户将设计图放入 `docs/designs/{feature_name}/`，接口文档放入 `docs/api/{feature_name}/`
- Agent 产出文档存放在 `docs/output/{feature_name}/` 目录下
- 流程结束后 Agent 自动将设计图和接口文档归档到 `docs/output/{feature_name}/designs/` 和 `docs/output/{feature_name}/api/`
- 产品分析文档：`{feature_name}_product_analysis.md`
- 架构设计文档：`{feature_name}_architecture.md`
- 测试报告文档：`{feature_name}_test_report.md`

### 代码要求
- ✅ 所有文本使用 `.t` 扩展（国际化）
- ✅ 继承 `BaseCubit` 和 `BaseState`
- ✅ 使用 pattern matching：`if (result case Success(:final data))`
- ✅ 使用不可变状态：`copy()` 和 `nextState()`
- ✅ 行长度：120 字符

---

## 步骤 8：归档 — 将用户输入文档统一归入 output 目录

测试完成后，主 Agent 自动执行归档操作，将用户分散放置的设计图和接口文档统一归入 `docs/output/{feature_name}/` 下。

### 执行流程

1. **确认 feature_name**：使用步骤 1 产品 Agent 确定的 feature_name

2. **归档设计图**：将 `docs/designs/` 下本次功能涉及的设计图文件复制到 `docs/output/{feature_name}/designs/`
    - 使用 `cp` 命令复制（保留原始文件，不删除）
    - 如果设计图路径不在 `docs/designs/` 下（如用户提供的其他路径），同样复制到归档目录

3. **归档接口文档**：将 `docs/api/` 下本次功能涉及的接口文档复制到 `docs/output/{feature_name}/api/`
    - 使用 `cp` 命令复制（保留原始文件，不删除）
    - 如果接口文档路径不在 `docs/api/` 下（如用户提供的其他路径），同样复制到归档目录

4. **归档后目录结构**：
   ```
   docs/output/{feature_name}/
   ├─ {feature_name}_product_analysis.md
   ├─ {feature_name}_architecture.md
   ├─ {feature_name}_test_report.md
   ├─ designs/                    ← 归档的设计图
   │   ├─ page_main.png
   │   ├─ page_detail.png
   │   └─ ...
   └─ api/                        ← 归档的接口文档
       ├─ api_spec.md
       └─ ...
   ```

---

## 后续任务

生成代码后提醒用户：
1. ✅ 代码已生成
2. ✅ 路由和依赖已配置
3. ✅ Repo 已基于真实 API 接口生成（含请求参数、响应映射、错误处理）
4. ✅ Page 已基于设计图生成（含 UI 布局、交互逻辑、视觉还原）
5. ✅ 测试用例已生成并执行
6. ✅ 文档已输出到 docs/output/{feature_name}/
7. ✅ 设计图和接口文档已归档到 docs/output/{feature_name}/
8. 📝 添加国际化翻译（使用 `/translate skill`）
9. 📝 测试功能（Mock 模式 + 实际 API）

---

## 快捷命令

```bash
# 格式化
dart format . --line-length 120

# 检查
flutter analyze

# 运行
flutter run

# 构建
flutter build apk --release

# 执行模块测试
flutter test test/business_modules/{feature_name}/
```

---

## 需要帮助？

- 📖 查看详细文档：[docs/guide.md](./docs/guide.md)
- 📝 查看代码模板：[templates/](./templates/)
- 🔧 查看架构说明：[docs/architecture.md](./docs/architecture.md)