import 'package:flutter_test/flutter_test.dart';
import 'package:pdv_lanchonete/apps/admin/admin_app.dart';

void main() {
  testWidgets('Admin app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const AdminApp());
    expect(find.byType(AdminApp), findsOneWidget);
  });
}
