import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:cryptoarth/features/auth/screens/login_screen.dart';
import 'package:cryptoarth/features/home/screens/main_screen.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathe;
  
  int _tickerIndex = 0;
  final List<String> _tickerTexts = [
    "ENCRYPTED CONNECTION",
    "BROKER SYNC ACTIVE",
    "ALGO ENGINE READY"
  ];
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _breathe = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Initial check and navigation or start 4s sequence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(authProvider).isAuthenticated) {
        _navigateToNext(immediate: true);
      } else {
         _startInitializationSequence();
      }
    });

    _tickerTimer = Timer.periodic(const Duration(milliseconds: 1300), (timer) {
      if (mounted) {
        setState(() => _tickerIndex = (_tickerIndex + 1) % _tickerTexts.length);
      }
    });
  }

  void _startInitializationSequence() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _navigateToNext();
    });
  }

  void _navigateToNext({bool immediate = false}) async {
    if (!mounted) return;
    
    final authCheck = ref.read(authProvider);
    if (authCheck.isCheckingSession) {
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToNext(immediate: immediate);
      return;
    }

    final Widget nextScreen = authCheck.isAuthenticated 
        ? const MainScreen() 
        : const LoginScreen();

    if (immediate) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
      return;
    }

    Navigator.pushReplacement(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.1, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _tickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.digitalVoidBlack,
      body: LuxuryBackground(
        child: Stack(
          children: [
            // Center Logo with Breathing Animation
            Center(
              child: AnimatedBuilder(
                animation: _breathe,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glow background for logo
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2 * _breathe.value),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: SvgPicture.asset("assets/images/favicon.svg", height: 100, width: 100),
                      ),
                      const SizedBox(height: 32),
                      Opacity(
                        opacity: _breathe.value,
                        child: Text(
                          "CryptoArth".toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            shadows: [
                              Shadow(color: AppColors.primary, blurRadius: 15),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "QUANTUM TRADING PROTOCOL",
                        style: TextStyle(
                          color: AppColors.secondary.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Refined Bottom Ticker
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 150,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, AppColors.primary.withOpacity(0.5), Colors.transparent],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _tickerTexts[_tickerIndex].toUpperCase(),
                        key: ValueKey(_tickerTexts[_tickerIndex]),
                        style: TextStyle(
                          color: AppColors.primary.withOpacity(0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Grain Overlay (Simulated via shader or texture if available, here basic opacity)
            IgnorePointer(
               child: Container(
                 decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.02),
                 ),
               ),
            ),
          ],
        ),
      ),
    );
  }
}
