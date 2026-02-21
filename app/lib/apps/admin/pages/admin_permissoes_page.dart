import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/permissao.dart';
import 'package:pdv_lanchonete/core/services/permissao_service.dart';

class AdminPermissoesPage extends StatefulWidget {
  const AdminPermissoesPage({super.key});

  @override
  State<AdminPermissoesPage> createState() => _AdminPermissoesPageState();
}

class _AdminPermissoesPageState extends State<AdminPermissoesPage> {
  String _perfilSelecionado = 'ADMIN';
  List<Permissao> _permissoes = [];
  bool _loading = true;
  bool _saving = false;

  final _perfis = ['ADMIN', 'OPERADOR'];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      _permissoes = await PermissaoService.listarPorPerfil(_perfilSelecionado);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _salvar(Permissao p, {bool? ler, bool? escrever, bool? excluir}) async {
    setState(() => _saving = true);
    try {
      await PermissaoService.atualizar(p.id, ler: ler, escrever: escrever, excluir: excluir);
      await _carregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  IconData _iconForModulo(String modulo) {
    switch (modulo) {
      case 'Produtos': return Icons.inventory_2;
      case 'Pessoas': return Icons.groups;
      case 'Vendas': return Icons.receipt;
      case 'Caixas': return Icons.point_of_sale;
      case 'Estoque': return Icons.warehouse;
      case 'Relatorios': return Icons.bar_chart;
      case 'NFe': return Icons.receipt_long;
      case 'OS': return Icons.build;
      case 'Backup': return Icons.storage;
      case 'Usuarios': return Icons.person;
      case 'Lojas': return Icons.store;
      case 'Cartoes': return Icons.credit_card;
      default: return Icons.extension;
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/permissoes";

    return AdminShell(
      currentRoute: route,
      subtitle: "Permissões",
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Perfil:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(width: 12),
                ..._perfis.map((p) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p),
                    selected: _perfilSelecionado == p,
                    onSelected: (sel) {
                      if (sel) {
                        setState(() => _perfilSelecionado = p);
                        _carregar();
                      }
                    },
                    selectedColor: const Color(0xFF2563EB).withOpacity(0.15),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _perfilSelecionado == p ? const Color(0xFF2563EB) : null,
                    ),
                  ),
                )),
                const Spacer(),
                if (_saving) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _permissoes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text('Nenhuma permissão encontrada',
                              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FixedColumnWidth(100),
                          2: FixedColumnWidth(100),
                          3: FixedColumnWidth(100),
                        },
                        border: TableBorder(
                          horizontalInside: BorderSide(color: Colors.grey[200]!),
                        ),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[100]),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('Módulo', style: TextStyle(fontWeight: FontWeight.w800)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('Ler', style: TextStyle(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('Escrever', style: TextStyle(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('Excluir', style: TextStyle(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                          ..._permissoes.map((p) => TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(_iconForModulo(p.modulo), size: 20, color: const Color(0xFF6B7280)),
                                    const SizedBox(width: 10),
                                    Text(p.modulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Center(
                                child: Checkbox(
                                  value: p.ler,
                                  onChanged: (v) => _salvar(p, ler: v),
                                  activeColor: const Color(0xFF16A34A),
                                ),
                              ),
                              Center(
                                child: Checkbox(
                                  value: p.escrever,
                                  onChanged: (v) => _salvar(p, escrever: v),
                                  activeColor: const Color(0xFF2563EB),
                                ),
                              ),
                              Center(
                                child: Checkbox(
                                  value: p.excluir,
                                  onChanged: (v) => _salvar(p, excluir: v),
                                  activeColor: const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
