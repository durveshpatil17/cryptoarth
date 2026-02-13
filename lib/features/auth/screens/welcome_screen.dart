import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/shared/widgets/stats_card.dart';
import 'package:cryptoarth/features/auth/screens/login_screen.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Effects (Glows based on Figma)
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyan.withOpacity(0.15),
                ),
              ),
            ),
          ),
           Positioned(
            bottom: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Feature Banner (Pill shape)
                  GlassContainer(
                    borderRadius: 30,
                    color: Colors.white,
                    opacity: 0.03,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: AppColors.gold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "One-Click Orders for Multiple Accounts",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Title Section
                  Text(
                    "AI-Powered Crypto",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                      shadows: [
                        Shadow(
                          color: AppColors.cyan.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Trading Perfected",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: "Platform for "),
                        TextSpan(
                          text: "Smart Traders",
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: AppColors.gold.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Stats Grid (Glassmorphism Cards)
                  SizedBox(
                    height: 280, // Fixed height for grid
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        StatsCard(
                          icon: Icons.person_outline,
                          iconColor: AppColors.cyan,
                          value: "50,000+",
                          label: "Active Traders",
                        ),
                        StatsCard(
                          icon: Icons.show_chart,
                          iconColor: AppColors.primary,
                          value: "\$2400M+",
                          label: "Monthly Volume",
                        ),
                        StatsCard(
                          icon: Icons.settings_suggest_outlined, // Changed to outline
                          iconColor: AppColors.purple,
                          value: "1M+",
                          label: "Trades Executed",
                        ),
                        StatsCard(
                          icon: Icons.dns_outlined,
                          iconColor: AppColors.orange,
                          value: "99.99%",
                          label: "Platform Uptime",
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Bottom Button (Rocket Launch)
                  CustomButton(
                    text: "Start Trading Free Now",
                    icon: Icons.rocket_launch,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.pink,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}
