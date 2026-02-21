import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/tabela_nutricional_item.dart';
import 'package:pdv_lanchonete/core/services/tabela_nutricional_service.dart';
import 'package:pdv_lanchonete/core/services/produto_service.dart';

class AdminTabelaNutricionalPage extends StatefulWidget {
  const AdminTabelaNutricionalPage({super.key});

  @override
  State<AdminTabelaNutricionalPage> createState() => _AdminTabelaNutricionalPageState();
}

class _AdminTabelaNutricionalPageState extends State<AdminTabelaNutricionalPage> {
  final _buscaCtrl = TextEditingController();
  List<ProdutoResumo> _produtos = [];
  ProdutoResumo? _produtoSelecionado;
  TabelaNutricionalItem? _nutri;
  bool _buscando = false;
  bool _carregando = false;
  bool _salvando = false;

  final _porcaoCtrl = TextEditingController();
  final _energiaCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _protCtrl = TextEditingController();
  final _gordTotCtrl = TextEditingController();
  final _gordSatCtrl = TextEditingController();
  final _gordTransCtrl = TextEditingController();
  final _fibrasCtrl = TextEditingController();
  final _sodioCtrl = TextEditingController();

  @override
  void dispose() {
    _buscaCtrl.dispose();
    _porcaoCtrl.dispose();
    _energiaCtrl.dispose();
    _carbCtrl.dispose();
    _protCtrl.dispose();
    _gordTotCtrl.dispose();
    _gordSatCtrl.dispose();
    _gordTransCtrl.dispose();
    _fibrasCtrl.dispose();
    _sodioCtrl.dispose();
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
      _nutri = await TabelaNutricionalService.buscarPorProduto(p.id);
      _preencherForm();
    } catch (_) {
      _nutri = null;
      _limparForm();
    }
    if (mounted) setState(() => _carregando = false);
  }

  void _preencherForm() {
    final n = _nutri;
    _porcaoCtrl.text = n?.porcao ?? '';
    _energiaCtrl.text = n?.energiaKcal.toString() ?? '0';
    _carbCtrl.text = n?.carboidratos.toString() ?? '0';
    _protCtrl.text = n?.proteinas.toString() ?? '0';
    _gordTotCtrl.text = n?.gordurasTotais.toString() ?? '0';
    _gordSatCtrl.text = n?.gordurasSaturadas.toString() ?? '0';
    _gordTransCtrl.text = n?.gordurasTrans.toString() ?? '0';
    _fibrasCtrl.text = n?.fibras.toString() ?? '0';
    _sodioCtrl.text = n?.sodio.toString() ?? '0';
  }

  void _limparForm() {
    for (final c in [_porcaoCtrl, _energiaCtrl, _carbCtrl, _protCtrl, _gordTotCtrl, _gordSatCtrl, _gordTransCtrl, _fibrasCtrl, _sodioCtrl]) {
      c.clear();
    }
  }

  Future<void> _salvar() async {
    if (_produtoSelecionado == null) return;
    setState(() => _salvando = true);
    try {
      await TabelaNutricionalService.salvar({
        'produto_id': _produtoSelecionado!.id,
        'porcao': _porcaoCtrl.text.trim(),
        'unidade_porcao': 'g',
        'energia_kcal': double.tryParse(_energiaCtrl.text) ?? 0,
        'carboidratos': double.tryParse(_carbCtrl.text) ?? 0,
        'proteinas': double.tryParse(_protCtrl.text) ?? 0,
        'gorduras_totais': double.tryParse(_gordTotCtrl.text) ?? 0,
        'gorduras_saturadas': double.tryParse(_gordSatCtrl.text) ?? 0,
        'gorduras_trans': double.tryParse(_gordTransCtrl.text) ?? 0,
        'fibras': double.tryParse(_fibrasCtrl.text) ?? 0,
        'sodio': double.tryParse(_sodioCtrl.text) ?? 0,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tabela nutricional salva!'), backgroundColor: Color(0xFF16A34A)),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _salvando = false);
  }

  Widget _nutriField(String label, TextEditingController ctrl, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            flex: 3,
            child: TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(suffixText: unit, isDense: true),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/tabela-nutricional";

    return AdminShell(
      currentRoute: route,
      subtitle: "Tabela Nutricional",
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
                        Icon(Icons.table_chart_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('Selecione um produto', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  )
                : _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Produto: ${_produtoSelecionado!.descricao}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('INFORMAÇÃO NUTRICIONAL',
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                  const Divider(thickness: 2),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        const Expanded(flex: 2, child: Text('Porção', style: TextStyle(fontWeight: FontWeight.w600))),
                                        Expanded(
                                          flex: 3,
                                          child: TextField(
                                            controller: _porcaoCtrl,
                                            decoration: const InputDecoration(hintText: 'Ex: 100g, 200ml', isDense: true),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                  _nutriField('Energia', _energiaCtrl, 'kcal'),
                                  _nutriField('Carboidratos', _carbCtrl, 'g'),
                                  _nutriField('Proteínas', _protCtrl, 'g'),
                                  _nutriField('Gorduras Totais', _gordTotCtrl, 'g'),
                                  _nutriField('Gorduras Saturadas', _gordSatCtrl, 'g'),
                                  _nutriField('Gorduras Trans', _gordTransCtrl, 'g'),
                                  _nutriField('Fibras', _fibrasCtrl, 'g'),
                                  _nutriField('Sódio', _sodioCtrl, 'mg'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _salvando ? null : _salvar,
                                icon: _salvando
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.save),
                                label: const Text('Salvar Tabela Nutricional'),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
