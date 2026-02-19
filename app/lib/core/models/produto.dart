class Produto {
  final int id;
  final String descricao;
  final double preco; // preco_venda
  final String? codigoBarras;
  final bool ativo;

  final double? precoCusto;
  final double? markup;
  final double? margem;

  Produto({
    required this.id,
    required this.descricao,
    required this.preco,
    this.codigoBarras,
    this.ativo = true,
    this.precoCusto,
    this.markup,
    this.margem,
  });

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();

    final s = v.toString().trim();
    if (s.isEmpty) return 0.0;

    // Se tiver vírgula e ponto, decide qual é decimal pelo último separador
    final hasComma = s.contains(',');
    final hasDot = s.contains('.');

    String normalized = s;

    if (hasComma && hasDot) {
      // Ex: "1.234,56" (pt-BR) ou "1,234.56" (en-US)
      final lastComma = s.lastIndexOf(',');
      final lastDot = s.lastIndexOf('.');
      final decimalIsComma = lastComma > lastDot;

      if (decimalIsComma) {
        // remove milhares ".", troca decimal "," por "."
        normalized = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // remove milhares ",", mantém decimal "."
        normalized = s.replaceAll(',', '');
      }
    } else if (hasComma && !hasDot) {
      // "123,45" => "123.45"
      normalized = s.replaceAll(',', '.');
    } else {
      // só ponto ou nenhum -> tenta direto
      normalized = s;
    }

    return double.tryParse(normalized) ?? 0.0;
  }

  static double? _parseDoubleNullable(dynamic v) {
    if (v == null) return null;
    final d = _parseDouble(v);
    return d == 0.0 ? null : d;
  }

  factory Produto.fromApi(Map<String, dynamic> json) {
    return Produto(
      id: (json['id'] as num).toInt(),
      descricao: (json['descricao'] ?? '').toString(),
      preco: _parseDouble(json['preco_venda']),
      codigoBarras: json['codigo_barras']?.toString(),
      ativo: json['ativo'] == null
          ? true
          : (json['ativo'] == true || json['ativo'] == 1),

      precoCusto: _parseDoubleNullable(json['preco_custo']),
      markup: _parseDoubleNullable(json['markup']),
      margem: _parseDoubleNullable(json['margem']),
    );
  }

  Produto copyWith({
    String? descricao,
    double? preco,
    String? codigoBarras,
    bool? ativo,
    double? precoCusto,
    double? markup,
    double? margem,
  }) {
    return Produto(
      id: id,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      ativo: ativo ?? this.ativo,
      precoCusto: precoCusto ?? this.precoCusto,
      markup: markup ?? this.markup,
      margem: margem ?? this.margem,
    );
  }
}
