class ErrorResponse {
  final int code;
  final String message;
  final String? details;
  final Map<String, dynamic>? errors;

  const ErrorResponse({
    required this.code,
    required this.message,
    this.details,
    this.errors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? 'Unknown error',
      details: json['details'],
      errors: json['errors'],
    );
  }

  factory ErrorResponse.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return const ErrorResponse(code: 2005, message: 'Bad request');
      case 401:
        return const ErrorResponse(code: 2001, message: 'Unauthorized');
      case 403:
        return const ErrorResponse(code: 2002, message: 'Forbidden');
      case 404:
        return const ErrorResponse(code: 2003, message: 'Not found');
      case 409:
        return const ErrorResponse(code: 2004, message: 'Conflict');
      case 422:
        return const ErrorResponse(code: 2005, message: 'Validation error');
      case 429:
        return const ErrorResponse(code: 2006, message: 'Too many requests');
      case 500:
        return const ErrorResponse(code: 2000, message: 'Server error');
      default:
        return ErrorResponse(
          code: 2000,
          message: 'Unexpected error: $statusCode',
        );
    }
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    if (details != null) 'details': details,
    if (errors != null) 'errors': errors,
  };

  @override
  String toString() => 'ErrorResponse(code: $code, message: $message)';
}