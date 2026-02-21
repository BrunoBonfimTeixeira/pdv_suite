import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_shell.dart';

class AdminConfiguracoesPage extends StatefulWidget {
  const AdminConfiguracoesPage({super.key});

  @override
  State<AdminConfiguracoesPage> createState() => _AdminConfiguracoesPageState();
}

class _AdminConfiguracoesPageState extends State<AdminConfiguracoesPage> {
  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? "/admin/configuracoes";

    return AdminShell(
      currentRoute: route,
      subtitle: "Configurações",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.settings, color: Color(0xFF2563EB), size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Configurações do Sistema', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                      Text('Ajustes gerais do sistema PDV', style: TextStyle(color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _section('Dados da Empresa', Icons.business, [
              _infoTile('Estas configurações são gerenciadas na tela de Lojas.', Icons.info_outline),
            ]),

            const SizedBox(height: 20),

            _section('Sistema', Icons.tune, [
              _infoTile('Versão: PDV Suite v1.0', Icons.verified),
              _infoTile('API: http://127.0.0.1:3000', Icons.cloud),
              _infoTile('Banco: MySQL (configurado via .env)', Icons.storage),
            ]),

            const SizedBox(height: 20),

            _section('Módulos Ativos', Icons.extension, [
              _moduleTile('Vendas / PDV', true),
              _moduleTile('Controle de Estoque', true),
              _moduleTile('Cadastro de Pessoas', true),
              _moduleTile('Nota Fiscal Eletrônica', true),
              _moduleTile('Ordens de Serviço', true),
              _moduleTile('Relatórios', true),
              _moduleTile('Backup', true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _infoTile(String text, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        title: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _moduleTile(String name, bool active) {
    return Card(
      child: ListTile(
        leading: Icon(
          active ? Icons.check_circle : Icons.cancel,
          color: active ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          size: 20,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF16A34A).withOpacity(0.1) : const Color(0xFFDC2626).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            active ? 'ATIVO' : 'INATIVO',
            style: TextStyle(
              color: active ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
