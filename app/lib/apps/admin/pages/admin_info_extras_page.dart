import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/info_extra.dart';
import 'package:pdv_lanchonete/core/services/info_extra_service.dart';
import 'package:pdv_lanchonete/core/services/produto_service.dart';

class AdminInfoExtrasPage extends StatefulWidget {
  const AdminInfoExtrasPage({super.key});

  @override
  State<AdminInfoExtrasPage> createState() => _AdminInfoExtrasPageState();
}

class _AdminInfoExtrasPageState extends State<AdminInfoExtrasPage> {
  final _buscaCtrl = TextEditingController();
  List<ProdutoResumo> _produtos = [];
  ProdutoResumo? _produtoSelecionado;
  List<InfoExtra> _extras = [];
  bool _buscando = false;
  bool _carregando = false;

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscarProdutos() async {
    final q = _buscaCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _buscando = true);
    try {
      final all = await ProdutoService.listar();
      _produtos = all.where((p) =>
        p.descricao.toLowerCase().contains(q.toLowerCase()) || p.id.toString() == q
      ).toList();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _buscando = false);
  }

  Future<void> _selecionarProduto(ProdutoResumo p) async {
    setState(() { _produtoSelecionado = p; _carregando = true; });
    try {
      _extras = await InfoExtraService.listarPorProduto(p.id);
    } catch (_) {
      _extras = [];
    }
    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _dialog({InfoExtra? editing}) async {
    if (_produtoSelecionado == null) return;
    final chaveCtrl = TextEditingController(text: editing?.chave ?? '');
    final valorCtrl = TextEditingController(text: editing?.valor ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(editing == null ? 'Nova Informação Extra' : 'Editar Informação'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: chaveCtrl, autofocus: true, decoration: const InputDecoration(labelText: 'Chave *', hintText: 'Ex: Marca, Fabricante, Cor...')),
              const SizedBox(height: 12),
              TextField(controller: valorCtrl, decoration: const InputDecoration(labelText: 'Valor *'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (chaveCtrl.text.trim().isEmpty) return;
              try {
                final data = {
                  'produto_id': _produtoSelecionado!.id,
                  'chave': chaveCtrl.text.trim(),
                  'valor': valorCtrl.text.trim(),
                };
                if (editing == null) {
                  await InfoExtraService.criar(data);
                } else {
                  await InfoExtraService.atualizar(editing.id, data);
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
    );

    chaveCtrl.dispose();
    valorCtrl.dispose();
    if (result == true) _selecionarProduto(_produtoSelecionado!);
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/info-extras";

    return AdminShell(
      currentRoute: route,
      subtitle: "Informações Extras",
      child: Row(
        children: [
          SizedBox(
            width: 320,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _buscaCtrl,
                          decoration: InputDecoration(
                            hintText: 'Buscar produto...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onSubmitted: (_) => _buscarProdutos(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _buscarProdutos,
                        icon: const Icon(Icons.search),
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ),
                if (_buscando) const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                Expanded(
                  child: ListView.builder(
                    itemCount: _produtos.length,
                    itemBuilder: (_, i) {
                      final p = _produtos[i];
                      final selected = _produtoSelecionado?.id == p.id;
                      return ListTile(
                        selected: selected,
                        selectedTileColor: const Color(0xFF2563EB).withOpacity(0.08),
                        title: Text(p.descricao, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        onTap: () => _selecionarProduto(p),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _produtoSelecionado == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('Selecione um produto', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  )
                : _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${_produtoSelecionado!.descricao} — ${_extras.length} info(s) extra(s)',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _dialog(),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Nova Info'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _extras.isEmpty
                                ? Center(child: Text('Nenhuma informação extra', style: TextStyle(color: Colors.grey[500])))
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _extras.length,
                                    itemBuilder: (_, i) {
                                      final e = _extras[i];
                                      return Card(
                                        child: ListTile(
                                          leading: const Icon(Icons.label_outline, color: Color(0xFF2563EB)),
                                          title: Text(e.chave, style: const TextStyle(fontWeight: FontWeight.w700)),
                                          subtitle: Text(e.valor),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _dialog(editing: e)),
                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                                onPressed: () async {
                                                  await InfoExtraService.remover(e.id);
                                                  _selecionarProduto(_produtoSelecionado!);
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
          ),
        ],
      ),
    );
  }
}
