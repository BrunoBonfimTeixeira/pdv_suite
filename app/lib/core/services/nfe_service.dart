import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/nota_fiscal.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class NfeService {
  static Future<NotaFiscal> emitir({
    required int vendaId,
    int? lojaId,
    String tipo = 'NFCE',
  }) async {
    try {
      final res = await ApiClient.dio.post('/nfe/emitir', data: {
        'venda_id': vendaId,
        if (lojaId != null) 'loja_id': lojaId,
        'tipo': tipo,
      });
      return NotaFiscal.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<List<NotaFiscal>> listar({
    String? status,
    String? tipo,
    String? de,
    String? ate,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      if (tipo != null) params['tipo'] = tipo;
      if (de != null) params['de'] = de;
      if (ate != null) params['ate'] = ate;

      final res =
          await ApiClient.dio.get('/nfe', queryParameters: params);
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => NotaFiscal.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<NotaFiscal> buscar(int id) async {
    try {
      final res = await ApiClient.dio.get('/nfe/$id');
      return NotaFiscal.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> cancelar(int id, String motivo) async {
    try {
      await ApiClient.dio.patch('/nfe/$id/cancelar', data: {
        'motivo_cancelamento': motivo,
      });
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<String> baixarXml(int id) async {
    try {
      final res = await ApiClient.dio.get('/nfe/$id/xml');
      return res.data?.toString() ?? '';
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
