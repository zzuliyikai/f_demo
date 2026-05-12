import 'package:dio/dio.dart';
import '../../storage/app_cache.dart';
import '../../di/injection.dart';

class AuthInterceptor extends Interceptor {
  final String tokenKey;

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