import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/forma_pagamento.dart';
import 'package:pdv_lanchonete/core/services/forma_pagamento_service.dart';

class AdminFormasPagamentoPage extends StatefulWidget {
  const AdminFormasPagamentoPage({super.key});

  @override
  State<AdminFormasPagamentoPage> createState() => _AdminFormasPagamentoPageState();
}

class _AdminFormasPagamentoPageState extends State<AdminFormasPagamentoPage> {
  List<FormaPagamento> _formas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      _formas = await FormaPagamentoService.listar(all: true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _dialog({FormaPagamento? editing}) async {
    final descCtrl = TextEditingController(text: editing?.descricao ?? '');
    String tipo = editing?.tipo ?? 'OUTROS';
    bool ativo = editing?.ativo ?? true;

    final tipos = ['DINHEIRO', 'CREDITO', 'DEBITO', 'PIX', 'OUTROS'];

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(editing == null ? 'Nova Forma de Pagamento' : 'Editar Forma'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Descricao *'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipos.contains(tipo) ? tipo : 'OUTROS',
                  items: tipos.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setStateDialog(() => tipo = v ?? 'OUTROS'),
                  decoration: const InputDecoration(labelText: 'Tipo'),
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
                  if (editing == null) {
                    await FormaPagamentoService.criar(descricao: desc, tipo: tipo, ativo: ativo);
                  } else {
                    await FormaPagamentoService.atualizar(id: editing.id, descricao: desc, tipo: tipo, ativo: ativo);
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
    if (result == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/formas-pagamento";

    return AdminShell(
      currentRoute: route,
      subtitle: "Formas de Pagamento",
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('${_formas.length} formas', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _dialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nova Forma'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _formas.length,
                    itemBuilder: (context, i) {
                      final f = _formas[i];
                      return Card(
                        child: ListTile(
                          leading: Icon(_iconForTipo(f.tipo), color: f.ativo ? Colors.green : Colors.grey),
                          title: Text(f.descricao, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('Tipo: ${f.tipo} | ${f.ativo ? "Ativo" : "Inativo"}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _dialog(editing: f)),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () async {
                                  await FormaPagamentoService.remover(f.id);
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

  IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case 'DINHEIRO': return Icons.payments;
      case 'CREDITO': return Icons.credit_card;
      case 'DEBITO': return Icons.credit_score;
      case 'PIX': return Icons.qr_code;
      default: return Icons.payment;
    }
  }
}
