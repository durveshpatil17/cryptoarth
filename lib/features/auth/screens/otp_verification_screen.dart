import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/features/home/screens/main_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {

  final String mobileNumber;

  const OtpVerificationScreen({
    super.key,
    required this.mobileNumber,
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
    final success = await ref.read(authProvider.notifier).login(widget.mobileNumber, otp);

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

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(

          children: [

            const SizedBox(height: 30),

            Text(
              "OTP sent to +91 ${widget.mobileNumber}",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: List.generate(6, (index) {

                return SizedBox(

                  width: 45,

                  child: TextField(

                    controller: controllers[index],
                    focusNode: focusNodes[index],

                    textAlign: TextAlign.center,

                    maxLength: 1,

                    keyboardType: TextInputType.number,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),

                    decoration: InputDecoration(

                      counterText: "",

                      filled: true,

                      fillColor: AppColors.cardSurface,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),

                    onChanged: (v) =>
                        onChanged(v, index),
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
