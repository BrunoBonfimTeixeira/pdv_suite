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

  factory Caixa.fromJson(Map<String, dynamic> json) {
    return Caixa(
      id: (json['id'] as num).toInt(),
      usuarioId: (json['usuario_id'] as num).toInt(),
      usuarioNome: json['usuario_nome'] as String?,
      dataAbertura: DateTime.parse(json['data_abertura'].toString()),
      dataFechamento: json['data_fechamento'] != null
          ? DateTime.parse(json['data_fechamento'].toString())
          : null,
      valorAbertura: (json['valor_abertura'] as num?)?.toDouble() ?? 0,
      valorFechamento: (json['valor_fechamento'] as num?)?.toDouble(),
      valorSistema: (json['valor_sistema'] as num?)?.toDouble(),
      diferenca: (json['diferenca'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'ABERTO',
      observacoes: json['observacoes'] as String?,
    );
  }
}
