import 'package:f_demo/core/network/dio_client.dart';
import 'package:f_demo/core/network/service_config.dart';
import 'package:f_demo/core/network/interceptors/auth_interceptor.dart';
import 'mapserver_errors.dart';

DioClient createMapserverClient() => DioClient(
  serviceName: 'mapserver',
  baseUrl: ServiceConfig.mapserverBaseUrl,
  connectTimeout: ServiceConfig.mapserverConnectTimeout,
  receiveTimeout: ServiceConfig.mapserverReceiveTimeout,
  errorInterceptor: MapserverErrorInterceptor(),
  authInterceptor: AuthInterceptor(tokenKey: 'mapserver'),
);