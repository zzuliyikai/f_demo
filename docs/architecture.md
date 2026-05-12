# Flutter App 框架架构设计文档

> 项目：f_demo | 技术选型：Bloc/Cubit + Dio + GoRouter + .t 扩展翻译

---

## 1. 项目目录结构（Feature-First 架构）

```
f_demo/
├── lib/
│   ├── main.dart                        # 入口：异步初始化（WidgetsFlutterBinding + get_it + AppCache）
│   ├── app.dart                         # MaterialApp.router（主题/国际化/路由/MultiRepositoryProvider）
│   │
│   ├── core/                            # 跨模块基础设施
│   │   ├── network/
│   │   │   ├── dio_client.dart          # DioClient 基类（工厂模式，按服务配置创建）
│   │   │   ├── service_config.dart      # 各服务的配置常量（baseUrl、超时等）
│   │   │   ├── api_result.dart          # Result<T> sealed class (Success / Failure)
│   │   │   ├── api_exception.dart       # 统一 ApiException 层级 + 服务专属子类
│   │   │   ├── interceptors/
│   │   │   │   ├── log_interceptor.dart     # 请求/响应日志拦截器
│   │   │   │   ├── retry_interceptor.dart   # 指数退避自动重试拦截器（最多3次）
│   │   │   │   └── auth_interceptor.dart    # Auth token 注入（按服务区分 token）
│   │   │   └── services/
│   │   │       ├── allstar/
│   │   │       │   ├── allstar_client.dart  # Allstar DioClient 配置
│   │   │       │   └── allstar_errors.dart  # Allstar 自定义错误码映射表
│   │   │       ├── ps/
│   │   │       │   ├── ps_client.dart       # PS DioClient 配置
│   │   │       │   └── ps_errors.dart       # PS 自定义错误码映射表
│   │   │       ├── mapserver/
│   │   │       │   ├── mapserver_client.dart # MapServer DioClient 配置
│   │   │       │   └── mapserver_errors.dart # MapServer 自定义错误码映射表
│   │   │       └── aurora/
│   │   │           ├── aurora_client.dart    # Aurora DioClient 配置
│   │   │           └── aurora_errors.dart    # Aurora 自定义错误码映射表
│   │   │
│   │   ├── router/
│   │   │   ├── app_router.dart          # GoRouter 配置（路由表 + 重定向守卫）
│   │   │   ├── route_names.dart         # 路由路径常量
│   │   │   └── route_guards.dart        # Auth/角色重定向守卫逻辑
│   │   │
│   │   ├── localization/
│   │   │   ├── string_extension.dart  # .t String 扩展（核心翻译机制）
│   │   │   └── localization.dart      # Localization 管理类（语言切换 + Map 加载）
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart           # ThemeData（light + dark）
│   │   │   ├── app_colors.dart          # 颜色常量
│   │   │   ├── app_text_styles.dart     # 文字样式定义
│   │   │   └── app_spacing.dart         # 间距/尺寸常量
│   │   │
│   │   ├── di/
│   │   │   └── injection.dart           # get_it 服务定位器注册入口
│   │   │
│   │   ├── storage/
│   │   │   └── app_cache.dart           # SharedPreferences 封装（token/mock模式/语言/主题）
│   │   │
│   │   ├── base/
│   │   │   ├── base_cubit.dart          # BaseCubit<T>（nextState + executeWithEffects）
│   │   │   └── base_state.dart          # BaseState（isLoading + effect + copy）
│   │   │
│   │   ├── effect/
│   │   │   ├── app_effect.dart          # Effect sealed class（Toast/导航/弹窗）
│   │   │   └── effect_handler.dart      # Effect → UI 动作集中映射
│   │   │
│   │   └── utils/
│   │       ├── logger.dart              # 日志工具
│   │       └── connectivity_helper.dart # 网络连通性检测（connectivity_plus）
│   │
│   ├── features/                        # 功能模块（generate-module 生成目标）
│   │   ├── home/
│   │   │   ├── home_cubit.dart
│   │   │   ├── home_state.dart
│   │   │   ├── home_repo.dart           # Abstract + Impl + Mock
│   │   │   └── home_page.dart
│   │   │
│   │   ├── settings/
│   │   │   ├── settings_cubit.dart
│   │   │   ├── settings_state.dart
│   │   │   ├── settings_repo.dart
│   │   │   └── settings_page.dart
│   │   │
│   │   └── ...（后续通过 generate-module 创建）
│   │
│   └── shared/                          # 共享 UI 组件
│       ├── widgets/
│       │   ├── loading_widget.dart      # 加载指示器
│       │   ├── error_widget.dart        # 错误状态展示
│       │   ├── empty_widget.dart        # 空数据展示
│       │   └── toast_handler.dart       # Toast 显示工具
│       │
│       └── extensions/
│           ├── context_extensions.dart  # BuildContext 便利方法
│           └── string_extensions.dart   # String 工具扩展
│
│   ├── localization/                     # 翻译 Map 文件
│   │   ├── zh_hans_strings.dart           # 中文简体（基准语言）
│   │   └── en_strings.dart                # 英语
│   │   └── (其他语言按需追加)
│
├── docs/                                # 项目文档
├── test/                                # 测试目录
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 2. 依赖清单

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0                        # Material 本地化 delegates 所需

  # 状态管理
  flutter_bloc: ^8.1.6                  # BlocProvider / BlocBuilder / RepositoryProvider
  equatable: ^2.0.5                     # State 值比较（可选）

  # 网络
  dio: ^5.4.3+1                         # HTTP 客户端 + 拦截器链
  connectivity_plus: ^6.0.3             # 网络连通性检测

  # 路由
  go_router: ^14.2.1                    # 声明式路由 + 深链接 + 重定向守卫

  # 依赖注入
  get_it: ^7.7.0                        # 轻量服务定位器

  # 存储
  shared_preferences: ^2.2.3            # KV 本地存储

  # UI
  cupertino_icons: ^1.0.8
  logger: ^2.3.0                        # 结构化日志
  pull_to_refresh: ^2.0.0               # 下拉刷新（generate-module 使用）

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7                     # Cubit/Bloc 测试工具
  mocktail: ^1.0.3                      # Mock 生成
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```

> 注意：不使用 `generate: true` 和 ARB 代码生成，翻译由 .t 扩展 + Dart Map 文件管理

---

## 3. 核心层设计

### 3.1 网络层（多服务 Dio 架构）

**4个后端服务**：Allstar、PS、MapServer、Aurora，各有独立 baseUrl 和自定义错误码。

**核心设计：每个服务独立 DioClient 实例**，通过 get_it 的 `instanceName` 注册和获取。

#### DioClient 基类

```dart
class DioClient {
  late final Dio _dio;
  final String serviceName;

  DioClient({
    required this.serviceName,
    required String baseUrl,
    required ErrorInterceptor errorInterceptor,
    AuthInterceptor? authInterceptor,
    int connectTimeout = 15,
    int receiveTimeout = 15,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: connectTimeout),
      receiveTimeout: Duration(seconds: receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.addAll([
      LogInterceptor(),
      if (authInterceptor != null) authInterceptor,
      RetryInterceptor(_dio),
      errorInterceptor,  // 每个服务有自己的错误映射逻辑
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? params, Options? options}) =>
      _dio.get(path, queryParameters: params, options: options);
  Future<Response> post(String path, {dynamic data, Options? options}) =>
      _dio.post(path, data: data, options: options);
  Future<Response> put(String path, {dynamic data, Options? options}) =>
      _dio.put(path, data: data, options: options);
  Future<Response> delete(String path, {Map<String, dynamic>? params, Options? options}) =>
      _dio.delete(path, queryParameters: params, options: options);
}
```

#### 服务配置常量

```dart
class ServiceConfig {
  // Allstar
  static const allstarBaseUrl = 'https://allstar.example.com/api';
  static const allstarConnectTimeout = 15;
  static const allstarReceiveTimeout = 15;

  // PS
  static const psBaseUrl = 'https://ps.example.com/api/v2';
  static const psConnectTimeout = 10;
  static const psReceiveTimeout = 20;

  // MapServer
  static const mapserverBaseUrl = 'https://mapserver.example.com';
  static const mapserverConnectTimeout = 15;
  static const mapserverReceiveTimeout = 30;  // 地图数据可能较大

  // Aurora
  static const auroraBaseUrl = 'https://aurora.example.com/api';
  static const auroraConnectTimeout = 10;
  static const auroraReceiveTimeout = 15;
}
```

#### 统一 ApiException 层级 + 服务专属错误码

```dart
// 统一层级（所有服务共用的基础异常）
sealed class ApiException implements Exception {
  final String message;
  final String? serviceCode;  // 原始服务错误码（如 Allstar 的 1001）
  const ApiException(this.message, {this.serviceCode});
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'Network error']);
}
class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'Request timed out']);
}
class ServerException extends ApiException {
  final int statusCode;
  const ServerException(this.statusCode, [super.message = 'Server error']);
}
class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Unauthorized'], {super.serviceCode});
}
class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Resource not found']);
}

// 服务专属异常（各服务自定义码映射到这些子类）
class AllstarTokenExpiredException extends UnauthorizedException {
  const AllstarTokenExpiredException() : super('Token expired', serviceCode: '1001');
}
class AuroraDeviceOfflineException extends ApiException {
  const AuroraDeviceOfflineException() : super('Device offline', serviceCode: '5001');
}
```

#### 服务专属错误码映射示例

```dart
// allstar_errors.dart
class AllstarErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badResponse) {
      final statusCode = err.response?.statusCode ?? 0;
      final body = err.response?.data;
      final errorCode = body is Map ? body['code']?.toString() : null;

      ApiException exception;
      switch (errorCode) {
        case '1001': exception = const AllstarTokenExpiredException();
        case '1002': exception = const ApiException('Invalid parameter', serviceCode: '1002');
        case '2001': exception = const ApiException('Permission denied', serviceCode: '2001');
        default:
          if (statusCode == 401) exception = const UnauthorizedException();
          else if (statusCode == 404) exception = const NotFoundException();
          else exception = ServerException(statusCode);
      }
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
      ));
    } else {
      // 通用网络/超时错误映射（所有服务一致）
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: _mapCommonErrors(err),
        type: err.type,
      ));
    }
  }

  ApiException _mapCommonErrors(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      default:
        return NetworkException(err.message ?? 'Unexpected error');
    }
  }
}
```

```dart
// aurora_errors.dart
class AuroraErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badResponse) {
      final statusCode = err.response?.statusCode ?? 0;
      final body = err.response?.data;
      final errorCode = body is Map ? body['error_code']?.toString() : null;
      // Aurora 用不同的字段名和不同的码值

      ApiException exception;
      switch (errorCode) {
        case '5001': exception = const AuroraDeviceOfflineException();
        case '5002': exception = const ApiException('Device not found', serviceCode: '5002');
        case '6001': exception = const UnauthorizedException(serviceCode: '6001');
        default:
          if (statusCode == 403) exception = const ApiException('Forbidden');
          else exception = ServerException(statusCode);
      }
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
      ));
    } else {
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: _mapCommonErrors(err),
        type: err.type,
      ));
    }
  }
  // _mapCommonErrors 同 Allstar
}
```

#### 服务客户端创建

```dart
// allstar_client.dart
DioClient createAllstarClient() => DioClient(
  serviceName: 'allstar',
  baseUrl: ServiceConfig.allstarBaseUrl,
  errorInterceptor: AllstarErrorInterceptor(),
  authInterceptor: AuthInterceptor(tokenKey: 'allstar_token'),
);

// aurora_client.dart
DioClient createAuroraClient() => DioClient(
  serviceName: 'aurora',
  baseUrl: ServiceConfig.auroraBaseUrl,
  connectTimeout: ServiceConfig.auroraConnectTimeout,
  receiveTimeout: ServiceConfig.auroraReceiveTimeout,
  errorInterceptor: AuroraErrorInterceptor(),
  authInterceptor: AuthInterceptor(tokenKey: 'aurora_token'),
);
```

#### DI 注册（get_it 按服务名注册）

```dart
// injection.dart
final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // 基础设施
  getIt.registerSingleton<AppCache>(AppCache());
  getIt.registerSingleton<Localization>(Localization.instance);

  // 多服务 DioClient（每个服务独立实例）
  getIt.registerSingleton<DioClient>(createAllstarClient(), instanceName: 'allstar');
  getIt.registerSingleton<DioClient>(createPsClient(), instanceName: 'ps');
  getIt.registerSingleton<DioClient>(createMapserverClient(), instanceName: 'mapserver');
  getIt.registerSingleton<DioClient>(createAuroraClient(), instanceName: 'aurora');
}
```

#### Repo 中使用指定服务客户端

```dart
class DeviceRepoImpl implements DeviceRepo {
  final DioClient _allstar = getIt<DioClient>(instanceName: 'allstar');
  final DioClient _aurora = getIt<DioClient>(instanceName: 'aurora');

  @override
  Future<Result<Map<String, dynamic>?>> getDeviceInfo(String id) async {
    try {
      // 设备基础信息来自 Allstar
      final response = await _allstar.get('/device/$id');
      return Success(response.data);
    } on DioException catch (e) {
      final exception = e.error as ApiException?;
      return Failure(exception?.message ?? e.message ?? 'Unknown error', exception: exception);
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getDeviceStatus(String id) async {
    try {
      // 设备在线状态来自 Aurora
      final response = await _aurora.get('/status/$id');
      return Success(response.data);
    } on DioException catch (e) {
      final exception = e.error as ApiException?;
      return Failure(exception?.message ?? e.message ?? 'Unknown error', exception: exception);
    }
  }
}
```

#### Auth 拦截器按服务区分 token

```dart
class AuthInterceptor extends Interceptor {
  final String tokenKey;  // 不同服务用不同的 token key

  AuthInterceptor({required this.tokenKey});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getIt<AppCache>().getToken(tokenKey);
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      getIt<AppCache>().clearToken(tokenKey);
    }
    handler.next(err);
  }
}
```

**AppCache 扩展（支持多服务 token）：**

```dart
class AppCache {
  late SharedPreferences _prefs;

  // 通用 token
  String get authToken => _prefs.getString('auth_token') ?? '';
  Future<void> setAuthToken(String token) => _prefs.setString('auth_token', token);
  Future<void> clearAuth() => _prefs.remove('auth_token');

  // 服务专属 token
  String getToken(String service) => _prefs.getString('token_$service') ?? '';
  Future<void> setToken(String service, String token) => _prefs.setString('token_$service', token);
  Future<void> clearToken(String service) => _prefs.remove('token_$service');

  // 其他字段不变...
}
```

### 3.2 路由层（GoRouter）

```dart
final appRouter = GoRouter(
  initialLocation: RouteNames.home,
  debugLogDiagnostics: true,
  redirect: _authGuard,
  routes: [
    GoRoute(
      path: RouteNames.home,
      name: 'home',
      builder: (context, state) => HomePage.routePage(),
    ),
    GoRoute(
      path: RouteNames.settings,
      name: 'settings',
      builder: (context, state) => SettingsPage.routePage(),
    ),
    // 新功能模块路由在此追加
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);

String? _authGuard(BuildContext context, GoRouterState state) {
  // 返回 null 允许访问，返回路径则重定向
  return null;
}
```

**RouteNames** — 路径常量：

```dart
class RouteNames {
  static const home = '/';
  static const settings = '/settings';
}
```

**导航方式（替代 GetX）：**
```dart
// 推入路由
context.go(RouteNames.settings);
context.push('/device-detail/123');

// 获取参数
final id = GoRouterState.of(context).queryParameters['id'] ?? '';

// 弹出
context.pop();
```

### 3.3 国际化层（.t 扩展方案）

**.t String 扩展（核心翻译机制）：**

```dart
// lib/core/localization/string_extension.dart
extension StringTranslation on String {
  String t => Localization.instance.translate(this);
}
```

**Localization 管理类（语言切换 + Map 加载）：**

```dart
// lib/core/localization/localization.dart
class Localization {
  static final Localization instance = Localization._();
  Localization._();

  Locale _currentLocale = const Locale('zh', 'Hans');
  final Map<Locale, Map<String, String>> _translations = {};

  Locale get currentLocale => _currentLocale;

  void load(Locale locale) {
    _currentLocale = locale;
    _translations[const Locale('zh', 'Hans')] = zhHansStrings;
    _translations[const Locale('en')] = enStrings;
    // 其他语言按需加载...
  }

  String translate(String key) {
    final translations = _translations[_currentLocale];
    if (translations == null) return key; // fallback: 返回原文（中文）
    return translations[key] ?? key;      // 未找到翻译: 返回原文
  }

  Future<void> changeLocale(Locale locale, AppCache cache) async {
    _currentLocale = locale;
    await cache.setLanguageCode(locale.languageCode);
  }
}
```

**翻译 Map 文件示例：**

```dart
// lib/localization/zh_hans_strings.dart（基准语言，key=中文，value=中文）
const Map<String, String> zhHansStrings = {
  '首页': '首页',
  '设置': '设置',
  '加载中...': '加载中...',
  '网络错误，请检查网络连接': '网络错误，请检查网络连接',
  '请求超时，请重试': '请求超时，请重试',
  '暂无数据': '暂无数据',
  '重试': '重试',
  '操作成功': '操作成功',
};

// lib/localization/en_strings.dart（key=中文，value=英文翻译）
const Map<String, String> enStrings = {
  '首页': 'Home',
  '设置': 'Settings',
  '加载中...': 'Loading...',
  '网络错误，请检查网络连接': 'Network error. Please check your connection.',
  '请求超时，请重试': 'Request timed out. Please try again.',
  '暂无数据': 'No data available',
  '重试': 'Retry',
  '操作成功': 'Operation successful',
};
```

**使用方式：**

```dart
// 代码中直接使用中文 + .t，简洁直观
Text('首页'.t)                           // 中文环境显示"首页"，英文环境显示"Home"
AppBar(title: Text('设备列表'.t))         // 不需要 context，可在任何地方使用
hintText: '请输入货架编号'.t              // 中国开发者无需想英文 key 名
```

**添加新翻译的工作流：**
1. 在代码中直接写 `'新中文文本'.t`
2. 运行 translate skill 的 Python 扫描脚本发现缺失 key
3. AI 自动为所有语言 Map 文件生成翻译
4. 批量更新所有 `*_strings.dart` 文件

### 3.4 主题层

```dart
class AppColors {
  static const primary = Color(0xFF6750A4);
  static const viewBackgroundColor = Color(0xFFF5F5F5);
  static const errorRed = Color(0xFFB3261E);
  static const successGreen = Color(0xFF4CAF50);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light),
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark),
  );
}
```

### 3.5 存储层

```dart
class AppCache {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 认证
  String get authToken => _prefs.getString('auth_token') ?? '';
  Future<void> setAuthToken(String token) => _prefs.setString('auth_token', token);
  Future<void> clearAuth() => _prefs.remove('auth_token');

  // Mock 模式切换
  bool get mockRepo => _prefs.getBool('mock_repo') ?? false;
  Future<void> setMockRepo(bool value) => _prefs.setBool('mock_repo', value);

  // 主题
  bool get isDarkMode => _prefs.getBool('is_dark_mode') ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool('is_dark_mode', value);

  // 语言
  String get languageCode => _prefs.getString('language_code') ?? 'en';
  Future<void> setLanguageCode(String code) => _prefs.setString('language_code', code);
}
```

---

## 4. 依赖注入策略（双层 DI）

**Layer 1 — get_it（基础设施单例）：**

```dart
final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // 基础设施
  getIt.registerSingleton<AppCache>(AppCache());
  getIt.registerSingleton<Localization>(Localization.instance);

  // 多服务 DioClient（按 instanceName 注册）
  getIt.registerSingleton<DioClient>(createAllstarClient(), instanceName: 'allstar');
  getIt.registerSingleton<DioClient>(createPsClient(), instanceName: 'ps');
  getIt.registerSingleton<DioClient>(createMapserverClient(), instanceName: 'mapserver');
  getIt.registerSingleton<DioClient>(createAuroraClient(), instanceName: 'aurora');
}
```

**Layer 2 — RepositoryProvider（Widget Tree 中的 Repo）：**

```dart
// 在 app.dart 中
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<HomeRepo>(
      create: (context) => _getRepo(MockHomeRepo(), HomeRepoImpl()),
    ),
    RepositoryProvider<SettingsRepo>(
      create: (context) => _getRepo(MockSettingsRepo(), SettingsRepoImpl()),
    ),
    // 新功能模块的 Repo 在此追加
  ],
  child: MaterialApp.router(...),
)

T _getRepo<T>(T mock, T real) => appCache.mockRepo ? mock : real;
```

**为什么双层：**
- get_it 管理 Widget Tree 之外的基础设施（Dio、SharedPreferences、配置）+ 多服务客户端按名注册
- RepositoryProvider 管理 Repo，沿用 generate-module 的 `context.read<XxxRepo>()` 模式
- `_getRepo(mock, real)` 保留 Mock 切换能力

---

## 5. Feature 模块模板规范

每个功能模块遵循统一结构，generate-module 据此生成：

```
lib/features/{module_name}/
├── {module_name}_cubit.dart       # extends BaseCubit<XxxState>
├── {module_name}_state.dart       # extends BaseState
├── {module_name}_repo.dart        # Abstract + Impl(DioClient) + Mock
├── {module_name}_page.dart        # StatefulWidget + routePage() 工厂
└── {module_name}_models.dart      # 数据模型（可选）
```

### BaseState / BaseCubit

**核心原则：loading 生命周期在"流程"层面控制，不在"请求"层面。**
一个流程 = loading 开始 → 执行所有请求 → loading 结束。中间请求完成只更新数据，不切换 loading，防止闪烁。

```dart
abstract class BaseState {
  bool isLoading = false;               // 整页首次加载
  final Map<String, bool> _loadingSlots = {};  // Named Loading Slots
  Effect? effect;

  BaseState copy();

  bool isLoadingSlot(String key) => _loadingSlots[key] ?? false;
  void setLoadingSlot(String key, bool value) => _loadingSlots[key] = value;
  bool get isAnyLoading => isLoading || _loadingSlots.values.any((v) => v);

  void clearEffect() => effect = null;
}

abstract class BaseCubit<T extends BaseState> extends Cubit<T> {
  BaseCubit(T initialState) : super(initialState);

  T nextState() => state.copy() as T;

  // ── Loading 生命周期手动控制 ──────────────────────────

  void startLoading(String slot) => emit(nextState()..setLoadingSlot(slot, true));
  void stopLoading(String slot) => emit(nextState()..setLoadingSlot(slot, false));
  void startLoadingAll(List<String> slots) {
    final s = nextState();
    for (final slot in slots) s.setLoadingSlot(slot, true);
    emit(s);
  }
  void stopLoadingAll(List<String> slots) {
    final s = nextState();
    for (final slot in slots) s.setLoadingSlot(slot, false);
    emit(s);
  }

  // ── 请求执行（不自动切换 loading）─────────────────────
  // 只处理数据返回和错误 Effect，loading 由开发者在流程层面手动控制

  Future<Result> run(Future<Result> action) async {
    final result = await action();
    if (result case Failure(:final reason)) {
      emit(nextState()..effect = EffectErrorToast(reason));
    }
    return result;
  }

  // ── 流程级便利方法（loading 不闪烁）────────────────────

  /// 整页首次加载：isLoading=true → 执行所有请求 → isLoading=false
  Future<void> loadPageFlow({required Future<void> action}) async {
    emit(nextState()..isLoading = true);
    await action();
    emit(nextState()..isLoading = false);
  }

  /// Slot 级加载：标记 slots → 执行所有请求 → slots 结束
  /// action 内可提前 stopLoading 某个 slot（数据先到先渲染）
  Future<void> loadSlotsFlow({
    required List<String> slots,
    required Future<void> action,
  }) async {
    startLoadingAll(slots);
    await action();
    stopLoadingAll(slots);  // 确保所有 slot 都关闭（防止遗漏）
  }

  // ── Overlay（提交/关键操作）+ 最少500ms防闪烁 ──────────

  Future<void> executeWithOverlay({
    required Future<Result> action,
    void Function(dynamic data)? onSuccess,
    String? onSuccessMsg,
  }) async {
    emit(nextState()..effect = const EffectOverlayLoading());
    final startTime = DateTime.now();
    final result = await action();
    // 最少显示500ms，防快速请求导致 overlay 闪烁
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 500) await Future.delayed(Duration(milliseconds: 500 - elapsed));
    if (result case Success(:final data)) {
      final newState = nextState()..clearEffect();
      if (onSuccess != null) onSuccess(data);
      if (onSuccessMsg != null) newState.effect = EffectSuccessToast(onSuccessMsg);
      emit(newState);
    } else if (result case Failure(:final reason)) {
      emit(nextState()..effect = EffectErrorToast(reason));
    }
  }

  // ── Toast（轻量操作）+ 最少500ms防闪烁 ────────────────

  Future<void> executeWithToast({
    required Future<Result> action,
    void Function(dynamic data)? onSuccess,
    String? onSuccessMsg,
  }) async {
    emit(nextState()..effect = const EffectToastLoading());
    final startTime = DateTime.now();
    final result = await action();
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 500) await Future.delayed(Duration(milliseconds: 500 - elapsed));
    if (result case Success(:final data)) {
      final newState = nextState()..clearEffect();
      if (onSuccess != null) onSuccess(data);
      if (onSuccessMsg != null) newState.effect = EffectSuccessToast(onSuccessMsg);
      emit(newState);
    } else if (result case Failure(:final reason)) {
      emit(nextState()..effect = EffectErrorToast(reason));
    }
  }
}
```

**Cubit 使用示例：**

```dart
class DashboardCubit extends BaseCubit<DashboardState> {
  final DashboardRepo _repo;

  // ── 并行请求：loading 从流程开始到结束，不闪烁
  Future<void> initialize() async {
    await loadSlotsFlow(slots: ['profile', 'devices', 'alerts'], action: () async {
      // 并行发起，哪个先完成就先渲染
      await Future.wait([
        _loadProfile(),
        _loadDevices(),
        _loadAlerts(),
      ]);
    });
  }

  Future<Result> _loadProfile() async {
    final result = await run(_repo.getProfile());
    if (result case Success(:final data)) {
      // 数据到了，提前结束该 slot 的 loading → UI 立刻渲染
      emit(nextState()..userName = data['name']..setLoadingSlot('profile', false));
    }
    return result;
  }

  // ── 顺序请求：loading 持续，中间不闪烁
  Future<void> loadSequential() async {
    await loadSlotsFlow(slots: ['devices'], action: () async {
      // 第一步：拿 config
      final configResult = await run(_repo.getConfig());
      if (configResult case Success(:final data)) {
        final type = data['deviceType'];
        // 第二步：拿 devices（loading 从一开始就在，中间没消失）
        final devicesResult = await run(_repo.getDevices(type));
        if (devicesResult case Success(:final data)) {
          emit(nextState()..devices = data['list']);
        }
      }
    });
  }

  // ── Overlay 提交（最少500ms显示）
  Future<void> submitConfig(Map<String, dynamic> config) async {
    await executeWithOverlay(
      action: () => _repo.updateConfig(config),
      onSuccessMsg: '配置保存成功',
    );
  }
}
```

**新旧方案对比：**

```
旧方案（逐请求切换，会闪烁）：
  loading=true → 请求1 → loading=false → loading=true → 请求2 → loading=false
  ❌ loading 闪烁消失又出现

新方案（流程级控制，不闪烁）：
  loading=true ─→ 请求1 ─→ 请求2 ─→ loading=false
  ✅ loading 从流程开始持续到结束，中间不闪烁
  ✅ 数据先到的 slot 可以提前 stopLoading → 先渲染
  ✅ Overlay/Toast 最少500ms显示，防快速请求闪烁
```

### Effect 系统（三种 Loading 模式）

```dart
sealed class Effect {}

// Loading 类型（三种场景）
class EffectPageLoading extends Effect { const EffectPageLoading(); }      // 页面内局部指示器（首次加载）
class EffectOverlayLoading extends Effect { const EffectOverlayLoading(); } // 全屏遮罩弹窗（提交/关键操作，防误触）
class EffectToastLoading extends Effect { const EffectToastLoading(); }     // 顶部 Toast 样式（轻量操作）

// 结果反馈
class EffectErrorToast<T> extends Effect { final T value; const EffectErrorToast(this.value); }
class EffectSuccessToast<T> extends Effect { final T value; const EffectSuccessToast(this.value); }

// 导航/弹窗
class EffectNavigate extends Effect { final String route; final Object? extra; const EffectNavigate(this.route, {this.extra}); }
class EffectDialog extends Effect { final Widget dialog; const EffectDialog(this.dialog); }
```

### Repo 规范

```dart
abstract class DeviceDetailRepo {
  Future<Result<Map<String, dynamic>?>> getData(String id);
}

class DeviceDetailRepoImpl implements DeviceDetailRepo {
  final DioClient _dio = getIt<DioClient>();

  @override
  Future<Result<Map<String, dynamic>?>> getData(String id) async {
    try {
      final response = await _dio.get('/api/device/$id');
      return Success(response.data);
    } on DioException catch (e) {
      final exception = e.error as ApiException?;
      return Failure(exception?.message ?? e.message ?? 'Unknown error', exception: exception);
    }
  }
}

class MockDeviceDetailRepo implements DeviceDetailRepo {
  @override
  Future<Result<Map<String, dynamic>?>> getData(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Success({'name': 'Mock Device', 'temperature': 25.5, 'isOnline': true});
  }
}
```

### Page 规范

```dart
class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({super.key});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();

  static Widget routePage() => BlocProvider<DeviceDetailCubit>(
    create: (context) => DeviceDetailCubit(context.read<DeviceDetailRepo>()),
    child: const DeviceDetailPage(),
  );
}
```

---

## 6. 错误处理三层策略

| 层级 | 机制 | 责任 |
|------|------|------|
| **Network 层** | 各服务 DioClient 自带 ErrorInterceptor | DioException + 服务自定义码 → 统一 ApiException；RetryInterceptor 指数退避重试 |
| **Repo 层** | Result<T> 包装 | 所有方法返回 Result，永不抛异常；Cubit 无需 try/catch |
| **Cubit/UI 层** | Effect 系统 | pattern matching 处理 Result；失败时 emit EffectErrorToast；BlocListener 路由到 UI |

**EffectHandler** 集中处理所有 UI 副作用（三种 Loading + Toast + 导航 + 弹窗）：

```dart
class EffectHandler {
  static Future<void> handleEffect(BuildContext context, Effect? effect) async {
    if (effect == null) return;

    // 先 dismiss 之前的 loading（Overlay/Toast 切换时需要先关掉旧的）
    if (effect is! EffectPageLoading) {
      await LoadingOverlay.dismiss();
      await ToastHandler.dismissMsg();
    }

    switch (effect) {
      // 三种 Loading 模式
      case EffectPageLoading():      // 页面首次加载：由 BlocBuilder 的 isLoading 控制，这里不额外操作
        break;
      case EffectOverlayLoading():   // 关键操作：全屏遮罩弹窗
        LoadingOverlay.show(context);
      case EffectToastLoading():     // 轻量操作：顶部 Toast 样式
        ToastHandler.showWaitMsg();

      // 结果反馈
      case EffectErrorToast<String>(:final value):
        ToastHandler.showMsgWithErrorIcon(value);
      case EffectSuccessToast<String>(:final value):
        ToastHandler.showMsgWithSuccessIcon(value);

      // 导航/弹窗
      case EffectNavigate(:final route, :final extra):
        context.push(route, extra: extra);
      case EffectDialog(:final dialog):
        showDialog(context: context, builder: (_) => dialog);
    }
  }
}
```

**三种 Loading 的 UI 实现：**

```dart
// 1. 页面内局部指示器（首次加载） — BlocBuilder 根据 isLoading 判断
BlocBuilder<XxxCubit, XxxState>(
  builder: (context, state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ActualContent(state);
  },
)

// 2. 全屏 Overlay Dialog（关键操作） — LoadingOverlay 工具
class LoadingOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context) {
    _entry = OverlayEntry(builder: (_) => const _LoadingMask());
    Overlay.of(context).insert(_entry!);
  }

  static Future<void> dismiss() async {
    _entry?.remove();
    _entry = null;
  }
}

class _LoadingMask extends StatelessWidget {
  const _LoadingMask();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),  // 半透明遮罩
      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}

// 3. 顶部 Toast 样式（轻量操作） — ToastHandler
class ToastHandler {
  static void showWaitMsg() { ... }     // 顶部滑入的提示条
  static void showMsgWithErrorIcon(String msg) { ... }
  static void showMsgWithSuccessIcon(String msg) { ... }
  static Future<void> dismissMsg() { ... }
}
```

**Cubit 中使用示例：**

```dart
class DeviceDetailCubit extends BaseCubit<DeviceDetailState> {
  final DeviceDetailRepo _repo;

  // 页面首次加载 → 局部指示器
  Future<void> initialize(String id) async {
    await loadPage(action: () => _repo.getDeviceInfo(id), onSuccess: (data) {
      emit(nextState()..deviceName = data['name']..isOnline = data['isOnline']);
    });
  }

  // 提交操作 → 全屏 Overlay（防双击）
  Future<void> submitConfig(Map<String, dynamic> config) async {
    await executeWithOverlay(
      action: () => _repo.updateConfig(config),
      onSuccessMsg: '配置保存成功',
    );
  }

  // 下拉刷新 → 顶部 Toast
  Future<void> refreshData() async {
    await executeWithToast(
      action: () => _repo.getDeviceInfo(state.id),
      onSuccessMsg: '数据已刷新',
    );
  }
}
```

---

## 7. App 入口

**main.dart：**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();      // 注册 get_it 单例
  await getIt<AppCache>().init();     // 初始化 SharedPreferences
  Localization.instance.load(Locale(appCache.languageCode)); // 加载翻译
  runApp(const FDemoApp());
}
```

**app.dart：**

```dart
class FDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appCache = getIt<AppCache>();
    return MultiRepositoryProvider(
      providers: _allRepoProviders(appCache),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'Hans'),
          Locale('en'),
        ],
        locale: Localization.instance.currentLocale,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appCache.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        routerConfig: appRouter,
      ),
    );
  }
}
```

---

## 8. 实施顺序

| 阶段 | 内容 | 依赖 |
|------|------|------|
| Phase 1 | pubspec.yaml + analysis_options.yaml + 翻译 Map 文件 | 无 |
| Phase 2 | Localization 管理类 + .t 扩展 | Phase 1 |
| Phase 3 | 网络层全部文件（api_exception → api_result → dio_client → 拦截器 → injection） | Phase 2 |
| Phase 4 | Base 类 + 工具（base_state → base_cubit → logger → connectivity） | Phase 3 |
| Phase 5 | 主题 + Shared UI + EffectHandler | Phase 4 |
| Phase 6 | 路由层 + Home Feature + Settings Feature | Phase 5 |
| Phase 7 | main.dart + app.dart 组装 + 删除旧代码 + analyze/format | Phase 6 |
| Phase 8 | 更新 generate-module skill 模板适配新架构 | Phase 7 |

---

## 9. 架构决策权衡

| 决策 | 选择 | 原因 |
|------|------|------|
| DI 方案 | get_it（不加 injectable） | 更简单，Repo 用 RepositoryProvider 管理；多服务 DioClient 用 instanceName 区分 |
| 国际化 | .t 扩展 + Dart Map 文件 | 对中国开发者更直观：`'中文'.t` 直接写中文，无需想英文 key；已有 translate skill 自动化扫描支持 |
| 网络架构 | 多服务独立 DioClient | 4个后端（Allstar/PS/MapServer/Aurora）各有 baseUrl + 自定义错误码；按 instanceName 注册，新增服务只需添加 client + errors 文件 |
| 路由 | GoRouter | 用户选择 + Flutter 推荐；深链接、重定向守卫、类型安全 |
| State 可变性 | mutable copy 模式 | 沿用 generate-module 的 nextState()..field = value 模式，比 equatable+immutable 更简洁 |
| 目录命名 | features/ | Flutter 社区标准术语，替代 business_modules/ |
| Mock 切换 | _getRepo(mock, real) | 沿用 generate-module 的 AppCache.mockRepo 切换模式 |
| 离线策略 | ConnectivityHelper 检测 | 渐进增强，非离线优先架构；检测后展示缓存或提示 |

---

## 10. 验证方式

1. `flutter pub get` 成功安装所有依赖
2. `flutter analyze` 无错误
3. `flutter run` 启动 app，显示 Home 页面
4. `'首页'.t` 在中文环境下显示"首页"，切换英文后显示"Home"
5. 导航到 Settings 页面验证 GoRouter 路由
6. 模拟网络错误验证 Effect Toast 显示