import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/forma_pagamento.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class FormaPagamentoService {
  static Future<List<FormaPagamento>> listar() async {
    try {
      final res = await ApiClient.dio.get('/formas-pagamento');
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => FormaPagamento.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
