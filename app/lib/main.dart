import 'package:flutter/material.dart';
import 'apps/admin/admin_app.dart';
import 'core/services/api_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/admin_produtos_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ liga interceptor do Authorization
  ApiClient.init();

  // ✅ restaura token do storage (se existir)
  await AuthService.tryRestoreSession();

  // ✅ força rotas admin para este app
  AdminProdutosService.useAdminEndpoints = true;

  runApp(const AdminApp());
}
