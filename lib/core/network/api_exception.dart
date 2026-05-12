class ApiException implements Exception {
  final String message;
  final String? serviceCode;
  ApiException(this.message, {this.serviceCode});
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Network error']) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException([String message = 'Request timed out']) : super(message);
}

class ServerException extends ApiException {
  final int statusCode;
  ServerException(this.statusCode, [String message = 'Server error']) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized', String? serviceCode]) : super(message, serviceCode: serviceCode);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource not found']) : super(message);
}

// Allstar 专属异常
class AllstarTokenExpiredException extends UnauthorizedException {
  AllstarTokenExpiredException() : super('Token expired', '1001');
}

class AllstarPermissionDeniedException extends ApiException {
  AllstarPermissionDeniedException() : super('Permission denied', serviceCode: '2001');
}

// Aurora 专属异常
class AuroraDeviceOfflineException extends ApiException {
  AuroraDeviceOfflineException() : super('Device offline', serviceCode: '5001');
}

class AuroraDeviceNotFoundException extends ApiException {
  AuroraDeviceNotFoundException() : super('Device not found', serviceCode: '5002');
}