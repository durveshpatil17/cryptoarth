import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_theme.dart';
import 'package:cryptoarth/features/auth/screens/welcome_screen.dart';
import 'package:cryptoarth/features/home/screens/main_screen.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:cryptoarth/features/auth/screens/login_screen.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

class CryptoarthApp extends ConsumerWidget {
  const CryptoarthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Cryptoarth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: authState.isLoading 
        ? const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          )
        : authState.isAuthenticated 
            ? const MainScreen() 
            : authState.hasSeenLanding
                ? LoginScreen()
                : const WelcomeScreen(),
    );
  }
}
