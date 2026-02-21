class Caixa {
  final int id;
  final int usuarioId;
  final String? usuarioNome;
  final DateTime dataAbertura;
  final DateTime? dataFechamento;
  final double valorAbertura;
  final double? valorFechamento;
  final double? valorSistema;
  final double? diferenca;
  final String status; // ABERTO, FECHADO
  final String? observacoes;

  Caixa({
    required this.id,
    required this.usuarioId,
    this.usuarioNome,
    required this.dataAbertura,
    this.dataFechamento,
    required this.valorAbertura,
    this.valorFechamento,
    this.valorSistema,
    this.diferenca,
    required this.status,
    this.observacoes,
  });

  bool get isAberto => status == 'ABERTO';

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static double? _toDoubleNullable(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final d = double.tryParse(v.toString());
    return d;
  }

  factory Caixa.fromJson(Map<String, dynamic> json) {
    return Caixa(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      usuarioId: (json['usuario_id'] is num) ? (json['usuario_id'] as num).toInt() : int.tryParse(json['usuario_id'].toString()) ?? 0,
      usuarioNome: json['usuario_nome'] as String?,
      dataAbertura: DateTime.tryParse(json['data_abertura']?.toString() ?? '') ?? DateTime.now(),
      dataFechamento: json['data_fechamento'] != null
          ? DateTime.tryParse(json['data_fechamento'].toString())
          : null,
      valorAbertura: _toDouble(json['valor_abertura']),
      valorFechamento: _toDoubleNullable(json['valor_fechamento']),
      valorSistema: _toDoubleNullable(json['valor_sistema']),
      diferenca: _toDoubleNullable(json['diferenca']),
      status: json['status'] as String? ?? 'ABERTO',
      observacoes: json['observacoes'] as String?,
    );
  }
}
