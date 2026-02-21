import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';

class SangriaDialog extends StatefulWidget {
  const SangriaDialog({super.key});

  @override
  State<SangriaDialog> createState() => _SangriaDialogState();
}

class _SangriaDialogState extends State<SangriaDialog> {
  final _valorCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();

  @override
  void dispose() {
    _valorCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.money_off, color: PdvTheme.danger),
          SizedBox(width: 10),
          Text('Sangria', style: TextStyle(color: PdvTheme.textPrimary)),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _valorCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: PdvTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(color: PdvTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _motivoCtrl,
              style: const TextStyle(color: PdvTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
              ),
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
            if (valor <= 0) return;
            Navigator.pop(context, {
              'valor': valor,
              'motivo': _motivoCtrl.text.trim().isEmpty ? null : _motivoCtrl.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: PdvTheme.danger,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar Sangria'),
        ),
      ],
    );
  }
}
