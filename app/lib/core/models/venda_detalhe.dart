// Helper para MySQL DECIMAL que vem como String no JSON
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

int? _toIntNullable(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

class VendaDetalhe {
  final int id;
  final int caixaId;
  final int usuarioId;
  final String? usuarioNome;
  final int? pessoaId;
  final String? pessoaNome;
  final DateTime dataHora;
  final double totalBruto;
  final double desconto;
  final double acrescimo;
  final double totalLiquido;
  final String status;
  final int numeroNfe;
  final List<VendaItemDetalhe> itens;
  final List<VendaPagamentoDetalhe> pagamentos;

  VendaDetalhe({
    required this.id,
    required this.caixaId,
    required this.usuarioId,
    this.usuarioNome,
    this.pessoaId,
    this.pessoaNome,
    required this.dataHora,
    required this.totalBruto,
    required this.desconto,
    required this.acrescimo,
    required this.totalLiquido,
    required this.status,
    required this.numeroNfe,
    this.itens = const [],
    this.pagamentos = const [],
  });

  bool get isCancelada => status == 'CANCELADA';

  factory VendaDetalhe.fromJson(Map<String, dynamic> json) {
    final itensList = (json['itens'] as List?)
            ?.map((e) => VendaItemDetalhe.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final pagsList = (json['pagamentos'] as List?)
            ?.map((e) => VendaPagamentoDetalhe.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return VendaDetalhe(
      id: _toInt(json['id']),
      caixaId: _toInt(json['caixa_id']),
      usuarioId: _toInt(json['usuario_id']),
      usuarioNome: json['usuario_nome'] as String?,
      pessoaId: _toIntNullable(json['pessoa_id']),
      pessoaNome: json['pessoa_nome'] as String?,
      dataHora: DateTime.parse(json['data_hora'].toString()),
      totalBruto: _toDouble(json['total_bruto']),
      desconto: _toDouble(json['desconto']),
      acrescimo: _toDouble(json['acrescimo']),
      totalLiquido: _toDouble(json['total_liquido']),
      status: json['status'] as String? ?? 'FINALIZADA',
      numeroNfe: _toInt(json['numero_nfe']),
      itens: itensList,
      pagamentos: pagsList,
    );
  }

  /// Para listagem (sem itens/pagamentos)
  factory VendaDetalhe.fromListJson(Map<String, dynamic> json) {
    return VendaDetalhe(
      id: _toInt(json['id']),
      caixaId: _toInt(json['caixa_id']),
      usuarioId: _toInt(json['usuario_id']),
      usuarioNome: json['usuario_nome'] as String?,
      pessoaId: _toIntNullable(json['pessoa_id']),
      pessoaNome: json['pessoa_nome'] as String?,
      dataHora: DateTime.parse(json['data_hora'].toString()),
      totalBruto: _toDouble(json['total_bruto']),
      desconto: _toDouble(json['desconto']),
      acrescimo: _toDouble(json['acrescimo']),
      totalLiquido: _toDouble(json['total_liquido']),
      status: json['status'] as String? ?? 'FINALIZADA',
      numeroNfe: _toInt(json['numero_nfe']),
    );
  }
}

class VendaItemDetalhe {
  final int id;
  final int produtoId;
  final String? produtoDescricao;
  final double quantidade;
  final double valorUnitario;
  final double valorTotal;

  VendaItemDetalhe({
    required this.id,
    required this.produtoId,
    this.produtoDescricao,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorTotal,
  });

  factory VendaItemDetalhe.fromJson(Map<String, dynamic> json) {
    return VendaItemDetalhe(
      id: _toInt(json['id']),
      produtoId: _toInt(json['produto_id']),
      produtoDescricao: json['produto_descricao'] as String?,
      quantidade: _toDouble(json['quantidade']),
      valorUnitario: _toDouble(json['valor_unitario']),
      valorTotal: _toDouble(json['valor_total']),
    );
  }
}

class VendaPagamentoDetalhe {
  final int id;
  final int formaPagamentoId;
  final String? formaDescricao;
  final double valor;

  VendaPagamentoDetalhe({
    required this.id,
    required this.formaPagamentoId,
    this.formaDescricao,
    required this.valor,
  });

  factory VendaPagamentoDetalhe.fromJson(Map<String, dynamic> json) {
    return VendaPagamentoDetalhe(
      id: _toInt(json['id']),
      formaPagamentoId: _toInt(json['forma_pagamento_id']),
      formaDescricao: json['forma_descricao'] as String?,
      valor: _toDouble(json['valor']),
    );
  }
}
