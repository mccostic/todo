abstract class AppException implements Exception{
  final String message;
  final int? code;
  final String? details;

  const AppException({required this.message,this.code,this.details});

  @override
  String toString() =>
      'AppException(code: $code, message: $message, details: $details)';

}

class NetworkException extends AppException{

  const NetworkException({
    super.message = 'No internet connection',
    super.code = 1000,
    super.details,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.code = 1001,
    super.details,
  });
}

class ConnectionException extends AppException {
  const ConnectionException({
    super.message = 'Connection failed',
    super.code = 1002,
    super.details,
  });
}

// ─── Server / HTTP ───────────────────────────
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error occurred',
    super.code = 2000,
    super.details,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized - Invalid API key',
    super.code = 2001,
    super.details,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Forbidden - Access denied',
    super.code = 2002,
    super.details,
  });
}


class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code = 2003,
    super.details,
  });
}

class ConflictException extends AppException {
  const ConflictException({
    super.message = 'Resource already exists',
    super.code = 2004,
    super.details,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Validation failed',
    super.code = 2005,
    super.details,
  });
}

class RateLimitException extends AppException {
  const RateLimitException({
    super.message = 'Too many requests',
    super.code = 2006,
    super.details,
  });
}

// ─── Business ────────────────────────────────
class BusinessException extends AppException {
  const BusinessException({
    required super.message,
    super.code = 3000,
    super.details,
  });
}

class TodoNotFoundException extends BusinessException {
  const TodoNotFoundException({
    super.message = 'Todo not found',
    super.code = 3001,
    super.details,
  });
}

class TodoAlreadyCompletedException extends BusinessException {
  const TodoAlreadyCompletedException({
    super.message = 'Todo is already completed',
    super.code = 3002,
    super.details,
  });
}

class TodoTitleEmptyException extends BusinessException {
  const TodoTitleEmptyException({
    super.message = 'Todo title cannot be empty',
    super.code = 3003,
    super.details,
  });
}

class TodoLimitExceededException extends BusinessException {
  const TodoLimitExceededException({
    super.message = 'Maximum todo limit reached',
    super.code = 3004,
    super.details,
  });
}

// ─── Cache ───────────────────────────────────
class CacheException extends AppException {
  const CacheException({
    super.message = 'Local storage error',
    super.code = 4000,
    super.details,
  });
}

class CacheNotFoundException extends CacheException {
  const CacheNotFoundException({
    super.message = 'No cached data found',
    super.code = 4001,
    super.details,
  });
}


