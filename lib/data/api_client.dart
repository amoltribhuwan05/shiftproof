import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static const String defaultBaseUrl = String.fromEnvironment(
    'SHIFT_PROOF_API_BASE_URL',
    defaultValue: 'https://shiftproof-gw-3x6v50c1.uc.gateway.dev',
  );

  final Dio dio;

  ApiClient({String? baseUrl}) : dio = Dio() {
    dio.options.baseUrl = baseUrl ?? defaultBaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  static final ApiClient instance = ApiClient();
}
