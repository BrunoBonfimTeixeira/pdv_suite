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
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      descricao: json['descricao']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'OUTROS',
      ativo: json['ativo'] == 1 || json['ativo'] == true,
    );
  }
}
