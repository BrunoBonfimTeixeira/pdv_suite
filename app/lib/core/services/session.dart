import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _kToken = 'auth_token';
  static const _kPerfil = 'auth_perfil';

  static Future<void> saveToken(String token, {String? perfil}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
    if (perfil != null) await sp.setString(_kPerfil, perfil);
  }

  static Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  static Future<String?> getPerfil() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kPerfil);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kPerfil);
  }
}
