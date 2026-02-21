import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/conversao_um.dart';
import 'package:pdv_lanchonete/core/services/conversao_um_service.dart';
import 'package:pdv_lanchonete/core/services/produto_service.dart';

class AdminConversaoUmPage extends StatefulWidget {
  const AdminConversaoUmPage({super.key});

  @override
  State<AdminConversaoUmPage> createState() => _AdminConversaoUmPageState();
}

class _AdminConversaoUmPageState extends State<AdminConversaoUmPage> {
  final _buscaCtrl = TextEditingController();
  List<ProdutoResumo> _produtos = [];
  ProdutoResumo? _produtoSelecionado;
  List<ConversaoUm> _conversoes = [];
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
        p.descricao.toLowerCase().contains(q.toLowerCase()) ||
        p.id.toString() == q
      ).toList();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _buscando = false);
  }

  Future<void> _selecionarProduto(ProdutoResumo p) async {
    setState(() { _produtoSelecionado = p; _carregando = true; });
    try {
      _conversoes = await ConversaoUmService.listarPorProduto(p.id);
    } catch (_) {
      _conversoes = [];
    }
    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _dialog({ConversaoUm? editing}) async {
    if (_produtoSelecionado == null) return;
    final origemCtrl = TextEditingController(text: editing?.umOrigem ?? _produtoSelecionado!.unidadeMedida);
    final destinoCtrl = TextEditingController(text: editing?.umDestino ?? '');
    final fatorCtrl = TextEditingController(text: editing?.fatorMultiplicador.toString() ?? '1');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(editing == null ? 'Nova Conversão' : 'Editar Conversão'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: origemCtrl, decoration: const InputDecoration(labelText: 'UM Origem *')),
              const SizedBox(height: 12),
              TextField(controller: destinoCtrl, autofocus: true, decoration: const InputDecoration(labelText: 'UM Destino *', hintText: 'Ex: CX, PCT, DZ...')),
              const SizedBox(height: 12),
              TextField(
                controller: fatorCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Fator Multiplicador *', hintText: 'Ex: 12 (1 CX = 12 UN)'),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Exemplo: 1 CX = 12 UN → Origem: CX, Destino: UN, Fator: 12',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (origemCtrl.text.trim().isEmpty || destinoCtrl.text.trim().isEmpty) return;
              try {
                final data = {
                  'produto_id': _produtoSelecionado!.id,
                  'um_origem': origemCtrl.text.trim(),
                  'um_destino': destinoCtrl.text.trim(),
                  'fator_multiplicador': double.tryParse(fatorCtrl.text) ?? 1,
                };
                if (editing == null) {
                  await ConversaoUmService.criar(data);
                } else {
                  await ConversaoUmService.atualizar(editing.id, data);
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

    origemCtrl.dispose();
    destinoCtrl.dispose();
    fatorCtrl.dispose();

    if (result == true) _selecionarProduto(_produtoSelecionado!);
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/conversao-um";

    return AdminShell(
      currentRoute: route,
      subtitle: "Conversão de UM",
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
                        subtitle: Text('UM: ${p.unidadeMedida}', style: const TextStyle(fontSize: 12)),
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
                        Icon(Icons.swap_horiz, size: 64, color: Colors.grey[400]),
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
                                    '${_produtoSelecionado!.descricao} — ${_conversoes.length} conversão(ões)',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _dialog(),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Nova Conversão'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _conversoes.isEmpty
                                ? Center(child: Text('Nenhuma conversão cadastrada', style: TextStyle(color: Colors.grey[500])))
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _conversoes.length,
                                    itemBuilder: (_, i) {
                                      final c = _conversoes[i];
                                      return Card(
                                        child: ListTile(
                                          leading: const Icon(Icons.swap_horiz, color: Color(0xFF2563EB)),
                                          title: Text(
                                            '1 ${c.umOrigem} = ${c.fatorMultiplicador} ${c.umDestino}',
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _dialog(editing: c)),
                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                                onPressed: () async {
                                                  await ConversaoUmService.remover(c.id);
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
