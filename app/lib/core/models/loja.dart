class Loja {
  final int id;
  final String nome;
  final String cnpj;
  final String inscricaoEstadual;
  final String inscricaoMunicipal;
  final String endereco;
  final String numero;
  final String bairro;
  final String cidade;
  final String uf;
  final String cep;
  final String telefone;
  final String email;
  final String regimeTributario;
  final String cnae;
  final bool ativo;

  Loja({
    required this.id,
    required this.nome,
    this.cnpj = '',
    this.inscricaoEstadual = '',
    this.inscricaoMunicipal = '',
    this.endereco = '',
    this.numero = '',
    this.bairro = '',
    this.cidade = '',
    this.uf = '',
    this.cep = '',
    this.telefone = '',
    this.email = '',
    this.regimeTributario = 'SIMPLES_NACIONAL',
    this.cnae = '',
    this.ativo = true,
  });

  factory Loja.fromJson(Map<String, dynamic> json) {
    return Loja(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      nome: json['nome']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
      inscricaoEstadual: json['inscricao_estadual']?.toString() ?? '',
      inscricaoMunicipal: json['inscricao_municipal']?.toString() ?? '',
      endereco: json['endereco']?.toString() ?? '',
      numero: json['numero']?.toString() ?? '',
      bairro: json['bairro']?.toString() ?? '',
      cidade: json['cidade']?.toString() ?? '',
      uf: json['uf']?.toString() ?? '',
      cep: json['cep']?.toString() ?? '',
      telefone: json['telefone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      regimeTributario: json['regime_tributario']?.toString() ?? 'SIMPLES_NACIONAL',
      cnae: json['cnae']?.toString() ?? '',
      ativo: json['ativo'] == 1 || json['ativo'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'cnpj': cnpj,
    'inscricao_estadual': inscricaoEstadual,
    'inscricao_municipal': inscricaoMunicipal,
    'endereco': endereco,
    'numero': numero,
    'bairro': bairro,
    'cidade': cidade,
    'uf': uf,
    'cep': cep,
    'telefone': telefone,
    'email': email,
    'regime_tributario': regimeTributario,
    'cnae': cnae,
    'ativo': ativo,
  };

  Loja copyWith({
    String? nome,
    String? cnpj,
    String? inscricaoEstadual,
    String? inscricaoMunicipal,
    String? endereco,
    String? numero,
    String? bairro,
    String? cidade,
    String? uf,
    String? cep,
    String? telefone,
    String? email,
    String? regimeTributario,
    String? cnae,
    bool? ativo,
  }) {
    return Loja(
      id: id,
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      inscricaoEstadual: inscricaoEstadual ?? this.inscricaoEstadual,
      inscricaoMunicipal: inscricaoMunicipal ?? this.inscricaoMunicipal,
      endereco: endereco ?? this.endereco,
      numero: numero ?? this.numero,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      cep: cep ?? this.cep,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      regimeTributario: regimeTributario ?? this.regimeTributario,
      cnae: cnae ?? this.cnae,
      ativo: ativo ?? this.ativo,
    );
  }
}
