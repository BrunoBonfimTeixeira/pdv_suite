import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_home_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_login_page.dart';
import 'package:pdv_lanchonete/apps/admin/admin_theme.dart';
import 'package:pdv_lanchonete/apps/admin/admin_usuarios_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_produtos_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_vendas_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_caixas_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_pessoas_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_categorias_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_estoque_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_relatorios_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_formas_pagamento_page.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';
import 'package:pdv_lanchonete/core/services/auth_service.dart';
import 'package:pdv_lanchonete/core/services/admin_produtos_service.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  bool _ready = false;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      ApiClient.init();
      AdminProdutosService.useAdminEndpoints = true;

      final user = await AuthService.tryRestoreSession();

      if (!mounted) return;
      setState(() {
        _ready = true;
        _logged = user != null;
      });
    } catch (e, st) {
      debugPrint("BOOT ERROR: $e");
      debugPrint("STACK: $st");
      if (!mounted) return;
      setState(() {
        _ready = true;
        _logged = false;
      });
    }
  }

  void _onLoggedIn() {
    setState(() => _logged = true);
  }

  void _onLoggedOut() {
    setState(() => _logged = false);
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'Admin PDV',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.light(),
      routes: {
        "/admin/login": (_) => AdminLoginPage(onLoggedIn: _onLoggedIn),
        "/admin/home": (_) => const AdminHomePage(),
        "/admin/usuarios": (_) => const AdminUsuariosPage(),
        "/admin/produtos": (_) => const AdminProdutosPage(),
        "/admin/vendas": (_) => const AdminVendasPage(),
        "/admin/caixas": (_) => const AdminCaixasPage(),
        "/admin/pessoas": (_) => const AdminPessoasPage(),
        "/admin/categorias": (_) => const AdminCategoriasPage(),
        "/admin/estoque": (_) => const AdminEstoquePage(),
        "/admin/relatorios": (_) => const AdminRelatoriosPage(),
        "/admin/formas-pagamento": (_) => const AdminFormasPagamentoPage(),
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text("Rota nao encontrada")),
        ),
      ),
      home: !_ready
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (_logged
          ? const AdminHomePage()
          : AdminLoginPage(onLoggedIn: _onLoggedIn)),
    );

    return app;
  }
}
