import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/shared/widgets/custom_text_field.dart';
import 'package:cryptoarth/features/auth/screens/otp_verification_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final TextEditingController mobileController = TextEditingController();

  void _sendOtp(BuildContext context, WidgetRef ref) async {
    final mobile = mobileController.text.trim();

    if (mobile.isEmpty || mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter valid 10-digit mobile number"),
        ),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).sendOtp(mobile);
      if (!context.mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            mobileNumber: mobile,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send OTP: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Back",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        titleSpacing: 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              const SizedBox(height: 20),

              /// Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),

                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),

                    SizedBox(width: 8),

                    Text(
                      "SECURE SIGN IN",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "Sign In to Your Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Enter your mobile number to access dashboard",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 48),

              /// Mobile field
              CustomTextField(
                label: "Mobile Number",
                hint: "Enter 10-digit number",
                prefixText: "+91",
                keyboardType: TextInputType.phone,
                controller: mobileController,
              ),

              const SizedBox(height: 24),

              /// Button
              authState.isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : CustomButton(
                    text: "SEND OTP",
                    icon: Icons.bolt,
                    onPressed: () => _sendOtp(context, ref),
                  ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text(
                    "New to CryptoArth?",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
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
    );
  }
}
