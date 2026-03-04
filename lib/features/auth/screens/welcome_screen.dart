import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/shared/widgets/stats_card.dart';
import 'package:cryptoarth/features/auth/screens/login_screen.dart';
import 'package:cryptoarth/features/auth/screens/signup_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';


class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _carouselTimer;

  final List<Map<String, String>> _carouselData = [
    {
      "title": "Zero Subscription Fees",
      "subtitle": "100% FREE FOREVER",
      "description": "No hidden charges. Complete professional trading platform at zero cost.",
      "highlight": "Save \$500+/month",
    },
    {
      "title": "AI-Powered Crypto",
      "subtitle": "TRADING PERFECTED",
      "description": "Institutional-grade algorithmic power for retail traders. Design, backtest, and deploy.",
      "highlight": "43% Higher Win-rate",
    },
    {
      "title": "Multi-Exchange Hub",
      "subtitle": "ONE DASHBOARD",
      "description": "Trade across 50+ exchanges from a single interface. Never miss an arbitrage opportunity.",
      "highlight": "2000+ Trading Pairs",
    },
  ];

  @override
  void initState() {
    super.initState();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _carouselData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Dynamic Background Glows
          Positioned(
            top: -100,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyan.withOpacity(0.1),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        
                        // Top Logo/Brand
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset("assets/images/favicon.svg", height: 26, width: 26),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                "Crypto Arth",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  letterSpacing: -0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text("PRO", style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Carousel Unit
                        SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) => setState(() => _currentPage = index),
                            itemCount: _carouselData.length,
                            itemBuilder: (context, index) {
                              final item = _carouselData[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        item["subtitle"]!,
                                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      item["title"]!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      item["description"]!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.5),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Dots Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _carouselData.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index ? AppColors.primary : Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Stats Grid (Matching Website)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.6,
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
                                icon: Icons.bolt,
                                iconColor: AppColors.purple,
                                value: "740k+",
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

                        const SizedBox(height: 40),

                        // "Why Traders Choose Us" Banner
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [const Color(0xFF1E293B), AppColors.cardSurface],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.verified_user, color: AppColors.green, size: 20),
                                  SizedBox(width: 10),
                                  Text("Institutional Grade", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Leverage the same algorithms used by elite quant funds to automate your trading 24/7.",
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 48),

                        // Extra Marketing (The Engine Behind...)
                        const Text(
                          "THE ENGINE BEHIND SMARTER TRADING",
                          style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Fixed Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(color: Colors.black54, blurRadius: 20, offset: const Offset(0, -5))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButton(
                        text: "Start Trading Free Now",
                        icon: Icons.rocket_launch,
                        onPressed: () {
                          ref.read(authProvider.notifier).setLandingSeen();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already a Pro?", style: TextStyle(color: Colors.white54, fontSize: 13)),
                          TextButton(
                            onPressed: () {
                              ref.read(authProvider.notifier).setLandingSeen();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
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
