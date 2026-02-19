import 'package:flutter/foundation.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';
import 'package:pdv_lanchonete/core/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  Usuario? _user;
  bool _loading = true;

  Usuario? get user => _user;
  bool get isLogged => _user != null;
  bool get loading => _loading;

  bool get isAdmin => _user?.perfil == 'ADMIN';
  bool get isGerente => _user?.perfil == 'GERENTE';

  Future<void> bootstrap() async {
    _loading = true;
    notifyListeners();

    _user = await AuthService.tryRestoreSession();

    _loading = false;
    notifyListeners();
  }

  Future<void> login(String login, String senha) async {
    _user = await AuthService.login(login: login, senha: senha);
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}
