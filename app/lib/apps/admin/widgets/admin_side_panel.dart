import 'package:flutter/material.dart';

class AdminSidePanel extends StatefulWidget {
  final String currentRoute;
  const AdminSidePanel({super.key, required this.currentRoute});

  @override
  State<AdminSidePanel> createState() => _AdminSidePanelState();
}

class _AdminSidePanelState extends State<AdminSidePanel> {
  // Paleta moderna (azul + teal)
  static const Color _navBg = Color(0xFF0B1F3B);      // fundo geral
  static const Color _cardBg = Color(0xFF0E2A4D);     // “card” sidebar
  static const Color _subBg = Color(0xFF0A2342);      // submenu
  static const Color _accent = Color(0xFF1EC9A5);     // teal destaque
  static const Color _text = Colors.white;

  bool _cadastrosOpen = false;

  bool _isActive(String route) => widget.currentRoute == route;
  bool _isAnyActive(List<String> routes) => routes.contains(widget.currentRoute);

  void _go(BuildContext context, String route) {
    if (_isActive(route)) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final cadastrosRoutes = <String>[
      "/admin/pessoas",
      "/admin/produtos",
      "/admin/cartoes",
      "/admin/usuarios",
      "/admin/permissoes",
      "/admin/lojas",
      "/admin/info-fiscais",
      "/admin/conversao-um",
      "/admin/tabela-nutricional",
      "/admin/info-extras",
      "/admin/categorias",
    ];

    return Container(
      width: 292,
      color: _navBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 18,
                  offset: Offset(6, 6),
                ),
              ],
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const _Header(accent: _accent),
                  const SizedBox(height: 6),

                  // Scrollable nav area
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // GRUPO: CADASTROS (expansível)
                          _GroupTile(
                            icon: Icons.menu_book_outlined,
                            title: "Cadastros",
                            isOpen: _cadastrosOpen,
                            isHighlighted: _isAnyActive(cadastrosRoutes),
                            accent: _accent,
                            onTap: () => setState(() => _cadastrosOpen = !_cadastrosOpen),
                          ),

                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 180),
                            crossFadeState: _cadastrosOpen
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: Container(
                              margin: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                              decoration: BoxDecoration(
                                color: _subBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                children: [
                                  _SubItem(
                                    icon: Icons.groups_2_outlined,
                                    label: "Pessoas",
                                    active: _isActive("/admin/pessoas"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/pessoas"),
                                  ),
                                  _SubItem(
                                    icon: Icons.inventory_2_outlined,
                                    label: "Produtos",
                                    active: _isActive("/admin/produtos"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/produtos"),
                                  ),
                                  _SubItem(
                                    icon: Icons.credit_card_outlined,
                                    label: "Cartões",
                                    active: _isActive("/admin/cartoes"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/cartoes"),
                                  ),
                                  _SubItem(
                                    icon: Icons.person_outline,
                                    label: "Usuários",
                                    active: _isActive("/admin/usuarios"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/usuarios"),
                                  ),
                                  _SubItem(
                                    icon: Icons.lock_outline,
                                    label: "Permissões",
                                    active: _isActive("/admin/permissoes"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/permissoes"),
                                  ),
                                  _SubItem(
                                    icon: Icons.store_mall_directory_outlined,
                                    label: "Lojas",
                                    active: _isActive("/admin/lojas"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/lojas"),
                                  ),
                                  _SubItem(
                                    icon: Icons.receipt_long_outlined,
                                    label: "Informações Fiscais",
                                    active: _isActive("/admin/info-fiscais"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/info-fiscais"),
                                  ),
                                  _SubItem(
                                    icon: Icons.swap_horiz_outlined,
                                    label: "Conversão de UM",
                                    active: _isActive("/admin/conversao-um"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/conversao-um"),
                                  ),
                                  _SubItem(
                                    icon: Icons.table_chart_outlined,
                                    label: "Tabela Nutricional",
                                    active: _isActive("/admin/tabela-nutricional"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/tabela-nutricional"),
                                  ),
                                  _SubItem(
                                    icon: Icons.info_outline,
                                    label: "Informações Extras",
                                    active: _isActive("/admin/info-extras"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/info-extras"),
                                  ),
                                  _SubItem(
                                    icon: Icons.category_outlined,
                                    label: "Categorias",
                                    active: _isActive("/admin/categorias"),
                                    accent: _accent,
                                    onTap: () => _go(context, "/admin/categorias"),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            secondChild: const SizedBox.shrink(),
                          ),

                          // Itens principais (pill)
                          _NavItem(
                            icon: Icons.receipt_outlined,
                            label: "Vendas",
                            active: _isActive("/admin/vendas"),
                            accent: _accent,
                            onTap: () => _go(context, "/admin/vendas"),
                          ),
                          _NavItem(
                            icon: Icons.point_of_sale,
                            label: "Caixas",
                            active: _isActive("/admin/caixas"),
                            accent: _accent,
                            onTap: () => _go(context, "/admin/caixas"),
                          ),
                          _NavItem(
                            icon: Icons.payment,
                            label: "Formas de Pagamento",
                            active: _isActive("/admin/formas-pagamento"),
                            accent: _accent,
                            onTap: () => _go(context, "/admin/formas-pagamento"),
                          ),
                          _NavItem(
                            icon: Icons.inventory_2,
                            label: "Estoque",
                            active: _isActive("/admin/estoque"),
                            accent: _accent,
                            onTap: () => _go(context, "/admin/estoque"),
                          ),
                          _NavItem(
                            icon: Icons.bar_chart_outlined,
                            label: "Relatórios",
                            active: _isActive("/admin/relatorios"),
                            accent: _accent,
                            onTap: () => _go(context, "/admin/relatorios"),
                          ),
                          _NavItem(
                            icon: Icons.dashboard_outlined,
                            label: "Painel de Controle",
                            active: _isActive("/admin/home"),
                            accent: _accent,
                            onTap: () => _go(context, "/admin/home"),
                          ),
                          _NavItem(
                            icon: Icons.receipt_long_outlined,
                            label: "Nota Fiscal Eletrônica",
                            active: _isActive("/admin/nfe"),
                            accent: _accent,
                            onTap: () => _go(context, "/admin/nfe"),
                          ),
                          _NavItem(
                            icon: Icons.build_outlined,
                            label: "Ordem de Serviço",
                            active: _isActive("/admin/os"),
                            accent: _accent,
                            onTap: () => _go(context, "/admin/os"),
                          ),
                          _NavItem(
                            icon: Icons.storage_outlined,
                            label: "Backup BD",
                            active: _isActive("/admin/backup"),
                            accent: _accent,
                            onTap: () => _go(context, "/admin/backup"),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  const Divider(color: Colors.white12, height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                    child: _NavItem(
                      icon: Icons.logout,
                      label: "Sair",
                      active: false,
                      accent: _accent,
                      danger: true,
                      onTap: () => _go(context, "/admin/login"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Color accent;
  const _Header({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(.10),
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(Icons.storefront, color: accent),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Admin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: .2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isOpen;
  final bool isHighlighted;
  final VoidCallback onTap;
  final Color accent;

  const _GroupTile({
    required this.icon,
    required this.title,
    required this.isOpen,
    required this.isHighlighted,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isHighlighted ? Colors.white.withOpacity(.08) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isHighlighted ? Colors.white12 : Colors.transparent),
          ),
          child: Row(
            children: [
              _IconBubble(icon: icon, active: isHighlighted, accent: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                isOpen ? Icons.expand_less : Icons.expand_more,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color accent;
  final VoidCallback onTap;
  final bool danger;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.accent,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final pillBg = active ? accent.withOpacity(.18) : Colors.white.withOpacity(.06);
    final border = active ? accent.withOpacity(.55) : Colors.white10;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              _IconBubble(
                icon: icon,
                active: active,
                accent: accent,
                danger: danger,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.2,
                    fontWeight: danger ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color accent;

  const _SubItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? accent.withOpacity(.18) : Colors.transparent;
    final border = active ? accent.withOpacity(.50) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color accent;
  final bool danger;

  const _IconBubble({
    required this.icon,
    required this.active,
    required this.accent,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? accent.withOpacity(.22) : Colors.white.withOpacity(.10);
    final border = active ? accent.withOpacity(.60) : Colors.white10;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
