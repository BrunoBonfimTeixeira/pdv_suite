import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';

class FecharCaixaDialog extends StatefulWidget {
  final int caixaId;
  const FecharCaixaDialog({super.key, required this.caixaId});

  @override
  State<FecharCaixaDialog> createState() => _FecharCaixaDialogState();
}

class _FecharCaixaDialogState extends State<FecharCaixaDialog> {
  final _valorCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void dispose() {
    _valorCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lock, color: PdvTheme.warning),
          SizedBox(width: 10),
          Text('Fechar Caixa', style: TextStyle(color: PdvTheme.textPrimary)),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Caixa #${widget.caixaId}',
              style: const TextStyle(color: PdvTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _valorCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: PdvTheme.textPrimary, fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Valor em Caixa (R\$) - deixe vazio para auto',
                labelStyle: TextStyle(color: PdvTheme.textSecondary),
                prefixIcon: Icon(Icons.attach_money, color: PdvTheme.warning),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _obsCtrl,
              style: const TextStyle(color: PdvTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Observacoes (opcional)',
                labelStyle: TextStyle(color: PdvTheme.textSecondary),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final valorStr = _valorCtrl.text.trim();
            final valor = valorStr.isEmpty ? null : double.tryParse(valorStr.replaceAll(',', '.'));
            final obs = _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim();
            Navigator.pop(context, {'valorFechamento': valor, 'observacoes': obs});
          },
          style: ElevatedButton.styleFrom(backgroundColor: PdvTheme.warning, foregroundColor: PdvTheme.bg),
          child: const Text('Fechar Caixa'),
        ),
      ],
    );
  }
}
