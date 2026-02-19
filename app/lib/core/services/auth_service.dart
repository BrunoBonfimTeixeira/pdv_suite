import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';
import 'package:pdv_lanchonete/core/services/auth_storage.dart';

class AuthService {
  static Future<Usuario?> tryRestoreSession() async {
    final token = await AuthStorage.loadToken();
    final user = await AuthStorage.loadUser();

    print("RESTORE token: ${token?.substring(0, 15)}... len=${token?.length}");
    print("RESTORE user: ${user?.login}");

    if (token == null || token.isEmpty || user == null) return null;

    ApiClient.setAuthToken(token);
    return user;
  }


  static Future<Usuario> login({
    required String login,
    required String senha,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        '/auth/login',
        data: {'login': login, 'senha': senha},
      );

      final data = res.data;
      if (data is! Map) {
        throw Exception('Resposta inválida da API.');
      }

      final token = (data['token'] ?? '').toString();
      final usuarioJson = data['usuario'];

      if (token.isEmpty || usuarioJson is! Map) {
        throw Exception('Login inválido.');
      }

      final usuario = Usuario.fromJson(Map<String, dynamic>.from(usuarioJson));

      ApiClient.setAuthToken(token);
      await AuthStorage.saveSession(token: token, usuario: usuario);

      return usuario;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401) throw Exception('Credenciais inválidas.');
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro ao logar.';
      throw Exception(msg);
    }
  }

  static Future<void> logout() async {
    ApiClient.setAuthToken(null);
    await AuthStorage.clear();
  }
}
