import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/shared/widgets/custom_text_field.dart';
import 'package:cryptoarth/features/auth/screens/otp_verification_screen.dart';
import 'package:cryptoarth/features/auth/screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

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

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void _sendOtp() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (email.isEmpty || !_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (mobile.isEmpty || mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid 10-digit mobile number"), backgroundColor: Colors.redAccent),
      );
      return;
    }
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to our terms & conditions"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    try {
      final exists = await ref.read(authProvider.notifier).checkUserExists(mobile);
      if (exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mobile number already registered. Please Login."),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        return;
      }

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

  Widget _buildBlinkingDot(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.2, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(value),
            boxShadow: [
              BoxShadow(color: color.withOpacity(value * 0.5), blurRadius: 4),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.digitalVoidBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white38, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
                const SizedBox(height: 10),

                /// Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBlinkingDot(AppColors.secondary),
                      const SizedBox(width: 8),
                      const Text(
                        "REGISTRATION PROTOCOL",
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary.withOpacity(0.2), width: 1),
                  ),
                  child: SvgPicture.asset("assets/images/favicon.svg", height: 60, width: 60),
                ),
                const SizedBox(height: 24),
                Text(
                  "CREATE PROTOCOL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: AppColors.secondary.withOpacity(0.5), blurRadius: 10),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "UNLEASH INSTITUTIONAL ALGORITHMS",
                  style: TextStyle(
                    color: AppColors.secondary.withOpacity(0.5),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),

                const SizedBox(height: 40),

                /// Name Fields in a Row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "First Name",
                        hint: "PHOENIX",
                        icon: Icons.person_outline,
                        controller: firstNameController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: "Last Name",
                        hint: "ALPHA",
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
                  hint: "ops@cryptoarth.in",
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
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                        activeColor: AppColors.eliteEmerald,
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
                            TextSpan(text: "Terms of Service", style: TextStyle(color: AppColors.eliteEmerald)),
                            TextSpan(text: " and "),
                            TextSpan(text: "Privacy Policy", style: TextStyle(color: AppColors.eliteEmerald)),
                            TextSpan(text: ". I understand that Crypto Arth provides trading technology only."),
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
                      text: "INITIALIZE PROTOCOL",
                      icon: Icons.bolt,
                      onPressed: _sendOtp,
                    ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white.withOpacity(0.4)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
