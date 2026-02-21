class InfoExtra {
  final int id;
  final int produtoId;
  final String chave;
  final String valor;

  InfoExtra({
    required this.id,
    required this.produtoId,
    this.chave = '',
    this.valor = '',
  });

  factory InfoExtra.fromJson(Map<String, dynamic> json) {
    return InfoExtra(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      produtoId: (json['produto_id'] is num) ? (json['produto_id'] as num).toInt() : int.tryParse(json['produto_id'].toString()) ?? 0,
      chave: json['chave']?.toString() ?? '',
      valor: json['valor']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'produto_id': produtoId,
    'chave': chave,
    'valor': valor,
  };

  InfoExtra copyWith({
    int? produtoId,
    String? chave,
    String? valor,
  }) {
    return InfoExtra(
      id: id,
      produtoId: produtoId ?? this.produtoId,
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
    );
  }
}
