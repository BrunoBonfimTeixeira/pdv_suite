import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';

class AbrirCaixaDialog extends StatefulWidget {
  const AbrirCaixaDialog({super.key});

  @override
  State<AbrirCaixaDialog> createState() => _AbrirCaixaDialogState();
}

class _AbrirCaixaDialogState extends State<AbrirCaixaDialog> {
  final _valorCtrl = TextEditingController(text: '0.00');
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
          Icon(Icons.lock_open, color: PdvTheme.accent),
          SizedBox(width: 10),
          Text('Abrir Caixa', style: TextStyle(color: PdvTheme.textPrimary)),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _valorCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: PdvTheme.textPrimary, fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Valor de Abertura (R\$)',
                labelStyle: TextStyle(color: PdvTheme.textSecondary),
                prefixIcon: Icon(Icons.attach_money, color: PdvTheme.accent),
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
            final valor = double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0;
            final obs = _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim();
            Navigator.pop(context, {'valorAbertura': valor, 'observacoes': obs});
          },
          child: const Text('Abrir Caixa'),
        ),
      ],
    );
  }
}
