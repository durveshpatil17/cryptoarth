import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'dart:math' as Math;

import 'package:cryptoarth/features/auth/screens/welcome_screen.dart';
import 'package:cryptoarth/features/settings/screens/profile_settings_screen.dart';
import 'package:cryptoarth/features/broker/screens/broker_login_screen.dart';
import 'package:cryptoarth/features/settings/screens/contact_us_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';

class ProfileAvatar extends ConsumerWidget {
  final double radius;
  const ProfileAvatar({super.key, this.radius = 16.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    
    String initials = "U";
    if (user != null) {
      if (user.name != null && user.name!.isNotEmpty) {
        final parts = user.name!.trim().split(' ');
        if (parts.length > 1) {
          initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        } else {
          initials = parts[0].substring(0, Math.min(2, parts[0].length)).toUpperCase();
        }
      } else if (user.phone != null && user.phone!.length >= 2) {
        initials = user.phone!.substring(user.phone!.length - 2);
      }
    }

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF8B5CF6),
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.75,
          ),
        ),
      ),
      onSelected: (value) {
        if (value == 'logout') {
          ref.read(authProvider.notifier).logout(context);
        } else if (value == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
          );
        } else if (value == 'broker') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BrokerLoginScreen()),
          );
        } else if (value == 'contact') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactUsScreen()),
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildMenuItem('profile', Icons.shield_outlined, 'Profile Settings'),
        _buildMenuItem('broker', Icons.link, 'Broker Login'),
        _buildMenuItem('webhook', Icons.code, 'Webhook'),
        _buildMenuItem('tour', Icons.timeline, 'View Tour Guide'),
        _buildMenuItem('contact', Icons.headphones, 'Contact Us'),
        const PopupMenuDivider(height: 1),
        _buildMenuItem('logout', Icons.logout, 'Logout', isDestructive: true),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? Colors.redAccent : Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDestructive ? Colors.redAccent : Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
