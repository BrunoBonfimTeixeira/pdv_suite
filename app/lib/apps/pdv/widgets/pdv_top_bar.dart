import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_controller.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';

class PdvTopBar extends StatelessWidget {
  final PdvController controller;
  const PdvTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final caixa = controller.caixaAberto;
    final usuario = controller.usuario;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: PdvTheme.surface,
        border: Border(bottom: BorderSide(color: PdvTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.point_of_sale, color: PdvTheme.accent, size: 28),
          const SizedBox(width: 10),
          const Text(
            'PDV',
            style: TextStyle(
              color: PdvTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 24),
          // Caixa info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: caixa != null
                  ? PdvTheme.accent.withOpacity(0.15)
                  : PdvTheme.danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: caixa != null
                    ? PdvTheme.accent.withOpacity(0.4)
                    : PdvTheme.danger.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  caixa != null ? Icons.lock_open : Icons.lock,
                  size: 16,
                  color: caixa != null ? PdvTheme.accent : PdvTheme.danger,
                ),
                const SizedBox(width: 6),
                Text(
                  caixa != null ? 'Caixa #${caixa.id}' : 'Caixa Fechado',
                  style: TextStyle(
                    color: caixa != null ? PdvTheme.accent : PdvTheme.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Cliente
          if (controller.clienteSelecionado != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: PdvTheme.card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 16, color: PdvTheme.accent),
                  const SizedBox(width: 6),
                  Text(
                    controller.clienteSelecionado!.nome,
                    style: const TextStyle(color: PdvTheme.textPrimary, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => controller.setCliente(null),
                    child: const Icon(Icons.close, size: 14, color: PdvTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          // Impressora toggle
          Tooltip(
            message: controller.impressoraAutomatica
                ? 'Impressora: Ligada'
                : 'Impressora: Desligada',
            child: IconButton(
              icon: Icon(
                Icons.print,
                color: controller.impressoraAutomatica
                    ? PdvTheme.accent
                    : PdvTheme.textSecondary,
                size: 20,
              ),
              onPressed: controller.toggleImpressoraAutomatica,
            ),
          ),
          const SizedBox(width: 8),
          // Operador
          if (usuario != null)
            Text(
              usuario.nome,
              style: const TextStyle(
                color: PdvTheme.textSecondary,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
}
