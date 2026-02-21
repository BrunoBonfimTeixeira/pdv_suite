import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/apps/admin/pages/pessoa_form_page.dart';
import 'package:pdv_lanchonete/core/models/pessoa.dart';
import 'package:pdv_lanchonete/core/services/pessoa_service.dart';

class AdminPessoasPage extends StatefulWidget {
  const AdminPessoasPage({super.key});

  @override
  State<AdminPessoasPage> createState() => _AdminPessoasPageState();
}

class _AdminPessoasPageState extends State<AdminPessoasPage> {
  List<Pessoa> _pessoas = [];
  bool _loading = true;
  String? _erro;
  String _busca = '';
  String _filtroTipo = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() { _loading = true; _erro = null; });
    try {
      _pessoas = await PessoaService.listar(
        q: _busca.isEmpty ? null : _busca,
        tipo: _filtroTipo.isEmpty ? null : _filtroTipo,
      );
    } catch (e) {
      _erro = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onBuscaChanged(String q) {
    _busca = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _carregar);
  }

  Future<void> _toggleAtivo(Pessoa p) async {
    try {
      await PessoaService.atualizar(id: p.id, ativo: !p.ativo);
      _carregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _novaPessoa() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PessoaFormPage()),
    );
    if (result == true) _carregar();
  }

  Future<void> _editarPessoa(Pessoa p) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PessoaFormPage(pessoa: p)),
    );
    if (result == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/pessoas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text('Pessoas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                // Busca
                SizedBox(
                  width: 280,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nome, CPF, telefone...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: _onBuscaChanged,
                  ),
                ),
                const SizedBox(width: 12),
                // Filtro tipo
                DropdownButton<String>(
                  value: _filtroTipo,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Todos')),
                    DropdownMenuItem(value: 'CLIENTE', child: Text('Clientes')),
                    DropdownMenuItem(value: 'FORNECEDOR', child: Text('Fornecedores')),
                  ],
                  onChanged: (v) {
                    _filtroTipo = v ?? '';
                    _carregar();
                  },
                ),
                const SizedBox(width: 12),
                IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _novaPessoa,
                  icon: const Icon(Icons.add),
                  label: const Text('Cadastrar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _erro != null
                    ? Center(child: Text('Erro: $_erro'))
                    : _pessoas.isEmpty
                        ? const Center(child: Text('Nenhuma pessoa encontrada.'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Nome')),
                                DataColumn(label: Text('CPF/CNPJ')),
                                DataColumn(label: Text('Telefone')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Tipo')),
                                DataColumn(label: Text('Ativo')),
                                DataColumn(label: Text('Acoes')),
                              ],
                              rows: _pessoas.map((p) {
                                return DataRow(cells: [
                                  DataCell(Text('${p.id}')),
                                  DataCell(Text(p.nome)),
                                  DataCell(Text(p.cpfCnpj ?? '-')),
                                  DataCell(Text(p.telefone ?? '-')),
                                  DataCell(Text(p.email ?? '-')),
                                  DataCell(_TipoChip(tipo: p.tipo)),
                                  DataCell(Switch(
                                    value: p.ativo,
                                    onChanged: (_) => _toggleAtivo(p),
                                  )),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => _editarPessoa(p),
                                        tooltip: 'Editar',
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
}

class _TipoChip extends StatelessWidget {
  final String tipo;
  const _TipoChip({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final isCliente = tipo == 'CLIENTE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCliente ? Colors.blue.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCliente ? Colors.blue.withOpacity(0.4) : Colors.purple.withOpacity(0.4)),
      ),
      child: Text(
        tipo,
        style: TextStyle(
          color: isCliente ? Colors.blue : Colors.purple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
