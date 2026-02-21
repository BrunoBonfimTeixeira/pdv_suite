class Categoria {
  final int id;
  final String descricao;
  final String cor;
  final String icone;
  final bool ativo;

  Categoria({
    required this.id,
    required this.descricao,
    this.cor = '#607D8B',
    this.icone = 'category',
    this.ativo = true,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      descricao: json['descricao']?.toString() ?? '',
      cor: json['cor']?.toString() ?? '#607D8B',
      icone: json['icone']?.toString() ?? 'category',
      ativo: json['ativo'] == 1 || json['ativo'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'descricao': descricao,
    'cor': cor,
    'icone': icone,
    'ativo': ativo,
  };

  Categoria copyWith({
    String? descricao,
    String? cor,
    String? icone,
    bool? ativo,
  }) {
    return Categoria(
      id: id,
      descricao: descricao ?? this.descricao,
      cor: cor ?? this.cor,
      icone: icone ?? this.icone,
      ativo: ativo ?? this.ativo,
    );
  }
}
