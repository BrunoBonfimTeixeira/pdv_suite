import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';
import 'package:pdv_lanchonete/core/models/pessoa.dart';
import 'package:pdv_lanchonete/core/services/pessoa_service.dart';

class BuscaPessoasDialog extends StatefulWidget {
  const BuscaPessoasDialog({super.key});

  @override
  State<BuscaPessoasDialog> createState() => _BuscaPessoasDialogState();
}

class _BuscaPessoasDialogState extends State<BuscaPessoasDialog> {
  final _searchCtrl = TextEditingController();
  List<Pessoa> _resultados = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _buscar('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _buscar(q));
  }

  Future<void> _buscar(String q) async {
    setState(() => _loading = true);
    try {
      final lista = await PessoaService.listar(q: q.isEmpty ? null : q);
      if (!mounted) return;
      setState(() {
        _resultados = lista;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PdvTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 520,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: PdvTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nome, CPF/CNPJ, telefone...',
                  prefixIcon: Icon(Icons.person_search, color: PdvTheme.accent),
                ),
                onChanged: _onChanged,
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _resultados.isEmpty
                      ? const Center(
                          child: Text('Nenhuma pessoa encontrada',
                              style: TextStyle(color: PdvTheme.textSecondary)),
                        )
                      : ListView.builder(
                          itemCount: _resultados.length,
                          itemBuilder: (context, i) {
                            final p = _resultados[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: PdvTheme.card,
                                child: Icon(
                                  p.tipo == 'FORNECEDOR' ? Icons.business : Icons.person,
                                  color: PdvTheme.accent,
                                  size: 20,
                                ),
                              ),
                              title: Text(p.nome,
                                  style: const TextStyle(color: PdvTheme.textPrimary)),
                              subtitle: Text(
                                [p.cpfCnpj, p.telefone].where((s) => s != null && s.isNotEmpty).join(' | '),
                                style: const TextStyle(color: PdvTheme.textSecondary, fontSize: 12),
                              ),
                              trailing: Text(p.tipo,
                                  style: const TextStyle(color: PdvTheme.textSecondary, fontSize: 11)),
                              onTap: () => Navigator.pop(context, p),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
