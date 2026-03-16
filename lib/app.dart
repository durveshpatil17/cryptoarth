import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_theme.dart';
import 'package:cryptoarth/shared/providers/theme_provider.dart';
import 'package:cryptoarth/features/auth/screens/welcome_screen.dart';
import 'package:cryptoarth/features/home/screens/main_screen.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';

class CryptoarthApp extends ConsumerWidget {
  const CryptoarthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'CryptoArth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    Widget screen;
    if (authState.isCheckingSession || !authState.isAuthenticated) {
      screen = const WelcomeScreen(key: ValueKey('auth_gate_welcome'));
    } else {
      screen = const MainScreen(key: ValueKey('auth_gate_main'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      switchInCurve: Curves.easeInOutQuart,
      switchOutCurve: Curves.easeInOutQuart,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: child,
      ),
      child: screen,
    );
  }
}
