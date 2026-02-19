import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class UsuarioService {
  static Future<Usuario?> autenticar({
    required String login,
    required String senha,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        '/auth/login',
        data: {'login': login, 'senha': senha},
      );

      final data = res.data;
      if (data is! Map) return null;

      final map = Map<String, dynamic>.from(data);

      final token = (map['token'] ?? '').toString();
      if (token.isNotEmpty) ApiClient.setAuthToken(token);

      final usuarioJson = map['usuario'];
      if (usuarioJson is! Map) return null;

      final usuarioMap = Map<String, dynamic>.from(usuarioJson);
      final usuario = Usuario.fromJson(usuarioMap);

      if (!usuario.ativo) {
        throw Exception('Usuário inativo.');
      }

      return usuario;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro ao autenticar';
      throw Exception(msg);
    }
  }
}
