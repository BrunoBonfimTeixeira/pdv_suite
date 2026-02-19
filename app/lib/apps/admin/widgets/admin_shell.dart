import 'package:flutter/material.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_side_panel.dart';
import 'package:pdv_lanchonete/apps/admin/widgets/admin_topbar.dart';

class AdminShell extends StatelessWidget {
  final String currentRoute;
  final Widget child;
  final String? subtitle;

  const AdminShell({
    super.key,
    required this.currentRoute,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSidePanel(currentRoute: currentRoute),

          Expanded(
            child: Column(
              children: [
                AdminTopbar(
                  title: "Lúbru",
                  subtitle: subtitle,
                  onLogout: () => Navigator.pushReplacementNamed(context, "/admin/login"),
                ),

                Expanded(
                  child: Container(
                    color: const Color(0xFFF4F6FA),
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        color: Colors.white,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
