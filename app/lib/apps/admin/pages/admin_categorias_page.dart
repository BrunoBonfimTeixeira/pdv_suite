import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/categoria.dart';
import 'package:pdv_lanchonete/core/services/categoria_service.dart';

class AdminCategoriasPage extends StatefulWidget {
  const AdminCategoriasPage({super.key});

  @override
  State<AdminCategoriasPage> createState() => _AdminCategoriasPageState();
}

class _AdminCategoriasPageState extends State<AdminCategoriasPage> {
  List<Categoria> _categorias = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      _categorias = await CategoriaService.listar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _dialog({Categoria? editing}) async {
    final descCtrl = TextEditingController(text: editing?.descricao ?? '');
    final corCtrl = TextEditingController(text: editing?.cor ?? '#607D8B');
    bool ativo = editing?.ativo ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(editing == null ? 'Nova Categoria' : 'Editar Categoria'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Descricao *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: corCtrl,
                  decoration: const InputDecoration(labelText: 'Cor (hex)', hintText: '#607D8B'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Ativo'),
                  value: ativo,
                  onChanged: (v) => setStateDialog(() => ativo = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final desc = descCtrl.text.trim();
                if (desc.isEmpty) return;
                try {
                  if (editing == null) {
                    await CategoriaService.criar(descricao: desc, cor: corCtrl.text.trim(), ativo: ativo);
                  } else {
                    await CategoriaService.atualizar(id: editing.id, descricao: desc, cor: corCtrl.text.trim(), ativo: ativo);
                  }
                  Navigator.pop(ctx, true);
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Erro: $e')));
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    descCtrl.dispose();
    corCtrl.dispose();

    if (result == true) _carregar();
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/categorias";

    return AdminShell(
      currentRoute: route,
      subtitle: "Categorias",
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('${_categorias.length} categorias', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _dialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nova Categoria'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categorias.length,
                    itemBuilder: (context, i) {
                      final c = _categorias[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: _parseColor(c.cor), radius: 18),
                          title: Text(c.descricao, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('ID: ${c.id} | ${c.ativo ? "Ativo" : "Inativo"}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _dialog(editing: c)),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () async {
                                  await CategoriaService.remover(c.id);
                                  _carregar();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
