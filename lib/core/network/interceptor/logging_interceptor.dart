import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    _logger.i(
      '📤 REQUEST\n'
          'Method  : ${options.method}\n'
          'URL     : ${options.uri}\n'
          'Headers : ${options.headers}\n'
          'Body    : ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    _logger.i(
      '📥 RESPONSE\n'
          'Status  : ${response.statusCode}\n'
          'URL     : ${response.requestOptions.uri}\n'
          'Data    : ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    _logger.e(
      '❌ ERROR\n'
          'Type    : ${err.type}\n'
          'URL     : ${err.requestOptions.uri}\n'
          'Message : ${err.message}\n'
          'Response: ${err.response?.data}',
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}