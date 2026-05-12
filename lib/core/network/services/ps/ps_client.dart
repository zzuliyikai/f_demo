import 'package:f_demo/core/network/dio_client.dart';
import 'package:f_demo/core/network/service_config.dart';
import 'package:f_demo/core/network/interceptors/auth_interceptor.dart';
import 'ps_errors.dart';

DioClient createPsClient() => DioClient(
  serviceName: 'ps',
  baseUrl: ServiceConfig.psBaseUrl,
  connectTimeout: ServiceConfig.psConnectTimeout,
  receiveTimeout: ServiceConfig.psReceiveTimeout,
  errorInterceptor: PsErrorInterceptor(),
  authInterceptor: AuthInterceptor(tokenKey: 'ps'),
);