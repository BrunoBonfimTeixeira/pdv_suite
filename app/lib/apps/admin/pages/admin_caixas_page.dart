import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/caixa.dart';
import 'package:pdv_lanchonete/core/services/caixa_service.dart';

class AdminCaixasPage extends StatefulWidget {
  const AdminCaixasPage({super.key});

  @override
  State<AdminCaixasPage> createState() => _AdminCaixasPageState();
}

class _AdminCaixasPageState extends State<AdminCaixasPage> {
  List<Caixa> _caixas = [];
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() { _loading = true; _erro = null; });
    try {
      _caixas = await CaixaService.listar();
    } catch (e) {
      _erro = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/caixas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text('Caixas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _erro != null
                    ? Center(child: Text('Erro: $_erro'))
                    : _caixas.isEmpty
                        ? const Center(child: Text('Nenhum caixa encontrado.'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Operador')),
                                DataColumn(label: Text('Abertura')),
                                DataColumn(label: Text('Fechamento')),
                                DataColumn(label: Text('Vlr Abertura'), numeric: true),
                                DataColumn(label: Text('Vlr Sistema'), numeric: true),
                                DataColumn(label: Text('Vlr Fechamento'), numeric: true),
                                DataColumn(label: Text('Diferenca'), numeric: true),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: _caixas.map((c) {
                                return DataRow(cells: [
                                  DataCell(Text('${c.id}')),
                                  DataCell(Text(c.usuarioNome ?? '-')),
                                  DataCell(Text(_formatDate(c.dataAbertura))),
                                  DataCell(Text(c.dataFechamento != null ? _formatDate(c.dataFechamento!) : '-')),
                                  DataCell(Text('R\$ ${c.valorAbertura.toStringAsFixed(2)}')),
                                  DataCell(Text(c.valorSistema != null ? 'R\$ ${c.valorSistema!.toStringAsFixed(2)}' : '-')),
                                  DataCell(Text(c.valorFechamento != null ? 'R\$ ${c.valorFechamento!.toStringAsFixed(2)}' : '-')),
                                  DataCell(Text(
                                    c.diferenca != null ? 'R\$ ${c.diferenca!.toStringAsFixed(2)}' : '-',
                                    style: TextStyle(
                                      color: c.diferenca != null && c.diferenca! < 0
                                          ? Colors.red
                                          : c.diferenca != null && c.diferenca! > 0
                                              ? Colors.orange
                                              : null,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                                  DataCell(_StatusChip(status: c.status)),
                                ]);
                              }).toList(),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final aberto = status == 'ABERTO';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: aberto ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: aberto ? Colors.green.withOpacity(0.4) : Colors.grey.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: aberto ? Colors.green : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
