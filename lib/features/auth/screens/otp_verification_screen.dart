import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/features/home/screens/main_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {

  final String mobileNumber;
  final bool isSignup;
  final Map<String, dynamic>? signupData;

  const OtpVerificationScreen({
    super.key,
    required this.mobileNumber,
    this.isSignup = false,
    this.signupData,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState()
      => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _obscureOtp = true;

  void onChanged(String value, int index) {

    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  String getOtp() {

    return controllers.map((c) => c.text).join();
  }

  void verifyOtp() {

    final otp = getOtp();

    if (otp.length != 6) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter complete OTP"),
        ),
      );

      return;
    }

    verify(otp);
  }

  Future<void> verify(String otp) async {
    bool success = false;
    
    if (widget.isSignup) {
      if (widget.signupData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup data missing! Please try again.")),
        );
        return;
      }
      
      final String firstName = widget.signupData!['first_name'] ?? '';
      final String lastName = widget.signupData!['last_name'] ?? '';
      final String email = widget.signupData!['email'] ?? '';
      
      if (firstName.isEmpty || email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Critical registration data missing.")),
        );
        return;
      }

      success = await ref.read(authProvider.notifier).signup(
        phone: widget.mobileNumber,
        otp: otp,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
    } else {
      success = await ref.read(authProvider.notifier).login(widget.mobileNumber, otp);
    }

    if (!mounted) return;

    if (success) {
      /// Navigate to main app
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
        (route) => false,
      );
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? "Invalid OTP! Try again."),
        ),
      );
    }
  }

  @override
  void dispose() {

    for (var c in controllers) {
      c.dispose();
    }

    for (var f in focusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textSecondary,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          "Verify OTP",
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              "OTP sent to +91 ${widget.mobileNumber}",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(child: Text("Enter 6-digit Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                TextButton.icon(
                  onPressed: () => setState(() => _obscureOtp = !_obscureOtp),
                  icon: Icon(_obscureOtp ? Icons.visibility : Icons.visibility_off, color: AppColors.primary, size: 18),
                  label: Text(_obscureOtp ? "Show" : "Hide", style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        obscureText: _obscureOtp,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: AppColors.cardSurface,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (v) => onChanged(v, index),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            ref.watch(authProvider).isLoading 
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: "VERIFY & ACCESS PANEL",
                    onPressed: verifyOtp,
                  ),
          ],
        ),
      ),
    );
  }
}
