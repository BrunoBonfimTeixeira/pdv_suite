class NotaFiscal {
  final int id;
  final int? vendaId;
  final int? lojaId;
  final String tipo;
  final String serie;
  final String numero;
  final String chaveAcesso;
  final String protocolo;
  final String status;
  final String xmlEnvio;
  final String xmlRetorno;
  final String motivoCancelamento;
  final String dataEmissao;
  final String criadoEm;

  NotaFiscal({
    required this.id,
    this.vendaId,
    this.lojaId,
    this.tipo = '',
    this.serie = '',
    this.numero = '',
    this.chaveAcesso = '',
    this.protocolo = '',
    this.status = '',
    this.xmlEnvio = '',
    this.xmlRetorno = '',
    this.motivoCancelamento = '',
    this.dataEmissao = '',
    this.criadoEm = '',
  });

  factory NotaFiscal.fromJson(Map<String, dynamic> json) {
    return NotaFiscal(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      vendaId: json['venda_id'] != null
          ? (json['venda_id'] is num) ? (json['venda_id'] as num).toInt() : int.tryParse(json['venda_id'].toString())
          : null,
      lojaId: json['loja_id'] != null
          ? (json['loja_id'] is num) ? (json['loja_id'] as num).toInt() : int.tryParse(json['loja_id'].toString())
          : null,
      tipo: json['tipo']?.toString() ?? '',
      serie: json['serie']?.toString() ?? '',
      numero: json['numero']?.toString() ?? '',
      chaveAcesso: json['chave_acesso']?.toString() ?? '',
      protocolo: json['protocolo']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      xmlEnvio: json['xml_envio']?.toString() ?? '',
      xmlRetorno: json['xml_retorno']?.toString() ?? '',
      motivoCancelamento: json['motivo_cancelamento']?.toString() ?? '',
      dataEmissao: json['data_emissao']?.toString() ?? '',
      criadoEm: json['criado_em']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'venda_id': vendaId,
    'loja_id': lojaId,
    'tipo': tipo,
    'serie': serie,
    'numero': numero,
    'chave_acesso': chaveAcesso,
    'protocolo': protocolo,
    'status': status,
    'xml_envio': xmlEnvio,
    'xml_retorno': xmlRetorno,
    'motivo_cancelamento': motivoCancelamento,
    'data_emissao': dataEmissao,
    'criado_em': criadoEm,
  };

  NotaFiscal copyWith({
    int? vendaId,
    int? lojaId,
    String? tipo,
    String? serie,
    String? numero,
    String? chaveAcesso,
    String? protocolo,
    String? status,
    String? xmlEnvio,
    String? xmlRetorno,
    String? motivoCancelamento,
    String? dataEmissao,
    String? criadoEm,
  }) {
    return NotaFiscal(
      id: id,
      vendaId: vendaId ?? this.vendaId,
      lojaId: lojaId ?? this.lojaId,
      tipo: tipo ?? this.tipo,
      serie: serie ?? this.serie,
      numero: numero ?? this.numero,
      chaveAcesso: chaveAcesso ?? this.chaveAcesso,
      protocolo: protocolo ?? this.protocolo,
      status: status ?? this.status,
      xmlEnvio: xmlEnvio ?? this.xmlEnvio,
      xmlRetorno: xmlRetorno ?? this.xmlRetorno,
      motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
      dataEmissao: dataEmissao ?? this.dataEmissao,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
