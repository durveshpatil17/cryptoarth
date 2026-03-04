import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Admin Panel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAdminCard(Icons.admin_panel_settings, "User Management", "Manage application users and permissions."),
            const SizedBox(height: 12),
            _buildAdminCard(Icons.analytics, "System Stats", "Monitor server health and trade execution metrics."),
            const SizedBox(height: 12),
            _buildAdminCard(Icons.security, "Security Logs", "Review access logs and security events."),
            const Spacer(),
            const Center(child: Text("Version 1.0.0 (Production)", style: TextStyle(color: Colors.white24, fontSize: 10))),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(IconData icon, String title, String subtitle) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      color: AppColors.cardSurface,
      opacity: 0.5,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        ],
      ),
    );
  }
}
