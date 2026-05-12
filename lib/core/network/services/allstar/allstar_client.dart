import 'package:f_demo/core/network/dio_client.dart';
import 'package:f_demo/core/network/service_config.dart';
import 'package:f_demo/core/network/interceptors/auth_interceptor.dart';
import 'allstar_errors.dart';

DioClient createAllstarClient() => DioClient(
  serviceName: 'allstar',
  baseUrl: ServiceConfig.allstarBaseUrl,
  connectTimeout: ServiceConfig.allstarConnectTimeout,
  receiveTimeout: ServiceConfig.allstarReceiveTimeout,
  errorInterceptor: AllstarErrorInterceptor(),
  authInterceptor: AuthInterceptor(tokenKey: 'allstar'),
);