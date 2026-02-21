// api_client.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._();

  static String _baseUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String url) {
    _baseUrl = url;
    dio.options.baseUrl = url;
  }

  static final Dio dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    headers: const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    responseType: ResponseType.json,
    validateStatus: (code) => code != null && code >= 200 && code < 500,
  ));

  static String? _token;
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final t = _token;
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          } else {
            options.headers.remove('Authorization');
          }

          if (kDebugMode) {
            debugPrint("[API] ${options.method} ${options.uri}");
          }

          return handler.next(options);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            final uri = e.requestOptions.uri;
            final status = e.response?.statusCode;
            debugPrint('[API ERROR] ${e.type} $uri status=$status msg=${e.message}');
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ));
    }
  }

  static void setAuthToken(String? token) {
    _token = (token == null || token.trim().isEmpty) ? null : token.trim();
  }

  static void clearAuthToken() => _token = null;

  static String? get token => _token;
}
