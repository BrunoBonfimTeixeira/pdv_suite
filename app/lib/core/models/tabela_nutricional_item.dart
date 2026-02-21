class TabelaNutricionalItem {
  final int id;
  final int produtoId;
  final String porcao;
  final String unidadePorcao;
  final double energiaKcal;
  final double carboidratos;
  final double proteinas;
  final double gordurasTotais;
  final double gordurasSaturadas;
  final double gordurasTrans;
  final double fibras;
  final double sodio;

  TabelaNutricionalItem({
    required this.id,
    required this.produtoId,
    this.porcao = '',
    this.unidadePorcao = '',
    this.energiaKcal = 0,
    this.carboidratos = 0,
    this.proteinas = 0,
    this.gordurasTotais = 0,
    this.gordurasSaturadas = 0,
    this.gordurasTrans = 0,
    this.fibras = 0,
    this.sodio = 0,
  });

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0;
  }

  factory TabelaNutricionalItem.fromJson(Map<String, dynamic> json) {
    return TabelaNutricionalItem(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      produtoId: (json['produto_id'] is num) ? (json['produto_id'] as num).toInt() : int.tryParse(json['produto_id'].toString()) ?? 0,
      porcao: json['porcao']?.toString() ?? '',
      unidadePorcao: json['unidade_porcao']?.toString() ?? '',
      energiaKcal: _parseDouble(json['energia_kcal']),
      carboidratos: _parseDouble(json['carboidratos']),
      proteinas: _parseDouble(json['proteinas']),
      gordurasTotais: _parseDouble(json['gorduras_totais']),
      gordurasSaturadas: _parseDouble(json['gorduras_saturadas']),
      gordurasTrans: _parseDouble(json['gorduras_trans']),
      fibras: _parseDouble(json['fibras']),
      sodio: _parseDouble(json['sodio']),
    );
  }

  Map<String, dynamic> toJson() => {
    'produto_id': produtoId,
    'porcao': porcao,
    'unidade_porcao': unidadePorcao,
    'energia_kcal': energiaKcal,
    'carboidratos': carboidratos,
    'proteinas': proteinas,
    'gorduras_totais': gordurasTotais,
    'gorduras_saturadas': gordurasSaturadas,
    'gorduras_trans': gordurasTrans,
    'fibras': fibras,
    'sodio': sodio,
  };

  TabelaNutricionalItem copyWith({
    int? produtoId,
    String? porcao,
    String? unidadePorcao,
    double? energiaKcal,
    double? carboidratos,
    double? proteinas,
    double? gordurasTotais,
    double? gordurasSaturadas,
    double? gordurasTrans,
    double? fibras,
    double? sodio,
  }) {
    return TabelaNutricionalItem(
      id: id,
      produtoId: produtoId ?? this.produtoId,
      porcao: porcao ?? this.porcao,
      unidadePorcao: unidadePorcao ?? this.unidadePorcao,
      energiaKcal: energiaKcal ?? this.energiaKcal,
      carboidratos: carboidratos ?? this.carboidratos,
      proteinas: proteinas ?? this.proteinas,
      gordurasTotais: gordurasTotais ?? this.gordurasTotais,
      gordurasSaturadas: gordurasSaturadas ?? this.gordurasSaturadas,
      gordurasTrans: gordurasTrans ?? this.gordurasTrans,
      fibras: fibras ?? this.fibras,
      sodio: sodio ?? this.sodio,
    );
  }
}
