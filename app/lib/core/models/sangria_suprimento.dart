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

class SangriaSuprimento {
  final int id;
  final int caixaId;
  final int usuarioId;
  final String? usuarioNome;
  final String tipo; // SANGRIA, SUPRIMENTO
  final double valor;
  final String? motivo;
  final DateTime criadoEm;

  SangriaSuprimento({
    required this.id,
    required this.caixaId,
    required this.usuarioId,
    this.usuarioNome,
    required this.tipo,
    required this.valor,
    this.motivo,
    required this.criadoEm,
  });

  bool get isSangria => tipo == 'SANGRIA';

  factory SangriaSuprimento.fromJson(Map<String, dynamic> json) {
    return SangriaSuprimento(
      id: _toInt(json['id']),
      caixaId: _toInt(json['caixa_id']),
      usuarioId: _toInt(json['usuario_id']),
      usuarioNome: json['usuario_nome'] as String?,
      tipo: json['tipo']?.toString() ?? 'SANGRIA',
      valor: _toDouble(json['valor']),
      motivo: json['motivo'] as String?,
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'].toString())
          : DateTime.now(),
    );
  }
}
