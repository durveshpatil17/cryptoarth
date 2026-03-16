import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final bgColor = AppColors.getBackground(context);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.04), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.05),
            blurRadius: 40,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.auto_awesome_rounded, "AI BUILDER"),
              _buildNavItem(context, 1, Icons.explore_rounded, "MARKET"),
              _buildNavItem(context, 2, Icons.wallet_rounded, "PORTFOLIO"),
              _buildNavItem(context, 3, Icons.dns_rounded, "ORDERS"),
              _buildNavItem(context, 4, Icons.account_circle_rounded, "PROFILE"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;
    final Color activeColor = AppColors.gold; 
    final isDark = AppColors.isDarkMode(context);
    
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap(index);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (index == 0 && isSelected)
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.aiBuilderGradient.createShader(bounds),
                  child: Column(
                    children: [
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? activeColor : (isDark ? Colors.white24 : Colors.black26),
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? activeColor : (isDark ? Colors.white24 : Colors.black26),
                        fontSize: 8,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: isSelected ? 4 : 0,
                height: 4,
                decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: isSelected ? (index == 0 ? const Color(0xFF9D50BB) : activeColor) : Colors.transparent,
                   boxShadow: isSelected ? [
                     BoxShadow(color: (index == 0 ? const Color(0xFF9D50BB) : activeColor).withOpacity(0.4), blurRadius: 8),
                   ] : [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
