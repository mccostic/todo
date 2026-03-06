import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const TimeoutException(),
            type: err.type,
          ),
        );

      case DioExceptionType.connectionError:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const NetworkException(),
            type: err.type,
          ),
        );

      case DioExceptionType.badResponse:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: _handleBadResponse(err),
            response: err.response,
            type: err.type,
          ),
        );

      default:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ServerException(
              message: err.message ?? 'Unknown server error',
            ),
            type: err.type,
          ),
        );
    }
  }

  AppException _handleBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // Try to get message and code from server response body
    final message = data is Map ? (data['message'] ?? '') as String : '';
    final serverCode = data is Map ? data['code'] as int? : null;

    // If server returned a business error code use it
    if (serverCode != null && serverCode >= 3000) {
      return _mapBusinessCode(serverCode, message);
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message.isNotEmpty ? message : 'Bad request',
          details: data?.toString(),
        );
      case 401:
        return UnauthorizedException(
          message: message.isNotEmpty ? message : 'Unauthorized',
        );
      case 403:
        return ForbiddenException(
          message: message.isNotEmpty ? message : 'Forbidden',
        );
      case 404:
        return NotFoundException(
          message: message.isNotEmpty ? message : 'Not found',
        );
      case 409:
        return ConflictException(
          message: message.isNotEmpty ? message : 'Conflict',
        );
      case 422:
        return ValidationException(
          message: message.isNotEmpty ? message : 'Validation failed',
          details: data?.toString(),
        );
      case 429:
        return RateLimitException(
          message: message.isNotEmpty ? message : 'Too many requests',
        );
      default:
        return ServerException(
          message: message.isNotEmpty
              ? message
              : 'Server error $statusCode',
        );
    }
  }

  AppException _mapBusinessCode(int code, String message) {
    switch (code) {
      case 3001:
        return TodoNotFoundException(message: message);
      case 3002:
        return TodoAlreadyCompletedException(message: message);
      case 3003:
        return TodoTitleEmptyException(message: message);
      case 3004:
        return TodoLimitExceededException(message: message);
      default:
        return BusinessException(message: message, code: code);
    }
  }
}