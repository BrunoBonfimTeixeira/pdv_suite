import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/info_fiscal.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class InfoFiscalService {
  static Future<InfoFiscal?> buscarPorProduto(int produtoId) async {
    try {
      final res = await ApiClient.dio.get('/info-fiscais/produto/$produtoId');
      if (res.data is Map) {
        return InfoFiscal.fromJson(Map<String, dynamic>.from(res.data));
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> salvar(Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.post('/info-fiscais', data: data);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
