import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';
import 'package:pdv_lanchonete/core/models/forma_pagamento.dart';

class FinalizarVendaDialog extends StatefulWidget {
  final double total;
  final List<FormaPagamento> formasPagamento;

  const FinalizarVendaDialog({
    super.key,
    required this.total,
    required this.formasPagamento,
  });

  @override
  State<FinalizarVendaDialog> createState() => _FinalizarVendaDialogState();
}

class _FinalizarVendaDialogState extends State<FinalizarVendaDialog> {
  late List<_PagamentoItem> _pagamentos;

  @override
  void initState() {
    super.initState();
    // Inicia com pagamento único em Dinheiro
    final dinheiro = widget.formasPagamento.isNotEmpty
        ? widget.formasPagamento.first
        : FormaPagamento(id: 1, descricao: 'Dinheiro', tipo: 'DINHEIRO');

    _pagamentos = [
      _PagamentoItem(
        forma: dinheiro,
        valorCtrl: TextEditingController(text: widget.total.toStringAsFixed(2)),
      ),
    ];
  }

  @override
  void dispose() {
    for (final p in _pagamentos) {
      p.valorCtrl.dispose();
    }
    super.dispose();
  }

  double get _totalPagamentos {
    return _pagamentos.fold(0.0, (s, p) {
      return s + (double.tryParse(p.valorCtrl.text.replaceAll(',', '.')) ?? 0);
    });
  }

  double get _restante => widget.total - _totalPagamentos;

  void _adicionarPagamento() {
    final formas = widget.formasPagamento;
    if (formas.isEmpty) return;

    setState(() {
      _pagamentos.add(_PagamentoItem(
        forma: formas.first,
        valorCtrl: TextEditingController(text: _restante > 0 ? _restante.toStringAsFixed(2) : '0.00'),
      ));
    });
  }

  void _removerPagamento(int index) {
    if (_pagamentos.length <= 1) return;
    setState(() {
      _pagamentos[index].valorCtrl.dispose();
      _pagamentos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.payment, color: PdvTheme.accent),
          SizedBox(width: 10),
          Text('Finalizar Venda', style: TextStyle(color: PdvTheme.textPrimary)),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PdvTheme.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total da Venda', style: TextStyle(color: PdvTheme.textSecondary)),
                  Text(
                    'R\$ ${widget.total.toStringAsFixed(2)}',
                    style: const TextStyle(color: PdvTheme.accent, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Pagamentos
            ...List.generate(_pagamentos.length, (i) {
              final pag = _pagamentos[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<int>(
                        value: pag.forma.id,
                        dropdownColor: PdvTheme.card,
                        style: const TextStyle(color: PdvTheme.textPrimary),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: widget.formasPagamento.map((f) {
                          return DropdownMenuItem(
                            value: f.id,
                            child: Text(f.descricao),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            pag.forma = widget.formasPagamento.firstWhere((f) => f.id == val);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: pag.valorCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: PdvTheme.textPrimary, fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          prefixText: 'R\$ ',
                          prefixStyle: TextStyle(color: PdvTheme.textSecondary),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_pagamentos.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: PdvTheme.danger, size: 20),
                        onPressed: () => _removerPagamento(i),
                      ),
                  ],
                ),
              );
            }),
            // Adicionar pagamento
            TextButton.icon(
              onPressed: _adicionarPagamento,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar forma de pagamento'),
            ),
            const SizedBox(height: 8),
            // Restante
            if (_restante.abs() > 0.01)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _restante > 0
                      ? PdvTheme.danger.withOpacity(0.1)
                      : PdvTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _restante > 0
                      ? 'Faltam R\$ ${_restante.toStringAsFixed(2)}'
                      : 'Troco: R\$ ${(-_restante).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _restante > 0 ? PdvTheme.danger : PdvTheme.warning,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
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
          onPressed: _restante <= 0.01
              ? () {
                  final pagamentos = _pagamentos.map((p) {
                    return {
                      'formaPagamentoId': p.forma.id,
                      'valor': double.tryParse(p.valorCtrl.text.replaceAll(',', '.')) ?? 0,
                    };
                  }).toList();
                  Navigator.pop(context, pagamentos);
                }
              : null,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

class _PagamentoItem {
  FormaPagamento forma;
  final TextEditingController valorCtrl;

  _PagamentoItem({required this.forma, required this.valorCtrl});
}
