class PdvConfig {
  final int id;
  final int usuarioId;
  final String corPrimaria;
  final String corSecundaria;
  final String corBorda;
  final String corFundo;
  final String imagemFundoUrl;
  final String tema;

  PdvConfig({
    required this.id,
    required this.usuarioId,
    this.corPrimaria = '#00D4AA',
    this.corSecundaria = '#00A885',
    this.corBorda = '#2A2A4A',
    this.corFundo = '#1A1A2E',
    this.imagemFundoUrl = '',
    this.tema = 'padrao',
  });

  factory PdvConfig.fromJson(Map<String, dynamic> json) {
    return PdvConfig(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id'].toString()) ?? 0,
      usuarioId: (json['usuario_id'] is num) ? (json['usuario_id'] as num).toInt() : int.tryParse(json['usuario_id'].toString()) ?? 0,
      corPrimaria: json['cor_primaria']?.toString() ?? '#00D4AA',
      corSecundaria: json['cor_secundaria']?.toString() ?? '#00A885',
      corBorda: json['cor_borda']?.toString() ?? '#2A2A4A',
      corFundo: json['cor_fundo']?.toString() ?? '#1A1A2E',
      imagemFundoUrl: json['imagem_fundo_url']?.toString() ?? '',
      tema: json['tema']?.toString() ?? 'padrao',
    );
  }

  Map<String, dynamic> toJson() => {
    'usuario_id': usuarioId,
    'cor_primaria': corPrimaria,
    'cor_secundaria': corSecundaria,
    'cor_borda': corBorda,
    'cor_fundo': corFundo,
    'imagem_fundo_url': imagemFundoUrl,
    'tema': tema,
  };

  PdvConfig copyWith({
    int? usuarioId,
    String? corPrimaria,
    String? corSecundaria,
    String? corBorda,
    String? corFundo,
    String? imagemFundoUrl,
    String? tema,
  }) {
    return PdvConfig(
      id: id,
      usuarioId: usuarioId ?? this.usuarioId,
      corPrimaria: corPrimaria ?? this.corPrimaria,
      corSecundaria: corSecundaria ?? this.corSecundaria,
      corBorda: corBorda ?? this.corBorda,
      corFundo: corFundo ?? this.corFundo,
      imagemFundoUrl: imagemFundoUrl ?? this.imagemFundoUrl,
      tema: tema ?? this.tema,
    );
  }
}
