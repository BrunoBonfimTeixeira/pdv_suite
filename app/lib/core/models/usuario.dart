class Usuario {
  final int id;
  final String nome;
  final String login;
  final String perfil;
  final bool ativo;

  const Usuario({
    required this.id,
    required this.nome,
    required this.login,
    required this.perfil,
    required this.ativo,
  });

  Usuario copyWith({
    int? id,
    String? nome,
    String? login,
    String? perfil,
    bool? ativo,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      login: login ?? this.login,
      perfil: perfil ?? this.perfil,
      ativo: ativo ?? this.ativo,
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['id'] as num).toInt(),
      nome: (json['nome'] ?? '').toString(),
      login: (json['login'] ?? '').toString(),
      perfil: (json['perfil'] ?? 'OPERADOR').toString(),
      ativo: (json['ativo'] == true) || (json['ativo'] == 1),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'login': login,
    'perfil': perfil,
    'ativo': ativo,
  };
}
