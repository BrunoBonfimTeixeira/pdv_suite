import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/info_fiscal.dart';
import 'package:pdv_lanchonete/core/services/info_fiscal_service.dart';
import 'package:pdv_lanchonete/core/services/produto_service.dart';

class AdminInfoFiscaisPage extends StatefulWidget {
  const AdminInfoFiscaisPage({super.key});

  @override
  State<AdminInfoFiscaisPage> createState() => _AdminInfoFiscaisPageState();
}

class _AdminInfoFiscaisPageState extends State<AdminInfoFiscaisPage> {
  final _buscaCtrl = TextEditingController();
  List<ProdutoResumo> _produtos = [];
  ProdutoResumo? _produtoSelecionado;
  InfoFiscal? _infoFiscal;
  bool _buscando = false;
  bool _carregando = false;
  bool _salvando = false;

  // Form controllers
  final _ncmCtrl = TextEditingController();
  final _cestCtrl = TextEditingController();
  final _cfopCtrl = TextEditingController();
  final _origemCtrl = TextEditingController();
  final _cstIcmsCtrl = TextEditingController();
  final _aliqIcmsCtrl = TextEditingController();
  final _cstPisCtrl = TextEditingController();
  final _aliqPisCtrl = TextEditingController();
  final _cstCofinsCtrl = TextEditingController();
  final _aliqCofinsCtrl = TextEditingController();

  @override
  void dispose() {
    _buscaCtrl.dispose();
    _ncmCtrl.dispose();
    _cestCtrl.dispose();
    _cfopCtrl.dispose();
    _origemCtrl.dispose();
    _cstIcmsCtrl.dispose();
    _aliqIcmsCtrl.dispose();
    _cstPisCtrl.dispose();
    _aliqPisCtrl.dispose();
    _cstCofinsCtrl.dispose();
    _aliqCofinsCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscarProdutos() async {
    final q = _buscaCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _buscando = true);
    try {
      _produtos = await ProdutoService.listar();
      _produtos = _produtos.where((p) =>
        p.descricao.toLowerCase().contains(q.toLowerCase()) ||
        p.id.toString() == q ||
        (p.codigoBarras?.contains(q) ?? false)
      ).toList();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _buscando = false);
  }

  Future<void> _selecionarProduto(ProdutoResumo p) async {
    setState(() {
      _produtoSelecionado = p;
      _carregando = true;
    });
    try {
      _infoFiscal = await InfoFiscalService.buscarPorProduto(p.id);
      _preencherForm();
    } catch (_) {
      _infoFiscal = null;
      _limparForm();
    }
    if (mounted) setState(() => _carregando = false);
  }

  void _preencherForm() {
    final f = _infoFiscal;
    _ncmCtrl.text = f?.ncm ?? '';
    _cestCtrl.text = f?.cest ?? '';
    _cfopCtrl.text = f?.cfop ?? '';
    _origemCtrl.text = f?.origem ?? '0';
    _cstIcmsCtrl.text = f?.cstIcms ?? '';
    _aliqIcmsCtrl.text = f?.aliqIcms.toString() ?? '0';
    _cstPisCtrl.text = f?.cstPis ?? '';
    _aliqPisCtrl.text = f?.aliqPis.toString() ?? '0';
    _cstCofinsCtrl.text = f?.cstCofins ?? '';
    _aliqCofinsCtrl.text = f?.aliqCofins.toString() ?? '0';
  }

  void _limparForm() {
    _ncmCtrl.clear();
    _cestCtrl.clear();
    _cfopCtrl.clear();
    _origemCtrl.text = '0';
    _cstIcmsCtrl.clear();
    _aliqIcmsCtrl.text = '0';
    _cstPisCtrl.clear();
    _aliqPisCtrl.text = '0';
    _cstCofinsCtrl.clear();
    _aliqCofinsCtrl.text = '0';
  }

  Future<void> _salvar() async {
    if (_produtoSelecionado == null) return;
    setState(() => _salvando = true);
    try {
      await InfoFiscalService.salvar({
        'produto_id': _produtoSelecionado!.id,
        'ncm': _ncmCtrl.text.trim(),
        'cest': _cestCtrl.text.trim(),
        'cfop': _cfopCtrl.text.trim(),
        'origem': _origemCtrl.text.trim(),
        'cst_icms': _cstIcmsCtrl.text.trim(),
        'aliq_icms': double.tryParse(_aliqIcmsCtrl.text) ?? 0,
        'cst_pis': _cstPisCtrl.text.trim(),
        'aliq_pis': double.tryParse(_aliqPisCtrl.text) ?? 0,
        'cst_cofins': _cstCofinsCtrl.text.trim(),
        'aliq_cofins': double.tryParse(_aliqCofinsCtrl.text) ?? 0,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informações fiscais salvas!'), backgroundColor: Color(0xFF16A34A)),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _salvando = false);
  }

  Widget _buildField(String label, TextEditingController ctrl, {bool isNumber = false, String? suffix}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : null,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/info-fiscais";

    return AdminShell(
      currentRoute: route,
      subtitle: "Informações Fiscais",
      child: Row(
        children: [
          // Left: product search
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
                if (_buscando) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                Expanded(
                  child: ListView.builder(
                    itemCount: _produtos.length,
                    itemBuilder: (_, i) {
                      final p = _produtos[i];
                      final selected = _produtoSelecionado?.id == p.id;
                      return ListTile(
                        selected: selected,
                        selectedTileColor: const Color(0xFF2563EB).withOpacity(0.08),
                        leading: CircleAvatar(
                          backgroundColor: selected ? const Color(0xFF2563EB) : Colors.grey[300],
                          child: Text('${p.id}', style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 12)),
                        ),
                        title: Text(p.descricao, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text('R\$ ${p.preco.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                        onTap: () => _selecionarProduto(p),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right: fiscal info form
          Expanded(
            child: _produtoSelecionado == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('Selecione um produto para editar informações fiscais',
                            style: TextStyle(color: Colors.grey[500], fontSize: 16)),
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
                              'Produto: ${_produtoSelecionado!.descricao} (ID: ${_produtoSelecionado!.id})',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            Row(children: [
                              Expanded(child: _buildField('NCM', _ncmCtrl)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildField('CEST', _cestCtrl)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildField('CFOP', _cfopCtrl)),
                            ]),
                            const SizedBox(height: 16),
                            _buildField('Origem', _origemCtrl),
                            const SizedBox(height: 20),
                            const Text('ICMS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(child: _buildField('CST ICMS', _cstIcmsCtrl)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildField('Alíquota ICMS', _aliqIcmsCtrl, isNumber: true, suffix: '%')),
                            ]),
                            const SizedBox(height: 20),
                            const Text('PIS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(child: _buildField('CST PIS', _cstPisCtrl)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildField('Alíquota PIS', _aliqPisCtrl, isNumber: true, suffix: '%')),
                            ]),
                            const SizedBox(height: 20),
                            const Text('COFINS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(child: _buildField('CST COFINS', _cstCofinsCtrl)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildField('Alíquota COFINS', _aliqCofinsCtrl, isNumber: true, suffix: '%')),
                            ]),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _salvando ? null : _salvar,
                                icon: _salvando
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.save),
                                label: const Text('Salvar Informações Fiscais'),
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
