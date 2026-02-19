import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class ProdutoResumo {
  final int id;
  final String descricao;
  final num preco;

  ProdutoResumo({
    required this.id,
    required this.descricao,
    required this.preco,
  });

  factory ProdutoResumo.fromJson(Map<String, dynamic> json) {
    return ProdutoResumo(
      id: (json['id'] as num).toInt(),
      descricao: (json['descricao'] ?? '') as String,
      // backend pode mandar "preco_venda" ou "preco"
      preco: (json['preco_venda'] ?? json['preco'] ?? 0) as num,
    );
  }
}

class ProdutoService {
  /// GET /produtos?filtro=abc&limit=100
  static Future<List<ProdutoResumo>> listar({String filtro = ''}) async {
    try {
      final res = await ApiClient.dio.get(
        '/produtos',
        queryParameters: {
          if (filtro.isNotEmpty) 'filtro': filtro,
          'limit': 100,
        },
      );

      final data = res.data;
      if (data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(ProdutoResumo.fromJson)
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro ao buscar produtos';
      throw Exception(msg);
    }
  }
}
