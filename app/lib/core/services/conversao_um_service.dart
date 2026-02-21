import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/conversao_um.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class ConversaoUmService {
  static Future<List<ConversaoUm>> listarPorProduto(int produtoId) async {
    try {
      final res =
          await ApiClient.dio.get('/conversao-um/produto/$produtoId');
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => ConversaoUm.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<int> criar(Map<String, dynamic> data) async {
    try {
      final res = await ApiClient.dio.post('/conversao-um', data: data);
      final body = res.data;
      if (body is Map && body['id'] != null) return (body['id'] as num).toInt();
      return 0;
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> atualizar(int id, Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.patch('/conversao-um/$id', data: data);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> remover(int id) async {
    try {
      await ApiClient.dio.delete('/conversao-um/$id');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
