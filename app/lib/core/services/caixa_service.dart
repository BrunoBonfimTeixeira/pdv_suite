import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/caixa.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class CaixaService {
  static Future<int> abrir({double valorAbertura = 0, String? observacoes}) async {
    try {
      final res = await ApiClient.dio.post('/caixas/abrir', data: {
        'valorAbertura': valorAbertura,
        if (observacoes != null) 'observacoes': observacoes,
      });

      final body = res.data;
      if (res.statusCode == 400 && body is Map && body['caixaId'] != null) {
        return (body['caixaId'] as num).toInt();
      }
      if (body is Map && body['caixaId'] != null) {
        return (body['caixaId'] as num).toInt();
      }
      throw Exception(body?['message'] ?? 'Erro ao abrir caixa');
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Erro ao abrir caixa';
      throw Exception(msg);
    }
  }

  static Future<Map<String, dynamic>> fechar({
    required int caixaId,
    double? valorFechamento,
    String? observacoes,
  }) async {
    try {
      final res = await ApiClient.dio.post('/caixas/fechar', data: {
        'caixaId': caixaId,
        if (valorFechamento != null) 'valorFechamento': valorFechamento,
        if (observacoes != null) 'observacoes': observacoes,
      });
      if (res.data is Map) return Map<String, dynamic>.from(res.data);
      throw Exception('Erro ao fechar caixa');
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Erro ao fechar caixa';
      throw Exception(msg);
    }
  }

  static Future<Caixa?> buscarAberto() async {
    try {
      final res = await ApiClient.dio.get('/caixas/aberto');
      if (res.data == null || res.data == '') return null;
      return Caixa.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<List<Caixa>> listar() async {
    try {
      final res = await ApiClient.dio.get('/caixas');
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => Caixa.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
