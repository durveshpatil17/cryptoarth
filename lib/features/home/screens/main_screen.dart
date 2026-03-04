import 'package:flutter/material.dart';

import 'package:cryptoarth/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:cryptoarth/shared/widgets/custom_drawer.dart';

import 'package:cryptoarth/features/home/screens/home_screen.dart';
import 'package:cryptoarth/features/portfolio/screens/portfolio_screen.dart';
import 'package:cryptoarth/features/marketplace/screens/marketplace_screen.dart';
import 'package:cryptoarth/features/orders/screens/orders_screen.dart';
import 'package:cryptoarth/features/profile/screens/profile_screen.dart';
import 'package:cryptoarth/features/home/screens/marketplace_home_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const MarketplaceHomeScreen(),
    const PortfolioScreen(),
    const HomeScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      drawer: const CustomDrawer(),
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
