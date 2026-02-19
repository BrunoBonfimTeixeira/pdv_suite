import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/item_carrinho.dart';
import 'package:pdv_lanchonete/core/models/venda.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class VendaService {
  static Future<int> salvarVenda({
    required int caixaId,
    required int usuarioId,
    required Venda venda,
  }) async {
    final itens = venda.itens.map((ItemCarrinho item) {
      return {
        'produtoId': item.produtoId,
        'quantidade': item.quantidade,
        'preco': item.preco,
        'total': item.subtotal,
      };
    }).toList();

    final double totalBruto = venda.total;
    final double desconto = 0.0;
    final double acrescimo = 0.0;
    final double totalLiquido = totalBruto;

    const int formaPagamentoId = 1; // ajuste depois (dinheiro/cartão etc.)

    try {
      final res = await ApiClient.dio.post(
        '/vendas',
        data: {
          'caixaId': caixaId,
          'usuarioId': usuarioId,
          'totalBruto': totalBruto,
          'desconto': desconto,
          'acrescimo': acrescimo,
          'totalLiquido': totalLiquido,
          'status': 'FINALIZADA',
          'numeroNfe': 0,
          'itens': itens,
          'pagamentos': [
            {'formaPagamentoId': formaPagamentoId, 'valor': totalLiquido}
          ],
        },
      );

      final body = res.data;
      if (body is Map && body['vendaId'] != null) {
        return (body['vendaId'] as num).toInt();
      }

      // fallback: se backend retornar só um número
      if (body is num) return body.toInt();

      throw Exception('Resposta inesperada ao salvar venda.');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro ao salvar venda';
      throw Exception(msg);
    }
  }
}
