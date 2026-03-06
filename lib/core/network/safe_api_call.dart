
import 'package:logger/logger.dart';
import 'package:todo/core/error/exceptions.dart';
import 'package:todo/core/network/api_response.dart';

import '../error/error_response.dart';

final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true,printEmojis: true)
);

Future<ApiResponse<T>> safeApiCall<T>({required Future<T> Function() call}) async{

  try{
    final result = await call();
    return ApiResponse.success(result);
  }
  on NetworkException catch (e){
    _logger.w('Network error: ${e.message}');
    return ApiResponse.failure(
      ErrorResponse(code: e.code!, message: e.message, details: e.details),
    );
  }
  on TimeoutException catch(e){
    _logger.w('Timeout error: ${e.message}');
    return ApiResponse.failure(
      ErrorResponse(code: e.code!, message: e.message, details: e.details),
    );
  }

  on UnauthorizedException catch(e){
    _logger.w('Auth error: ${e.message}');
    return ApiResponse.failure(
      ErrorResponse(code: e.code!, message: e.message, details: e.details),
    );
  }

  on ForbiddenException catch(e){
    _logger.w('Forbidden error: ${e.message}');
    return ApiResponse.failure(
      ErrorResponse(code: e.code!, message: e.message, details: e.details),
    );
  }

  on NotFoundException catch(e){
    _logger.w('Not found error: ${e.message}');
    return ApiResponse.failure(
      ErrorResponse(code: e.code!, message: e.message, details: e.details),
    );
  }

  on ValidationException catch(e){
    _logger.w('Validation error: ${e.message}');
    return ApiResponse.failure(
      ErrorResponse(code: e.code!, message: e.message, details: e.details),
    );
  }

  on BusinessException catch(e){
    _logger.w('Business error: ${e.message}');
    return ApiResponse.failure(
      ErrorResponse(code: e.code!, message: e.message, details: e.details),
    );
  }

  on AppException catch(e){
// Catch any remaining app exceptions
    _logger.e('App error: ${e.message}');
    return ApiResponse.failure(
      ErrorResponse(
        code: e.code ?? 9999,
        message: e.message,
        details: e.details,
      ),
    );
  }
  catch (e, stackTrace){
    _logger.e('Unexpected error', error: e, stackTrace: stackTrace);
    return ApiResponse.failure(
      ErrorResponse(code: 9999, message: 'Unexpected error: $e'),
    );
  }

}

// Void response — for delete etc
Future<ApiResponse<void>> safeApiVoidCall({
  required Future<void> Function() call,
}) async {
  try {
    await call();
    return ApiResponse.success(null);
  } on AppException catch (e) {
    _logger.e('App error: ${e.message}');
    return ApiResponse.failure(
      ErrorResponse(
        code: e.code ?? 9999,
        message: e.message,
        details: e.details,
      ),
    );
  } catch (e, stackTrace) {
    _logger.e('Unexpected error', error: e, stackTrace: stackTrace);
    return ApiResponse.failure(
      ErrorResponse(code: 9999, message: 'Unexpected error: $e'),
    );
  }
}