import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/core/services/api_client.dart';
import 'package:pdv_lanchonete/apps/admin/admin_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiClient.init();

  runApp(const AdminApp());
}
