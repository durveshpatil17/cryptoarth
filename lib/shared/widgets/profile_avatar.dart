import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

import 'package:cryptoarth/features/auth/screens/welcome_screen.dart';
import 'package:cryptoarth/features/settings/screens/profile_settings_screen.dart';
import 'package:cryptoarth/features/broker/screens/broker_login_screen.dart';
import 'package:cryptoarth/features/settings/screens/contact_us_screen.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFF8B5CF6),
          shape: BoxShape.circle,
        ),
        child: const Text(
          "JD",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      onSelected: (value) {
        if (value == 'logout') {
          // Navigate to Welcome Screen and clear stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
          );
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
