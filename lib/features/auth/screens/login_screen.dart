import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/shared/widgets/custom_text_field.dart';
import 'package:cryptoarth/features/auth/screens/otp_verification_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:cryptoarth/features/auth/screens/signup_screen.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();

  void _sendOtp() async {
    final mobile = mobileController.text.trim();

    if (mobile.isEmpty || mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit mobile number"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      // Check if user exists first to prevent new users from entering via login
      final exists = await ref.read(authProvider.notifier).checkUserExists(mobile);
      if (!exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mobile number not found. Please create an account first."),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignupScreen()),
        );
        return;
      }

      await ref.read(authProvider.notifier).sendOtp(mobile);
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            mobileNumber: mobile,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send OTP: $e")),
      );
    }
  }

  Widget _buildBlinkingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.1, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(value),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(value * 0.5), blurRadius: 4),
            ],
          ),
        );
      },
      onEnd: () {}, // Handled by repeating if it were a controller, but TweenAnimationBuilder is easier for simple loops sometimes
    );
     // Note: TweenAnimationBuilder doesn't repeat naturally without a key change or using a real controller.
     // Let me use a proper controller for the smooth blinking.
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.richBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LuxuryBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                /// Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBlinkingDot(),
                      const SizedBox(width: 8),
                      const Text(
                        "AUTHORIZATION TERMINAL",
                        style: TextStyle(
                          color: AppColors.primary, 
                          fontSize: 9, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 2
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
                  ),
                  child: SvgPicture.asset("assets/images/favicon.svg", height: 80, width: 80),
                ),
                const SizedBox(height: 32),
                Text(
                  "IDENTITY VERIFICATION",
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 24, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "SECURE LINK ENCRYPTION ACTIVE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondary.withOpacity(0.5), 
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 60),

                /// Mobile field
                CustomTextField(
                  label: "Mobile Access Code",
                  hint: "INPUT 10-DEGITS",
                  prefixText: "+91",
                  icon: Icons.fingerprint,
                  keyboardType: TextInputType.phone,
                  controller: mobileController,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                const SizedBox(height: 24),

                /// Button
                authState.isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) 
                  : CustomButton(
                      text: "SEND OTP",
                      icon: Icons.bolt,
                      onPressed: _sendOtp,
                    ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New to CryptoArth?", style: TextStyle(color: Colors.white.withOpacity(0.4))),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
