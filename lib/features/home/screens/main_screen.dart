import 'package:flutter/material.dart';

import 'package:cryptoarth/shared/widgets/custom_bottom_nav_bar.dart';

import 'package:cryptoarth/features/home/screens/home_screen.dart';
import 'package:cryptoarth/features/portfolio/screens/portfolio_screen.dart';
import 'package:cryptoarth/features/marketplace/screens/marketplace_screen.dart';
import 'package:cryptoarth/features/orders/screens/orders_screen.dart';
import 'package:cryptoarth/features/tools/screens/calculator_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PortfolioScreen(),
    const MarketplaceScreen(),
    const OrdersScreen(),
    const CalculatorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
