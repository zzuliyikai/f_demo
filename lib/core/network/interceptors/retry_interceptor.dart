import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor(this.dio, {this.maxRetries = 3, this.baseDelay = const Duration(seconds: 1)});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isRetriable(err) && err.requestOptions.retryCount < maxRetries) {
      final delay = baseDelay * (1 << err.requestOptions.retryCount);
      await Future.delayed(delay);
      err.requestOptions.retryCount++;
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } on DioException catch (e) {
        handler.reject(e);
      }
    } else {
      handler.reject(err);
    }
  }

  bool _isRetriable(DioException err) =>
      err.type == DioExceptionType.connectionTimeout ||
      err.type == DioExceptionType.connectionError ||
      (err.type == DioExceptionType.badResponse && err.response?.statusCode != null && err.response!.statusCode! >= 500);
}

extension RetryOptions on RequestOptions {
  int get retryCount => (extra['retryCount'] as int?) ?? 0;
  set retryCount(int value) => extra['retryCount'] = value;
}