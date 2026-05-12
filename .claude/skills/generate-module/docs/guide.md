# 完整流程指南

## 步骤 1：收集需求（详细）

### 必需信息详解

#### 1. 功能名称
- **中文名称**：如"环境传感器"、"设备列表"
- **英文名称**：如"environment_sensor"、"device_list"
- 用于生成类名、文件名、路由名

#### 2. 功能描述
- 这个功能的作用是什么？
- 需要解决什么问题？
- 有什么特殊需求？

#### 3. 数据字段（State 属性）
每个字段需要明确：
- **字段名**（camelCase）：如 `deviceName`、`temperature`
- **类型**：`String`、`int`、`double`、`bool`、`List<T>`等
- **默认值**：如 `''`、`0`、`false`、`[]`
- **说明**：字段的用途

示例：
```
deviceName: String, 默认值: ''
temperature: double, 默认值: 0.0
isOnline: bool, 默认值: false
lastUpdateTime: String, 默认值: ''
```

#### 4. 需要的操作
常见操作：
- **数据加载**：`loadData()`、`loadList()`
- **刷新**：`refreshData()`、`refreshList()`
- **删除**：`deleteItem()`、`deleteItems()`
- **编辑**：`updateItem()`、`saveItem()`
- **添加**：`addItem()`、`createItem()`
- **搜索**：`searchItems()`
- **筛选**：`filterItems()`

每个操作需要明确：
- 操作名称
- 参数（如：id、item）
- 返回类型（如：`Result<void>`、`Result<List<Item>>`）

#### 5. 页面类型
- **列表页**：显示数据列表
- **详情页**：显示单个项目详情
- **表单页**：添加/编辑数据
- **单页面**：集成了列表和详情

#### 6. 设计图（可选）
- 提供设计图路径，如：`design-image/environment_sensor.png`
- 会根据设计图生成 UI 代码
- 如果没有设计图，使用标准模板

#### 7. 模块位置
- **独立模块**：`lib/business_modules/{feature_name}/`
- **添加到现有模块**：指定现有模块路径

---

## 步骤 2：生成文件（详细）

### 2.1 生成 State 文件

从 `templates/state_template.dart` 读取模板，替换占位符：
- `___FeatureName___` → PascalCase 类名（如 `EnvironmentSensor`）
- `___featureName___` → camelCase 变量名（如 `environmentSensor`）
- `___FIELDS___` → 数据字段定义

示例：
```dart
class EnvironmentSensorState extends BaseState {
  String deviceName = '';
  double temperature = 0.0;
  bool isOnline = false;

  @override
  EnvironmentSensorState copy() => EnvironmentSensorState()
    ..deviceName = deviceName
    ..temperature = temperature
    ..isOnline = isOnline;
}
```

### 2.2 生成 Cubit 文件

从 `templates/cubit_template.dart` 读取模板，根据需求生成方法。

每个方法的步骤：
1. 使用 `executeWithEffects()` 或手动处理
2. 调用 Repository 方法
3. 使用 pattern matching 处理 Result
4. 更新 State：`emit(nextState()..field = value)`

### 2.3 生成 Repo 文件

从 `templates/repo_template.dart` 读取模板，生成：
- **抽象接口**：定义所有数据操作方法
- **Impl 实现**：调用真实 API（TODO 标记）
- **Mock 实现**：返回模拟数据

### 2.4 生成 Page 文件

从 `templates/page_template.dart` 读取模板：
- 根据"页面类型"选择页面结构
- 根据"设计图"生成 UI 代码
- 使用 `BlocListener` 处理 Effect
- 使用 `BlocBuilder` 构建 UI

---

## 步骤 3：配置路由（详细）

### 3.1 打开路由文件

文件路径：`lib/main_frame/router.dart`

### 3.2 找到路由列表

查找类似这样的结构：
```dart
final List<GetPage> routes = [
  _buildPage(...),
  _buildPage(...),
  // 在这里添加新路由
];
```

### 3.3 添加路由

```dart
_buildPage(
  name: '/environment-sensor',  // kebab-case
  page: () => EnvironmentSensorPage.routePage(),
),
```

**注意事项**：
- 路由名使用 kebab-case（小写+连字符）
- 使用 `routePage()` 静态方法
- 路由名应该与功能相关

### 3.4 导入页面

在文件顶部添加导入：
```dart
import 'package:nexoptim/business_modules/environment_sensor/environment_sensor_page.dart';
```

---

## 步骤 4：注册 Repository（详细）

### 4.1 打开依赖文件

文件路径：`lib/main_frame/repo_providers.dart`

### 4.2 找到 allRepoProviders 函数

查找返回 RepositoryProvider 列表的函数。

### 4.3 添加 Repository 注册

```dart
RepositoryProvider<EnvironmentSensorRepo>(create: (context) {
  return _getRepo(
    MockEnvironmentSensorRepo(),
    EnvironmentSensorRepoImpl(),
  );
}),
```

**注意事项**：
- 使用 `RepositoryProvider`
- 使用 `_getRepo()` 切换 Mock 和真实实现
- Mock 放前面，真实实现放后面

### 4.4 导入 Repository

在文件顶部添加导入：
```dart
import 'package:nexoptim/business_modules/environment_sensor/environment_sensor_repo.dart';
```

---

## 步骤 5：检查验证（详细）

### 5.1 代码格式化

```bash
dart format . --line-length 120
```

检查点：
- [ ] 所有文件格式化成功
- [ ] 没有格式化警告

### 5.2 代码分析

```bash
flutter analyze
```

检查点：
- [ ] 没有错误
- [ ] 没有警告（或警告可忽略）
- [ ] 所有导入路径正确

### 5.3 运行测试

```bash
flutter test
```

检查点：
- [ ] 所有测试通过
- [ ] 新功能的测试覆盖

### 5.4 运行应用

```bash
flutter run
```

检查点：
- [ ] 应用启动成功
- [ ] 可以导航到新页面
- [ ] Mock 数据显示正常

### 5.5 Mock 模式测试

1. 启用 Mock 模式：设置 `$appCache.mockRepo = true`
2. 重启应用
3. 检查：
   - [ ] Mock 数据加载正常
   - [ ] UI 显示正常
   - [ ] 交互功能正常

### 5.6 真实 API 测试

1. 关闭 Mock 模式：设置 `$appCache.mockRepo = false`
2. 重启应用
3. 检查：
   - [ ] API 调用正常
   - [ ] 数据显示正确
   - [ ] 错误处理正常

---

## 常见问题

### Q1: 导入路径错误
**问题**：`Target of URI doesn't exist`

**解决**：
1. 检查文件路径是否正确
2. 检查文件名是否匹配（大小写）
3. 运行 `flutter pub get`

### Q2: 路由找不到
**问题**：`Route not found`

**解决**：
1. 检查路由是否已注册
2. 检查路由名称是否正确（区分大小写）
3. 检查是否使用了 `routePage()` 方法

### Q3: Repository 未注册
**问题**：`Could not find the correct Provider`

**解决**：
1. 检查 Repository 是否已注册
2. 检查 Provider 类型是否匹配
3. 检查导入是否正确

### Q4: Mock 模式不生效
**问题**：Mock 模式切换后没有效果

**解决**：
1. 需要完全重启应用（热重载不够）
2. 检查 `$appCache.mockRepo` 的值
3. 检查 `_getRepo()` 调用是否正确

---

## 下一步

完成基本功能后：

1. **添加国际化翻译**
   - 使用 `/translate skill`
   - 为所有文本添加翻译

2. **完善 UI**
   - 根据设计图调整样式
   - 添加动画和交互

3. **编写测试**
   - 单元测试
   - Widget 测试
   - 集成测试

4. **编写文档**
   - API 文档
   - 使用说明
   - 架构说明
