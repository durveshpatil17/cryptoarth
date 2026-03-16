import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/providers/theme_provider.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';
import 'package:cryptoarth/features/broker/screens/broker_login_screen.dart';
import 'package:cryptoarth/features/admin/screens/admin_panel_screen.dart';
import 'package:cryptoarth/features/portfolio/screens/pnl_report_screen.dart';
import 'package:cryptoarth/features/signals/screens/scanner_screen.dart';
import 'package:cryptoarth/features/tools/screens/calculator_screen.dart';
import 'package:cryptoarth/features/home/screens/main_screen.dart';
import 'package:cryptoarth/shared/widgets/app_tour.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final balanceAsync = ref.watch(paymentBalanceProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Drawer(
      backgroundColor: AppColors.getBackground(context),
      child: Column(
        children: [
          // Premium Profile Header
          Container(
            padding: const EdgeInsets.fromLTRB(28, 72, 28, 36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
              border: Border(
                bottom: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.04), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
                    gradient: RadialGradient(
                      colors: [AppColors.gold.withOpacity(0.1), Colors.transparent],
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.person_rounded, color: AppColors.gold, size: 28),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name?.toUpperCase() ?? "GUEST USER",
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                        ),
                        child: balanceAsync.when(
                          data: (balance) => Text(
                            "${balance?.balance.floor() ?? 0} CREDITS",
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          loading: () => const SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 1)),
                          error: (_, __) => const Icon(Icons.error_outline, size: 8, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                // Theme Toggle Icon Button
                IconButton(
                  onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: AppColors.gold.withOpacity(0.8),
                    size: 20,
                  ),
                  tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.gold.withOpacity(0.05),
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.gold.withOpacity(0.1)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                _buildSectionHeader(context, "NAVIGATION"),
                _buildPremiumItem(context, Icons.home_rounded, "HOME", AppColors.gold, () {
                   Navigator.pop(context);
                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 0)), (r) => false);
                }, isAI: true),
                _buildPremiumItem(context, Icons.hub_rounded, "BROKER CONNECTION", AppColors.gold, () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const BrokerLoginScreen()));
                }),
                _buildPremiumItem(context, Icons.radar_rounded, "MARKET SCANNER", AppColors.gold, () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
                }),

                const SizedBox(height: 28),
                _buildSectionHeader(context, "REPORTS & ANALYTICS"),
                _buildPremiumItem(context, Icons.analytics_rounded, "P&L OVERVIEW", AppColors.gold, () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const PnLReportScreen()));
                }),
                _buildPremiumItem(context, Icons.calculate_rounded, "MARGIN CALCULATOR", AppColors.gold, () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorScreen()));
                }),
                _buildPremiumItem(context, Icons.explore_rounded, "APP TOUR", AppColors.cyan, () {
                   Navigator.pop(context);
                   showDialog(context: context, builder: (_) => AppTour(onFinish: () => Navigator.pop(context)));
                }),


                const SizedBox(height: 28),
                _buildSectionHeader(context, "SETTINGS"),
                _buildPremiumItem(context, Icons.shield_rounded, "ADMIN CONSOLE", isDark ? Colors.white38 : Colors.black26, () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
                }),
                _buildPremiumItem(context, Icons.logout_rounded, "LOGOUT", Colors.redAccent.withOpacity(0.8), () {
                   Navigator.pop(context);
                   ref.read(authProvider.notifier).logout(context);
                }),
              ],
            ),
          ),

          // Refined Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.04))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Version 1.2.0 (Build 42)",
                  style: TextStyle(color: AppColors.getTextSecondary(context).withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981))),
                    const SizedBox(width: 8),
                    Text(
                      "ENCRYPTED CONNECTION ACTIVE",
                      style: TextStyle(color: AppColors.getTextSecondary(context).withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 14),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.getTextSecondary(context).withOpacity(0.3),
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.2,
        ),
      ),
    );
  }

  Widget _buildPremiumItem(BuildContext context, IconData icon, String title, Color accentColor, VoidCallback onTap, {bool isAI = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
        child: Row(
          children: [
            if (isAI)
              ShaderMask(
                shaderCallback: (bounds) => AppColors.aiBuilderGradient.createShader(bounds),
                child: Icon(icon, color: Colors.white, size: 19),
              )
            else
              Icon(icon, color: accentColor.withOpacity(0.7), size: 19),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.getTextPrimary(context).withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.getTextSecondary(context).withOpacity(0.1), size: 16),
          ],
        ),
      ),
    );
  }
}
