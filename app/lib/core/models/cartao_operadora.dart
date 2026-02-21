class CartaoOperadora {
  final int id;
  final String descricao;
  final String bandeira;
  final double taxaPercentual;
  final int diasRecebimento;
  final bool ativo;

  CartaoOperadora({
    required this.id,
    required this.descricao,
    this.bandeira = '',
    this.taxaPercentual = 0,
    this.diasRecebimento = 0,
    this.ativo = true,
  });

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0;
  }

  factory CartaoOperadora.fromJson(Map<String, dynamic> json) {
    return CartaoOperadora(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      descricao: json['descricao']?.toString() ?? '',
      bandeira: json['bandeira']?.toString() ?? '',
      taxaPercentual: _parseDouble(json['taxa_percentual']),
      diasRecebimento: (json['dias_recebimento'] is num) ? (json['dias_recebimento'] as num).toInt() : int.tryParse(json['dias_recebimento'].toString()) ?? 0,
      ativo: json['ativo'] == 1 || json['ativo'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'descricao': descricao,
    'bandeira': bandeira,
    'taxa_percentual': taxaPercentual,
    'dias_recebimento': diasRecebimento,
    'ativo': ativo,
  };

  CartaoOperadora copyWith({
    String? descricao,
    String? bandeira,
    double? taxaPercentual,
    int? diasRecebimento,
    bool? ativo,
  }) {
    return CartaoOperadora(
      id: id,
      descricao: descricao ?? this.descricao,
      bandeira: bandeira ?? this.bandeira,
      taxaPercentual: taxaPercentual ?? this.taxaPercentual,
      diasRecebimento: diasRecebimento ?? this.diasRecebimento,
      ativo: ativo ?? this.ativo,
    );
  }
}
