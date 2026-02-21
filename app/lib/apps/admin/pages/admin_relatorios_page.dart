import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/services/report_service.dart';

class AdminRelatoriosPage extends StatefulWidget {
  const AdminRelatoriosPage({super.key});

  @override
  State<AdminRelatoriosPage> createState() => _AdminRelatoriosPageState();
}

class _AdminRelatoriosPageState extends State<AdminRelatoriosPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  DateTime _inicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fim = DateTime.now();

  List<VendaDiaria> _vendasDiarias = [];
  List<ReportItem> _topProdutos = [];
  List<ReportItem> _porCategoria = [];
  List<ReportItem> _porPagamento = [];
  List<ReportItem> _porOperador = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _carregar();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _carregar() async {
    setState(() => _loading = true);
    final ini = _fmt(_inicio);
    final fim = _fmt(_fim);

    try {
      final results = await Future.wait([
        ReportService.vendasPorPeriodo(ini, fim),
        ReportService.topProdutos(inicio: ini, fim: fim),
        ReportService.porCategoria(inicio: ini, fim: fim),
        ReportService.porPagamento(inicio: ini, fim: fim),
        ReportService.porOperador(inicio: ini, fim: fim),
      ]);
      _vendasDiarias = results[0] as List<VendaDiaria>;
      _topProdutos = results[1] as List<ReportItem>;
      _porCategoria = results[2] as List<ReportItem>;
      _porPagamento = results[3] as List<ReportItem>;
      _porOperador = results[4] as List<ReportItem>;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _selecionarDatas() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _inicio, end: _fim),
    );
    if (range != null) {
      _inicio = range.start;
      _fim = range.end;
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/relatorios";

    return AdminShell(
      currentRoute: route,
      subtitle: "Relatorios",
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _selecionarDatas,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text('${_fmt(_inicio)} a ${_fmt(_fim)}'),
                ),
                const SizedBox(width: 12),
                if (_loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Vendas'),
              Tab(text: 'Top Produtos'),
              Tab(text: 'Categorias'),
              Tab(text: 'Pagamentos'),
              Tab(text: 'Operadores'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildVendasTab(),
                _buildBarTab(_topProdutos, 'Produto'),
                _buildBarTab(_porCategoria, 'Categoria'),
                _buildBarTab(_porPagamento, 'Forma'),
                _buildBarTab(_porOperador, 'Operador'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendasTab() {
    if (_vendasDiarias.isEmpty) {
      return const Center(child: Text('Nenhuma venda no periodo.'));
    }

    final totalReceita = _vendasDiarias.fold<double>(0, (s, v) => s + v.receita);
    final totalQtd = _vendasDiarias.fold<int>(0, (s, v) => s + v.qtd);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _kpiCard('Total Vendas', totalQtd.toString(), Colors.blue),
            const SizedBox(width: 12),
            _kpiCard('Receita', 'R\$ ${totalReceita.toStringAsFixed(2)}', Colors.green),
            const SizedBox(width: 12),
            _kpiCard('Ticket Medio', totalQtd > 0 ? 'R\$ ${(totalReceita / totalQtd).toStringAsFixed(2)}' : '-', Colors.orange),
          ],
        ),
        const SizedBox(height: 16),
        ..._vendasDiarias.map((v) => Card(
              child: ListTile(
                leading: Text(v.data.substring(5), style: const TextStyle(fontWeight: FontWeight.w700)),
                title: Text('${v.qtd} vendas'),
                trailing: Text('R\$ ${v.receita.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            )),
      ],
    );
  }

  Widget _buildBarTab(List<ReportItem> items, String label) {
    if (items.isEmpty) return const Center(child: Text('Sem dados no periodo.'));

    final maxTotal = items.map((i) => i.total).reduce((a, b) => a > b ? a : b);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final pct = maxTotal > 0 ? item.total / maxTotal : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700))),
                  Text('R\$ ${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 16,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(Colors.primaries[i % Colors.primaries.length]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kpiCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
