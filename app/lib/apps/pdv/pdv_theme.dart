import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/core/models/pdv_config.dart';

class PdvTheme {
  PdvTheme._();

  // Default colors (used as fallback)
  static const Color bg = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color card = Color(0xFF0F3460);
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentDark = Color(0xFF00A885);
  static const Color danger = Color(0xFFE94560);
  static const Color warning = Color(0xFFF5A623);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color border = Color(0xFF2A2A4A);
  static const Color inputBg = Color(0xFF0D1B3E);

  static Color parseHex(String hex, [Color fallback = Colors.grey]) {
    try {
      final h = hex.replaceFirst('#', '');
      if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
      if (h.length == 8) return Color(int.parse(h, radix: 16));
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  /// Get configured colors from PdvConfig, falling back to defaults
  static Color accentFrom(PdvConfig? config) =>
      config != null && config.corPrimaria.isNotEmpty ? parseHex(config.corPrimaria, accent) : accent;

  static Color accentDarkFrom(PdvConfig? config) =>
      config != null && config.corSecundaria.isNotEmpty ? parseHex(config.corSecundaria, accentDark) : accentDark;

  static Color borderFrom(PdvConfig? config) =>
      config != null && config.corBorda.isNotEmpty ? parseHex(config.corBorda, border) : border;

  static Color bgFrom(PdvConfig? config) =>
      config != null && config.corFundo.isNotEmpty ? parseHex(config.corFundo, bg) : bg;

  static ThemeData dark({PdvConfig? config}) {
    final cfgAccent = accentFrom(config);
    final cfgAccentDark = accentDarkFrom(config);
    final cfgBg = bgFrom(config);
    final cfgBorder = borderFrom(config);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: cfgBg,
      colorScheme: ColorScheme.dark(
        primary: cfgAccent,
        secondary: cfgAccentDark,
        surface: surface,
        error: danger,
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cfgBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cfgBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cfgAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cfgAccent,
          foregroundColor: cfgBg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: cfgAccent),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
