import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/core/models/pessoa.dart';
import 'package:pdv_lanchonete/core/services/pessoa_service.dart';

class PessoaFormPage extends StatefulWidget {
  final Pessoa? pessoa;
  const PessoaFormPage({super.key, this.pessoa});

  @override
  State<PessoaFormPage> createState() => _PessoaFormPageState();
}

class _PessoaFormPageState extends State<PessoaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _cpfCnpjCtrl;
  late final TextEditingController _telefoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _enderecoCtrl;
  String _tipo = 'CLIENTE';
  bool _saving = false;

  bool get _isEditing => widget.pessoa != null;

  @override
  void initState() {
    super.initState();
    final p = widget.pessoa;
    _nomeCtrl = TextEditingController(text: p?.nome ?? '');
    _cpfCnpjCtrl = TextEditingController(text: p?.cpfCnpj ?? '');
    _telefoneCtrl = TextEditingController(text: p?.telefone ?? '');
    _emailCtrl = TextEditingController(text: p?.email ?? '');
    _enderecoCtrl = TextEditingController(text: p?.endereco ?? '');
    if (p != null) _tipo = p.tipo;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCnpjCtrl.dispose();
    _telefoneCtrl.dispose();
    _emailCtrl.dispose();
    _enderecoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await PessoaService.atualizar(
          id: widget.pessoa!.id,
          nome: _nomeCtrl.text.trim(),
          cpfCnpj: _cpfCnpjCtrl.text.trim(),
          telefone: _telefoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          endereco: _enderecoCtrl.text.trim(),
          tipo: _tipo,
        );
      } else {
        await PessoaService.criar(
          nome: _nomeCtrl.text.trim(),
          cpfCnpj: _cpfCnpjCtrl.text.trim().isEmpty ? null : _cpfCnpjCtrl.text.trim(),
          telefone: _telefoneCtrl.text.trim().isEmpty ? null : _telefoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          endereco: _enderecoCtrl.text.trim().isEmpty ? null : _enderecoCtrl.text.trim(),
          tipo: _tipo,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Pessoa' : 'Nova Pessoa'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(labelText: 'Nome *'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatorio' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'CLIENTE', child: Text('Cliente')),
                    DropdownMenuItem(value: 'FORNECEDOR', child: Text('Fornecedor')),
                  ],
                  onChanged: (v) => setState(() => _tipo = v ?? 'CLIENTE'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _cpfCnpjCtrl,
                  decoration: const InputDecoration(labelText: 'CPF/CNPJ'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _telefoneCtrl,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _enderecoCtrl,
                  decoration: const InputDecoration(labelText: 'Endereco'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _saving ? null : _salvar,
                    child: _saving
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_isEditing ? 'Salvar' : 'Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
