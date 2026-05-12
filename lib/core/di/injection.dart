import 'package:get_it/get_it.dart';
import 'package:f_demo/core/network/dio_client.dart';
import 'package:f_demo/core/network/services/allstar/allstar_client.dart';
import 'package:f_demo/core/network/services/ps/ps_client.dart';
import 'package:f_demo/core/network/services/mapserver/mapserver_client.dart';
import 'package:f_demo/core/network/services/aurora/aurora_client.dart';
import 'package:f_demo/core/storage/app_cache.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // 基础设施
  getIt.registerSingleton<AppCache>(AppCache());

  // 多服务 DioClient（按 instanceName 注册）
  getIt.registerSingleton<DioClient>(createAllstarClient(), instanceName: 'allstar');
  getIt.registerSingleton<DioClient>(createPsClient(), instanceName: 'ps');
  getIt.registerSingleton<DioClient>(createMapserverClient(), instanceName: 'mapserver');
  getIt.registerSingleton<DioClient>(createAuroraClient(), instanceName: 'aurora');
}