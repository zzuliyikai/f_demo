import 'package:dio/dio.dart';
import 'interceptors/log_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/auth_interceptor.dart';

class DioClient {
  late final Dio _dio;
  final String serviceName;

  DioClient({
    required this.serviceName,
    required String baseUrl,
    required Interceptor errorInterceptor,
    AuthInterceptor? authInterceptor,
    int connectTimeout = 15,
    int receiveTimeout = 15,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: connectTimeout),
      receiveTimeout: Duration(seconds: receiveTimeout),
      sendTimeout: Duration(seconds: connectTimeout),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.addAll([
      AppLogInterceptor(),
      if (authInterceptor != null) authInterceptor,
      RetryInterceptor(_dio),
      errorInterceptor,
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