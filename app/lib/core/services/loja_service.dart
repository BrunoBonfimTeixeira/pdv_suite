import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/loja.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class LojaService {
  static Future<List<Loja>> listar() async {
    try {
      final res = await ApiClient.dio.get('/lojas');
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => Loja.fromJson(Map<String, dynamic>.from(m)))
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
      final res = await ApiClient.dio.post('/lojas', data: data);
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
      await ApiClient.dio.patch('/lojas/$id', data: data);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> remover(int id) async {
    try {
      await ApiClient.dio.delete('/lojas/$id');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
