class ConversaoUm {
  final int id;
  final int produtoId;
  final String umOrigem;
  final String umDestino;
  final double fatorMultiplicador;

  ConversaoUm({
    required this.id,
    required this.produtoId,
    this.umOrigem = '',
    this.umDestino = '',
    this.fatorMultiplicador = 0,
  });

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0;
  }

  factory ConversaoUm.fromJson(Map<String, dynamic> json) {
    return ConversaoUm(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      produtoId: (json['produto_id'] is num) ? (json['produto_id'] as num).toInt() : int.tryParse(json['produto_id'].toString()) ?? 0,
      umOrigem: json['um_origem']?.toString() ?? '',
      umDestino: json['um_destino']?.toString() ?? '',
      fatorMultiplicador: _parseDouble(json['fator_multiplicador']),
    );
  }

  Map<String, dynamic> toJson() => {
    'produto_id': produtoId,
    'um_origem': umOrigem,
    'um_destino': umDestino,
    'fator_multiplicador': fatorMultiplicador,
  };

  ConversaoUm copyWith({
    int? produtoId,
    String? umOrigem,
    String? umDestino,
    double? fatorMultiplicador,
  }) {
    return ConversaoUm(
      id: id,
      produtoId: produtoId ?? this.produtoId,
      umOrigem: umOrigem ?? this.umOrigem,
      umDestino: umDestino ?? this.umDestino,
      fatorMultiplicador: fatorMultiplicador ?? this.fatorMultiplicador,
    );
  }
}
