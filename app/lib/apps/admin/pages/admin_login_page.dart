import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/core/services/auth_service.dart';

class AdminLoginPage extends StatefulWidget {
  final VoidCallback? onLoggedIn;
  const AdminLoginPage({super.key, this.onLoggedIn});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _login = TextEditingController(text: "99");
  final _senha = TextEditingController(text: "123456");
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _login.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      if (!_formKey.currentState!.validate()) {
        setState(() => _loading = false);
        return;
      }

      final user = await AuthService.login(
        login: _login.text.trim(),
        senha: _senha.text,
      );
      if (!mounted) return;

      // (AuthService.login já lança Exception se falhar, mas mantive sua checagem)
      if (user == null) {
        setState(() {
          _loading = false;
          _error = "Não foi possível autenticar.";
        });
        return;
      }

      // ✅ avisa o AdminApp que agora está logado
      widget.onLoggedIn?.call();

      // ✅ navega
      Navigator.of(context).pushReplacementNamed("/admin/home");
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: cs.primaryContainer,
                            child: Icon(Icons.admin_panel_settings, color: cs.onPrimaryContainer),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Admin • PDV", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                SizedBox(height: 2),
                                Text("Acesse para gerenciar usuários e produtos"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _login,
                        decoration: const InputDecoration(
                          labelText: "Login",
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Informe o login" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _senha,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Senha",
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? "Informe a senha" : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_error!, style: TextStyle(color: cs.onErrorContainer)),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _loading ? null : _entrar,
                        icon: _loading
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.login),
                        label: Text(_loading ? "Entrando..." : "Entrar"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
