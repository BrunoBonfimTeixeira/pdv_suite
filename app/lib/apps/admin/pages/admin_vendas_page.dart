import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/venda_detalhe.dart';
import 'package:pdv_lanchonete/core/services/venda_service.dart';

class AdminVendasPage extends StatefulWidget {
  const AdminVendasPage({super.key});

  @override
  State<AdminVendasPage> createState() => _AdminVendasPageState();
}

class _AdminVendasPageState extends State<AdminVendasPage> {
  List<VendaDetalhe> _vendas = [];
  bool _loading = true;
  String? _erro;
  String _filtroStatus = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() { _loading = true; _erro = null; });
    try {
      _vendas = await VendaService.listar(
        status: _filtroStatus.isEmpty ? null : _filtroStatus,
      );
    } catch (e) {
      _erro = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _cancelarVenda(VendaDetalhe venda) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Venda'),
        content: Text('Deseja cancelar a venda #${venda.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Nao')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancelar Venda'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await VendaService.cancelar(venda.id);
      _carregar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Venda #${venda.id} cancelada.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _verDetalhes(VendaDetalhe venda) async {
    try {
      final detalhe = await VendaService.buscarPorId(venda.id);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Venda #${detalhe.id}'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Status: ${detalhe.status}'),
                  Text('Data: ${detalhe.dataHora}'),
                  Text('Operador: ${detalhe.usuarioNome ?? '-'}'),
                  if (detalhe.pessoaNome != null) Text('Cliente: ${detalhe.pessoaNome}'),
                  Text('Total: R\$ ${detalhe.totalLiquido.toStringAsFixed(2)}'),
                  const Divider(),
                  const Text('Itens:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...detalhe.itens.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${i.produtoDescricao ?? 'Produto #${i.produtoId}'} '
                      '- ${i.quantidade}x R\$ ${i.valorUnitario.toStringAsFixed(2)} '
                      '= R\$ ${i.valorTotal.toStringAsFixed(2)}',
                    ),
                  )),
                  const Divider(),
                  const Text('Pagamentos:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...detalhe.pagamentos.map((p) => Text(
                    '${p.formaDescricao ?? 'Forma #${p.formaPagamentoId}'}: R\$ ${p.valor.toStringAsFixed(2)}',
                  )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/vendas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text('Vendas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                // Filtro status
                DropdownButton<String>(
                  value: _filtroStatus,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Todas')),
                    DropdownMenuItem(value: 'FINALIZADA', child: Text('Finalizadas')),
                    DropdownMenuItem(value: 'CANCELADA', child: Text('Canceladas')),
                  ],
                  onChanged: (v) {
                    _filtroStatus = v ?? '';
                    _carregar();
                  },
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _carregar,
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _erro != null
                    ? Center(child: Text('Erro: $_erro'))
                    : _vendas.isEmpty
                        ? const Center(child: Text('Nenhuma venda encontrada.'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Data/Hora')),
                                DataColumn(label: Text('Operador')),
                                DataColumn(label: Text('Cliente')),
                                DataColumn(label: Text('Total'), numeric: true),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Acoes')),
                              ],
                              rows: _vendas.map((v) {
                                return DataRow(cells: [
                                  DataCell(Text('${v.id}')),
                                  DataCell(Text(_formatDate(v.dataHora))),
                                  DataCell(Text(v.usuarioNome ?? '-')),
                                  DataCell(Text(v.pessoaNome ?? '-')),
                                  DataCell(Text('R\$ ${v.totalLiquido.toStringAsFixed(2)}')),
                                  DataCell(_StatusChip(status: v.status)),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility, size: 20),
                                        onPressed: () => _verDetalhes(v),
                                        tooltip: 'Detalhes',
                                      ),
                                      if (!v.isCancelada)
                                        IconButton(
                                          icon: const Icon(Icons.cancel, size: 20, color: Colors.red),
                                          onPressed: () => _cancelarVenda(v),
                                          tooltip: 'Cancelar',
                                        ),
                                    ],
                                  )),
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
    final isCancelada = status == 'CANCELADA';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCancelada ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCancelada ? Colors.red.withOpacity(0.4) : Colors.green.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isCancelada ? Colors.red : Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
