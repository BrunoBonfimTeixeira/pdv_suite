import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/loja.dart';
import 'package:pdv_lanchonete/core/services/loja_service.dart';

class AdminLojasPage extends StatefulWidget {
  const AdminLojasPage({super.key});

  @override
  State<AdminLojasPage> createState() => _AdminLojasPageState();
}

class _AdminLojasPageState extends State<AdminLojasPage> {
  List<Loja> _all = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      _all = await LojaService.listar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _dialog({Loja? editing}) async {
    final nomeCtrl = TextEditingController(text: editing?.nome ?? '');
    final cnpjCtrl = TextEditingController(text: editing?.cnpj ?? '');
    final ieCtrl = TextEditingController(text: editing?.inscricaoEstadual ?? '');
    final imCtrl = TextEditingController(text: editing?.inscricaoMunicipal ?? '');
    final endCtrl = TextEditingController(text: editing?.endereco ?? '');
    final numCtrl = TextEditingController(text: editing?.numero ?? '');
    final bairroCtrl = TextEditingController(text: editing?.bairro ?? '');
    final cidadeCtrl = TextEditingController(text: editing?.cidade ?? '');
    final ufCtrl = TextEditingController(text: editing?.uf ?? '');
    final cepCtrl = TextEditingController(text: editing?.cep ?? '');
    final telCtrl = TextEditingController(text: editing?.telefone ?? '');
    final emailCtrl = TextEditingController(text: editing?.email ?? '');
    final cnaeCtrl = TextEditingController(text: editing?.cnae ?? '');
    String regime = editing?.regimeTributario ?? 'SIMPLES_NACIONAL';
    bool ativo = editing?.ativo ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(editing == null ? 'Nova Loja' : 'Editar Loja'),
          content: SizedBox(
            width: 520,
            height: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nomeCtrl, autofocus: true, decoration: const InputDecoration(labelText: 'Nome *')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextField(controller: cnpjCtrl, decoration: const InputDecoration(labelText: 'CNPJ'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: ieCtrl, decoration: const InputDecoration(labelText: 'Inscrição Estadual'))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextField(controller: imCtrl, decoration: const InputDecoration(labelText: 'Inscrição Municipal'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: cnaeCtrl, decoration: const InputDecoration(labelText: 'CNAE'))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(flex: 3, child: TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'Endereço'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: numCtrl, decoration: const InputDecoration(labelText: 'Nº'))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextField(controller: bairroCtrl, decoration: const InputDecoration(labelText: 'Bairro'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: cidadeCtrl, decoration: const InputDecoration(labelText: 'Cidade'))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    SizedBox(width: 80, child: TextField(controller: ufCtrl, decoration: const InputDecoration(labelText: 'UF'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: cepCtrl, decoration: const InputDecoration(labelText: 'CEP'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Telefone'))),
                  ]),
                  const SizedBox(height: 10),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: regime,
                    decoration: const InputDecoration(labelText: 'Regime Tributário'),
                    items: const [
                      DropdownMenuItem(value: 'SIMPLES_NACIONAL', child: Text('Simples Nacional')),
                      DropdownMenuItem(value: 'LUCRO_PRESUMIDO', child: Text('Lucro Presumido')),
                      DropdownMenuItem(value: 'LUCRO_REAL', child: Text('Lucro Real')),
                      DropdownMenuItem(value: 'MEI', child: Text('MEI')),
                    ],
                    onChanged: (v) => setD(() => regime = v ?? regime),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Ativo'),
                    value: ativo,
                    onChanged: (v) => setD(() => ativo = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nomeCtrl.text.trim().isEmpty) return;
                try {
                  final data = {
                    'nome': nomeCtrl.text.trim(),
                    'cnpj': cnpjCtrl.text.trim(),
                    'inscricao_estadual': ieCtrl.text.trim(),
                    'inscricao_municipal': imCtrl.text.trim(),
                    'endereco': endCtrl.text.trim(),
                    'numero': numCtrl.text.trim(),
                    'bairro': bairroCtrl.text.trim(),
                    'cidade': cidadeCtrl.text.trim(),
                    'uf': ufCtrl.text.trim(),
                    'cep': cepCtrl.text.trim(),
                    'telefone': telCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'regime_tributario': regime,
                    'cnae': cnaeCtrl.text.trim(),
                    'ativo': ativo,
                  };
                  if (editing == null) {
                    await LojaService.criar(data);
                  } else {
                    await LojaService.atualizar(editing.id, data);
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

    for (final c in [nomeCtrl, cnpjCtrl, ieCtrl, imCtrl, endCtrl, numCtrl, bairroCtrl, cidadeCtrl, ufCtrl, cepCtrl, telCtrl, emailCtrl, cnaeCtrl]) {
      c.dispose();
    }

    if (result == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/lojas";

    return AdminShell(
      currentRoute: route,
      subtitle: "Lojas",
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('${_all.length} loja(s)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _dialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nova Loja'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _all.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.store_mall_directory_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text('Nenhuma loja cadastrada', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _all.length,
                          itemBuilder: (context, i) {
                            final l = _all[i];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: l.ativo ? const Color(0xFF2563EB) : Colors.grey,
                                  child: const Icon(Icons.store, color: Colors.white, size: 20),
                                ),
                                title: Text(l.nome, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text(
                                  '${l.cnpj.isNotEmpty ? "CNPJ: ${l.cnpj}" : "Sem CNPJ"} | '
                                  '${l.cidade.isNotEmpty ? "${l.cidade}/${l.uf}" : "Sem cidade"}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: l.ativo ? const Color(0xFF16A34A).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        l.ativo ? 'ATIVA' : 'INATIVA',
                                        style: TextStyle(
                                          color: l.ativo ? const Color(0xFF16A34A) : Colors.grey,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _dialog(editing: l)),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () async {
                                        await LojaService.remover(l.id);
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
