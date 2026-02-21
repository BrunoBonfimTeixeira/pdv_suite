import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/models/nota_fiscal.dart';
import 'package:pdv_lanchonete/core/services/nfe_service.dart';

class AdminNfePage extends StatefulWidget {
  const AdminNfePage({super.key});

  @override
  State<AdminNfePage> createState() => _AdminNfePageState();
}

class _AdminNfePageState extends State<AdminNfePage> {
  List<NotaFiscal> _notas = [];
  bool _loading = true;
  String? _filtroStatus;
  String? _filtroTipo;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      _notas = await NfeService.listar(status: _filtroStatus, tipo: _filtroTipo);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  Color _corStatus(String status) {
    switch (status.toUpperCase()) {
      case 'AUTORIZADA': return const Color(0xFF16A34A);
      case 'PENDENTE': return const Color(0xFFEAB308);
      case 'CANCELADA': return const Color(0xFFDC2626);
      case 'REJEITADA': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7280);
    }
  }

  Future<void> _emitirDialog() async {
    final vendaIdCtrl = TextEditingController();
    String tipo = 'NFCE';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Emitir Nota Fiscal'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: vendaIdCtrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ID da Venda *'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'NFCE', child: Text('NFC-e (Consumidor)')),
                    DropdownMenuItem(value: 'NFE', child: Text('NF-e (Eletrônica)')),
                  ],
                  onChanged: (v) => setD(() => tipo = v ?? tipo),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final vendaId = int.tryParse(vendaIdCtrl.text.trim());
                if (vendaId == null) return;
                try {
                  await NfeService.emitir(vendaId: vendaId, tipo: tipo);
                  Navigator.pop(ctx, true);
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Erro: $e')));
                }
              },
              child: const Text('Emitir'),
            ),
          ],
        ),
      ),
    );

    vendaIdCtrl.dispose();
    if (result == true) _carregar();
  }

  Future<void> _cancelarNota(NotaFiscal nota) async {
    final motivoCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Nota Fiscal'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nota #${nota.id} — ${nota.tipo} ${nota.numero}'),
              const SizedBox(height: 12),
              TextField(
                controller: motivoCtrl,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Motivo do cancelamento *'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () async {
              if (motivoCtrl.text.trim().isEmpty) return;
              try {
                await NfeService.cancelar(nota.id, motivoCtrl.text.trim());
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Erro: $e')));
              }
            },
            child: const Text('Cancelar Nota'),
          ),
        ],
      ),
    );

    motivoCtrl.dispose();
    if (result == true) _carregar();
  }

  Future<void> _verXml(NotaFiscal nota) async {
    try {
      final xml = await NfeService.baixarXml(nota.id);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('XML — Nota #${nota.id}'),
          content: SizedBox(
            width: 600,
            height: 400,
            child: SingleChildScrollView(
              child: SelectableText(
                xml.isNotEmpty ? xml : '(vazio)',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/nfe";

    return AdminShell(
      currentRoute: route,
      subtitle: "Nota Fiscal Eletrônica",
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('${_notas.length} nota(s)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(width: 16),
                // Filter chips
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: _filtroStatus == null,
                  onSelected: (_) { _filtroStatus = null; _carregar(); },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Pendentes'),
                  selected: _filtroStatus == 'PENDENTE',
                  onSelected: (_) { _filtroStatus = 'PENDENTE'; _carregar(); },
                  selectedColor: const Color(0xFFEAB308).withOpacity(0.2),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Autorizadas'),
                  selected: _filtroStatus == 'AUTORIZADA',
                  onSelected: (_) { _filtroStatus = 'AUTORIZADA'; _carregar(); },
                  selectedColor: const Color(0xFF16A34A).withOpacity(0.2),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Canceladas'),
                  selected: _filtroStatus == 'CANCELADA',
                  onSelected: (_) { _filtroStatus = 'CANCELADA'; _carregar(); },
                  selectedColor: const Color(0xFFDC2626).withOpacity(0.2),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _emitirDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Emitir NF'),
                ),
              ],
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _notas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text('Nenhuma nota fiscal encontrada',
                              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _notas.length,
                      itemBuilder: (_, i) {
                        final n = _notas[i];
                        final cor = _corStatus(n.status);
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: cor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.receipt, color: cor, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('#${n.id}', style: const TextStyle(fontWeight: FontWeight.w800)),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: cor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(n.status, style: TextStyle(color: cor, fontWeight: FontWeight.w700, fontSize: 11)),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2563EB).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(n.tipo, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 11)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Venda: ${n.vendaId ?? "-"} | Série: ${n.serie} | Nº: ${n.numero.isNotEmpty ? n.numero : "-"} | ${n.dataEmissao.isNotEmpty ? n.dataEmissao.substring(0, 10) : "-"}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                      if (n.chaveAcesso.isNotEmpty)
                                        Text('Chave: ${n.chaveAcesso}', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontFamily: 'monospace')),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.code, size: 20),
                                  tooltip: 'Ver XML',
                                  onPressed: () => _verXml(n),
                                ),
                                if (n.status == 'PENDENTE' || n.status == 'AUTORIZADA')
                                  IconButton(
                                    icon: const Icon(Icons.cancel, size: 20, color: Color(0xFFDC2626)),
                                    tooltip: 'Cancelar',
                                    onPressed: () => _cancelarNota(n),
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
