import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

class LuxuryBackground extends StatefulWidget {
  final Widget child;
  const LuxuryBackground({super.key, required this.child});

  @override
  State<LuxuryBackground> createState() => _LuxuryBackgroundState();
}

class _LuxuryBackgroundState extends State<LuxuryBackground> with TickerProviderStateMixin {
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.getBackground(context);
    final isDark = AppColors.isDarkMode(context);

    return Stack(
      children: [
        // 1. Dynamic Luxury Base
        Container(
          decoration: BoxDecoration(
            color: bgColor,
          ),
        ),
        
        // 2. Smooth, Slow Ambient Drifting Orbs (Atmospheric)
        AnimatedBuilder(
          animation: _orbController,
          builder: (context, child) {
            return Stack(
              children: [
                _buildAtmosphericLight(
                  size: 600,
                  color: AppColors.gold.withOpacity(isDark ? 0.04 : 0.08), 
                  alignment: Alignment(
                    math.cos(_orbController.value * 2 * math.pi) * 0.7,
                    math.sin(_orbController.value * 2 * math.pi) * 0.8,
                  ),
                ),
                _buildAtmosphericLight(
                  size: 800,
                  color: AppColors.sapphire.withOpacity(isDark ? 0.04 : 0.06), 
                  alignment: Alignment(
                    math.sin(_orbController.value * 2 * math.pi) * 0.5,
                    math.cos(_orbController.value * 2 * math.pi) * 0.9,
                  ),
                ),
              ],
            );
          },
        ),

        // 3. Subtle Vignette For Depth (Lighter in light mode)
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.transparent,
                bgColor.withOpacity(isDark ? 0.6 : 0.1),
                bgColor,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        ),
        
        // 4. Content
        widget.child,
      ],
    );
  }

  Widget _buildAtmosphericLight({required double size, required Color color, required Alignment alignment}) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
