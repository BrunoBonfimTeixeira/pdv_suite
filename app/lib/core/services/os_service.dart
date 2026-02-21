import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/ordem_servico.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class OsService {
  static Future<List<OrdemServico>> listar({
    String? status,
    String? prioridade,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      if (prioridade != null) params['prioridade'] = prioridade;

      final res =
          await ApiClient.dio.get('/os', queryParameters: params);
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => OrdemServico.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<OrdemServico> buscar(int id) async {
    try {
      final res = await ApiClient.dio.get('/os/$id');
      return OrdemServico.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<int> criar(Map<String, dynamic> data) async {
    try {
      final res = await ApiClient.dio.post('/os', data: data);
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
      await ApiClient.dio.patch('/os/$id', data: data);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> remover(int id) async {
    try {
      await ApiClient.dio.delete('/os/$id');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
