import 'package:dio/dio.dart';
import 'package:f_demo/core/network/api_result.dart';
import 'package:f_demo/core/network/api_exception.dart';
import 'package:f_demo/core/network/dio_client.dart';
import 'package:f_demo/core/di/injection.dart';

abstract class HomeRepo {
  Future<Result<dynamic>> getHomeData();
}

class HomeRepoImpl implements HomeRepo {
  final DioClient _dio = getIt<DioClient>(instanceName: 'allstar');

  @override
  Future<Result<dynamic>> getHomeData() async {
    try {
      final response = await _dio.get('/home');
      return Success(response.data);
    } on DioException catch (e) {
      final exception = e.error;
      if (exception is ApiException) {
        return Failure(exception.message, exception: exception);
      }
      return Failure(e.message ?? 'Unknown error');
    }
  }
}

class MockHomeRepo implements HomeRepo {
  @override
  Future<Result<dynamic>> getHomeData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Success({'title': 'Welcome to FDemo'});
  }
}