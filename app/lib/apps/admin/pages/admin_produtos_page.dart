import 'dart:async';
import 'package:flutter/material.dart';

import 'package:pdv_lanchonete/apps/admin/admin_colors.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/produto.dart';
import 'package:pdv_lanchonete/core/services/admin_produtos_service.dart';
import 'produto_form_page.dart';

class AdminProdutosPage extends StatefulWidget {
  const AdminProdutosPage({super.key});

  @override
  State<AdminProdutosPage> createState() => _AdminProdutosPageState();
}

enum ProdutosFilter { ativos, inativos, todos }

class _AdminProdutosPageState extends State<AdminProdutosPage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  bool _loading = true;
  String? _error;

  ProdutosFilter _filter = ProdutosFilter.ativos;

  List<Produto> _all = [];
  List<Produto> _filtered = [];

  @override
  void initState() {
    super.initState();
    _carregar();

    _searchCtrl.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 240), _aplicarFiltro);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // =========================
  // DATA
  // =========================
  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final lista = await AdminProdutosService.listar();
      if (!mounted) return;
      _all = lista;
      _aplicarFiltro();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _aplicarFiltro() {
    final q = _searchCtrl.text.trim().toLowerCase();
    Iterable<Produto> base = _all;

    switch (_filter) {
      case ProdutosFilter.ativos:
        base = base.where((p) => p.ativo);
        break;
      case ProdutosFilter.inativos:
        base = base.where((p) => !p.ativo);
        break;
      case ProdutosFilter.todos:
        break;
    }

    if (q.isEmpty) {
      setState(() => _filtered = base.toList());
      return;
    }

    setState(() {
      _filtered = base.where((p) {
        final cb = (p.codigoBarras ?? '').toLowerCase();
        return p.id.toString().contains(q) ||
            p.descricao.toLowerCase().contains(q) ||
            cb.contains(q);
      }).toList();
    });
  }

  Future<void> _abrirForm({Produto? editing}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProdutoFormPage(editing: editing)),
    );
    if (changed == true) _carregar();
  }

  Future<void> _toggleAtivo(Produto p, bool ativo) async {
    final old = p.ativo;

    setState(() {
      _all = _all.map((x) => x.id == p.id ? x.copyWith(ativo: ativo) : x).toList();
    });
    _aplicarFiltro();

    try {
      await AdminProdutosService.atualizar(id: p.id, ativo: ativo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto #${p.id} atualizado.')),
      );
    } catch (e) {
      setState(() {
        _all = _all.map((x) => x.id == p.id ? x.copyWith(ativo: old) : x).toList();
      });
      _aplicarFiltro();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _removerSoft(Produto p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Inativar produto #${p.id}?'),
        content: const Text(
          'Recomendado: isso apenas inativa (soft-delete) para não quebrar histórico de vendas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Inativar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final oldList = List<Produto>.from(_all);

    setState(() {
      _all = _all.map((x) => x.id == p.id ? x.copyWith(ativo: false) : x).toList();
    });
    _aplicarFiltro();

    try {
      await AdminProdutosService.removerSoft(id: p.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto #${p.id} inativado.')),
      );
    } catch (e) {
      setState(() => _all = oldList);
      _aplicarFiltro();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void _goHomeAdmin() {
    Navigator.pushReplacementNamed(context, "/admin/home");
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/produtos";

    return AdminShell(
      currentRoute: route,
      subtitle: "Produtos",
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        child: Column(
            children: [
              const SizedBox(height: 6),
              _HeroHeader(
                navy: AdminColors.navy,
                teal: AdminColors.teal,
                totalAll: _all.length,
                totalFiltered: _filtered.length,
                filter: _filter,
                onFilterChanged: (f) {
                  setState(() => _filter = f);
                  _aplicarFiltro();
                },
                searchCtrl: _searchCtrl,
                onClearSearch: () {
                  _searchCtrl.clear();
                  _aplicarFiltro();
                },
                onNovo: () => _abrirForm(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _loading
                      ? const _CenterLoader()
                      : (_error != null)
                      ? _StateCard(
                    icon: Icons.error_outline_rounded,
                    title: "Falha ao carregar",
                    subtitle: _error!,
                    actionLabel: "Tentar novamente",
                    onAction: _carregar,
                  )
                      : (_filtered.isEmpty)
                      ? _StateCard(
                    icon: Icons.inventory_2_outlined,
                    title: "Nada por aqui",
                    subtitle:
                    "Nenhum produto encontrado com os filtros atuais. Tente buscar por outro termo ou cadastre um novo produto.",
                    actionLabel: "Cadastrar produto",
                    onAction: () => _abrirForm(),
                  )
                      : _ProdutosTableCard(
                    navy: AdminColors.navy,
                    teal: AdminColors.teal,
                    items: _filtered,
                    onEdit: (p) => _abrirForm(editing: p),
                    onToggleAtivo: _toggleAtivo,
                    onSoftRemove: _removerSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

// =========================== COMPONENTS ===========================

class _HeroHeader extends StatelessWidget {
  final Color navy;
  final Color teal;
  final int totalAll;
  final int totalFiltered;
  final ProdutosFilter filter;
  final ValueChanged<ProdutosFilter> onFilterChanged;

  final TextEditingController searchCtrl;
  final VoidCallback onClearSearch;
  final VoidCallback onNovo;

  const _HeroHeader({
    required this.navy,
    required this.teal,
    required this.totalAll,
    required this.totalFiltered,
    required this.filter,
    required this.onFilterChanged,
    required this.searchCtrl,
    required this.onClearSearch,
    required this.onNovo,
  });

  String _filterLabel(ProdutosFilter f) {
    switch (f) {
      case ProdutosFilter.ativos:
        return "Ativos";
      case ProdutosFilter.inativos:
        return "Inativos";
      case ProdutosFilter.todos:
        return "Todos";
    }
  }

  IconData _filterIcon(ProdutosFilter f) {
    switch (f) {
      case ProdutosFilter.ativos:
        return Icons.check_circle_outline_rounded;
      case ProdutosFilter.inativos:
        return Icons.remove_circle_outline_rounded;
      case ProdutosFilter.todos:
        return Icons.layers_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AdminColors.a(navy, .08)),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            offset: const Offset(0, 14),
            color: AdminColors.a(Colors.black, .06),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AdminColors.a(teal, .16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminColors.a(teal, .35)),
                ),
                child: Icon(Icons.inventory_2_outlined, color: navy),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gestão de Produtos",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Busque, edite e controle o status com um clique",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              _Chip(
                icon: Icons.list_alt_rounded,
                text: "$totalFiltered / $totalAll",
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: onNovo,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Cadastrar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: navy,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SearchField(
                  controller: searchCtrl,
                  onClear: onClearSearch,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: ProdutosFilter.values.map((f) {
                    final selected = f == filter;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => onFilterChanged(f),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AdminColors.a(navy, .12)
                                  : Colors.transparent,
                            ),
                            boxShadow: selected
                                ? [
                              BoxShadow(
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                                color: AdminColors.a(Colors.black, .06),
                              )
                            ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _filterIcon(f),
                                size: 18,
                                color: selected ? navy : AdminColors.a(navy, .55),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _filterLabel(f),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: selected ? navy : AdminColors.a(navy, .70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _SearchField({required this.controller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: "Buscar por ID, descrição, código de barras…",
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: hasText
            ? IconButton(
          tooltip: "Limpar",
          icon: const Icon(Icons.close_rounded),
          onPressed: onClear,
        )
            : null,
        filled: true,
        fillColor: const Color(0xFFF6F8FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ProdutosTableCard extends StatelessWidget {
  final Color navy;
  final Color teal;
  final List<Produto> items;

  final void Function(Produto p) onEdit;
  final void Function(Produto p, bool ativo) onToggleAtivo;
  final void Function(Produto p) onSoftRemove;

  const _ProdutosTableCard({
    required this.navy,
    required this.teal,
    required this.items,
    required this.onEdit,
    required this.onToggleAtivo,
    required this.onSoftRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey("table"),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AdminColors.a(navy, .08)),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 14),
            color: AdminColors.a(Colors.black, .06),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(color: Color(0xFFF7F9FD)),
              child: Row(
                children: const [
                  Icon(Icons.table_rows_outlined, size: 18),
                  SizedBox(width: 8),
                  Text("Lista de produtos",
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: c.maxWidth),
                        child: DataTable(
                            dataRowMinHeight: 58,
                            dataRowMaxHeight: 66,
                            columnSpacing: 18,
                            headingRowHeight: 50,
                            dividerThickness: 0.7,
                            headingRowColor: MaterialStateProperty.all(
                              const Color(0xFFF7F9FD),
                            ),
                            headingTextStyle: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AdminColors.a(navy, .85),
                            ),
                            columns: const [
                              DataColumn(label: Text("ID")),
                              DataColumn(label: Text("Descrição")),
                              DataColumn(label: Text("Preço")),
                              DataColumn(label: Text("Cód. Barras")),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("Ações")),
                            ],
                            rows: List.generate(items.length, (i) {
                              final p = items[i];
                              final zebra = i.isEven;

                              return DataRow(
                                color: MaterialStateProperty.all(
                                  zebra
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFFFBFCFF),
                                ),
                                onSelectChanged: (_) => onEdit(p),
                                cells: [
                                  DataCell(Text(
                                    p.id.toString(),
                                    style:
                                    const TextStyle(fontWeight: FontWeight.w900),
                                  )),
                                  DataCell(
                                    SizedBox(
                                      width: 380,
                                      child: Text(
                                        p.descricao,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: AdminColors.a(navy, .90),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(
                                    "R\$ ${p.preco.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: navy,
                                    ),
                                  )),
                                  DataCell(Text(p.codigoBarras ?? "-")),
                                  DataCell(
                                    Row(
                                      children: [
                                        _StatusPill(
                                          ativo: p.ativo,
                                          navy: navy,
                                          teal: teal,
                                        ),
                                        const SizedBox(width: 10),
                                        Switch.adaptive(
                                          value: p.ativo,
                                          onChanged: (v) => onToggleAtivo(p, v),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _RowActionsMenu(
                                        onEdit: () => onEdit(p),
                                        onToggle: () => onToggleAtivo(p, !p.ativo),
                                        onSoftRemove: () => onSoftRemove(p),
                                        isAtivo: p.ativo,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    );
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowActionsMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onSoftRemove;
  final bool isAtivo;

  const _RowActionsMenu({
    required this.onEdit,
    required this.onToggle,
    required this.onSoftRemove,
    required this.isAtivo,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: "Ações",
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: 1,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.edit_outlined),
            title: Text("Editar"),
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            dense: true,
            leading:
            Icon(isAtivo ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            title: Text(isAtivo ? "Inativar" : "Ativar"),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 3,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.delete_outline, color: Color(0xFFB42318)),
            title: Text(
              "Inativar (soft delete)",
              style: TextStyle(
                color: Color(0xFFB42318),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
      onSelected: (v) {
        if (v == 1) onEdit();
        if (v == 2) onToggle();
        if (v == 3) onSoftRemove();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: const Icon(Icons.more_horiz_rounded),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool ativo;
  final Color navy;
  final Color teal;

  const _StatusPill({
    required this.ativo,
    required this.navy,
    required this.teal,
  });

  @override
  Widget build(BuildContext context) {
    final bg = ativo ? AdminColors.a(teal, .16) : const Color(0xFFF2F4F7);
    final fg = ativo ? const Color(0xFF0F766E) : const Color(0xFF475467);
    final text = ativo ? "Ativo" : "Inativo";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminColors.a(fg, .20)),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w900, color: fg),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.teal,
        foregroundColor: AdminColors.navy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _IconSurface extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _IconSurface({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 6),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AdminColors.a(Colors.white, .85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AdminColors.a(AdminColors.navy, .10)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  color: AdminColors.a(Colors.black, .05),
                ),
              ],
            ),
            child: Icon(icon, color: AdminColors.navy),
          ),
        ),
      ),
    );
  }
}

class _CenterLoader extends StatelessWidget {
  const _CenterLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _StateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      key: ValueKey(title),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                blurRadius: 26,
                offset: const Offset(0, 14),
                color: AdminColors.a(Colors.black, .06),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: Colors.black38),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.teal,
                  foregroundColor: AdminColors.navy,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
