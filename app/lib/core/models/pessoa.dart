class Pessoa {
  final int id;
  final String nome;
  final String? cpfCnpj;
  final String? telefone;
  final String? email;
  final String? endereco;
  final String tipo; // CLIENTE, FORNECEDOR
  final bool ativo;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Pessoa({
    required this.id,
    required this.nome,
    this.cpfCnpj,
    this.telefone,
    this.email,
    this.endereco,
    this.tipo = 'CLIENTE',
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String? ?? '',
      cpfCnpj: json['cpf_cnpj'] as String?,
      telefone: json['telefone'] as String?,
      email: json['email'] as String?,
      endereco: json['endereco'] as String?,
      tipo: json['tipo'] as String? ?? 'CLIENTE',
      ativo: json['ativo'] == 1 || json['ativo'] == true,
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'].toString())
          : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'cpfCnpj': cpfCnpj,
        'telefone': telefone,
        'email': email,
        'endereco': endereco,
        'tipo': tipo,
        'ativo': ativo,
      };

  Pessoa copyWith({
    int? id,
    String? nome,
    String? cpfCnpj,
    String? telefone,
    String? email,
    String? endereco,
    String? tipo,
    bool? ativo,
  }) {
    return Pessoa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      endereco: endereco ?? this.endereco,
      tipo: tipo ?? this.tipo,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
    );
  }
}
