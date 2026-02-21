double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class MovimentoEstoque {
  final int id;
  final int produtoId;
  final String tipo;
  final double quantidade;
  final double estoqueAnterior;
  final double estoquePosterior;
  final String? motivo;
  final int usuarioId;
  final String? usuarioNome;
  final int? referenciaId;
  final String? referenciaTipo;
  final DateTime criadoEm;

  MovimentoEstoque({
    required this.id,
    required this.produtoId,
    required this.tipo,
    required this.quantidade,
    required this.estoqueAnterior,
    required this.estoquePosterior,
    this.motivo,
    required this.usuarioId,
    this.usuarioNome,
    this.referenciaId,
    this.referenciaTipo,
    required this.criadoEm,
  });

  factory MovimentoEstoque.fromJson(Map<String, dynamic> json) {
    return MovimentoEstoque(
      id: _toInt(json['id']),
      produtoId: _toInt(json['produto_id']),
      tipo: json['tipo']?.toString() ?? '',
      quantidade: _toDouble(json['quantidade']),
      estoqueAnterior: _toDouble(json['estoque_anterior']),
      estoquePosterior: _toDouble(json['estoque_posterior']),
      motivo: json['motivo'] as String?,
      usuarioId: _toInt(json['usuario_id']),
      usuarioNome: json['usuario_nome'] as String?,
      referenciaId: json['referencia_id'] != null ? _toInt(json['referencia_id']) : null,
      referenciaTipo: json['referencia_tipo'] as String?,
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'].toString())
          : DateTime.now(),
    );
  }
}
