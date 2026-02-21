class InfoFiscal {
  final int id;
  final int produtoId;
  final String ncm;
  final String cest;
  final String cfop;
  final String origem;
  final String cstIcms;
  final double aliqIcms;
  final String cstPis;
  final double aliqPis;
  final String cstCofins;
  final double aliqCofins;

  InfoFiscal({
    required this.id,
    required this.produtoId,
    this.ncm = '',
    this.cest = '',
    this.cfop = '',
    this.origem = '',
    this.cstIcms = '',
    this.aliqIcms = 0,
    this.cstPis = '',
    this.aliqPis = 0,
    this.cstCofins = '',
    this.aliqCofins = 0,
  });

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0;
  }

  factory InfoFiscal.fromJson(Map<String, dynamic> json) {
    return InfoFiscal(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      produtoId: (json['produto_id'] is num) ? (json['produto_id'] as num).toInt() : int.tryParse(json['produto_id'].toString()) ?? 0,
      ncm: json['ncm']?.toString() ?? '',
      cest: json['cest']?.toString() ?? '',
      cfop: json['cfop']?.toString() ?? '',
      origem: json['origem']?.toString() ?? '',
      cstIcms: json['cst_icms']?.toString() ?? '',
      aliqIcms: _parseDouble(json['aliq_icms']),
      cstPis: json['cst_pis']?.toString() ?? '',
      aliqPis: _parseDouble(json['aliq_pis']),
      cstCofins: json['cst_cofins']?.toString() ?? '',
      aliqCofins: _parseDouble(json['aliq_cofins']),
    );
  }

  Map<String, dynamic> toJson() => {
    'produto_id': produtoId,
    'ncm': ncm,
    'cest': cest,
    'cfop': cfop,
    'origem': origem,
    'cst_icms': cstIcms,
    'aliq_icms': aliqIcms,
    'cst_pis': cstPis,
    'aliq_pis': aliqPis,
    'cst_cofins': cstCofins,
    'aliq_cofins': aliqCofins,
  };

  InfoFiscal copyWith({
    int? produtoId,
    String? ncm,
    String? cest,
    String? cfop,
    String? origem,
    String? cstIcms,
    double? aliqIcms,
    String? cstPis,
    double? aliqPis,
    String? cstCofins,
    double? aliqCofins,
  }) {
    return InfoFiscal(
      id: id,
      produtoId: produtoId ?? this.produtoId,
      ncm: ncm ?? this.ncm,
      cest: cest ?? this.cest,
      cfop: cfop ?? this.cfop,
      origem: origem ?? this.origem,
      cstIcms: cstIcms ?? this.cstIcms,
      aliqIcms: aliqIcms ?? this.aliqIcms,
      cstPis: cstPis ?? this.cstPis,
      aliqPis: aliqPis ?? this.aliqPis,
      cstCofins: cstCofins ?? this.cstCofins,
      aliqCofins: aliqCofins ?? this.aliqCofins,
    );
  }
}
