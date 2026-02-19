import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/core/models/produto.dart';
import 'package:pdv_lanchonete/core/services/admin_produtos_service.dart';

class ProdutoFormPage extends StatefulWidget {
  final Produto? editing;
  const ProdutoFormPage({super.key, this.editing});

  @override
  State<ProdutoFormPage> createState() => _ProdutoFormPageState();
}

class _ProdutoFormPageState extends State<ProdutoFormPage>
    with TickerProviderStateMixin {
  // ===== Paleta moderna
  static const Color _navy = Color(0xFF0B1F3B);
  static const Color _teal = Color(0xFF1EC9A5);
  static const Color _bg = Color(0xFFF4F7FB);

  late final TabController _tab;

  // ===== Campos do backend atual
  final _desc = TextEditingController();
  final _preco = TextEditingController();
  final _codigoBarras = TextEditingController();
  bool _ativo = true;

  // ===== Código (ID) travado
  final _codigoId = TextEditingController();

  // ===== Campos “ERP”
  final _descricaoReduzida = TextEditingController();
  String _um = "UN";

  // Estoque
  bool _controlarEstoque = false;
  final _estoqueMin = TextEditingController(text: "0,000");
  final _estoqueAtual = TextEditingController(text: "0,000");

  // Formação de preço (agora no Geral)
  final _precoCusto = TextEditingController(text: "0,00");
  final _markup = TextEditingController(text: "0,00");
  final _margem = TextEditingController(text: "0,00");

  // Fiscal/Config
  final _ncm = TextEditingController();
  final _cest = TextEditingController();
  final _cfop = TextEditingController();
  final _observacoes = TextEditingController();

  bool _saving = false;

  // evita recálculo em loop (digitando em custo/markup/margem/venda)
  bool _lockAuto = false;

  // lembra qual campo foi editado por último
  // "markup" | "margem" | "venda" | ""
  String _lastPriceDriver = "";

  @override
  void initState() {
    super.initState();

    // ✅ removi "Preços" => agora são 5 tabs
    _tab = TabController(length: 5, vsync: this);

    final p = widget.editing;
    if (p != null) {
      _codigoId.text = p.id.toString(); // ✅ Código = ID (travado)
      _desc.text = p.descricao;
      _preco.text = p.preco.toStringAsFixed(2).replaceAll(".", ",");
      _codigoBarras.text = p.codigoBarras ?? "";
      _ativo = p.ativo;

      _precoCusto.text =
          (p.precoCusto ?? 0).toStringAsFixed(2).replaceAll(".", ",");
      _markup.text = (p.markup ?? 0).toStringAsFixed(2).replaceAll(".", ",");
      _margem.text = (p.margem ?? 0).toStringAsFixed(2).replaceAll(".", ",");
    } else {
      _codigoId.text = "Automático";
    }

    // ✅ UI (Resumo) conforme digita
    for (final c in [
      _desc,
      _preco,
      _codigoBarras,
      _codigoId,
      _descricaoReduzida,
      _estoqueMin,
      _estoqueAtual,
      _precoCusto,
      _markup,
      _margem,
      _ncm,
      _cest,
      _cfop,
      _observacoes,
    ]) {
      c.addListener(_softRefresh);
    }
  }

  void _softRefresh() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tab.dispose();
    _desc.dispose();
    _preco.dispose();
    _codigoBarras.dispose();
    _codigoId.dispose();
    _descricaoReduzida.dispose();
    _estoqueMin.dispose();
    _estoqueAtual.dispose();
    _precoCusto.dispose();
    _markup.dispose();
    _margem.dispose();
    _ncm.dispose();
    _cest.dispose();
    _cfop.dispose();
    _observacoes.dispose();
    super.dispose();
  }

  double _parseNum(String s) =>
      double.tryParse(s.replaceAll(".", "").replaceAll(",", ".")) ?? 0.0;

  String _fmtMoney(double v) => v.toStringAsFixed(2).replaceAll(".", ",");

  void _setTextSafe(TextEditingController ctrl, String value) {
    _lockAuto = true;
    ctrl.text = value;
    ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
    _lockAuto = false;
  }

  // ====== Fórmulas
  // Markup (%) = (venda - custo)/custo * 100
  // Margem (%) = (venda - custo)/venda * 100
  // venda = custo*(1+mk/100)
  // venda = custo/(1-mg/100)

  void _recalcFromMarkup() {
    if (_lockAuto) return;
    _lastPriceDriver = "markup";

    final custo = _parseNum(_precoCusto.text);
    final mk = _parseNum(_markup.text);
    if (custo <= 0.0) return;

    final venda = custo * (1.0 + mk / 100.0);
    final mg = venda > 0.0 ? ((venda - custo) / venda) * 100.0 : 0.0;

    _setTextSafe(_preco, _fmtMoney(venda));
    _setTextSafe(_margem, _fmtMoney(mg));
  }

  void _recalcFromMargem() {
    if (_lockAuto) return;
    _lastPriceDriver = "margem";

    final custo = _parseNum(_precoCusto.text);
    final mg = _parseNum(_margem.text);
    if (custo <= 0.0) return;

    final fator = 1.0 - (mg / 100.0);
    if (fator <= 0.0) return;

    final venda = custo / fator;
    final mk = ((venda - custo) / custo) * 100.0;

    _setTextSafe(_preco, _fmtMoney(venda));
    _setTextSafe(_markup, _fmtMoney(mk));
  }

  /// ✅ quando o usuário mexe DIRETO no preço venda, recalcula markup/margem
  /// (e também quando muda custo com venda já preenchida)
  void _recalcFromVenda() {
    if (_lockAuto) return;
    _lastPriceDriver = "venda";

    final custo = _parseNum(_precoCusto.text);
    final venda = _parseNum(_preco.text);

    if (custo <= 0.0 || venda <= 0.0) return;

    final mk = ((venda - custo) / custo) * 100.0;
    final mg = ((venda - custo) / venda) * 100.0;

    _setTextSafe(_markup, _fmtMoney(mk));
    _setTextSafe(_margem, _fmtMoney(mg));
  }

  void _recalcWhenCustoChanges() {
    if (_lockAuto) return;

    // ✅ se já existe venda preenchida, a prioridade é recalcular markup/margem automaticamente
    final venda = _parseNum(_preco.text);
    if (venda > 0.0) {
      _recalcFromVenda();
      return;
    }

    // senão, mantém o comportamento de recalcular conforme o último "driver"
    if (_lastPriceDriver == "markup") {
      _recalcFromMarkup();
    } else if (_lastPriceDriver == "margem") {
      _recalcFromMargem();
    }
  }

  Future<bool> _checkBarcodeAndMaybeOpen() async {
    final barras = _codigoBarras.text.trim();
    if (barras.isEmpty) return true;

    // procura na API
    final found = await AdminProdutosService.buscarPorCodigoBarras(barras);
    if (found == null) return true;

    // se estou editando o MESMO produto, ok
    if (widget.editing != null && found.id == widget.editing!.id) {
      return true;
    }

    if (!mounted) return false;

    final open = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Código de barras já existe"),
        content: Text(
          "Esse código já está cadastrado no produto:\n\n"
              "• ID: ${found.id}\n"
              "• ${found.descricao}\n\n"
              "Deseja abrir esse produto?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Abrir produto"),
          ),
        ],
      ),
    );

    if (open == true) {
      // volta informando que quer abrir o produto existente
      Navigator.pop(context, {
        'action': 'open_product',
        'id': found.id,
      });
    }

    return false; // bloqueia o save
  }


  Future<void> _save() async {
    // ✅ impede duplicidade de código de barras e oferece abrir
    final okDup = await _checkBarcodeAndMaybeOpen();
    if (!okDup) return;

    final descricao = _desc.text.trim();
    final precoVenda = _parseNum(_preco.text);

    // ✅ obrigatório
    final barras = _codigoBarras.text.trim();

    final precoCusto = _parseNum(_precoCusto.text);
    final markup = _parseNum(_markup.text);
    final margem = _parseNum(_margem.text);

    if (descricao.isEmpty || precoVenda <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Descrição e preço de venda válidos são obrigatórios."),
        ),
      );
      return;
    }

    if (barras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código de barras é obrigatório.")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      if (widget.editing == null) {
        await AdminProdutosService.criar(
          descricao: descricao,
          preco: precoVenda,
          codigoBarras: barras,
          ativo: _ativo,
          precoCusto: precoCusto > 0 ? precoCusto : null,
          markup: markup != 0 ? markup : null,
          margem: margem != 0 ? margem : null,
        );
      } else {
        await AdminProdutosService.atualizar(
          id: widget.editing!.id,
          descricao: descricao,
          preco: precoVenda,
          codigoBarras: barras,
          ativo: _ativo,
          precoCusto: precoCusto > 0 ? precoCusto : null,
          markup: markup != 0 ? markup : null,
          margem: margem != 0 ? margem : null,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString();
      if (msg.contains("Rota não encontrada") ||
          msg.contains("404") ||
          msg.toLowerCase().contains("not found")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "⚠️ Sua API ainda não tem as rotas ADMIN de produtos.\n"
                  "Crie /admin/produtos (GET/POST/PATCH/DELETE) para salvar.",
            ),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editing != null;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: Text(isEdit ? "Editar Produto" : "Cadastrar Produto"),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : () => Navigator.pop(context, false),
            icon: const Icon(Icons.close, color: Colors.white),
            label: const Text("Cancelar", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.save),
              label: Text(_saving ? "Salvando..." : "Salvar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: _navy,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isNarrow = c.maxWidth < 1100;

          final form = _mainForm(isNarrow: isNarrow);
          final side = _rightPanel(isNarrow: isNarrow);

          if (isNarrow) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                form,
                const SizedBox(height: 12),
                side,
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: form),
                const SizedBox(width: 14),
                SizedBox(width: 320, child: side),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _mainForm({required bool isNarrow}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(blurRadius: 24, color: Colors.black.withOpacity(.06))
        ],
      ),
      child: Column(
        children: [
          // Top fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              runSpacing: 12,
              spacing: 12,
              children: [
                _fieldBox(
                  label: "Código",
                  width: 130,
                  child: TextField(
                    controller: _codigoId,
                    enabled: false,
                    readOnly: true,
                  ),
                ),
                _fieldBox(
                  label: "Código de Barras *",
                  width: 220,
                  child: TextField(controller: _codigoBarras),
                ),
                _fieldBox(
                  label: "Descrição *",
                  width: isNarrow ? double.infinity : 420,
                  child: TextField(controller: _desc),
                ),
                _fieldBox(
                  label: "Descrição Reduzida",
                  width: 260,
                  child: TextField(controller: _descricaoReduzida),
                ),
                _fieldBox(
                  label: "UM",
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: _um,
                    items: const [
                      DropdownMenuItem(value: "UN", child: Text("UN")),
                      DropdownMenuItem(value: "KG", child: Text("KG")),
                      DropdownMenuItem(value: "LT", child: Text("LT")),
                    ],
                    onChanged: (v) => setState(() => _um = v ?? "UN"),
                  ),
                ),
                _fieldBox(
                  label: "Preço Venda *",
                  width: 160,
                  child: TextField(
                    controller: _preco,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _recalcFromVenda(), // ✅
                  ),
                ),
                SizedBox(
                  width: 210,
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Ativo"),
                    value: _ativo,
                    onChanged: (v) => setState(() => _ativo = v),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              labelColor: _navy,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                color: _teal.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(14),
              ),
              tabs: const [
                Tab(text: "Geral"),
                Tab(text: "Estoque"),
                Tab(text: "Fiscal"),
                Tab(text: "Config"),
                Tab(text: "Ingredientes"),
              ],
            ),
          ),
          const Divider(height: 1),

          SizedBox(
            height: 560,
            child: TabBarView(
              controller: _tab,
              children: [
                _tabGeral(),
                _tabEstoque(),
                _tabFiscal(),
                _tabConfig(),
                _tabIngredientes(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightPanel({required bool isNarrow}) {
    final venda = _parseNum(_preco.text);
    final custo = _parseNum(_precoCusto.text);
    final lucro = (venda > 0 && custo > 0) ? (venda - custo) : null;

    return Column(
      children: [
        _sideCard(
          title: "Resumo",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kv("Descrição", _desc.text.isEmpty ? "-" : _desc.text),
              _kv("Código barras",
                  _codigoBarras.text.isEmpty ? "-" : _codigoBarras.text),
              _kv("Venda", venda <= 0 ? "-" : "R\$ ${_fmtMoney(venda)}"),
              _kv("Custo", custo <= 0 ? "-" : "R\$ ${_fmtMoney(custo)}"),
              _kv("Lucro", (lucro == null) ? "-" : "R\$ ${_fmtMoney(lucro)}"),
              _kv("Status", _ativo ? "Ativo" : "Inativo"),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sideCard(
          title: "Atenções",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("• Fiscal, estoque e ingredientes estão prontos na UI."),
              SizedBox(height: 6),
              Text("• Para salvar tudo, sua API precisa ter rotas ADMIN."),
            ],
          ),
        ),
      ],
    );
  }

  // ====== Tabs

  Widget _tabGeral() {
    return _tabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Formação de preço"),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _fieldBox(
                label: "Preço custo",
                width: 220,
                child: TextField(
                  controller: _precoCusto,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recalcFromVenda(), // ✅ custo + venda => mk/mg
                ),
              ),
              _fieldBox(
                label: "Markup (%)",
                width: 220,
                child: TextField(
                  controller: _markup,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recalcFromMarkup(),
                ),
              ),
              _fieldBox(
                label: "Margem (%)",
                width: 220,
                child: TextField(
                  controller: _margem,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recalcFromMargem(),
                ),
              ),
              _fieldBox(
                label: "Preço venda",
                width: 220,
                child: TextField(
                  controller: _preco,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recalcFromVenda(), // ✅
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Dica: custo + venda calculam Markup/Margem automaticamente. "
                "Ou edite Markup/Margem para recalcular a venda.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          _sectionTitle("Informações gerais"),
          const SizedBox(height: 10),
          _fieldBox(
            label: "Observações internas",
            width: double.infinity,
            child: TextField(controller: _observacoes, maxLines: 4),
          ),
        ],
      ),
    );
  }

  Widget _tabEstoque() => _tabScroll(child: const SizedBox.shrink());
  Widget _tabFiscal() => _tabScroll(child: const SizedBox.shrink());
  Widget _tabConfig() => _tabScroll(child: const SizedBox.shrink());
  Widget _tabIngredientes() => _tabScroll(child: const SizedBox.shrink());

  // ====== UI helpers
  Widget _tabScroll({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _sectionTitle(String t) {
    return Text(t,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16));
  }

  Widget _fieldBox({
    required String label,
    required double width,
    required Widget child,
  }) {
    return SizedBox(
      width: width.isFinite ? width : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: _navy,
            ),
          ),
          const SizedBox(height: 6),
          Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF6F8FC),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _sideCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(blurRadius: 24, color: Colors.black.withOpacity(.06))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(color: Colors.black54))),
          const SizedBox(width: 8),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  Widget _pill(String label, bool on) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: on ? _teal.withOpacity(.18) : Colors.black12.withOpacity(.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: on ? _teal.withOpacity(.6) : Colors.black12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: on ? _navy : Colors.black54,
        ),
      ),
    );
  }
}
