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
      id: (json['id'] as num).toInt(),
      caixaId: (json['caixa_id'] as num).toInt(),
      usuarioId: (json['usuario_id'] as num).toInt(),
      usuarioNome: json['usuario_nome'] as String?,
      pessoaId: (json['pessoa_id'] as num?)?.toInt(),
      pessoaNome: json['pessoa_nome'] as String?,
      dataHora: DateTime.parse(json['data_hora'].toString()),
      totalBruto: (json['total_bruto'] as num).toDouble(),
      desconto: (json['desconto'] as num?)?.toDouble() ?? 0,
      acrescimo: (json['acrescimo'] as num?)?.toDouble() ?? 0,
      totalLiquido: (json['total_liquido'] as num).toDouble(),
      status: json['status'] as String? ?? 'FINALIZADA',
      numeroNfe: (json['numero_nfe'] as num?)?.toInt() ?? 0,
      itens: itensList,
      pagamentos: pagsList,
    );
  }

  /// Para listagem (sem itens/pagamentos)
  factory VendaDetalhe.fromListJson(Map<String, dynamic> json) {
    return VendaDetalhe(
      id: (json['id'] as num).toInt(),
      caixaId: (json['caixa_id'] as num).toInt(),
      usuarioId: (json['usuario_id'] as num).toInt(),
      usuarioNome: json['usuario_nome'] as String?,
      pessoaId: (json['pessoa_id'] as num?)?.toInt(),
      pessoaNome: json['pessoa_nome'] as String?,
      dataHora: DateTime.parse(json['data_hora'].toString()),
      totalBruto: (json['total_bruto'] as num).toDouble(),
      desconto: (json['desconto'] as num?)?.toDouble() ?? 0,
      acrescimo: (json['acrescimo'] as num?)?.toDouble() ?? 0,
      totalLiquido: (json['total_liquido'] as num).toDouble(),
      status: json['status'] as String? ?? 'FINALIZADA',
      numeroNfe: (json['numero_nfe'] as num?)?.toInt() ?? 0,
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
      id: (json['id'] as num).toInt(),
      produtoId: (json['produto_id'] as num).toInt(),
      produtoDescricao: json['produto_descricao'] as String?,
      quantidade: (json['quantidade'] as num).toDouble(),
      valorUnitario: (json['valor_unitario'] as num).toDouble(),
      valorTotal: (json['valor_total'] as num).toDouble(),
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
      id: (json['id'] as num).toInt(),
      formaPagamentoId: (json['forma_pagamento_id'] as num).toInt(),
      formaDescricao: json['forma_descricao'] as String?,
      valor: (json['valor'] as num).toDouble(),
    );
  }
}
