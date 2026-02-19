import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdv_lanchonete/core/models/usuario.dart';

class AuthStorage {
  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user';

  static Future<void> saveSession({
    required String token,
    required Usuario usuario,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
    await sp.setString(_kUser, jsonEncode(usuario.toJson()));
  }

  static Future<String?> loadToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  static Future<Usuario?> loadUser() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kUser);
    if (raw == null || raw.isEmpty) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return Usuario.fromJson(map);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kUser);
  }
}
