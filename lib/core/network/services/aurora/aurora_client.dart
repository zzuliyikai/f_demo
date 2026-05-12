import 'package:f_demo/core/network/dio_client.dart';
import 'package:f_demo/core/network/service_config.dart';
import 'package:f_demo/core/network/interceptors/auth_interceptor.dart';
import 'aurora_errors.dart';

DioClient createAuroraClient() => DioClient(
  serviceName: 'aurora',
  baseUrl: ServiceConfig.auroraBaseUrl,
  connectTimeout: ServiceConfig.auroraConnectTimeout,
  receiveTimeout: ServiceConfig.auroraReceiveTimeout,
  errorInterceptor: AuroraErrorInterceptor(),
  authInterceptor: AuthInterceptor(tokenKey: 'aurora'),
);