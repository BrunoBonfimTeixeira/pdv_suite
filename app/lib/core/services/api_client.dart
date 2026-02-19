// api_client.dart
import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._();

  static const String baseUrl = 'http://127.0.0.1:3000';

  static final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
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
          // ✅ INJETA TOKEN AQUI
          final t = _token;
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          } else {
            options.headers.remove('Authorization');
          }

          // logs
          // ignore: avoid_print
          print("➡️ ${options.method} ${options.uri}");
          // ignore: avoid_print
          print("AUTH: ${options.headers['Authorization']}");

          return handler.next(options);
        },
        onError: (e, handler) {
          final uri = e.requestOptions.uri;
          final status = e.response?.statusCode;
          final data = e.response?.data;
          // ignore: avoid_print
          print('[API ERROR] ${e.type} $uri status=$status data=$data msg=${e.message}');
          return handler.next(e);
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  static void setAuthToken(String? token) {
    _token = (token == null || token.trim().isEmpty) ? null : token.trim();
  }

  static void clearAuthToken() => _token = null;

  static String? get token => _token;
}
