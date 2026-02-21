import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/categoria.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class CategoriaService {
  static Future<List<Categoria>> listar() async {
    try {
      final res = await ApiClient.dio.get('/categorias');
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => Categoria.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<int> criar({
    required String descricao,
    String? cor,
    String? icone,
    bool ativo = true,
  }) async {
    try {
      final res = await ApiClient.dio.post('/categorias', data: {
        'descricao': descricao,
        if (cor != null) 'cor': cor,
        if (icone != null) 'icone': icone,
        'ativo': ativo,
      });
      final data = res.data;
      if (data is Map && data['id'] != null) return (data['id'] as num).toInt();
      return 0;
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> atualizar({
    required int id,
    String? descricao,
    String? cor,
    String? icone,
    bool? ativo,
  }) async {
    try {
      await ApiClient.dio.patch('/categorias/$id', data: {
        if (descricao != null) 'descricao': descricao,
        if (cor != null) 'cor': cor,
        if (icone != null) 'icone': icone,
        if (ativo != null) 'ativo': ativo,
      });
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> remover(int id) async {
    try {
      await ApiClient.dio.delete('/categorias/$id');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
