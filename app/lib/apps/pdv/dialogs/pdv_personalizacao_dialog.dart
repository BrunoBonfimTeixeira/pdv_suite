import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/core/models/pdv_config.dart';

class PdvPersonalizacaoDialog extends StatefulWidget {
  final PdvConfig config;
  const PdvPersonalizacaoDialog({super.key, required this.config});

  @override
  State<PdvPersonalizacaoDialog> createState() => _PdvPersonalizacaoDialogState();
}

class _PdvPersonalizacaoDialogState extends State<PdvPersonalizacaoDialog> {
  late TextEditingController _corPrimariaCtrl;
  late TextEditingController _corSecundariaCtrl;
  late TextEditingController _corBordaCtrl;
  late TextEditingController _corFundoCtrl;
  late TextEditingController _imagemFundoCtrl;

  @override
  void initState() {
    super.initState();
    _corPrimariaCtrl = TextEditingController(text: widget.config.corPrimaria);
    _corSecundariaCtrl = TextEditingController(text: widget.config.corSecundaria);
    _corBordaCtrl = TextEditingController(text: widget.config.corBorda);
    _corFundoCtrl = TextEditingController(text: widget.config.corFundo);
    _imagemFundoCtrl = TextEditingController(text: widget.config.imagemFundoUrl);
  }

  @override
  void dispose() {
    _corPrimariaCtrl.dispose();
    _corSecundariaCtrl.dispose();
    _corBordaCtrl.dispose();
    _corFundoCtrl.dispose();
    _imagemFundoCtrl.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  void _restaurarPadrao() {
    setState(() {
      _corPrimariaCtrl.text = '#00D4AA';
      _corSecundariaCtrl.text = '#00A885';
      _corBordaCtrl.text = '#2A2A4A';
      _corFundoCtrl.text = '#1A1A2E';
      _imagemFundoCtrl.clear();
    });
  }

  Widget _colorField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _parseHex(ctrl.text),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF00D4AA), width: 2),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewBg = _parseHex(_corFundoCtrl.text);
    final previewAccent = _parseHex(_corPrimariaCtrl.text);
    final previewBorder = _parseHex(_corBordaCtrl.text);

    return Dialog(
      backgroundColor: const Color(0xFF16213E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 620,
        height: 520,
        child: Row(
          children: [
            // Left: form
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personalizar PDV',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Altere as cores do seu PDV',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _colorField('Cor Primária', _corPrimariaCtrl),
                            _colorField('Cor Secundária', _corSecundariaCtrl),
                            _colorField('Cor das Bordas', _corBordaCtrl),
                            _colorField('Cor de Fundo', _corFundoCtrl),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: TextField(
                                controller: _imagemFundoCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  labelText: 'URL da Imagem de Fundo',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  hintText: 'https://...',
                                  hintStyle: const TextStyle(color: Colors.white30),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white24),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF00D4AA), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _restaurarPadrao,
                          child: const Text('Restaurar Padrão', style: TextStyle(color: Colors.white60)),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D4AA),
                            foregroundColor: const Color(0xFF1A1A2E),
                          ),
                          onPressed: () {
                            Navigator.pop(context, PdvConfig(
                              id: widget.config.id,
                              usuarioId: widget.config.usuarioId,
                              corPrimaria: _corPrimariaCtrl.text.trim(),
                              corSecundaria: _corSecundariaCtrl.text.trim(),
                              corBorda: _corBordaCtrl.text.trim(),
                              corFundo: _corFundoCtrl.text.trim(),
                              imagemFundoUrl: _imagemFundoCtrl.text.trim(),
                              tema: widget.config.tema,
                            ));
                          },
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Right: preview
            Container(
              width: 200,
              decoration: BoxDecoration(
                color: previewBg,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: previewBorder, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('PREVIEW', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  Container(
                    width: 160, height: 36,
                    decoration: BoxDecoration(
                      color: previewAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text('Botão Primário', style: TextStyle(color: previewBg, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 160, height: 80,
                    decoration: BoxDecoration(
                      color: previewBg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: previewBorder),
                    ),
                    alignment: Alignment.center,
                    child: Text('Painel', style: TextStyle(color: previewAccent, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 160, height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: previewBorder),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Borda', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
