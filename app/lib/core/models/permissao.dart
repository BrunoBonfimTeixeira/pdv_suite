class Permissao {
  final int id;
  final String perfil;
  final String modulo;
  final bool ler;
  final bool escrever;
  final bool excluir;

  Permissao({
    required this.id,
    required this.perfil,
    required this.modulo,
    this.ler = false,
    this.escrever = false,
    this.excluir = false,
  });

  factory Permissao.fromJson(Map<String, dynamic> json) {
    return Permissao(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      perfil: json['perfil']?.toString() ?? '',
      modulo: json['modulo']?.toString() ?? '',
      ler: json['ler'] == 1 || json['ler'] == true,
      escrever: json['escrever'] == 1 || json['escrever'] == true,
      excluir: json['excluir'] == 1 || json['excluir'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'perfil': perfil,
    'modulo': modulo,
    'ler': ler,
    'escrever': escrever,
    'excluir': excluir,
  };

  Permissao copyWith({
    String? perfil,
    String? modulo,
    bool? ler,
    bool? escrever,
    bool? excluir,
  }) {
    return Permissao(
      id: id,
      perfil: perfil ?? this.perfil,
      modulo: modulo ?? this.modulo,
      ler: ler ?? this.ler,
      escrever: escrever ?? this.escrever,
      excluir: excluir ?? this.excluir,
    );
  }
}
