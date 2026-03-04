import 'package:flutter/material.dart';
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
                    const Text(
                      "Crypto Arth",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                    _buildMenuItem(Icons.home_outlined, "Home", onTap: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 0)),
                        (route) => false,
                      );
                    }),
                    _buildMenuItem(Icons.currency_exchange, "Broker Login", onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BrokerLoginScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.radar_outlined, "Scanner", onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScannerScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.calculate_outlined, "Margin Calculator", onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CalculatorScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.assessment_outlined, "PnL Report", onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PnLReportScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.admin_panel_settings_outlined, "Admin Panel", onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
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
                   Navigator.pop(context);
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
