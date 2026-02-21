import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';
import 'package:pdv_lanchonete/core/services/auth_storage.dart';

class AuthService {
  static Future<Usuario?> tryRestoreSession() async {
    try {
      final token = await AuthStorage.loadToken();
      final user = await AuthStorage.loadUser();

      if (token == null || token.isEmpty || user == null) return null;

      ApiClient.setAuthToken(token);
      return user;
    } catch (_) {
      return null;
    }
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

      // Status != 200 => erro
      final statusCode = res.statusCode ?? 0;
      if (statusCode == 401) {
        throw Exception('Credenciais invalidas.');
      }
      if (statusCode == 403) {
        throw Exception('Usuario inativo.');
      }
      if (statusCode < 200 || statusCode >= 300) {
        final msg = (res.data is Map ? res.data['message'] : null) ?? 'Erro ao logar.';
        throw Exception(msg.toString());
      }

      final data = res.data;
      if (data is! Map) {
        throw Exception('Resposta invalida da API.');
      }

      final token = (data['token'] ?? '').toString();
      final usuarioJson = data['usuario'];

      if (token.isEmpty || usuarioJson is! Map) {
        throw Exception('Login invalido.');
      }

      final usuario = Usuario.fromJson(Map<String, dynamic>.from(usuarioJson));

      ApiClient.setAuthToken(token);
      await AuthStorage.saveSession(token: token, usuario: usuario);

      return usuario;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401) throw Exception('Credenciais invalidas.');
      if (code == 403) throw Exception('Usuario inativo.');
      throw Exception('Erro de conexao. Verifique se a API esta rodando.');
    } catch (e) {
      // Se ja e uma Exception nossa, repassa
      if (e is Exception) rethrow;
      throw Exception('Erro inesperado ao logar.');
    }
  }

  static Future<void> logout() async {
    ApiClient.setAuthToken(null);
    await AuthStorage.clear();
  }
}
