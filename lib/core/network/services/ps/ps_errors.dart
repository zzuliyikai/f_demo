import 'package:dio/dio.dart';
import 'package:f_demo/core/network/api_exception.dart';

class PsErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badResponse) {
      final statusCode = err.response?.statusCode ?? 0;
      final body = err.response?.data;
      final errorCode = body is Map ? body['error_code']?.toString() : null;

      ApiException exception;
      switch (errorCode) {
        case '3001':
          exception = ApiException('Data conflict', serviceCode: '3001');
        case '3002':
          exception = ApiException('Rate limited', serviceCode: '3002');
        default:
          if (statusCode == 401) {
            exception = UnauthorizedException();
          } else if (statusCode == 404) {
            exception = NotFoundException();
          } else {
            exception = ServerException(statusCode);
          }
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

  ApiException _mapCommonErrors(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.connectionError:
        return NetworkException();
      default:
        return NetworkException(err.message ?? 'Unexpected error');
    }
  }
}