# 架构参考

## 项目架构概览

NexOptim 使用 Flutter + BLoC/Cubit 架构，结合 Repository 模式和 GetX 路由。

### 核心组件

```
┌─────────────────────────────────────────┐
│              Presentation Layer          │
│  ┌──────────┐      ┌──────────────────┐ │
│  │   Page   │──────│   BlocBuilder    │ │
│  └──────────┘      └──────────────────┘ │
│                            │             │
│                     ┌──────▼──────┐      │
│                     │   Cubit     │      │
│                     └──────┬──────┘      │
└────────────────────────────┼─────────────┘
                               │
┌──────────────────────────────▼────────────┐
│              Business Logic Layer         │
│  ┌──────────────────────────────────────┐ │
│  │            Repository                 │ │
│  │  ┌───────────┐    ┌────────────────┐ │ │
│  │  │   Impl    │    │      Mock      │ │ │
│  │  └───────────┘    └────────────────┘ │ │
│  └──────────────────────────────────────┘ │
└────────────────────────────────────────────┘
```

---

## 状态管理：BLoC/Cubit

### BaseCubit

所有 Cubit 都继承 `BaseCubit<T>`，提供以下功能：

```dart
abstract class BaseCubit<T extends BaseState> extends Cubit<T> {
  BaseCubit(T initialState) : super(initialState);

  // 创建状态副本
  T nextState();

  // 执行操作并自动处理 Effect
  Future<void> executeWithEffects({
    required Future Function() action,
    void Function(dynamic)? onSuccess,
    String? onSuccessMsg,
  });
}
```

### 使用示例

```dart
class MyCubit extends BaseCubit<MyState> {
  final MyRepo _repo;

  MyCubit(this._repo) : super(MyState());

  Future<void> loadData(String id) async {
    // 方法 1：手动处理
    final result = await _repo.getData(id);
    if (result case Success(:final data)) {
      emit(nextState()..name = data);
    } else if (result case Failure(:final reason)) {
      emit(nextState()..effect = EffectErrorToast(reason));
    }

    // 方法 2：使用 executeWithEffects
    await executeWithEffects(
      action: () => _repo.getData(id),
      onSuccess: (data) => emit(nextState()..name = data),
      onSuccessMsg: '加载成功',
    );
  }
}
```

### BaseState

所有 State 都继承 `BaseState`，提供以下功能：

```dart
abstract class BaseState {
  Effect? effect;

  // 创建状态副本
  BaseState copy();
}
```

### 使用示例

```dart
class MyState extends BaseState {
  String name = '';
  bool isLoading = false;

  @override
  MyState copy() => MyState()
    ..name = name
    ..isLoading = isLoading;
}

// 使用
emit(nextState()..name = 'New Name');
```

---

## Effect 系统

Effect 用于处理一次性事件，如 Toast、Dialog、Navigation。

### Effect 类型

```dart
sealed class Effect {}

// 显示加载中
class EffectToastLoading extends Effect {}

// 显示错误提示
class EffectErrorToast<T> extends Effect {
  final T value;
  EffectErrorToast(this.value);
}

// 显示成功提示
class EffectSuccessToast<T> extends Effect {
  final T value;
  EffectSuccessToast(this.value);
}

// 导航到新页面
class EffectNavigate extends Effect {
  final String route;
  final Object? arguments;
  EffectNavigate(this.route, {this.arguments});
}

// 显示对话框
class EffectDialog extends Effect {
  final Widget dialog;
  EffectDialog(this.dialog);
}
```

### 在 BlocListener 中处理

```dart
BlocListener<MyCubit, MyState>(
  listener: (context, state) async {
    // 处理 Effect
    if (state.effect case EffectToastLoading()) {
      ToastHandler.showWaitMsg();
    } else if (state.effect case EffectErrorToast(:final value)) {
      ToastHandler.showMsgWithErrorIcon(value);
    } else if (state.effect case EffectSuccessToast(:final value)) {
      ToastHandler.showMsgWithSuccessIcon(value);
    }

    // 清除 Effect
    if (state.effect != null) {
      emit(state..effect = null);
    }
  },
  child: /* UI */,
)
```

---

## 数据层：Repository 模式

### Repository 接口

定义数据操作抽象接口：

```dart
abstract class MyRepo {
  Future<Result<Map<String, dynamic>?>> getData(String id);
  Future<Result<List<Item>>> getList();
  Future<Result<void>> deleteItem(String id);
}
```

### Repository 实现

真实的 API 调用实现：

```dart
class MyRepoImpl implements MyRepo {
  final HttpManager _http;

  @override
  Future<Result<Map<String, dynamic>?>> getData(String id) async {
    try {
      final response = await _http.get('/api/data/$id');
      return Success(response.data);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
```

### Mock 实现

用于开发和测试的模拟数据：

```dart
class MockMyRepo implements MyRepo {
  @override
  Future<Result<Map<String, dynamic>?>> getData(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    return Success({'id': id, 'name': 'Mock Data'});
  }
}
```

### Result 类型

统一的异步操作结果类型：

```dart
sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends Result<T> {
  final String reason;
  Failure(this.reason);
}
```

### 使用 Pattern Matching

```dart
final result = await repo.getData(id);
switch (result) {
  case Success(:final data):
    // 处理成功
    print(data);
  case Failure(:final reason):
    // 处理失败
    print(reason);
}
```

---

## 路由：GetX

### 路由配置

在 `lib/main_frame/router.dart` 中定义所有路由：

```dart
final List<GetPage> routes = [
  _buildPage(
    name: '/home',
    page: () => HomePage.routePage(),
  ),
  _buildPage(
    name: '/device-detail',
    page: () => DeviceDetailPage.routePage(),
  ),
];
```

### 导航方法

```dart
// 导航到新页面
Get.toNamed('/device-detail', arguments: {'id': '123'});

// 替换当前页面
Get.offNamed('/home');

// 清空栈并导航
Get.offAllNamed('/login');

// 返回上一页
Get.back();

// 返回并带数据
Get.back(result: 'data');
```

### 获取路由参数

```dart
@override
void initState() {
  super.initState();
  final id = Get.arguments?['id'] ?? '';
}
```

### routePage() 模式

所有页面都应该提供静态方法 `routePage()`：

```dart
class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();

  static Widget routePage() => BlocProvider<MyCubit>(
    create: (context) => MyCubit(context.read<MyRepo>()),
    child: const MyPage(),
  );
}
```

---

## 依赖注入

### Repository 注册

在 `lib/main_frame/repo_providers.dart` 中注册所有 Repository：

```dart
List allRepoProviders() => [
  RepositoryProvider<MyRepo>(create: (context) {
    return _getRepo(
      MockMyRepo(),
      MyRepoImpl(),
    );
  }),
];
```

### _getRepo() 方法

根据 Mock 模式切换实现：

```dart
T _getRepo<T>(T mockRepo, T realRepo) {
  if ($appCache.mockRepo) {
    return mockRepo;
  }
  return realRepo;
}
```

### 启用 Mock 模式

```dart
// 在应用启动时设置
$appCache.mockRepo = true; // 需要重启应用
```

### 使用 Repository

```dart
class MyCubit extends BaseCubit<MyState> {
  final MyRepo _repo;

  MyCubit(this._repo) : super(MyState());

  // 在 Page 中创建
  static Widget routePage() => BlocProvider<MyCubit>(
    create: (context) => MyCubit(context.read<MyRepo>()),
    child: const MyPage(),
  );
}
```

---

## 不可变状态

### 为什么使用不可变状态？

1. **可预测性**：状态不会在不知情的情况下被修改
2. **可追踪性**：每次状态改变都是新的对象
3. **时间旅行调试**：可以回溯到之前的状态

### 如何更新状态？

```dart
// ❌ 错误：直接修改
state.name = 'New Name';
emit(state);

// ✅ 正确：创建副本
emit(nextState()..name = 'New Name');
```

### copy() 方法

每个 State 都需要实现 `copy()` 方法：

```dart
@override
MyState copy() => MyState()
  ..name = name
  ..isLoading = isLoading
  ..items = List.from(items);
```

### nextState() 方法

`BaseCubit` 提供的便捷方法：

```dart
T nextState() {
  final newState = state.copy() as T;
  return newState;
}

// 使用
emit(nextState()..name = 'New Name');
```

---

## 国际化

### .t 扩展

所有文本都需要使用 `.t` 扩展：

```dart
// ❌ 错误
Text('设备列表')

// ✅ 正确
Text('设备列表'.t)
```

### 添加翻译

使用 `/translate skill` 添加翻译：

```dart
// 中文
'设备列表'

// 英文
'Device List'

// 德语
'Geräteliste'
```

---

## 代码规范

### 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件名 | snake_case | `device_list_page.dart` |
| 类名 | PascalCase | `DeviceListPage` |
| 方法名 | camelCase | `loadData` |
| 变量名 | camelCase | `deviceName` |
| 常量名 | camelCase | `maxItems` |
| 路由名 | kebab-case | `/device-list` |

### 格式规范

```bash
# 行长度：120 字符
dart format . --line-length 120

# 检查代码
flutter analyze
```

### 注释规范

```dart
/// 文档注释（用于公开 API）
Future<void> loadData(String id) async {
  // 单行注释（用于实现细节）
  final result = await _repo.getData(id);
}
```

---

## 常见模式

### 加载数据

```dart
Future<void> loadData(String id) async {
  emit(nextState()..isLoading = true);
  final result = await _repo.getData(id);
  if (result case Success(:final data)) {
    emit(nextState()
      ..isLoading = false
      ..data = data);
  } else if (result case Failure(:final reason)) {
    emit(nextState()
      ..isLoading = false
      ..effect = EffectErrorToast(reason));
  }
}
```

### 刷新数据

```dart
Future<void> refreshData() async {
  await loadData(state.id);
}
```

### 删除项目

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

### 表单提交

```dart
Future<void> submitForm() async {
  if (!_validateForm()) return;

  await executeWithEffects(
    action: () => _repo.createItem(formData),
    onSuccess: (_) {
      Get.back(result: 'success');
    },
    onSuccessMsg: '提交成功',
  );
}
```
