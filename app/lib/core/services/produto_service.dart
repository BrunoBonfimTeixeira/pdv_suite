import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class ProdutoResumo {
  final int id;
  final String descricao;
  final double preco;
  final String unidadeMedida;
  final double estoqueAtual;
  final String? codigoBarras;
  final int? categoriaId;
  final String? categoriaDescricao;

  ProdutoResumo({
    required this.id,
    required this.descricao,
    required this.preco,
    this.unidadeMedida = 'UN',
    this.estoqueAtual = 0,
    this.codigoBarras,
    this.categoriaId,
    this.categoriaDescricao,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory ProdutoResumo.fromJson(Map<String, dynamic> json) {
    return ProdutoResumo(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      descricao: (json['descricao'] ?? '').toString(),
      preco: _toDouble(json['preco_venda'] ?? json['preco']),
      unidadeMedida: json['unidade_medida']?.toString() ?? 'UN',
      estoqueAtual: _toDouble(json['estoque_atual']),
      codigoBarras: json['codigo_barras']?.toString(),
      categoriaId: json['categoria_id'] != null
          ? (json['categoria_id'] is num ? (json['categoria_id'] as num).toInt() : int.tryParse(json['categoria_id'].toString()))
          : null,
      categoriaDescricao: json['categoria_descricao'] as String?,
    );
  }
}

class ProdutoService {
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

  /// Buscar produto por codigo de barras exato
  static Future<ProdutoResumo?> buscarPorCodigoBarras(String codigo) async {
    try {
      final res = await ApiClient.dio.get(
        '/produtos',
        queryParameters: {'q': codigo.trim()},
      );

      final data = res.data;
      if (data is! List || data.isEmpty) return null;

      // Filtra o produto com codigo de barras exato
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          final cb = item['codigo_barras']?.toString() ?? '';
          if (cb == codigo.trim()) {
            return ProdutoResumo.fromJson(item);
          }
        }
      }
      // Se nao encontrou exato, retorna o primeiro resultado
      return ProdutoResumo.fromJson(Map<String, dynamic>.from(data.first));
    } on DioException {
      return null;
    }
  }
}
