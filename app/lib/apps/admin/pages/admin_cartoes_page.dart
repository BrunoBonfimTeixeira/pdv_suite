import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/cartao_operadora.dart';
import 'package:pdv_lanchonete/core/services/cartao_service.dart';

class AdminCartoesPage extends StatefulWidget {
  const AdminCartoesPage({super.key});

  @override
  State<AdminCartoesPage> createState() => _AdminCartoesPageState();
}

class _AdminCartoesPageState extends State<AdminCartoesPage> {
  List<CartaoOperadora> _all = [];
  List<CartaoOperadora> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregar();
    _searchCtrl.addListener(_filtrar);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      _all = await CartaoService.listar();
      _filtrar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _filtrar() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_all)
          : _all.where((c) =>
              c.descricao.toLowerCase().contains(q) ||
              c.bandeira.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _dialog({CartaoOperadora? editing}) async {
    final descCtrl = TextEditingController(text: editing?.descricao ?? '');
    final bandeiraCtrl = TextEditingController(text: editing?.bandeira ?? '');
    final taxaCtrl = TextEditingController(text: editing?.taxaPercentual.toString() ?? '0');
    final diasCtrl = TextEditingController(text: editing?.diasRecebimento.toString() ?? '30');
    bool ativo = editing?.ativo ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(editing == null ? 'Nova Operadora' : 'Editar Operadora'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Descrição *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bandeiraCtrl,
                  decoration: const InputDecoration(labelText: 'Bandeira', hintText: 'Visa, Mastercard...'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: taxaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Taxa (%)', suffixText: '%'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: diasCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Dias Recebimento'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Ativo'),
                  value: ativo,
                  onChanged: (v) => setStateDialog(() => ativo = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final desc = descCtrl.text.trim();
                if (desc.isEmpty) return;
                try {
                  final data = {
                    'descricao': desc,
                    'bandeira': bandeiraCtrl.text.trim(),
                    'taxa_percentual': double.tryParse(taxaCtrl.text) ?? 0,
                    'dias_recebimento': int.tryParse(diasCtrl.text) ?? 30,
                    'ativo': ativo,
                  };
                  if (editing == null) {
                    await CartaoService.criar(data);
                  } else {
                    await CartaoService.atualizar(editing.id, data);
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

    descCtrl.dispose();
    bandeiraCtrl.dispose();
    taxaCtrl.dispose();
    diasCtrl.dispose();

    if (result == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/cartoes";

    return AdminShell(
      currentRoute: route,
      subtitle: "Cartões / Operadoras",
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('${_filtered.length} operadora(s)',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _dialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nova Operadora'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.credit_card_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text('Nenhuma operadora encontrada',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final c = _filtered[i];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: c.ativo ? const Color(0xFF2563EB) : Colors.grey,
                                  child: const Icon(Icons.credit_card, color: Colors.white, size: 20),
                                ),
                                title: Text(c.descricao, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text(
                                  'Bandeira: ${c.bandeira.isNotEmpty ? c.bandeira : "-"} | '
                                  'Taxa: ${c.taxaPercentual.toStringAsFixed(2)}% | '
                                  'Receb: ${c.diasRecebimento} dias',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: c.ativo ? const Color(0xFF16A34A).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        c.ativo ? 'ATIVO' : 'INATIVO',
                                        style: TextStyle(
                                          color: c.ativo ? const Color(0xFF16A34A) : Colors.grey,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _dialog(editing: c)),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () async {
                                        await CartaoService.remover(c.id);
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
