import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class AdminService {
  static Future<List<Usuario>> listarUsuarios() async {
    try {
      final res = await ApiClient.dio.get('/admin/usuarios');
      final data = res.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map((m) => Usuario.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }

      throw Exception('Resposta inválida da API.');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> atualizarUsuario({
    required int id,
    String? nome,
    String? login,
    String? perfil,
    bool? ativo,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (nome != null) payload['nome'] = nome;
      if (login != null) payload['login'] = login;
      if (perfil != null) payload['perfil'] = perfil;
      if (ativo != null) payload['ativo'] = ativo;

      await ApiClient.dio.patch('/admin/usuarios/$id', data: payload);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<int> criarUsuario({
    required String nome,
    required String login,
    required String senha,
    String perfil = 'OPERADOR',
  }) async {
    try {
      final res = await ApiClient.dio.post('/admin/usuarios', data: {
        'nome': nome,
        'login': login,
        'senha': senha,
        'perfil': perfil,
      });
      final body = res.data;
      if (res.statusCode == 409) {
        throw Exception(body?['message'] ?? 'Login já existe.');
      }
      if (body is Map && body['id'] != null) {
        return (body['id'] as num).toInt();
      }
      throw Exception('Erro ao criar usuário.');
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
