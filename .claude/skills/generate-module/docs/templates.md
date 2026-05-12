# 代码模板说明

## 模板文件列表

- `state_template.dart` - State 类模板
- `cubit_template.dart` - Cubit 类模板
- `repo_template.dart` - Repository 接口和实现模板
- `page_template.dart` - Page 页面模板

## 使用方法

### 1. 读取模板

使用 `Read` 工具读取模板文件：
```
Read: templates/state_template.dart
```

### 2. 替换占位符

模板中的占位符：

| 占位符 | 说明 | 示例 |
|--------|------|------|
| `___FeatureName___` | PascalCase 类名 | `EnvironmentSensor` |
| `___featureName___` | camelCase 变量名 | `environmentSensor` |
| `___feature_name___` | kebab-case 文件名 | `environment_sensor` |
| `___FIELDS___` | State 字段定义 | 动态生成 |
| `___METHODS___` | Cubit 方法定义 | 动态生成 |
| `___PAGE_CONTENT___` | 页面内容 | 动态生成 |

### 3. 生成代码

将替换后的内容写入目标文件。

---

## State 模板详解

### 基本结构

```dart
import '../base_cubit.dart';

class ___FeatureName___State extends BaseState {
  // 字段定义

  @override
  ___FeatureName___State copy() => ___FeatureName___State()
    ..复制所有字段;

  @override
  String toString() => '___FeatureName___State()';
}
```

### 字段定义示例

```dart
String deviceName = '';
double temperature = 0.0;
bool isOnline = false;
List<String> tags = [];
```

### copy() 方法

```dart
@override
EnvironmentSensorState copy() => EnvironmentSensorState()
  ..deviceName = deviceName
  ..temperature = temperature
  ..isOnline = isOnline
  ..tags = tags;
```

---

## Cubit 模板详解

### 基本结构

```dart
import 'package:nexoptim/business_modules/base_logic.dart';
import '../base_cubit.dart';
import '___feature_name___repo.dart';
import '___feature_name___state.dart';

class ___FeatureName___Cubit extends BaseCubit<___FeatureName___State> {
  final ___FeatureName___Repo _repo;

  ___FeatureName___Cubit(this._repo) : super(___FeatureName___State());

  // 方法定义
}
```

### 常见方法模板

#### 初始化方法

```dart
Future<void> initialize(String id) async {
  emit(nextState()..isLoading = true);
  final result = await _repo.getData(id);
  if (result case Success(:final data)) {
    emit(nextState()
      ..isLoading = false
      ..deviceName = data['deviceName'] ?? '');
  } else if (result case Failure(:final reason)) {
    emit(nextState()
      ..isLoading = false
      ..effect = EffectErrorToast(reason));
  }
}
```

#### 使用 executeWithEffects

```dart
Future<void> loadData(String id) async {
  await executeWithEffects(
    action: () => _repo.getData(id),
    onSuccess: (data) {
      emit(nextState()
        ..deviceName = data['deviceName'] ?? ''
        ..temperature = data['temperature'] ?? 0.0);
    },
  );
}
```

#### 刷新方法

```dart
Future<void> refreshData() async {
  await loadData(state.id);
}
```

#### 删除方法

```dart
Future<void> deleteItem(String itemId) async {
  await executeWithEffects(
    action: () => _repo.deleteItem(itemId),
    onSuccess: (_) {
      emit(nextState()..items.removeWhere((item) => item.id == itemId));
    },
    onSuccessMsg: '删除成功',
  );
}
```

---

## Repo 模板详解

### 基本结构

```dart
import '../../main_frame/result.dart';

abstract class ___FeatureName___Repo {
  // 方法定义
}

class ___FeatureName___RepoImpl implements ___FeatureName___Repo {
  // 实现
}

class Mock___FeatureName___Repo implements ___FeatureName___Repo {
  // Mock 实现
}
```

### 方法定义示例

```dart
abstract class EnvironmentSensorRepo {
  Future<Result<Map<String, dynamic>?>> getData(String id);
  Future<Result<List<Map<String, dynamic>>>> getList();
  Future<Result<void>> deleteItem(String id);
  Future<Result<void>> updateItem(Map<String, dynamic> data);
}
```

### Impl 实现

```dart
class EnvironmentSensorRepoImpl implements EnvironmentSensorRepo {
  @override
  Future<Result<Map<String, dynamic>?>> getData(String id) async {
    // TODO: 实现 API 调用
    try {
      final response = await http.get('/api/sensor/$id');
      if (response.statusCode == 200) {
        return Success(response.data);
      } else {
        return Failure('请求失败');
      }
    } catch (e) {
      return Failure('网络错误');
    }
  }
}
```

### Mock 实现

```dart
class MockEnvironmentSensorRepo implements EnvironmentSensorRepo {
  @override
  Future<Result<Map<String, dynamic>?>> getData(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Success({
      'deviceName': 'Mock Sensor',
      'temperature': 25.5,
      'isOnline': true,
    });
  }
}
```

---

## Page 模板详解

### 基本结构

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:nexoptim/business_modules/base_logic.dart';
import '../../../main_frame/app_effect.dart';
import '../../../main_frame/toast_handler.dart';
import '../../../ui_components/factory/ui_factory.dart';
import '../../../ui_components/ui_theme.dart';
import '___feature_name___cubit.dart';
import '___feature_name___repo.dart';
import '___feature_name___state.dart';

class ___FeatureName___Page extends StatefulWidget {
  const ___FeatureName___Page({super.key});

  @override
  State<___FeatureName___Page> createState() => ___FeatureName___PageState();

  static Widget routePage() => BlocProvider<___FeatureName___Cubit>(
        create: (context) {
          ___FeatureName___Cubit cubit = ___FeatureName___Cubit(
            context.read<___FeatureName___Repo>()
          );
          return cubit;
        },
        child: const ___FeatureName___Page(),
      );
}
```

### BlocListener

```dart
BlocListener<___FeatureName___Cubit, ___FeatureName___State>(
  listener: (context, state) async {
    if (state.effect is! EffectToastLoading) {
      await ToastHandler.dismissMsg();
    }
    switch (state.effect) {
      case EffectToastLoading():
        ToastHandler.showWaitMsg();
        break;
      case EffectErrorToast<String>(:final value):
        ToastHandler.showMsgWithErrorIcon(value);
        break;
      case EffectSuccessToast<String>(:final value):
        ToastHandler.showMsgWithSuccessIcon(value);
        break;
      default:
        break;
    }
  },
  child: /* UI 内容 */,
)
```

### BlocBuilder

```dart
BlocBuilder<___FeatureName___Cubit, ___FeatureName___State>(
  builder: (context, state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return /* 实际 UI */;
  },
)
```

### SmartRefresher

```dart
SmartRefresher(
  enablePullDown: true,
  controller: _refreshController,
  onRefresh: _onRefresh,
  child: /* 可滚动内容 */,
)
```

---

## UI 组件示例

### 卡片容器

```dart
Container(
  decoration: AppStyles.roundCornerDecoration(),
  padding: EdgeInsets.all(16.dp),
  child: /* 内容 */,
)
```

### 列表项

```dart
ListTile(
  title: Text(item.name.t),
  subtitle: Text(item.description.t),
  trailing: Icon(Icons.chevron_right),
  onTap: () => /* 点击事件 */,
)
```

### 按钮

```dart
ElevatedButton(
  onPressed: () => /* 点击事件 */,
  child: Text('按钮文本'.t),
)
```

---

## 页面类型模板

### 列表页

```dart
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: _buildHeader()),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildListItem(state.items[index]),
        childCount: state.items.length,
      ),
    ),
  ],
)
```

### 详情页

```dart
SingleChildScrollView(
  child: Column(
    children: [
      _buildInfoCard(),
      _buildDetailsCard(),
      _buildActionsCard(),
    ],
  ),
)
```

### 表单页

```dart
Form(
  child: Column(
    children: [
      TextFormField(
        decoration: InputDecoration(labelText: '名称'.t),
        onChanged: (value) => /* 更新状态 */,
      ),
      ElevatedButton(
        onPressed: () => /* 提交 */,
        child: Text('保存'.t),
      ),
    ],
  ),
)
```
