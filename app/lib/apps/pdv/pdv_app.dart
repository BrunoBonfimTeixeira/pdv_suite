import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/pages/home_page.dart';

class PdvApp extends StatelessWidget {
  const PdvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDV Lanchonete',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A0B0),
        ),
      ),
      home: const PdvShell(),
    );
  }
}
