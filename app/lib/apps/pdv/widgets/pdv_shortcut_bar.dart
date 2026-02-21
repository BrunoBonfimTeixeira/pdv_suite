import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';

class PdvShortcutBar extends StatelessWidget {
  const PdvShortcutBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: PdvTheme.surface,
        border: Border(top: BorderSide(color: PdvTheme.border)),
      ),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ShortcutChip(tecla: 'F1', label: 'Abrir Caixa'),
            _ShortcutChip(tecla: 'F2', label: 'Fechar Caixa'),
            _ShortcutChip(tecla: 'F3', label: 'Produtos'),
            _ShortcutChip(tecla: 'F4', label: 'Pessoas'),
            _ShortcutChip(tecla: 'F5', label: 'Sangria'),
            _ShortcutChip(tecla: 'F6', label: 'Suprimento'),
            _ShortcutChip(tecla: 'F', label: 'Finalizar'),
            _ShortcutChip(tecla: 'D', label: 'Desconto'),
            _ShortcutChip(tecla: 'C', label: 'Cancelar'),
            _ShortcutChip(tecla: 'R', label: 'Reimprimir'),
            _ShortcutChip(tecla: 'I', label: 'Impressora'),
            _ShortcutChip(tecla: 'F10', label: 'Personalizar'),
          ],
        ),
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  final String tecla;
  final String label;
  const _ShortcutChip({required this.tecla, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: PdvTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: PdvTheme.accent.withOpacity(0.4)),
            ),
            child: Text(
              tecla,
              style: const TextStyle(
                color: PdvTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: PdvTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
