class OrdemServico {
  final int id;
  final int? pessoaId;
  final String pessoaNome;
  final int? usuarioId;
  final String descricao;
  final String defeitoRelatado;
  final String solucao;
  final String status;
  final String prioridade;
  final String dataAbertura;
  final String dataPrevisao;
  final String dataConclusao;
  final double valorOrcamento;
  final double valorFinal;
  final String observacoes;

  OrdemServico({
    required this.id,
    this.pessoaId,
    this.pessoaNome = '',
    this.usuarioId,
    this.descricao = '',
    this.defeitoRelatado = '',
    this.solucao = '',
    this.status = '',
    this.prioridade = '',
    this.dataAbertura = '',
    this.dataPrevisao = '',
    this.dataConclusao = '',
    this.valorOrcamento = 0,
    this.valorFinal = 0,
    this.observacoes = '',
  });

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0;
  }

  factory OrdemServico.fromJson(Map<String, dynamic> json) {
    return OrdemServico(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      pessoaId: json['pessoa_id'] != null
          ? (json['pessoa_id'] is num) ? (json['pessoa_id'] as num).toInt() : int.tryParse(json['pessoa_id'].toString())
          : null,
      pessoaNome: json['pessoa_nome']?.toString() ?? '',
      usuarioId: json['usuario_id'] != null
          ? (json['usuario_id'] is num) ? (json['usuario_id'] as num).toInt() : int.tryParse(json['usuario_id'].toString())
          : null,
      descricao: json['descricao']?.toString() ?? '',
      defeitoRelatado: json['defeito_relatado']?.toString() ?? '',
      solucao: json['solucao']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      prioridade: json['prioridade']?.toString() ?? '',
      dataAbertura: json['data_abertura']?.toString() ?? '',
      dataPrevisao: json['data_previsao']?.toString() ?? '',
      dataConclusao: json['data_conclusao']?.toString() ?? '',
      valorOrcamento: _parseDouble(json['valor_orcamento']),
      valorFinal: _parseDouble(json['valor_final']),
      observacoes: json['observacoes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'pessoa_id': pessoaId,
    'pessoa_nome': pessoaNome,
    'usuario_id': usuarioId,
    'descricao': descricao,
    'defeito_relatado': defeitoRelatado,
    'solucao': solucao,
    'status': status,
    'prioridade': prioridade,
    'data_abertura': dataAbertura,
    'data_previsao': dataPrevisao,
    'data_conclusao': dataConclusao,
    'valor_orcamento': valorOrcamento,
    'valor_final': valorFinal,
    'observacoes': observacoes,
  };

  OrdemServico copyWith({
    int? pessoaId,
    String? pessoaNome,
    int? usuarioId,
    String? descricao,
    String? defeitoRelatado,
    String? solucao,
    String? status,
    String? prioridade,
    String? dataAbertura,
    String? dataPrevisao,
    String? dataConclusao,
    double? valorOrcamento,
    double? valorFinal,
    String? observacoes,
  }) {
    return OrdemServico(
      id: id,
      pessoaId: pessoaId ?? this.pessoaId,
      pessoaNome: pessoaNome ?? this.pessoaNome,
      usuarioId: usuarioId ?? this.usuarioId,
      descricao: descricao ?? this.descricao,
      defeitoRelatado: defeitoRelatado ?? this.defeitoRelatado,
      solucao: solucao ?? this.solucao,
      status: status ?? this.status,
      prioridade: prioridade ?? this.prioridade,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      dataPrevisao: dataPrevisao ?? this.dataPrevisao,
      dataConclusao: dataConclusao ?? this.dataConclusao,
      valorOrcamento: valorOrcamento ?? this.valorOrcamento,
      valorFinal: valorFinal ?? this.valorFinal,
      observacoes: observacoes ?? this.observacoes,
    );
  }
}
