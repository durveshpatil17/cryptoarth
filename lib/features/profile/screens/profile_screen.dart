import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:cryptoarth/shared/widgets/app_tour.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';
import 'package:cryptoarth/features/settings/screens/profile_settings_screen.dart';
import 'package:cryptoarth/features/tutorials/screens/tutorial_ai_screen.dart';
import 'package:cryptoarth/features/tutorials/screens/tutorials_list_screen.dart';
import 'package:cryptoarth/features/profile/screens/contact_us_screen.dart';
import 'package:cryptoarth/features/profile/screens/webhook_screen.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "MY PROFILE",
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w800, 
                fontSize: 14, 
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'BIOMETRIC & ACCOUNT SETTINGS',
              style: TextStyle(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.w700, letterSpacing: 1.2),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white70),
          onPressed: () {
            final ScaffoldState? root = context.findRootAncestorStateOfType<ScaffoldState>();
            root?.openDrawer();
          },
        ),
      ),
      body: LuxuryBackground(
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            _buildProfileHeader(ref),
              
            const SizedBox(height: 32),
            
            // Settings Groups
            _buildSectionTitle("ACCOUNT"),
            _buildOption(Icons.person_outline, "Profile Settings", Colors.blueAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()));
            }),
            _buildOption(Icons.webhook_outlined, "Webhook", Colors.orangeAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WebhookScreen()));
            }),
            
            const SizedBox(height: 24),
            _buildSectionTitle("LEARNING"),
            _buildOption(Icons.map_outlined, "View Tour Guide", Colors.amberAccent, () {
              showDialog(
                context: context,
                builder: (context) => AppTour(onFinish: () => Navigator.pop(context)),
              );
            }),
            _buildOption(Icons.psychology_outlined, "Tutorial AI", Colors.purpleAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TutorialAIScreen()));
            }),
            _buildOption(Icons.video_library_outlined, "Video Tutorials", Colors.redAccent, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TutorialsListScreen()));
            }),
            
            const SizedBox(height: 24),
            _buildSectionTitle("SUPPORT"),
             _buildOption(Icons.contact_support_outlined, "Contact Us", Colors.greenAccent, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
             }),
            
            const SizedBox(height: 48),
            const Center(
              child: Text(
                "Version 1.2.0 (Build 42)",
                style: TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildProfileHeader(WidgetRef ref) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      color: AppColors.cardSurface,
      opacity: 0.5,
      child: Row(
        children: [
          const ProfileAvatar(radius: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.watch(authProvider).user?.name ?? "CryptoArth User",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  "Pro Trader • Active Strategy",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code, color: AppColors.cyan),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderRadius: 16,
          color: AppColors.cardSurface,
          opacity: 0.3,
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
