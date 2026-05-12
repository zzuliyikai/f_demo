import 'package:f_demo/core/network/api_exception.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String reason;
  final ApiException? exception;
  const Failure(this.reason, {this.exception});
}