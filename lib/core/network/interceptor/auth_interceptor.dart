// lib/core/network/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import '../../config/app_config.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    options.headers['X-API-Key'] = AppConfig.apiKey;
    handler.next(options);
  }
}