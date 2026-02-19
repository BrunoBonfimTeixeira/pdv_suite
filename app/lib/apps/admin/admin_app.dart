import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_home_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_login_page.dart';
import 'package:pdv_lanchonete/apps/admin/admin_theme.dart';
import 'package:pdv_lanchonete/apps/admin/admin_usuarios_page.dart';
import 'package:pdv_lanchonete/apps/admin/pages/admin_produtos_page.dart';
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
      // ✅ garante interceptors/headers
      ApiClient.init();

      // ✅ liga rotas admin (agora você já tem /admin/produtos)
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

  // ✅ chamado após login com sucesso
  void _onLoggedIn() {
    setState(() => _logged = true);
    // opcional: garante que sempre cai na home após login
    // (evita rota antiga ficar "presa")
  }

  // ✅ chamado após logout (se você implementar)
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
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text("Rota não encontrada")),
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
