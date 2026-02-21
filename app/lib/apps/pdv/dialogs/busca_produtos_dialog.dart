import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';
import 'package:pdv_lanchonete/core/models/produto.dart';
import 'package:pdv_lanchonete/core/services/produto_service.dart';

class BuscaProdutosDialog extends StatefulWidget {
  const BuscaProdutosDialog({super.key});

  @override
  State<BuscaProdutosDialog> createState() => _BuscaProdutosDialogState();
}

class _BuscaProdutosDialogState extends State<BuscaProdutosDialog> {
  final _searchCtrl = TextEditingController();
  List<Produto> _resultados = [];
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
      final lista = await ProdutoService.listar(filtro: q);
      if (!mounted) return;
      setState(() {
        _resultados = lista.map((r) => Produto(
          id: r.id,
          descricao: r.descricao,
          preco: r.preco,
          codigoBarras: null,
          ativo: true,
        )).toList();
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
                  hintText: 'Buscar por nome, codigo ou barras...',
                  prefixIcon: Icon(Icons.search, color: PdvTheme.accent),
                ),
                onChanged: _onChanged,
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _resultados.isEmpty
                      ? const Center(
                          child: Text('Nenhum produto encontrado',
                              style: TextStyle(color: PdvTheme.textSecondary)),
                        )
                      : ListView.builder(
                          itemCount: _resultados.length,
                          itemBuilder: (context, i) {
                            final p = _resultados[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: PdvTheme.card,
                                child: Text('${p.id}',
                                    style: const TextStyle(color: PdvTheme.accent, fontSize: 12)),
                              ),
                              title: Text(p.descricao,
                                  style: const TextStyle(color: PdvTheme.textPrimary)),
                              trailing: Text(
                                'R\$ ${p.preco.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: PdvTheme.accent, fontWeight: FontWeight.w700),
                              ),
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
