import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/pdv_config.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class PdvConfigService {
  static Future<PdvConfig> carregar() async {
    try {
      final res = await ApiClient.dio.get('/pdv-config/minha-config');
      return PdvConfig.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> salvar(Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.post('/pdv-config', data: data);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
