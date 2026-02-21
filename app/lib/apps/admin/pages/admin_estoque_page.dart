import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/services/estoque_service.dart';

class AdminEstoquePage extends StatefulWidget {
  const AdminEstoquePage({super.key});

  @override
  State<AdminEstoquePage> createState() => _AdminEstoquePageState();
}

class _AdminEstoquePageState extends State<AdminEstoquePage> {
  List<NivelEstoque> _niveis = [];
  bool _loading = true;
  bool _apenasAlerta = false;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      _niveis = await EstoqueService.listarNiveis(
        apenasAlerta: _apenasAlerta,
        q: _busca.isNotEmpty ? _busca : null,
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _ajustar(NivelEstoque item) async {
    final tipoCtrl = ValueNotifier<String>('ENTRADA');
    final qtdCtrl = TextEditingController();
    final motivoCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ValueListenableBuilder<String>(
        valueListenable: tipoCtrl,
        builder: (ctx, tipo, _) => AlertDialog(
          title: Text('Ajustar Estoque: ${item.descricao}'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Estoque atual: ${item.estoqueAtual.toStringAsFixed(3)} ${item.unidadeMedida}'),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'ENTRADA', label: Text('Entrada')),
                    ButtonSegment(value: 'SAIDA', label: Text('Saida')),
                    ButtonSegment(value: 'AJUSTE', label: Text('Ajuste')),
                  ],
                  selected: {tipo},
                  onSelectionChanged: (s) => tipoCtrl.value = s.first,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtdCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: tipo == 'AJUSTE' ? 'Novo estoque' : 'Quantidade',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: motivoCtrl,
                  decoration: const InputDecoration(labelText: 'Motivo (opcional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final qtd = double.tryParse(qtdCtrl.text.replaceAll(',', '.')) ?? 0;
                if (qtd <= 0 && tipo != 'AJUSTE') return;
                try {
                  await EstoqueService.ajustar(
                    produtoId: item.id,
                    tipo: tipoCtrl.value,
                    quantidade: qtd,
                    motivo: motivoCtrl.text.trim().isEmpty ? null : motivoCtrl.text.trim(),
                  );
                  Navigator.pop(ctx, true);
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Erro: $e')));
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );

    qtdCtrl.dispose();
    motivoCtrl.dispose();

    if (result == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/estoque";
    final alertas = _niveis.where((n) => n.emAlerta).length;

    return AdminShell(
      currentRoute: route,
      subtitle: "Estoque",
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar produto...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      _busca = v;
                      _carregar();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: Text('Alertas ($alertas)'),
                  selected: _apenasAlerta,
                  onSelected: (v) {
                    _apenasAlerta = v;
                    _carregar();
                  },
                  selectedColor: Colors.red.shade100,
                ),
                const SizedBox(width: 8),
                Text('${_niveis.length} produtos'),
              ],
            ),
          ),
          _loading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _niveis.length,
                    itemBuilder: (context, i) {
                      final n = _niveis[i];
                      return Card(
                        color: n.emAlerta ? Colors.red.shade50 : null,
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                n.estoqueAtual.toStringAsFixed(n.unidadeMedida == 'UN' ? 0 : 3),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: n.emAlerta ? Colors.red : Colors.black87,
                                ),
                              ),
                              Text(n.unidadeMedida, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                            ],
                          ),
                          title: Text(n.descricao, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            'Min: ${n.estoqueMinimo.toStringAsFixed(3)} | ${n.categoriaDescricao ?? "Sem categoria"}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.tune),
                            onPressed: () => _ajustar(n),
                            tooltip: 'Ajustar estoque',
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
