import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/widgets/app_tour.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptoarth/features/strategies/screens/execution_history_screen.dart';

import 'package:cryptoarth/shared/theme/app_colors.dart';

import 'package:cryptoarth/features/home/screens/main_screen.dart';
import 'package:cryptoarth/features/strategies/screens/backtest_config_screen.dart';
import 'package:cryptoarth/features/strategies/screens/code_generator_screen.dart';
import 'package:cryptoarth/features/home/screens/chat_history_screen.dart';
import 'package:cryptoarth/features/tools/screens/calculator_screen.dart';

import 'package:cryptoarth/features/strategies/screens/templates_screen.dart';




import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';
import 'package:cryptoarth/features/broker/screens/broker_login_screen.dart';
import 'package:cryptoarth/features/admin/screens/admin_panel_screen.dart';
import 'package:cryptoarth/features/portfolio/screens/pnl_report_screen.dart';
import 'package:cryptoarth/features/signals/screens/scanner_screen.dart';

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
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: SvgPicture.asset("assets/images/favicon.svg"),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.watch(authProvider).user?.name ?? "CryptoArth User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ref.watch(authProvider).user?.phone ?? "No phone",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4), // Keep a small gap before credits
                    ref.watch(paymentBalanceProvider).when(
                      data: (balance) => Text(
                        "Credits: ${balance?.balance.floor() ?? 0}",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                      ),
                      loading: () => Text(
                        "Loading credits...",
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                      ),
                      error: (_, __) => Text(
                        "Error loading credits",
                        style: TextStyle(color: Colors.redAccent.withOpacity(0.5), fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.home_outlined, "Home", color: Colors.blueAccent, onTap: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 0)),
                        (route) => false,
                      );
                    }),
                    _buildMenuItem(Icons.currency_exchange, "Broker Login", color: Colors.orangeAccent, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BrokerLoginScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.radar_outlined, "Scanner", color: Colors.greenAccent, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScannerScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.calculate_outlined, "Margin Calculator", color: Colors.purpleAccent, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CalculatorScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.assessment_outlined, "PnL Report", color: Colors.cyanAccent, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PnLReportScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.admin_panel_settings_outlined, "Admin Panel", color: Colors.redAccent, onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                      );
                    }),

                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withOpacity(0.05)),
                    _buildMenuItem(Icons.logout, "Logout", color: Colors.redAccent, onTap: () {
                       Navigator.pop(context);
                       ref.read(authProvider.notifier).logout(context);
                    }),
                  ],
                ),
              ),
            ),
          ),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {required Color color, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap ?? () {},
    );
  }
}
