import 'package:flutter/material.dart';

import 'package:cryptoarth/shared/theme/app_colors.dart';

import 'package:cryptoarth/features/home/screens/main_screen.dart';
import 'package:cryptoarth/features/strategies/screens/backtest_config_screen.dart';
import 'package:cryptoarth/features/strategies/screens/code_generator_screen.dart';
import 'package:cryptoarth/features/home/screens/chat_history_screen.dart';
import 'package:cryptoarth/features/strategies/screens/templates_screen.dart';
import 'package:cryptoarth/features/settings/screens/credits_screen.dart';



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [AppColors.cyan, AppColors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: "Crypto", style: TextStyle(color: AppColors.cyan)),
                          TextSpan(text: "Arth AI", style: TextStyle(color: AppColors.purple)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "AI-Powered Trading",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // New Chat Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: const Icon(Icons.chat_bubble_outline, color: AppColors.cyan),
                title: const Text(
                  "New Chat",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
                // Add left border indicator simulation if needed, or just keep simple for now
                minLeadingWidth: 20,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.science_outlined, "Backtest", onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BacktestConfigScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.code, "Code Generator", onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CodeGeneratorScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.history, "Chat History", onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatHistoryScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.bookmark_border, "Templates", onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TemplatesScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.monetization_on_outlined, "Credits", onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreditsScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.shopping_bag_outlined, "Marketplace", onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 2)),
                        (route) => false,
                      );
                    }),
                    _buildMenuItem(Icons.bar_chart, "Portfolio / P&L", onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 1)),
                        (route) => false,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          
          // Footer / Logout
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(16),
                color: Colors.redAccent.withOpacity(0.05),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                   Navigator.pop(context); // Close drawer
                   ref.read(authProvider.notifier).logout(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap ?? () {},
    );
  }
}
