import '../../main_frame/result.dart';

abstract class ___FeatureName___Repo {
  Future<Result<Map<String, dynamic>?>> getData(String id);
}

class ___FeatureName___RepoImpl implements ___FeatureName___Repo {
  @override
  Future<Result<Map<String, dynamic>?>> getData(String id) async {
    // TODO: 实现 API 调用
    await Future.delayed(const Duration(milliseconds: 500));
    return Success({'name': 'Test', 'id': id});
  }
}

class Mock___FeatureName___Repo implements ___FeatureName___Repo {
  @override
  Future<Result<Map<String, dynamic>?>> getData(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Success({'name': 'Mock Test', 'id': id});
  }
}
