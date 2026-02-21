import 'package:dio/dio.dart';
import 'package:pdv_lanchonete/core/models/movimento_estoque.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';

class NivelEstoque {
  final int id;
  final String descricao;
  final double estoqueAtual;
  final double estoqueMinimo;
  final String unidadeMedida;
  final double precoVenda;
  final int? categoriaId;
  final String? categoriaDescricao;

  NivelEstoque({
    required this.id,
    required this.descricao,
    required this.estoqueAtual,
    required this.estoqueMinimo,
    required this.unidadeMedida,
    required this.precoVenda,
    this.categoriaId,
    this.categoriaDescricao,
  });

  bool get emAlerta => estoqueMinimo > 0 && estoqueAtual <= estoqueMinimo;

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory NivelEstoque.fromJson(Map<String, dynamic> json) {
    return NivelEstoque(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      descricao: json['descricao']?.toString() ?? '',
      estoqueAtual: _d(json['estoque_atual']),
      estoqueMinimo: _d(json['estoque_minimo']),
      unidadeMedida: json['unidade_medida']?.toString() ?? 'UN',
      precoVenda: _d(json['preco_venda']),
      categoriaId: json['categoria_id'] != null ? (json['categoria_id'] is num ? (json['categoria_id'] as num).toInt() : int.tryParse(json['categoria_id'].toString())) : null,
      categoriaDescricao: json['categoria_descricao'] as String?,
    );
  }
}

class EstoqueService {
  static Future<List<NivelEstoque>> listarNiveis({bool apenasAlerta = false, int? categoriaId, String? q}) async {
    try {
      final params = <String, dynamic>{};
      if (apenasAlerta) params['alerta'] = '1';
      if (categoriaId != null) params['categoriaId'] = categoriaId;
      if (q != null && q.isNotEmpty) params['q'] = q;

      final res = await ApiClient.dio.get('/estoque', queryParameters: params);
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => NivelEstoque.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<List<MovimentoEstoque>> movimentos(int produtoId) async {
    try {
      final res = await ApiClient.dio.get('/estoque/$produtoId/movimentos');
      if (res.data is List) {
        return (res.data as List)
            .whereType<Map>()
            .map((m) => MovimentoEstoque.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }

  static Future<void> ajustar({
    required int produtoId,
    required String tipo,
    required double quantidade,
    String? motivo,
  }) async {
    try {
      await ApiClient.dio.post('/estoque/ajuste', data: {
        'produtoId': produtoId,
        'tipo': tipo,
        'quantidade': quantidade,
        if (motivo != null) 'motivo': motivo,
      });
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Erro';
      throw Exception(msg);
    }
  }
}
