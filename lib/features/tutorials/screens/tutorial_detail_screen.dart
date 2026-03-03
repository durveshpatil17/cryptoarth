import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';

class TutorialDetailScreen extends StatelessWidget {
  final dynamic tutorial;

  const TutorialDetailScreen({super.key, required this.tutorial});

  @override
  Widget build(BuildContext context) {
    final title = tutorial['title'] ?? 'Tutorial Details';
    final content = tutorial['content'] ?? 'No content available.';
    final videoUrl = tutorial['video_url'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (videoUrl != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 64),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (tutorial['category'] ?? 'GENERAL').toString().toUpperCase(),
                    style: const TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  tutorial['duration'] ?? '5:00',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              content,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 40),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Row(
                children: [
                   const Icon(Icons.info_outline, color: AppColors.cyan),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Text(
                       "For more help, you can always ask our AI Copilot in the main chat.",
                       style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
