import 'package:flutter/material.dart';

class AdminTopbar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;

  const AdminTopbar({
    super.key,
    this.title = "Lúbru",
    this.subtitle,
    this.onSettings,
    this.onLogout,
  });

  static const Color _top = Color(0xFF0B1F3B);
  static const Color _accent = Color(0xFF1EC9A5);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: _top,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _accent.withOpacity(.50)),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 12),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .2,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.70),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),

                const Spacer(),

                _ActionIcon(
                  icon: Icons.settings_outlined,
                  onTap: onSettings ?? () {},
                ),
                const SizedBox(width: 8),
                _ActionIcon(
                  icon: Icons.logout,
                  onTap: onLogout ?? () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
