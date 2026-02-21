class FormaPagamento {
  final int id;
  final String descricao;
  final String tipo;
  final bool ativo;

  FormaPagamento({
    required this.id,
    required this.descricao,
    required this.tipo,
    this.ativo = true,
  });

  factory FormaPagamento.fromJson(Map<String, dynamic> json) {
    return FormaPagamento(
      id: (json['id'] as num).toInt(),
      descricao: json['descricao'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'OUTROS',
      ativo: json['ativo'] == 1 || json['ativo'] == true,
    );
  }
}
