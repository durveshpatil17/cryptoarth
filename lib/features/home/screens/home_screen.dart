import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/custom_drawer.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';
import 'package:cryptoarth/shared/widgets/notifications_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: "Crypto", style: TextStyle(color: AppColors.cyan)),
              TextSpan(text: "Arth AI", style: TextStyle(color: AppColors.purple)), // Using Purple for 'Arth AI' based on logo gradient hint
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const NotificationsDialog(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ProfileAvatar(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background subtle gradients
          Positioned(
             top: 50,
             left: 0,
             right: 0,
             child: Center(
               child: Container(
                 width: 200,
                 height: 200,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: AppColors.purple.withOpacity(0.15),
                 ),
               ),
             ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Central Icon/Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.purple, AppColors.cyan],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyan.withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 60),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          const Text(
                            "Build Your Strategy",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          const Text(
                            "Describe your trading idea in plain\nEnglish and let AI create your strategy\ninstantly",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat("1K+", "Strategies", AppColors.primary),
                              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                              _buildStat("50K+", "Users", AppColors.cyan),
                              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                              _buildStat("99.9%", "Accuracy", AppColors.purple),
                            ],
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Quick Action Chips
                          Row(
                            children: [
                              Expanded(child: _buildActionChip(Icons.lightbulb_outline, "RSI oversold\nbuy")),
                              const SizedBox(width: 16),
                              Expanded(child: _buildActionChip(Icons.lightbulb_outline, "MACD\ncrossover")),
                            ],
                          ),
                          
                          const SizedBox(height: 100), // Space for bottom input
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom Input Area
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GlassContainer(
                    borderRadius: 24,
                    color: AppColors.cardSurface,
                    opacity: 0.8,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: AppColors.cyan),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Describe your strategy...",
                              hintStyle: TextStyle(color: AppColors.textSecondary),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.mic_none, color: AppColors.purple),
                          onPressed: () {},
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 20),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                 // Indicators below input
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator(AppColors.primary, "AI-Powered"),
                      const SizedBox(width: 16),
                      _buildIndicator(AppColors.cyan, "Real-time"),
                      const SizedBox(width: 16),
                      _buildIndicator(AppColors.purple, "Instant"),
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

  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
