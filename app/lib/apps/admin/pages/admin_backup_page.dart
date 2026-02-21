import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';
import 'package:pdv_lanchonete/core/services/backup_service.dart';

class AdminBackupPage extends StatefulWidget {
  const AdminBackupPage({super.key});

  @override
  State<AdminBackupPage> createState() => _AdminBackupPageState();
}

class _AdminBackupPageState extends State<AdminBackupPage> {
  Map<String, dynamic>? _info;
  bool _loading = true;
  bool _exportando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      _info = await BackupService.info();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _exportar() async {
    setState(() => _exportando = true);
    try {
      final sql = await BackupService.exportar();
      if (!mounted) return;

      // Copy to clipboard as fallback (web can't download files easily)
      await Clipboard.setData(ClipboardData(text: sql));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup exportado! ${sql.length} caracteres copiados para a área de transferência.'),
          backgroundColor: const Color(0xFF16A34A),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    if (mounted) setState(() => _exportando = false);
  }

  String _formatBytes(dynamic bytes) {
    if (bytes == null) return '0 B';
    final b = (bytes is num) ? bytes.toDouble() : double.tryParse(bytes.toString()) ?? 0;
    if (b < 1024) return '${b.toStringAsFixed(0)} B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/backup";

    return AdminShell(
      currentRoute: route,
      subtitle: "Backup BD",
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.storage, color: Color(0xFF2563EB), size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Backup do Banco de Dados', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                            Text('Visualize informações e exporte backup SQL', style: TextStyle(color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _exportando ? null : _exportar,
                        icon: _exportando
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.download, size: 20),
                        label: Text(_exportando ? 'Exportando...' : 'Exportar Backup'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // KPI Cards
                  if (_info != null) ...[
                    Row(
                      children: [
                        _kpiCard('Banco', _info!['database']?.toString() ?? '-', Icons.dns, const Color(0xFF2563EB)),
                        const SizedBox(width: 16),
                        _kpiCard('Tamanho Total', _formatBytes(_info!['total_size']), Icons.pie_chart, const Color(0xFF16A34A)),
                        const SizedBox(width: 16),
                        _kpiCard('Tabelas', '${(_info!['tables'] as List?)?.length ?? 0}', Icons.table_chart, const Color(0xFFF97316)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tables detail
                    const Text('Detalhes das Tabelas', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 12),
                    if (_info!['tables'] is List)
                      ...(_info!['tables'] as List).map((t) {
                        final table = Map<String, dynamic>.from(t as Map);
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.table_rows, color: Color(0xFF2563EB), size: 20),
                            ),
                            title: Text(table['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                            subtitle: Text('Registros: ${table['rows'] ?? 0} | Tamanho: ${_formatBytes(table['size'])}'),
                          ),
                        );
                      }),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
