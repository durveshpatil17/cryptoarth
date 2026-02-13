import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedTab = 0; // 0: Predefined, 1: My Strategies

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Strategy Marketplace',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Deploy and manage your AI trading strategies',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
             onPressed: () {}, 
             icon: const Icon(Icons.search, color: Colors.white70),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ProfileAvatar(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Tab Bar
              Container(
                 padding: const EdgeInsets.all(4),
                 decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                 ),
                 child: Row(
                    children: [
                       Expanded(child: _buildTabButton(0, "Predefined", "3", const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)]))), // Purple-Pink Gradient
                       Expanded(child: _buildTabButton(1, "My Strategies", "0", null)),
                    ],
                 ),
              ),

              const SizedBox(height: 24),

              // Strategy List
              _buildStrategyList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title, String count, Gradient? activeGradient) {
     final bool isSelected = _selectedTab == index;
     return GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
           padding: const EdgeInsets.symmetric(vertical: 12),
           decoration: BoxDecoration(
              gradient: isSelected ? activeGradient : null,
              color: isSelected && activeGradient == null ? const Color(0xFF1E1E2E) : Colors.transparent, // Fallback color if no gradient
              borderRadius: BorderRadius.circular(8),
           ),
           child: Column(
              children: [
                 Text(
                    title,
                    style: TextStyle(
                       color: isSelected ? Colors.white : Colors.white70,
                       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                       fontSize: 12,
                    ),
                 ),
                 const SizedBox(height: 4),
                 Text(
                    count,
                    style: TextStyle(
                       color: isSelected ? Colors.white : Colors.white70,
                       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                       fontSize: 16,
                    ),
                 ),
              ],
           ),
        ),
     );
  }

  Widget _buildStrategyList() {
     // Mock Data for "Predefined"
     if (_selectedTab == 0) {
        return Column(
           children: [
              _StrategyCard(
                 title: "200 EMA High/Low Breakout",
                 author: "Pawan Matade",
                 time: "5 days ago",
                 initials: "PM",
                 status: "Waiting",
                 realPnl: "+0.00",
                 winRate: "0%",
                 drawdown: "0%",
                 ticker: "-100.0% BTCUSD 15W", // Placeholder string from screenshot
                 isLive: false,
              ),
              const SizedBox(height: 16),
              _StrategyCard(
                 title: "SuperTrend ETH Trend Following",
                 author: "Pawan Matade",
                 time: "5 days ago",
                 initials: "PM", // Placeholder avatar
                 status: "Waiting",
                 realPnl: "+0.00",
                 winRate: "25%",
                 drawdown: "0%",
                 ticker: "74.9% BTCUSD 15M",
                 isLive: false,
              ),
              const SizedBox(height: 16),
              _StrategyCard(
                 title: "RSI Pro Strategy",
                 author: "Pawan Matade",
                 time: "3 days ago",
                 initials: "PM",
                 status: "Active",
                 realPnl: "+15.50",
                 winRate: "68%",
                 drawdown: "12%",
                 ticker: "89.2% ETHUSD 1H",
                 isLive: false,
              ),
           ],
        );
     } else {
        return Center(
           child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text("No strategies created yet.", style: TextStyle(color: Colors.white.withOpacity(0.5))),
           ),
        );
     }
  }
}

class _StrategyCard extends StatelessWidget {
   final String title;
   final String author;
   final String time;
   final String initials;
   final String status;
   final String realPnl;
   final String winRate;
   final String drawdown;
   final String ticker;
   final bool isLive;

  const _StrategyCard({
    required this.title,
    required this.author,
    required this.time,
    required this.initials,
    required this.status,
    required this.realPnl,
    required this.winRate,
    required this.drawdown,
    required this.ticker,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == "Active";
    
    return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
       ),
       child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Header Row
             Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Expanded(
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text(
                               title,
                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                             Row(
                                children: [
                                   // Avatar
                                    CircleAvatar(
                                       radius: 10,
                                       backgroundColor: Colors.blueGrey,
                                       child: const Icon(Icons.person, size: 12, color: Colors.white),
                                    ),
                                   const SizedBox(width: 8),
                                   Text("$author • $time", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                ],
                             ),
                         ],
                      ),
                   ),
                   const SizedBox(width: 8),
                   // P&L Badge & Status
                   Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                         Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                               color: AppColors.green.withOpacity(0.1), // Green transparency
                               borderRadius: BorderRadius.circular(8),
                               border: Border.all(color: AppColors.green),
                            ),
                            child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                  const CircleAvatar(radius: 3, backgroundColor: AppColors.green),
                                  const SizedBox(width: 4),
                                  Text(realPnl, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                               ],
                            ),
                         ),
                         const SizedBox(height: 4),
                         const Text("Real P&L", style: TextStyle(color: Colors.white54, fontSize: 10)),
                         const SizedBox(height: 8),
                         Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                               border: Border.all(color: Colors.orange.withOpacity(0.5)),
                               borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                  CircleAvatar(radius: 3, backgroundColor: isActive ? AppColors.green : Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(status, style: TextStyle(color: isActive ? Colors.white : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                               ],
                            ),
                         ),
                      ],
                   )
                ],
             ),

             const SizedBox(height: 16),
             
             // Stats Grid (Left Side: Win Rate%, Right Side: Ticker info)
             // Simplified layout to match the messy screenshot data a bit
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                            winRate, // Actually reusing this slot for the big green number on left in screenshot (which looks like ROI/WinRate combo)
                            style: const TextStyle(color: AppColors.green, fontSize: 24, fontWeight: FontWeight.bold),
                         ),
                         const SizedBox(height: 4),
                         Text(
                            ticker,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                         ),
                         const SizedBox(height: 8),
                         Text(
                            "Max DD | Symbol | Timeframe",
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                         ),
                      ],
                   ),
                   Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                         const Text("Win Rate", style: TextStyle(color: Colors.white54, fontSize: 12)),
                         Text(
                             winRate, // Reusing for right side "Win Rate"
                             style: const TextStyle(color: AppColors.cyan, fontSize: 20, fontWeight: FontWeight.bold),
                         ),
                      ],
                   )
                ],
             ),

             const SizedBox(height: 16),

             // Paper / Live Toggle Switch
             Row(
                children: [
                   Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: AppColors.cyan),
                         color: AppColors.cyan.withOpacity(0.1),
                      ),
                      child: const Center(
                         child: Text(
                            "PAPER",
                            style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 12),
                         ),
                      ),
                   ),
                   const Spacer(),
                   // Toggle Switch visual
                   Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                         Container(
                            width: 50,
                            height: 28,
                            decoration: BoxDecoration(
                               color: const Color(0xFF1E293B),
                               borderRadius: BorderRadius.circular(20),
                            ),
                         ),
                         Container(
                            width: 50,
                            height: 28,
                            alignment: Alignment.centerRight,
                             padding: const EdgeInsets.all(2),
                            child: Container(
                               width: 24,
                               height: 24,
                               decoration: const BoxDecoration(
                                  color: AppColors.cyan,
                                  shape: BoxShape.circle,
                               ),
                            ),
                         ),
                      ],
                   ),
                ],
             ),

             const SizedBox(height: 12),

             // Broker Warning
             Row(
                children: [
                   const CircleAvatar(radius: 3, backgroundColor: Colors.redAccent),
                   const SizedBox(width: 8),
                   Expanded(
                      child: Text(
                         "Broker not connected - login broker to deploy/switch mode",
                         style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 11),
                      ),
                   ),
                ],
             ),

             const SizedBox(height: 16),

             // Action Buttons
             Row(
                children: [
                   Expanded(
                      child: _buildOutlineButton(Icons.show_chart, "Chart"),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                      child: _buildOutlineButton(Icons.description_outlined, "Report"),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                      child: Container(
                         height: 40,
                         decoration: BoxDecoration(
                            gradient: LinearGradient(
                               colors: [AppColors.green.withOpacity(0.8), const Color(0xFF059669)],
                               begin: Alignment.centerLeft,
                               end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                         ),
                         child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Icon(Icons.rocket_launch_outlined, color: Colors.white, size: 16),
                               SizedBox(width: 6),
                               Text("Deploy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                         ),
                      ),
                   ),
                ],
             ),

             const SizedBox(height: 16),

             // Footer: No Broker Connected Alert
             Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                   color: Colors.redAccent.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                   children: [
                      Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                         ),
                         child: const Icon(Icons.link_off, color: Colors.redAccent, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            const Text(
                               "No Broker Connected",
                               style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                               "Connect your broker to start trading",
                               style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                            ),
                         ],
                      )
                   ],
                ),
             ),
          ],
       ),
    );
  }

  Widget _buildOutlineButton(IconData icon, String label) {
     return Container(
        height: 40,
        decoration: BoxDecoration(
           color: const Color(0xFF1E293B), // Dark blue-grey
           borderRadius: BorderRadius.circular(8),
           border: Border.all(color: Colors.transparent),
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
              Icon(icon, color: AppColors.cyan, size: 16),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 12)),
           ],
        ),
     );
  }
}
