import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_controller.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';
import 'package:pdv_lanchonete/apps/pdv/dialogs/desconto_item_dialog.dart';

class PdvItensPanel extends StatelessWidget {
  final PdvController controller;
  const PdvItensPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final itens = controller.itens;
    final cfgAccent = PdvTheme.accentFrom(controller.pdvConfig);
    final cfgBorder = PdvTheme.borderFrom(controller.pdvConfig);

    if (itens.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: PdvTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              'Nenhum item adicionado',
              style: TextStyle(color: PdvTheme.textSecondary.withOpacity(0.5), fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Use o campo de codigo de barras ou F3 para buscar',
              style: TextStyle(color: PdvTheme.textSecondary.withOpacity(0.3), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: PdvTheme.card.withOpacity(0.5),
            border: Border(bottom: BorderSide(color: cfgBorder)),
          ),
          child: const Row(
            children: [
              SizedBox(width: 36, child: Text('#', style: _headerStyle)),
              Expanded(flex: 4, child: Text('Produto', style: _headerStyle)),
              SizedBox(width: 70, child: Text('Qtd', style: _headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 80, child: Text('Unit.', style: _headerStyle, textAlign: TextAlign.right)),
              SizedBox(width: 70, child: Text('Desc.', style: _headerStyle, textAlign: TextAlign.right)),
              SizedBox(width: 90, child: Text('Total', style: _headerStyle, textAlign: TextAlign.right)),
              SizedBox(width: 36),
            ],
          ),
        ),
        // Items
        Expanded(
          child: ListView.builder(
            itemCount: itens.length,
            itemBuilder: (context, index) {
              final item = itens[index];
              final temDesconto = item.descontoCalculado > 0;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.transparent : PdvTheme.card.withOpacity(0.2),
                  border: Border(bottom: BorderSide(color: cfgBorder, width: 0.5)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: PdvTheme.textSecondary, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.descricao,
                        style: const TextStyle(color: PdvTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (item.quantidade > 1) {
                                controller.alterarQuantidade(index, item.quantidade - 1);
                              }
                            },
                            child: const Icon(Icons.remove_circle_outline, size: 16, color: PdvTheme.textSecondary),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '${item.quantidade}',
                              style: const TextStyle(color: PdvTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),
                          InkWell(
                            onTap: () => controller.alterarQuantidade(index, item.quantidade + 1),
                            child: Icon(Icons.add_circle_outline, size: 16, color: cfgAccent),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        'R\$ ${item.preco.toStringAsFixed(2)}',
                        style: const TextStyle(color: PdvTheme.textSecondary, fontSize: 13),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    // Desconto
                    SizedBox(
                      width: 70,
                      child: InkWell(
                        onTap: () async {
                          final result = await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (_) => DescontoItemDialog(item: item),
                          );
                          if (result != null) {
                            controller.setDescontoItem(
                              index,
                              percentual: result['percentual'] ?? 0.0,
                              valor: result['valor'] ?? 0.0,
                            );
                          }
                        },
                        child: Text(
                          temDesconto ? '-${item.descontoCalculado.toStringAsFixed(2)}' : '-',
                          style: TextStyle(
                            color: temDesconto ? PdvTheme.warning : PdvTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: temDesconto ? FontWeight.w700 : FontWeight.normal,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        'R\$ ${item.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(color: cfgAccent, fontWeight: FontWeight.w700, fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: PdvTheme.danger),
                        onPressed: () => controller.removerItem(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static const _headerStyle = TextStyle(
    color: PdvTheme.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}
