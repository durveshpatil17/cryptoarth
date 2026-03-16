import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';
import 'package:cryptoarth/features/home/screens/main_screen.dart';

import 'package:flutter/services.dart';
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
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  bool _showSuccessBanner = true;
  bool _obscureOtp = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  void onChanged(String value, int index) {
    if (value.isNotEmpty) {
      HapticFeedback.lightImpact();
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
        verifyOtp(); // Auto verify on last digit
      }
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  String getOtp() {
    return controllers.map((c) => c.text).join();
  }

  void verifyOtp() {
    HapticFeedback.mediumImpact();
    final otp = getOtp();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ENTER COMPLETE CODE")),
      );
      return;
    }
    verify(otp);
  }

  Future<void> verify(String otp) async {
    bool success = false;
    if (widget.isSignup) {
      if (widget.signupData == null) return;
      success = await ref.read(authProvider.notifier).signup(
            phone: widget.mobileNumber,
            otp: otp,
            email: widget.signupData!['email'] ?? '',
            firstName: widget.signupData!['first_name'] ?? '',
            lastName: widget.signupData!['last_name'] ?? '',
          );
    } else {
      success = await ref.read(authProvider.notifier).login(widget.mobileNumber, otp);
    }

    if (!mounted) return;
    if (success) {
      HapticFeedback.heavyImpact();
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
    } else {
      HapticFeedback.vibrate();
      final error = ref.read(authProvider).error;
      setState(() {
        _errorMessage = error ?? "INVALID AUTHENTICATION CODE";
      });
      // Auto-clear error after 3 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _errorMessage = null);
      });
    }
  }

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.richBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white38, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LuxuryBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Content Flow
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Success Banner Area
                              AnimatedSize(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOutQuart,
                                child: _showSuccessBanner 
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            _buildBlinkingDot(AppColors.primary),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Text(
                                                "SECURE CHANNEL ESTABLISHED. AWAITING CODE.",
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, color: AppColors.primary, size: 14),
                                              onPressed: () => setState(() => _showSuccessBanner = false),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox(height: 20),
                              ),

                              const Spacer(flex: 1),

                              // 2. Identity Icon Core
                              Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (_errorMessage != null)
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        duration: const Duration(milliseconds: 400),
                                        builder: (context, val, child) {
                                          return Container(
                                            width: 120 * val,
                                            height: 120 * val,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.red.withOpacity(0.3 * val),
                                                  blurRadius: 30 * val,
                                                  spreadRadius: 10 * val,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                         shape: BoxShape.circle,
                                         color: (_errorMessage != null 
                                           ? Colors.red 
                                           : AppColors.primary).withOpacity(0.05),
                                         boxShadow: [
                                           BoxShadow(
                                             color: (_errorMessage != null 
                                               ? Colors.red 
                                               : AppColors.primary).withOpacity(0.1), 
                                             blurRadius: 40, spreadRadius: -5
                                           ),
                                         ],
                                         border: Border.all(
                                           color: (_errorMessage != null 
                                             ? Colors.red 
                                             : AppColors.primary).withOpacity(0.2), 
                                           width: 1
                                         ),
                                      ),
                                      child: Icon(
                                        _errorMessage != null ? Icons.gpp_bad_rounded : Icons.lock_open_rounded, 
                                        color: _errorMessage != null ? Colors.redAccent : AppColors.primary, 
                                        size: 40
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // 3. Text Header
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      _errorMessage != null ? "AUTHORIZATION FAILED" : "IDENTIFICATION REQUIRED",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _errorMessage != null ? Colors.redAccent : Colors.white, 
                                        fontSize: 20, 
                                        fontWeight: FontWeight.w900, 
                                        letterSpacing: 2,
                                        shadows: [
                                          Shadow(color: (_errorMessage != null ? Colors.red : AppColors.primary).withOpacity(0.5), blurRadius: 10),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (_errorMessage != null)
                                      Text(
                                        _errorMessage!.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                                      )
                                    else
                                      Text(
                                        "ENCRYPTED ACCESS CODE SENT TO +91 ${widget.mobileNumber}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.secondary.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 48),

                              // 4. OTP Input Area
                              Center(
                                child: FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(6, (index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: _buildOtpField(index),
                                      );
                                    }),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // 5. Action Button
                              Consumer(
                                builder: (context, ref, child) {
                                  final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
                                  if (isLoading) {
                                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                                  }
                                  return CustomButton(
                                    text: "AUTHENTICATE",
                                    onPressed: verifyOtp,
                                  );
                                },
                              ),

                              const SizedBox(height: 32),

                              // 6. Resend Timer
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.cyan),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "RESEND AVAILABLE IN 59S",
                                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                                  ),
                                ],
                              ),
                              
                              const Spacer(flex: 2),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return GlassContainer(
      borderRadius: 16,
      color: AppColors.jewelGreen,
      opacity: 0.06,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: AppColors.cyan.withOpacity(0.1),
                 ),
                 child: const Icon(Icons.security_rounded, color: AppColors.cyan, size: 18),
               ),
               const SizedBox(width: 12),
               const Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text("SECURE CODE DISPATCHED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
                     Text("Validated by CryptoArth", style: TextStyle(color: Colors.white24, fontSize: 8)),
                   ],
                 ),
               ),
               IconButton(
                 iconSize: 16,
                 padding: EdgeInsets.zero,
                 constraints: const BoxConstraints(),
                 icon: Icon(Icons.close, color: Colors.white.withOpacity(0.2)), 
                 onPressed: () => setState(() => _showSuccessBanner = false),
               ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
             width: double.infinity,
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
             decoration: BoxDecoration(
               color: Colors.black26,
               borderRadius: BorderRadius.circular(10),
               border: Border.all(color: Colors.white.withOpacity(0.05)),
             ),
             child: Row(
               children: [
                  const Icon(Icons.phone_android, color: Colors.white54, size: 12),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Sent to ${widget.mobileNumber}",
                      style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w500),
                    ),
                  ),
               ],
             ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
               _buildBadge("LIVE", AppColors.primary),
               const SizedBox(width: 10),
               _buildBadge("SECURE", Colors.blueAccent),
               const Spacer(),
               const Icon(Icons.chat_bubble_outline, color: Colors.white24, size: 10),
            ],
          ),
          const SizedBox(height: 8),
          // Animated Progress Bar shell
          Container(
            height: 2,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(2),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 3), // Faster Loading Line
              onEnd: () => setState(() => _showSuccessBanner = false),
              builder: (context, value, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                         BoxShadow(
                           color: AppColors.primary.withOpacity(0.5),
                           blurRadius: 6,
                           spreadRadius: 1,
                         ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildOtpField(int index) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) HapticFeedback.lightImpact();
        setState(() {}); // Redraw to update glow
      },
      child: Container(
        width: 44,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _errorMessage != null 
              ? AppColors.jewelRed.withOpacity(0.5)
              : focusNodes[index].hasFocus 
                ? AppColors.eliteEmerald 
                : Colors.white.withOpacity(0.08),
            width: focusNodes[index].hasFocus ? 1.0 : 0.5,
          ),
          boxShadow: _errorMessage != null
            ? [BoxShadow(color: AppColors.jewelRed.withOpacity(0.2), blurRadius: 10, spreadRadius: -1)]
            : focusNodes[index].hasFocus ? [
              BoxShadow(color: AppColors.eliteEmerald.withOpacity(0.3), blurRadius: 10, spreadRadius: -1),
            ] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              color: Colors.white.withOpacity(0.06),
              child: RawKeyboardListener(
                focusNode: FocusNode(), // Dummy to catch keys
                onKey: (event) {
                  if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                    if (controllers[index].text.isEmpty && index > 0) {
                      focusNodes[index - 1].requestFocus();
                    }
                  }
                },
                child: TextField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  textAlign: TextAlign.center,
                  autofocus: index == 0,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  obscureText: _obscureOtp,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()]),
                  decoration: const InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => onChanged(v, index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
