import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/services/report_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  DashboardData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      _data = await ReportService.dashboard();
    } catch (e) {
      debugPrint('Dashboard error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/home";

    return AdminShell(
      currentRoute: route,
      subtitle: "Painel de Controle",
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('Erro ao carregar dashboard'))
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // KPIs row
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _KpiCard(
                            title: 'Vendas Hoje',
                            value: _data!.hoje.qtd.toString(),
                            subtitle: 'R\$ ${_data!.hoje.receita.toStringAsFixed(2)}',
                            icon: Icons.today,
                            color: Colors.blue,
                          ),
                          _KpiCard(
                            title: 'Vendas Semana',
                            value: _data!.semana.qtd.toString(),
                            subtitle: 'R\$ ${_data!.semana.receita.toStringAsFixed(2)}',
                            icon: Icons.date_range,
                            color: Colors.green,
                          ),
                          _KpiCard(
                            title: 'Vendas Mes',
                            value: _data!.mes.qtd.toString(),
                            subtitle: 'R\$ ${_data!.mes.receita.toStringAsFixed(2)}',
                            icon: Icons.calendar_month,
                            color: Colors.orange,
                          ),
                          _KpiCard(
                            title: 'Ticket Medio',
                            value: 'R\$ ${_data!.ticketMedio.toStringAsFixed(2)}',
                            subtitle: 'media por venda',
                            icon: Icons.receipt_long,
                            color: Colors.purple,
                          ),
                          _KpiCard(
                            title: 'Estoque Alerta',
                            value: _data!.alertaEstoque.toString(),
                            subtitle: 'produtos abaixo do minimo',
                            icon: Icons.warning_amber,
                            color: _data!.alertaEstoque > 0 ? Colors.red : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Top produtos do mes
                      const Text(
                        'Top Produtos do Mes',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      if (_data!.topProdutos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nenhuma venda neste mes.', style: TextStyle(color: Colors.black54)),
                        )
                      else
                        ..._data!.topProdutos.asMap().entries.map((e) {
                          final i = e.key;
                          final p = e.value;
                          final maxTotal = _data!.topProdutos.first.total;
                          final pct = maxTotal > 0 ? p.total / maxTotal : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    '${i + 1}.',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(p.descricao, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 14,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation(Colors.primaries[i % Colors.primaries.length]),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    'R\$ ${p.total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }
}
