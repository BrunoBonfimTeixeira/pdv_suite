import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/item_carrinho.dart';
import 'package:pdv_lanchonete/core/models/venda.dart';
import 'package:pdv_lanchonete/core/models/venda_detalhe.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class VendaService {
  static Future<int> salvarVenda({
    required int caixaId,
    required int usuarioId,
    required Venda venda,
    int? pessoaId,
    List<Map<String, dynamic>>? pagamentos,
    String? observacoes,
    double descontoVenda = 0,
  }) async {
    final itens = venda.itens.map((ItemCarrinho item) {
      return item.toJson();
    }).toList();

    final double totalLiquido = venda.total - descontoVenda;

    final pags = pagamentos ?? [
      {'formaPagamentoId': 1, 'valor': totalLiquido}
    ];

    try {
      final res = await ApiClient.dio.post(
        '/vendas',
        data: {
          'caixaId': caixaId,
          'usuarioId': usuarioId,
          if (pessoaId != null) 'pessoaId': pessoaId,
          'itens': itens,
          'pagamentos': pags,
          if (observacoes != null) 'observacoes': observacoes,
          if (descontoVenda > 0) 'descontoVenda': descontoVenda,
        },
      );

      final body = res.data;
      if (body is Map && body['vendaId'] != null) {
        return (body['vendaId'] as num).toInt();
      }
      if (body is num) return body.toInt();
      throw Exception('Resposta inesperada ao salvar venda.');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro ao salvar venda';
      throw Exception(msg);
    }
  }

  static Future<List<VendaDetalhe>> listar({
    String? status,
    int? caixaId,
    int? usuarioId,
    int? limit,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      if (caixaId != null) params['caixaId'] = caixaId;
      if (usuarioId != null) params['usuarioId'] = usuarioId;
      if (limit != null) params['limit'] = limit;

      final res = await ApiClient.dio.get('/vendas', queryParameters: params);
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => VendaDetalhe.fromListJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<VendaDetalhe> buscarPorId(int id) async {
    try {
      final res = await ApiClient.dio.get('/vendas/$id');
      return VendaDetalhe.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> cancelar(int id) async {
    try {
      final res = await ApiClient.dio.patch('/vendas/$id/cancelar');
      if (res.statusCode != 200) {
        final msg = res.data?['message']?.toString() ?? 'Erro ao cancelar venda';
        throw Exception(msg);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
