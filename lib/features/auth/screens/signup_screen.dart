import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/shared/widgets/custom_text_field.dart';
import 'package:cryptoarth/features/auth/screens/otp_verification_screen.dart';
import 'package:cryptoarth/features/auth/screens/login_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  
  bool _agreedToTerms = false;

  void _sendOtp() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid 10-digit mobile number")),
      );
      return;
    }
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to our terms & conditions")),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).sendOtp(mobile);
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            mobileNumber: mobile,
            isSignup: true,
            signupData: {
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
            },
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Back to Home",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              /// Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.rocket_launch, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 8),
                    Text(
                      "CREATE ACCOUNT",
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Join Crypto Arth Pro",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Create your trading account in minutes",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              /// Name Fields in a Row
              Row(
                children: [
                   Expanded(
                     child: CustomTextField(
                      label: "First Name",
                      hint: "John",
                      icon: Icons.person_outline,
                      controller: firstNameController,
                    ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: CustomTextField(
                      label: "Last Name",
                      hint: "Doe",
                      icon: Icons.person_outline,
                      controller: lastNameController,
                    ),
                   ),
                ],
              ),
              
              const SizedBox(height: 20),

              /// Email Field
              CustomTextField(
                label: "Email Address",
                hint: "trading@example.com",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),

              const SizedBox(height: 20),

              /// Mobile Field
              CustomTextField(
                label: "Mobile Number",
                hint: "Enter 10-digit number",
                prefixText: "+91",
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                controller: mobileController,
              ),

              const SizedBox(height: 24),
              
              /// Terms Checkbox
              Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   SizedBox(
                     height: 24,
                     width: 24,
                     child: Checkbox(
                       value: _agreedToTerms, 
                       onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                       activeColor: AppColors.primary,
                       side: const BorderSide(color: Colors.white24),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                     ),
                   ),
                   const SizedBox(width: 12),
                   const Expanded(
                     child: Text.rich(
                       TextSpan(
                         text: "I agree to the ",
                         style: TextStyle(color: Colors.white54, fontSize: 13),
                         children: [
                           TextSpan(text: "Terms of Service", style: TextStyle(color: Color(0xFF10B981))),
                           TextSpan(text: " and "),
                           TextSpan(text: "Privacy Policy", style: TextStyle(color: Color(0xFF10B981))),
                           TextSpan(text: ". I understand that Crypto Arth provides trading technology only and I am responsible for all trading decisions."),
                         ]
                       ),
                       style: TextStyle(height: 1.4),
                     ),
                   )
                 ],
              ),

              const SizedBox(height: 32),

              /// Signup Button
              authState.isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) 
                : CustomButton(
                    text: "SEND OTP & CONTINUE",
                    icon: Icons.bolt,
                    onPressed: _sendOtp,
                  ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                    },
                    child: const Text(
                      "Sign In with OTP",
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              
              // Bottom Card Placeholder for "PASSWORDLESS AUTHENTICATION"
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 16),
                        const SizedBox(width: 8),
                         Text(
                          "PASSWORDLESS AUTHENTICATION",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBadgeItem(Icons.phone_android, "Mobile OTP Login"),
                        _buildBadgeItem(Icons.no_encryption_gmailerrorred, "No Passwords"),
                        _buildBadgeItem(Icons.flash_on, "Instant Access"),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange.withOpacity(0.7), size: 12),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    );
  }
}
