import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';

class DescontoVendaDialog extends StatefulWidget {
  final double totalBruto;
  final double descontoAtual;

  const DescontoVendaDialog({
    super.key,
    required this.totalBruto,
    this.descontoAtual = 0,
  });

  @override
  State<DescontoVendaDialog> createState() => _DescontoVendaDialogState();
}

class _DescontoVendaDialogState extends State<DescontoVendaDialog> {
  bool _usarPercentual = true;
  final _valorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.descontoAtual > 0) {
      _usarPercentual = false;
      _valorCtrl.text = widget.descontoAtual.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    super.dispose();
  }

  double get _descontoCalculado {
    final v = double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0;
    if (_usarPercentual) {
      return widget.totalBruto * v / 100;
    }
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.discount, color: PdvTheme.warning),
          SizedBox(width: 10),
          Text('Desconto na Venda', style: TextStyle(color: PdvTheme.textPrimary)),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PdvTheme.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bruto', style: TextStyle(color: PdvTheme.textSecondary)),
                  Text(
                    'R\$ ${widget.totalBruto.toStringAsFixed(2)}',
                    style: const TextStyle(color: PdvTheme.accent, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Percentual (%)'),
                  selected: _usarPercentual,
                  onSelected: (v) => setState(() => _usarPercentual = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Valor (R\$)'),
                  selected: !_usarPercentual,
                  onSelected: (v) => setState(() => _usarPercentual = false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valorCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: PdvTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: _usarPercentual ? '' : 'R\$ ',
                suffixText: _usarPercentual ? '%' : '',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            if (_descontoCalculado > 0)
              Text(
                'Desconto: R\$ ${_descontoCalculado.toStringAsFixed(2)}  |  Total: R\$ ${(widget.totalBruto - _descontoCalculado).toStringAsFixed(2)}',
                style: const TextStyle(color: PdvTheme.warning, fontWeight: FontWeight.w700),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 0.0),
          child: const Text('Limpar Desconto'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _descontoCalculado);
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
