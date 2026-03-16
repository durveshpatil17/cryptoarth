import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/features/strategies/providers/copilot_provider.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/core/utils/time_utils.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(chatHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.digitalVoidBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHAT LOGS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 0.8),
            ),
            Text(
              'HISTORY OF AI STRATEGY DIALOGUES',
              style: TextStyle(fontSize: 8, color: AppColors.cyan.withOpacity(0.5), fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.history, color: AppColors.purple.withOpacity(0.4), size: 20),
          ),
        ],
      ),
      body: LuxuryBackground(
        child: historyAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return const Center(child: Text("NO ARCHIVED DIALOGUES FOUND", style: TextStyle(color: Colors.white10, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)));
            }
  
            return Column(
              children: [
                const SizedBox(height: 100),
                // Header Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Text(
                          "TOTAL SESSIONS: ${sessions.length}",
                          style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.info_outline, size: 14, color: Colors.white12),
                    ],
                  ),
                ),
                
                // Chat List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    itemCount: sessions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final String title = session['title'] ?? session['summary'] ?? "Untitled Operation";
                      final String date = TimeUtils.formatRelativeTime(session['created_at']?.toString());
                      final String? sessionId = session['session_id']?.toString() ?? session['id']?.toString();
                      
                      return InkWell(
                        onTap: () {
                          if (sessionId != null) {
                            HapticFeedback.mediumImpact();
                            ref.read(copilotProvider.notifier).loadSession(sessionId);
                            Navigator.pop(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.purple.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.purple.withOpacity(0.1)),
                                ),
                                child: const Icon(Icons.webhook_outlined, color: AppColors.purple, size: 18),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "ID: ${session['session_id'] ?? 'N/A'}",
                                      style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    date.toUpperCase(),
                                    style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 8, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 8),
                                  const Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 10),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
  
                // Pagination Controls
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPaginationButton("PREV", Icons.keyboard_arrow_left, false),
                      Text(
                        "PAGE 01 / 01",
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                      ),
                      _buildPaginationButton("NEXT", Icons.keyboard_arrow_right, true),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 1)),
          error: (e, s) => Center(child: Text("DISTURBANCE ENCOUNTERED: $e", style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  Widget _buildPaginationButton(String label, IconData icon, bool isNext) {
    return InkWell(
      onTap: () => HapticFeedback.selectionClick(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            if (!isNext) Icon(icon, color: Colors.white24, size: 14),
            if (!isNext) const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
            ),
            if (isNext) const SizedBox(width: 10),
            if (isNext) Icon(icon, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }
}
