import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import '../providers/tutorial_provider.dart';

class TutorialAIScreen extends ConsumerStatefulWidget {
  const TutorialAIScreen({super.key});

  @override
  ConsumerState<TutorialAIScreen> createState() => _TutorialAIScreenState();
}

class _TutorialAIScreenState extends ConsumerState<TutorialAIScreen> {
  String? selectedDemo;
  String? selectedLanguage;
  bool isDemoStarted = false;

  final List<String> demoTypes = [
    "Sign up",
    "Sign in",
    "AI Builder",
    "Complete Tutorial",
  ];

  final List<String> languages = [
    "Hindi",
    "English",
    "Marathi",
    "Gujarati",
    "Tamil",
    "Telugu",
    "Kannada",
    "Bengali",
    "Malayalam",
  ];

  Future<void> _handleStartDemo() async {
    if (selectedDemo == null || selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select demo type and language"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Call the API
    await ref.read(tutorialAiNotifierProvider.notifier).generateTutorial(
      selectedDemo!,
      selectedLanguage!,
    );

    if (mounted) {
      final state = ref.read(tutorialAiNotifierProvider);
      state.when(
        data: (_) {
          setState(() => isDemoStarted = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tutorial generation started successfully!"),
              backgroundColor: AppColors.green,
            ),
          );
        },
        loading: () {}, // Handled by button UI
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to start tutorial: $err"),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorialState = ref.watch(tutorialAiNotifierProvider);
    final isLoading = tutorialState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tutorial AI",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Presentation (AI Binder Active)",
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildControlBar(isLoading),
              const SizedBox(height: 48),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isDemoStarted) ...[
                      const Text(
                        "Select demo type and language",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Choose a demo from the dropdown, select your language, then click Start Demo.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const Icon(Icons.auto_awesome, color: AppColors.cyan, size: 80),
                      const SizedBox(height: 24),
                      Text(
                        "Processing: $selectedDemo",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Output Language: $selectedLanguage",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "AI is preparing your visual presentation...",
                        style: TextStyle(color: AppColors.cyan, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  "© 2025 All rights reserved by DeMatade Algo Technology Solutions Private Limited",
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBar(bool isLoading) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      color: const Color(0xFF1E293B),
      opacity: 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildMicIcon(true),
              const SizedBox(width: 10),
              _buildMicIcon(false),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  "Demo Type",
                  selectedDemo,
                  demoTypes,
                  (val) => setState(() => selectedDemo = val),
                  isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Language",
                  selectedLanguage,
                  languages,
                  (val) => setState(() => selectedLanguage = val),
                  isLoading,
                ),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                isLoading ? "..." : "Start", 
                AppColors.cyan, 
                isLoading ? () {} : _handleStartDemo
              ),
              const SizedBox(width: 8),
              _buildActionButton("Reset", Colors.transparent, () {
                setState(() {
                  selectedDemo = null;
                  selectedLanguage = null;
                  isDemoStarted = false;
                });
              }, isReset: true, isDisabled: isLoading),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicIcon(bool isEnabled) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: isEnabled ? AppColors.green.withOpacity(0.4) : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.mic_none,
          color: isEnabled ? AppColors.green : Colors.white.withOpacity(0.4),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, Function(String?) onChanged, bool isDisabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
          isExpanded: true,
          dropdownColor: const Color(0xFF0F172A),
          icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white38),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: isDisabled ? null : onChanged,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap, {bool isReset = false, bool isDisabled = false}) {
    final bool isStart = label == "Start" || label == "...";
    
    return ElevatedButton(
      onPressed: (isDisabled || label == "...") ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color == Colors.transparent ? Colors.transparent : color,
        disabledBackgroundColor: color.withOpacity(0.3),
        foregroundColor: isStart ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: isReset ? BorderSide(color: Colors.white.withOpacity(0.2)) : BorderSide.none,
        ),
        elevation: 0,
      ).copyWith(
        elevation: WidgetStateProperty.all(0.0),
      ),
      child: label == "..." 
        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
        : Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isStart ? Colors.black : (isReset ? Colors.white60 : Colors.white),
            ),
          ),
    );
  }
}
