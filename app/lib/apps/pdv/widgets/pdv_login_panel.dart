import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';
import 'package:pdv_lanchonete/core/services/auth_service.dart';

class PdvLoginPanel extends StatefulWidget {
  final void Function(Usuario usuario) onLoggedIn;
  const PdvLoginPanel({super.key, required this.onLoggedIn});

  @override
  State<PdvLoginPanel> createState() => _PdvLoginPanelState();
}

class _PdvLoginPanelState extends State<PdvLoginPanel> {
  final _loginCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _loginFocus = FocusNode();
  bool _loading = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _loginFocus.requestFocus();
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _senhaCtrl.dispose();
    _loginFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final login = _loginCtrl.text.trim();
    final senha = _senhaCtrl.text.trim();
    if (login.isEmpty || senha.isEmpty) return;

    setState(() { _loading = true; _erro = null; });

    try {
      final usuario = await AuthService.login(login: login, senha: senha);
      widget.onLoggedIn(usuario);
    } catch (e) {
      setState(() { _erro = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: PdvTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PdvTheme.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.point_of_sale, color: PdvTheme.accent, size: 48),
            const SizedBox(height: 12),
            const Text(
              'PDV - Login',
              style: TextStyle(color: PdvTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _loginCtrl,
              focusNode: _loginFocus,
              style: const TextStyle(color: PdvTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Login',
                labelStyle: TextStyle(color: PdvTheme.textSecondary),
                prefixIcon: Icon(Icons.person, color: PdvTheme.textSecondary),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _senhaCtrl,
              obscureText: true,
              style: const TextStyle(color: PdvTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: PdvTheme.textSecondary),
                prefixIcon: Icon(Icons.lock, color: PdvTheme.textSecondary),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_erro != null) ...[
              const SizedBox(height: 12),
              Text(_erro!, style: const TextStyle(color: PdvTheme.danger, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('ENTRAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
