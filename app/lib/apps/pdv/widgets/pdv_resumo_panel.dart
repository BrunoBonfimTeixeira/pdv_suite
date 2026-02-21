import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_controller.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';

class PdvResumoPanel extends StatelessWidget {
  final PdvController controller;
  final VoidCallback onFinalizar;
  final VoidCallback onCancelar;

  const PdvResumoPanel({
    super.key,
    required this.controller,
    required this.onFinalizar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final temDesconto = controller.totalDescontos > 0.01;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: PdvTheme.surface,
        border: Border(left: BorderSide(color: PdvTheme.border)),
      ),
      child: Column(
        children: [
          // Total grande
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: PdvTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PdvTheme.accent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                if (temDesconto) ...[
                  const Text(
                    'SUBTOTAL',
                    style: TextStyle(color: PdvTheme.textSecondary, fontSize: 11, letterSpacing: 1),
                  ),
                  Text(
                    'R\$ ${controller.totalBruto.toStringAsFixed(2)}',
                    style: const TextStyle(color: PdvTheme.textSecondary, fontSize: 18, fontWeight: FontWeight.w600, decoration: TextDecoration.lineThrough),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Desconto: -R\$ ${controller.totalDescontos.toStringAsFixed(2)}',
                    style: const TextStyle(color: PdvTheme.warning, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  temDesconto ? 'TOTAL' : 'TOTAL',
                  style: const TextStyle(
                    color: PdvTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${controller.totalLiquido.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: PdvTheme.accent,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Info itens
          _InfoRow(label: 'Itens', value: '${controller.totalItens}'),
          _InfoRow(label: 'Produtos', value: '${controller.itens.length}'),
          if (controller.clienteSelecionado != null)
            _InfoRow(label: 'Cliente', value: controller.clienteSelecionado!.nome),
          if (controller.descontoVenda > 0)
            _InfoRow(label: 'Desc. Venda', value: '-R\$ ${controller.descontoVenda.toStringAsFixed(2)}'),
          const Spacer(),
          // Mensagens
          if (controller.mensagem.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PdvTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PdvTheme.accent.withOpacity(0.3)),
              ),
              child: Text(
                controller.mensagem,
                style: const TextStyle(color: PdvTheme.accent, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          if (controller.erro != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PdvTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PdvTheme.danger.withOpacity(0.3)),
              ),
              child: Text(
                controller.erro!,
                style: const TextStyle(color: PdvTheme.danger, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          // Botoes
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: controller.temItens && controller.caixaEstaAberto && !controller.processando
                  ? onFinalizar
                  : null,
              icon: const Icon(Icons.check_circle, size: 22),
              label: const Text('FINALIZAR (F)', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: PdvTheme.accent,
                foregroundColor: PdvTheme.bg,
                disabledBackgroundColor: PdvTheme.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: controller.temItens ? onCancelar : null,
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('CANCELAR (C)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PdvTheme.danger,
                side: BorderSide(color: controller.temItens ? PdvTheme.danger : PdvTheme.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: PdvTheme.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: PdvTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
