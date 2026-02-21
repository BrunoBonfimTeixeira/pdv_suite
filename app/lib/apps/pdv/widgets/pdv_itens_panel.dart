import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_controller.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';

class PdvItensPanel extends StatelessWidget {
  final PdvController controller;
  const PdvItensPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final itens = controller.itens;

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
              'Pressione F3 para buscar produtos',
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
            border: const Border(bottom: BorderSide(color: PdvTheme.border)),
          ),
          child: const Row(
            children: [
              SizedBox(width: 40, child: Text('#', style: _headerStyle)),
              Expanded(flex: 4, child: Text('Produto', style: _headerStyle)),
              SizedBox(width: 80, child: Text('Qtd', style: _headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 100, child: Text('Unit.', style: _headerStyle, textAlign: TextAlign.right)),
              SizedBox(width: 110, child: Text('Total', style: _headerStyle, textAlign: TextAlign.right)),
              SizedBox(width: 40),
            ],
          ),
        ),
        // Items
        Expanded(
          child: ListView.builder(
            itemCount: itens.length,
            itemBuilder: (context, index) {
              final item = itens[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.transparent : PdvTheme.card.withOpacity(0.2),
                  border: const Border(bottom: BorderSide(color: PdvTheme.border, width: 0.5)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
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
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (item.quantidade > 1) {
                                controller.alterarQuantidade(index, item.quantidade - 1);
                              }
                            },
                            child: const Icon(Icons.remove_circle_outline, size: 18, color: PdvTheme.textSecondary),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${item.quantidade}',
                              style: const TextStyle(color: PdvTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),
                          InkWell(
                            onTap: () => controller.alterarQuantidade(index, item.quantidade + 1),
                            child: const Icon(Icons.add_circle_outline, size: 18, color: PdvTheme.accent),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        'R\$ ${item.preco.toStringAsFixed(2)}',
                        style: const TextStyle(color: PdvTheme.textSecondary, fontSize: 13),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: Text(
                        'R\$ ${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(color: PdvTheme.accent, fontWeight: FontWeight.w700, fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      width: 40,
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
