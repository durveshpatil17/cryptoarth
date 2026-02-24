import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/features/strategies/providers/copilot_provider.dart';

import 'package:cryptoarth/core/utils/time_utils.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(chatHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Click to continue conversation',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.purple.withOpacity(0.5)),
                color: AppColors.purple.withOpacity(0.1),
              ),
              child: const Icon(Icons.history, color: AppColors.purple, size: 20),
            ),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text("No chat history found", style: TextStyle(color: Colors.white54)));
          }

          return Column(
            children: [
              // Header Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        "Total Sessions: ${sessions.length}",
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "Click any chat to continue",
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white10),
              
              // Chat List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: sessions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final String title = session['title'] ?? session['summary'] ?? "Untitled Chat";
                    final String date = TimeUtils.formatRelativeTime(session['created_at']?.toString());
                    
                    return InkWell(
                      onTap: () {
                        final String? sessionId = session['session_id']?.toString() ?? session['id']?.toString();
                        if (sessionId != null) {
                          ref.read(copilotProvider.notifier).loadSession(sessionId);
                          Navigator.pop(context); // Go back to Home / AI Chat
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Error: Session ID missing")),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.chat_bubble_outline, color: AppColors.purple, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Session ID: ${session['session_id'] ?? 'N/A'}",
                                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  date,
                                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                                ),
                                const SizedBox(height: 4),
                                const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPaginationButton("Prev", Icons.chevron_left, false),
                    const Text(
                      "Page 1 of 1",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    _buildPaginationButton("Next", Icons.chevron_right, true),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
        error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildPaginationButton(String label, IconData icon, bool isNext) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            if (!isNext) Icon(icon, color: AppColors.textSecondary, size: 16),
            if (!isNext) const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
            if (isNext) const SizedBox(width: 8),
            if (isNext) Icon(icon, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
