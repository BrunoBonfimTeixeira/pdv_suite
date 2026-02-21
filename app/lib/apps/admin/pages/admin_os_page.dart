import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/ordem_servico.dart';
import 'package:pdv_lanchonete/core/services/os_service.dart';

class AdminOsPage extends StatefulWidget {
  const AdminOsPage({super.key});

  @override
  State<AdminOsPage> createState() => _AdminOsPageState();
}

class _AdminOsPageState extends State<AdminOsPage> {
  List<OrdemServico> _all = [];
  bool _loading = true;
  String? _filtroStatus;

  final _statusList = ['ABERTA', 'EM_ANDAMENTO', 'AGUARDANDO', 'CONCLUIDA', 'CANCELADA'];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      _all = await OsService.listar(status: _filtroStatus);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'ABERTA': return const Color(0xFF2563EB);
      case 'EM_ANDAMENTO': return const Color(0xFFEAB308);
      case 'AGUARDANDO': return const Color(0xFFF97316);
      case 'CONCLUIDA': return const Color(0xFF16A34A);
      case 'CANCELADA': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _corPrioridade(String p) {
    switch (p) {
      case 'BAIXA': return const Color(0xFF6B7280);
      case 'MEDIA': return const Color(0xFF2563EB);
      case 'ALTA': return const Color(0xFFF97316);
      case 'URGENTE': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7280);
    }
  }

  String _labelStatus(String s) => s.replaceAll('_', ' ');

  Future<void> _dialog({OrdemServico? editing}) async {
    final descCtrl = TextEditingController(text: editing?.descricao ?? '');
    final defeitoCtrl = TextEditingController(text: editing?.defeitoRelatado ?? '');
    final solucaoCtrl = TextEditingController(text: editing?.solucao ?? '');
    final pessoaIdCtrl = TextEditingController(text: editing?.pessoaId?.toString() ?? '');
    final valorOrcCtrl = TextEditingController(text: editing?.valorOrcamento.toString() ?? '0');
    final valorFinCtrl = TextEditingController(text: editing?.valorFinal.toString() ?? '0');
    final obsCtrl = TextEditingController(text: editing?.observacoes ?? '');
    String prioridade = editing?.prioridade ?? 'MEDIA';
    String status = editing?.status ?? 'ABERTA';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(editing == null ? 'Nova Ordem de Serviço' : 'Editar OS #${editing.id}'),
          content: SizedBox(
            width: 520,
            height: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: pessoaIdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ID da Pessoa (Cliente)')),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, autofocus: true, decoration: const InputDecoration(labelText: 'Descrição *')),
                  const SizedBox(height: 10),
                  TextField(controller: defeitoCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Defeito Relatado')),
                  const SizedBox(height: 10),
                  if (editing != null)
                    TextField(controller: solucaoCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Solução')),
                  if (editing != null) const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: prioridade,
                        decoration: const InputDecoration(labelText: 'Prioridade'),
                        items: ['BAIXA', 'MEDIA', 'ALTA', 'URGENTE'].map((p) =>
                          DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (v) => setD(() => prioridade = v ?? prioridade),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (editing != null)
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: status,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: _statusList.map((s) =>
                            DropdownMenuItem(value: s, child: Text(_labelStatus(s)))).toList(),
                          onChanged: (v) => setD(() => status = v ?? status),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextField(controller: valorOrcCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor Orçamento', prefixText: 'R\$ '))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: valorFinCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor Final', prefixText: 'R\$ '))),
                  ]),
                  const SizedBox(height: 10),
                  TextField(controller: obsCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Observações')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (descCtrl.text.trim().isEmpty) return;
                try {
                  final data = <String, dynamic>{
                    'descricao': descCtrl.text.trim(),
                    'defeito_relatado': defeitoCtrl.text.trim(),
                    'prioridade': prioridade,
                    'valor_orcamento': double.tryParse(valorOrcCtrl.text) ?? 0,
                    'valor_final': double.tryParse(valorFinCtrl.text) ?? 0,
                    'observacoes': obsCtrl.text.trim(),
                  };
                  final pid = int.tryParse(pessoaIdCtrl.text.trim());
                  if (pid != null) data['pessoa_id'] = pid;
                  if (editing != null) {
                    data['status'] = status;
                    data['solucao'] = solucaoCtrl.text.trim();
                    if (status == 'CONCLUIDA') data['data_conclusao'] = DateTime.now().toIso8601String();
                    await OsService.atualizar(editing.id, data);
                  } else {
                    await OsService.criar(data);
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
      ),
    );

    for (final c in [descCtrl, defeitoCtrl, solucaoCtrl, pessoaIdCtrl, valorOrcCtrl, valorFinCtrl, obsCtrl]) {
      c.dispose();
    }
    if (result == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/os";

    return AdminShell(
      currentRoute: route,
      subtitle: "Ordens de Serviço",
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('${_all.length} OS', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(width: 16),
                ChoiceChip(label: const Text('Todas'), selected: _filtroStatus == null,
                  onSelected: (_) { _filtroStatus = null; _carregar(); }),
                const SizedBox(width: 6),
                ..._statusList.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(_labelStatus(s), style: const TextStyle(fontSize: 12)),
                    selected: _filtroStatus == s,
                    selectedColor: _corStatus(s).withOpacity(0.2),
                    onSelected: (_) { _filtroStatus = s; _carregar(); },
                  ),
                )),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _dialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nova OS'),
                ),
              ],
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _all.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.build_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text('Nenhuma ordem de serviço', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _all.length,
                      itemBuilder: (_, i) {
                        final os = _all[i];
                        final corSt = _corStatus(os.status);
                        final corPr = _corPrioridade(os.prioridade);
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(color: corSt.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(Icons.build, color: corSt, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Text('OS #${os.id}', style: const TextStyle(fontWeight: FontWeight.w800)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: corSt.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                          child: Text(_labelStatus(os.status), style: TextStyle(color: corSt, fontWeight: FontWeight.w700, fontSize: 11)),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: corPr.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                          child: Text(os.prioridade, style: TextStyle(color: corPr, fontWeight: FontWeight.w700, fontSize: 11)),
                                        ),
                                      ]),
                                      const SizedBox(height: 4),
                                      Text(os.descricao, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(
                                        'Cliente: ${os.pessoaNome.isNotEmpty ? os.pessoaNome : "N/A"} | '
                                        'Orç: R\$ ${os.valorOrcamento.toStringAsFixed(2)} | '
                                        'Abertura: ${os.dataAbertura.isNotEmpty ? os.dataAbertura.substring(0, 10) : "-"}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _dialog(editing: os)),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () async {
                                    await OsService.remover(os.id);
                                    _carregar();
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
    );
  }
}
