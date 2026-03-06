import '../error/error_response.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final ErrorResponse? error;
  final int? statusCode;

  const ApiResponse._({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T? data, {int? statusCode}) {
    return ApiResponse._(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure(ErrorResponse error, {int? statusCode}) {
    return ApiResponse._(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  // ← isSuccess no longer requires data != null
  bool get isSuccess => success;
  bool get isFailure => !success;
  bool get hasData => data != null;

  ApiResponse<R> map<R>(R Function(T? data) transform) {
    if (isSuccess) {
      return ApiResponse.success(transform(data), statusCode: statusCode);
    }
    return ApiResponse.failure(error!, statusCode: statusCode);
  }

  @override
  String toString() => success
      ? 'ApiResponse.success(data: $data)'
      : 'ApiResponse.failure(error: $error)';
}