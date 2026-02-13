import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  // Mock Data
  final List<Map<String, dynamic>> _chatSessions = [
    {
      "id": 1,
      "title": "Ema (9/21 EMA) Strategy",
      "messageCount": 0,
      "date": "Feb 10 at 06:24 PM",
      "isActive": false,
    },
    {
      "id": 2,
      "title": "Ema (9/21 EMA) Backtest Analysis",
      "messageCount": 3,
      "date": "Feb 9 at 02:45 PM",
      "isActive": false,
    },
    {
      "id": 3,
      "title": "Bollinger Bands Squeeze Setup",
      "messageCount": 12,
      "date": "Feb 5 at 01:17 PM",
      "isActive": true, // Example active state
    },
  ];

  @override
  Widget build(BuildContext context) {
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
      body: Column(
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
                    "Total Sessions: ${_chatSessions.length + 4}", // Mock total
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
              itemCount: _chatSessions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final session = _chatSessions[index];
                final bool isActive = session['isActive'];
                
                return InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Opening '${session['title']}'...")),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive 
                            ? AppColors.purple 
                            : Colors.white.withOpacity(0.05),
                        width: isActive ? 1.5 : 1,
                      ),
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: AppColors.purple.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                        )
                      ] : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.message, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${session['messageCount']} messages",
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        session['date'],
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E1117), // Darker inner bg
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Click to continue this conversation",
                            style: TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                        ),
                        
                        if (isActive)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Click to continue chat",
                                  style: TextStyle(color: AppColors.purple.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward, size: 14, color: AppColors.purple),
                              ],
                            ),
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
                  "Page 1 of 3",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                _buildPaginationButton("Next", Icons.chevron_right, true),
              ],
            ),
          ),
        ],
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
