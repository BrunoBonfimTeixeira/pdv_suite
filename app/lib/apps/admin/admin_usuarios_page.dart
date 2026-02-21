// lib/apps/admin/pages/admin_usuarios_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';
import 'package:pdv_lanchonete/core/services/admin_service.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  final _searchCtrl = TextEditingController();
  final _debouncer = _Debouncer(const Duration(milliseconds: 250));

  bool _loading = true;
  String? _error;

  List<Usuario> _all = [];
  List<Usuario> _filtered = [];

  // Filtros
  String _perfilFilter = 'TODOS'; // TODOS | ADMIN | OPERADOR
  bool _somenteAtivos = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      _debouncer.run(_applyFilters);
    });
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await AdminService.listarUsuarios();
      setState(() {
        _all = list;
        _loading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    final q = _searchCtrl.text.trim().toLowerCase();

    List<Usuario> out = List.of(_all);

    if (_perfilFilter != 'TODOS') {
      out = out.where((u) => (u.perfil ?? '').toUpperCase() == _perfilFilter).toList();
    }

    if (_somenteAtivos) {
      out = out.where((u) => u.ativo == true).toList();
    }

    if (q.isNotEmpty) {
      out = out.where((u) {
        final nome = (u.nome ?? '').toLowerCase();
        final login = (u.login ?? '').toLowerCase();
        final perfil = (u.perfil ?? '').toLowerCase();
        return nome.contains(q) || login.contains(q) || perfil.contains(q);
      }).toList();
    }

    // Ordena: ativos primeiro, depois nome
    out.sort((a, b) {
      final aa = (a.ativo == true) ? 0 : 1;
      final bb = (b.ativo == true) ? 0 : 1;
      final c1 = aa.compareTo(bb);
      if (c1 != 0) return c1;
      return (a.nome ?? '').compareTo(b.nome ?? '');
    });

    setState(() => _filtered = out);
  }

  Future<void> _toggleAtivo(Usuario u, bool value) async {
    final idx = _all.indexWhere((x) => x.id == u.id);
    if (idx < 0) return;

    final old = _all[idx];
    final updated = old.copyWith(ativo: value);

    setState(() {
      _all[idx] = updated;
      _applyFilters();
    });

    try {
      await AdminService.atualizarUsuario(id: u.id, ativo: value);
      if (!mounted) return;
      _snack('Usuário ${value ? "ativado" : "desativado"} com sucesso.');
    } catch (e) {
      setState(() {
        _all[idx] = old; // rollback
        _applyFilters();
      });
      if (!mounted) return;
      _snack('Falha ao atualizar: $e', isError: true);
    }
  }

  Future<void> _editarUsuario(Usuario u) async {
    final res = await showDialog<_EditResult>(
      context: context,
      builder: (_) => _EditUsuarioDialog(usuario: u),
    );
    if (res == null) return;

    final idx = _all.indexWhere((x) => x.id == u.id);
    if (idx < 0) return;

    final old = _all[idx];
    final updated = old.copyWith(
      nome: res.nome ?? old.nome,
      login: res.login ?? old.login,
      perfil: (res.perfil ?? old.perfil).toUpperCase(),
    );

    setState(() {
      _all[idx] = updated;
      _applyFilters();
    });

    try {
      await AdminService.atualizarUsuario(
        id: u.id,
        nome: res.nome,
        login: res.login,
        perfil: res.perfil,
      );
      if (!mounted) return;
      _snack('Usuário atualizado.');
    } catch (e) {
      setState(() {
        _all[idx] = old; // rollback
        _applyFilters();
      });
      if (!mounted) return;
      _snack('Falha ao atualizar: $e', isError: true);
    }
  }


  Future<void> _criarUsuario() async {
    final res = await showDialog<_CreateResult>(
      context: context,
      builder: (_) => const _CriarUsuarioDialog(),
    );
    if (res == null) return;

    try {
      await AdminService.criarUsuario(
        nome: res.nome,
        login: res.login,
        senha: res.senha,
        perfil: res.perfil,
      );
      if (!mounted) return;
      _snack('Usuario criado com sucesso.');
      _load();
    } catch (e) {
      if (!mounted) return;
      _snack('Erro: $e', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? cs.error : cs.inverseSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final route = ModalRoute.of(context)?.settings.name ?? "/admin/usuarios";

    return AdminShell(
      currentRoute: route,
      subtitle: "Usuários",
      child: Column(
        children: [
          // Action bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Text('${_filtered.length} usuário(s)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                IconButton(
                  tooltip: 'Atualizar',
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _criarUsuario,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Cadastrar'),
                ),
              ],
            ),
          ),
          // Top filters
          _Toolbar(
            searchCtrl: _searchCtrl,
            perfilFilter: _perfilFilter,
            somenteAtivos: _somenteAtivos,
            onPerfilChanged: (v) {
              setState(() => _perfilFilter = v);
              _applyFilters();
            },
            onSomenteAtivosChanged: (v) {
              setState(() => _somenteAtivos = v);
              _applyFilters();
            },
          ),

          Expanded(
            child: _loading
                ? const _UsersSkeleton()
                : (_error != null)
                ? _ErrorState(
              message: _error!,
              onRetry: _load,
            )
                : _filtered.isEmpty
                ? _EmptyState(
              title: 'Nenhum usuário encontrado',
              subtitle: 'Tente ajustar os filtros ou a busca.',
              onClear: () {
                _searchCtrl.clear();
                setState(() {
                  _perfilFilter = 'TODOS';
                  _somenteAtivos = false;
                });
                _applyFilters();
              },
            )
                : LayoutBuilder(
              builder: (context, c) {
                final isWide = c.maxWidth >= 900;
                if (isWide) {
                  return _UsersTable(
                    users: _filtered,
                    onEdit: _editarUsuario,
                    onToggleAtivo: _toggleAtivo,
                  );
                }
                return _UsersList(
                  users: _filtered,
                  onEdit: _editarUsuario,
                  onToggleAtivo: _toggleAtivo,
                );
              },
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cs.outlineVariant.withOpacity(.7))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} usuário(s)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  'Atualize pelo botão ⟳',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------- Toolbar -------------------- */

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.searchCtrl,
    required this.perfilFilter,
    required this.somenteAtivos,
    required this.onPerfilChanged,
    required this.onSomenteAtivosChanged,
  });

  final TextEditingController searchCtrl;
  final String perfilFilter;
  final bool somenteAtivos;
  final ValueChanged<String> onPerfilChanged;
  final ValueChanged<bool> onSomenteAtivosChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(.7))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          TextField(
            controller: searchCtrl,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar por nome, login ou perfil…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                tooltip: 'Limpar',
                onPressed: () => searchCtrl.clear(),
                icon: const Icon(Icons.close),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),

          // Filters row
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ChoiceChip(
                label: 'Todos',
                selected: perfilFilter == 'TODOS',
                onTap: () => onPerfilChanged('TODOS'),
              ),
              _ChoiceChip(
                label: 'Admin',
                selected: perfilFilter == 'ADMIN',
                onTap: () => onPerfilChanged('ADMIN'),
              ),
              _ChoiceChip(
                label: 'Operador',
                selected: perfilFilter == 'OPERADOR',
                onTap: () => onPerfilChanged('OPERADOR'),
              ),
              const SizedBox(width: 4),
              FilterChip(
                label: const Text('Somente ativos'),
                selected: somenteAtivos,
                onSelected: onSomenteAtivosChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

/* -------------------- Wide: DataTable -------------------- */

class _UsersTable extends StatelessWidget {
  const _UsersTable({
    required this.users,
    required this.onEdit,
    required this.onToggleAtivo,
  });

  final List<Usuario> users;
  final Future<void> Function(Usuario u) onEdit;
  final Future<void> Function(Usuario u, bool value) onToggleAtivo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: cs.outlineVariant.withOpacity(.6),
            ),
            child: DataTable(
              headingRowHeight: 46,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 64,
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Nome')),
                DataColumn(label: Text('Login')),
                DataColumn(label: Text('Perfil')),
                DataColumn(label: Text('Ativo')),
                DataColumn(label: Text('Ações')),
              ],
              rows: users.map((u) {
                final perfil = (u.perfil ?? '').toUpperCase();
                return DataRow(
                  cells: [
                    DataCell(Text('${u.id ?? '-'}')),
                    DataCell(Text(u.nome ?? '-')),
                    DataCell(Text(u.login ?? '-')),
                    DataCell(_PerfilBadge(perfil: perfil)),
                    DataCell(
                      Switch(
                        value: u.ativo == true,
                        onChanged: (v) => onToggleAtivo(u, v),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () => onEdit(u),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------- Narrow: List -------------------- */

class _UsersList extends StatelessWidget {
  const _UsersList({
    required this.users,
    required this.onEdit,
    required this.onToggleAtivo,
  });

  final List<Usuario> users;
  final Future<void> Function(Usuario u) onEdit;
  final Future<void> Function(Usuario u, bool value) onToggleAtivo;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final u = users[i];
        final perfil = (u.perfil ?? '').toUpperCase();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Text(
                    (u.nome?.trim().isNotEmpty ?? false) ? u.nome!.trim()[0].toUpperCase() : '?',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              u.nome ?? 'Sem nome',
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _PerfilBadge(perfil: perfil),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Login: ${u.login ?? '-'} • ID: ${u.id ?? '-'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Switch(
                            value: u.ativo == true,
                            onChanged: (v) => onToggleAtivo(u, v),
                          ),
                          const SizedBox(width: 8),
                          Text(u.ativo == true ? 'Ativo' : 'Inativo'),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => onEdit(u),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* -------------------- Badges -------------------- */

class _PerfilBadge extends StatelessWidget {
  const _PerfilBadge({required this.perfil});

  final String perfil;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final label = (perfil.isEmpty) ? '—' : perfil;
    final isAdmin = perfil == 'ADMIN';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAdmin ? cs.primaryContainer : cs.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isAdmin ? cs.onPrimaryContainer : cs.onSecondaryContainer,
          fontWeight: FontWeight.w700,
          letterSpacing: .3,
        ),
      ),
    );
  }
}

/* -------------------- Dialog Edit -------------------- */

class _EditUsuarioDialog extends StatefulWidget {
  const _EditUsuarioDialog({required this.usuario});

  final Usuario usuario;

  @override
  State<_EditUsuarioDialog> createState() => _EditUsuarioDialogState();
}

class _EditUsuarioDialogState extends State<_EditUsuarioDialog> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _loginCtrl;
  late String _perfil;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.usuario.nome ?? '');
    _loginCtrl = TextEditingController(text: widget.usuario.login ?? '');
    _perfil = (widget.usuario.perfil ?? 'OPERADOR').toUpperCase();
    if (_perfil != 'ADMIN' && _perfil != 'OPERADOR') _perfil = 'OPERADOR';
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _loginCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar usuário'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _loginCtrl,
              decoration: const InputDecoration(
                labelText: 'Login',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _perfil,
              items: const [
                DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                DropdownMenuItem(value: 'OPERADOR', child: Text('OPERADOR')),
              ],
              onChanged: (v) => setState(() => _perfil = v ?? 'OPERADOR'),
              decoration: const InputDecoration(
                labelText: 'Perfil',
                prefixIcon: Icon(Icons.admin_panel_settings_outlined),
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
        FilledButton(
          onPressed: () {
            final nome = _nomeCtrl.text.trim();
            final login = _loginCtrl.text.trim();
            Navigator.pop(
              context,
              _EditResult(
                nome: nome.isEmpty ? null : nome,
                login: login.isEmpty ? null : login,
                perfil: _perfil,
              ),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _EditResult {
  const _EditResult({this.nome, this.login, this.perfil});
  final String? nome;
  final String? login;
  final String? perfil;
}

class _EditSnapshot {
  final String nome;
  final String login;
  final String perfil;
  final bool ativo;

  const _EditSnapshot({
    required this.nome,
    required this.login,
    required this.perfil,
    required this.ativo,
  });

  factory _EditSnapshot.fromUsuario(Usuario u) => _EditSnapshot(
    nome: u.nome,
    login: u.login,
    perfil: u.perfil,
    ativo: u.ativo,
  );

  Usuario toUsuario(Usuario base) => base.copyWith(
    nome: nome.trim(),
    login: login.trim(),
    perfil: perfil.trim().toUpperCase(),
    ativo: ativo,
  );
}

/* -------------------- States -------------------- */

class _UsersSkeleton extends StatelessWidget {
  const _UsersSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const _ShimmerBox(width: 40, height: 40, radius: 999),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _ShimmerBox(width: 240, height: 14),
                      SizedBox(height: 8),
                      _ShimmerBox(width: 180, height: 12),
                      SizedBox(height: 12),
                      _ShimmerBox(width: 140, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 12,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        final base = cs.surfaceContainerHighest;
        final hi = cs.surfaceContainerHigh;
        final color = Color.lerp(base, hi, t) ?? base;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline),
                      const SizedBox(width: 10),
                      Text(
                        'Falha ao carregar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar de novo'),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onClear,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.manage_accounts_outlined, size: 40),
                  const SizedBox(height: 10),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: onClear,
                    child: const Text('Limpar filtros'),
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

/* -------------------- Utils -------------------- */

class _Debouncer {
  _Debouncer(this.duration);
  final Duration duration;
  Timer? _t;

  void run(VoidCallback fn) {
    _t?.cancel();
    _t = Timer(duration, fn);
  }

  void dispose() => _t?.cancel();
}

/* -------------------- Criar Usuário -------------------- */

class _CreateResult {
  final String nome;
  final String login;
  final String senha;
  final String perfil;

  _CreateResult({
    required this.nome,
    required this.login,
    required this.senha,
    required this.perfil,
  });
}

class _CriarUsuarioDialog extends StatefulWidget {
  const _CriarUsuarioDialog();

  @override
  State<_CriarUsuarioDialog> createState() => _CriarUsuarioDialogState();
}

class _CriarUsuarioDialogState extends State<_CriarUsuarioDialog> {
  final _nomeCtrl = TextEditingController();
  final _loginCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  String _perfil = 'OPERADOR';

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _loginCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Usuario'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome *'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _loginCtrl,
              decoration: const InputDecoration(labelText: 'Login *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _senhaCtrl,
              decoration: const InputDecoration(labelText: 'Senha *'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _perfil,
              decoration: const InputDecoration(labelText: 'Perfil'),
              items: const [
                DropdownMenuItem(value: 'OPERADOR', child: Text('Operador')),
                DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
              ],
              onChanged: (v) => setState(() => _perfil = v ?? 'OPERADOR'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final nome = _nomeCtrl.text.trim();
            final login = _loginCtrl.text.trim();
            final senha = _senhaCtrl.text.trim();
            if (nome.isEmpty || login.isEmpty || senha.isEmpty) return;
            Navigator.pop(
              context,
              _CreateResult(nome: nome, login: login, senha: senha, perfil: _perfil),
            );
          },
          child: const Text('Criar'),
        ),
      ],
    );
  }
}
