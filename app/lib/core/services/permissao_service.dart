import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/permissao.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class PermissaoService {
  static Future<List<Permissao>> listarPorPerfil(String perfil) async {
    try {
      final res = await ApiClient.dio.get('/permissoes',
          queryParameters: {'perfil': perfil});
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => Permissao.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> atualizar(int id,
      {bool? ler, bool? escrever, bool? excluir}) async {
    try {
      await ApiClient.dio.patch('/permissoes/$id', data: {
        if (ler != null) 'ler': ler,
        if (escrever != null) 'escrever': escrever,
        if (excluir != null) 'excluir': excluir,
      });
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
