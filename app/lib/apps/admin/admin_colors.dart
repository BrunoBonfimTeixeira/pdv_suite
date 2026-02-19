import 'package:flutter/material.dart';

class AdminColors {
  static const Color navy = Color(0xFF0B1F3B);
  static const Color teal = Color(0xFF1EC9A5);
  static const Color bg   = Color(0xFFF4F7FB);

  static Color a(Color c, double opacity) {
    final v = (opacity.clamp(0, 1) * 255).round();
    return c.withAlpha(v);
  }
}
