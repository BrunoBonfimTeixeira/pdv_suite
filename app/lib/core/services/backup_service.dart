import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class BackupService {
  static Future<Map<String, dynamic>> info() async {
    try {
      final res = await ApiClient.dio.get('/backup/info');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<String> exportar() async {
    try {
      final res = await ApiClient.dio.get('/backup/export',
          options: Options(responseType: ResponseType.plain));
      return res.data?.toString() ?? '';
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
