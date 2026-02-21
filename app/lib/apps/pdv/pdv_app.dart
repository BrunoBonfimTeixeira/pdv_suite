import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_screen.dart';
import 'package:pdv_lanchonete/apps/pdv/pdv_theme.dart';

class PdvApp extends StatelessWidget {
  const PdvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDV',
      debugShowCheckedModeBanner: false,
      theme: PdvTheme.dark(),
      home: const PdvScreen(),
    );
  }
}
