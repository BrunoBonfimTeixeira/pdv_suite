import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';
import 'package:pdv_lanchonete/core/models/item_carrinho.dart';

class DescontoItemDialog extends StatefulWidget {
  final ItemCarrinho item;
  const DescontoItemDialog({super.key, required this.item});

  @override
  State<DescontoItemDialog> createState() => _DescontoItemDialogState();
}

class _DescontoItemDialogState extends State<DescontoItemDialog> {
  bool _usarPercentual = true;
  final _valorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item.descontoPercentual > 0) {
      _usarPercentual = true;
      _valorCtrl.text = widget.item.descontoPercentual.toStringAsFixed(2);
    } else if (widget.item.descontoValor > 0) {
      _usarPercentual = false;
      _valorCtrl.text = widget.item.descontoValor.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.discount, color: PdvTheme.warning),
          SizedBox(width: 10),
          Text('Desconto no Item', style: TextStyle(color: PdvTheme.textPrimary)),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.descricao,
              style: const TextStyle(color: PdvTheme.textPrimary, fontWeight: FontWeight.w700),
            ),
            Text(
              'Subtotal: R\$ ${widget.item.subtotalBruto.toStringAsFixed(2)}',
              style: const TextStyle(color: PdvTheme.textSecondary),
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
              style: const TextStyle(color: PdvTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: _usarPercentual ? '' : 'R\$ ',
                suffixText: _usarPercentual ? '%' : '',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Limpar desconto
            Navigator.pop(context, {'percentual': 0.0, 'valor': 0.0});
          },
          child: const Text('Limpar Desconto'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final v = double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0;
            if (_usarPercentual) {
              Navigator.pop(context, {'percentual': v, 'valor': 0.0});
            } else {
              Navigator.pop(context, {'percentual': 0.0, 'valor': v});
            }
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
