import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_theme.dart';
import 'package:cryptoarth/features/auth/screens/welcome_screen.dart';

class CryptoarthApp extends StatelessWidget {
  const CryptoarthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cryptoarth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}
