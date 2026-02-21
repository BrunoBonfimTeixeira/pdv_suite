import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _exportar() {
    final buf = StringBuffer();
    buf.writeln('=== RELATORIO PDV ===');
    buf.writeln('Periodo: ${_fmt(_inicio)} a ${_fmt(_fim)}');
    buf.writeln('');

    if (_vendasDiarias.isNotEmpty) {
      final totalReceita = _vendasDiarias.fold<double>(0, (s, v) => s + v.receita);
      final totalQtd = _vendasDiarias.fold<int>(0, (s, v) => s + v.qtd);
      buf.writeln('--- VENDAS ---');
      buf.writeln('Total vendas: $totalQtd');
      buf.writeln('Receita total: R\$ ${totalReceita.toStringAsFixed(2)}');
      buf.writeln('Ticket medio: R\$ ${totalQtd > 0 ? (totalReceita / totalQtd).toStringAsFixed(2) : "0.00"}');
      buf.writeln('');
      for (final v in _vendasDiarias) {
        buf.writeln('  ${v.data}  |  ${v.qtd} vendas  |  R\$ ${v.receita.toStringAsFixed(2)}');
      }
      buf.writeln('');
    }

    void writeSection(String title, List<ReportItem> items) {
      if (items.isEmpty) return;
      buf.writeln('--- $title ---');
      for (final i in items) {
        buf.writeln('  ${i.label}: R\$ ${i.total.toStringAsFixed(2)} (${i.qtd}x)');
      }
      buf.writeln('');
    }

    writeSection('TOP PRODUTOS', _topProdutos);
    writeSection('POR CATEGORIA', _porCategoria);
    writeSection('POR PAGAMENTO', _porPagamento);
    writeSection('POR OPERADOR', _porOperador);

    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Relatorio copiado para a area de transferencia!'), backgroundColor: Color(0xFF16A34A)),
    );
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
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _exportar,
                  icon: const Icon(Icons.content_copy, size: 18),
                  label: const Text('Exportar'),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tab,
            isScrollable: true,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
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
                _buildBarTab(_topProdutos, 'Produto', const Color(0xFF2563EB)),
                _buildBarTab(_porCategoria, 'Categoria', const Color(0xFF16A34A)),
                _buildBarTab(_porPagamento, 'Forma', const Color(0xFFF97316)),
                _buildBarTab(_porOperador, 'Operador', const Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendasTab() {
    if (_vendasDiarias.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Nenhuma venda no periodo', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    final totalReceita = _vendasDiarias.fold<double>(0, (s, v) => s + v.receita);
    final totalQtd = _vendasDiarias.fold<int>(0, (s, v) => s + v.qtd);
    final ticketMedio = totalQtd > 0 ? totalReceita / totalQtd : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _kpiCard('Total Vendas', totalQtd.toString(), Icons.receipt, const Color(0xFF2563EB)),
            const SizedBox(width: 12),
            _kpiCard('Receita', 'R\$ ${totalReceita.toStringAsFixed(2)}', Icons.attach_money, const Color(0xFF16A34A)),
            const SizedBox(width: 12),
            _kpiCard('Ticket Medio', 'R\$ ${ticketMedio.toStringAsFixed(2)}', Icons.trending_up, const Color(0xFFF97316)),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Vendas por Dia', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 12),
        ..._vendasDiarias.map((v) {
          final pct = totalReceita > 0 ? v.receita / totalReceita : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(v.data.length >= 10 ? v.data.substring(5) : v.data,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const Spacer(),
                      Text('${v.qtd} vendas', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(width: 12),
                      Text('R\$ ${v.receita.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        // Footer totals
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Total: ', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
            Text('R\$ ${totalReceita.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF16A34A))),
          ],
        ),
      ],
    );
  }

  Widget _buildBarTab(List<ReportItem> items, String label, Color baseColor) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Sem dados no periodo', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    final maxTotal = items.map((i) => i.total).reduce((a, b) => a > b ? a : b);
    final sumTotal = items.fold<double>(0, (s, i) => s + i.total);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _kpiCard('Total $label', items.length.toString(), Icons.list, baseColor),
            const SizedBox(width: 12),
            _kpiCard('Receita', 'R\$ ${sumTotal.toStringAsFixed(2)}', Icons.attach_money, const Color(0xFF16A34A)),
          ],
        ),
        const SizedBox(height: 20),
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final pct = maxTotal > 0 ? item.total / maxTotal : 0.0;
          final pctTotal = sumTotal > 0 ? (item.total / sumTotal * 100) : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: baseColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: baseColor)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                      Text('${pctTotal.toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      const SizedBox(width: 10),
                      Text('R\$ ${item.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation(baseColor.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
