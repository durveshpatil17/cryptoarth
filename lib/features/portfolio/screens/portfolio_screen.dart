import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/portfolio/providers/portfolio_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/pnl_provider.dart';
import 'package:cryptoarth/features/orders/providers/order_provider.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Filter States (Shared if needed, but tabs can have local filters)
  String _selectedStrategy = "All Strategies";
  String _selectedSymbol = "All";
  String _mode = "Live"; 

  // Mock
  final List<String> _strategies = ["All Strategies", "RSI Strategy", "MACD Strategy"];
  final List<String> _symbols = ["All", "BTC/USDT", "ETH/USDT"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Portfolio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false, 
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, size: 20, color: Colors.white)),
          const ProfileAvatar(),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF8B5CF6).withOpacity(0.2), 
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFFD8B4FE),
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Open Positions"))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Closed Positions"))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Order Book"))),
                Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("P&L Report"))),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOpenPositionsTab(),
          _buildClosedPositionsTab(),
          _buildOrderBookTab(), // Reusing order list design
          _buildPnLReportTab(), // Reusing P&L report design
        ],
      ),
    );
  }

  // --- OPEN POSITIONS TAB ---
  Widget _buildOpenPositionsTab() {
    return ref.watch(portfolioProvider).when(
      data: (positions) {
        final totalUnrealizedPnl = positions.fold<num>(0, (sum, pos) => sum + pos.pnl);
        return RefreshIndicator(
          onRefresh: () => ref.read(portfolioProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Total Unrealized P&L Header
                Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.cyan.withOpacity(0.2), AppColors.background]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
                   ),
                   child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               const Text("Total Unrealized P&L", style: TextStyle(color: Colors.white70, fontSize: 11)),
                               const SizedBox(height: 4),
                               Text("${totalUnrealizedPnl >= 0 ? '+' : '-'}\$${totalUnrealizedPnl.abs().toStringAsFixed(2)}", style: TextStyle(color: totalUnrealizedPnl >= 0 ? AppColors.green : Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                         ),
                         Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                               color: Colors.white.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text("${positions.length} Active", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                         ),
                      ],
                   ),
                ),
                const SizedBox(height: 16),
                
                if (positions.isEmpty)
                   const Padding(padding: EdgeInsets.only(top: 32), child: Center(child: Text("No Open Positions", style: TextStyle(color: Colors.white54)))),

                // Position List
                ...positions.map((pos) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPositionCard(
                    pos.symbol, 
                    pos.quantity >= 0 ? "LONG" : "SHORT", 
                    "${pos.pnl >= 0 ? '+' : '-'}\$${pos.pnl.abs().toStringAsFixed(2)}", 
                    "${pos.pnlPercentage.toStringAsFixed(2)}%", 
                    pos.quantity.abs().toString(), 
                    pos.entryPrice.toStringAsFixed(2), 
                    pos.currentPrice.toStringAsFixed(2), 
                    "N/A", // Liquidation price not in API typically
                     pos.pnl >= 0,
                  ),
                )).toList(),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      error: (e, s) => Center(child: Text("Error fetching positions: $e", style: const TextStyle(color: Colors.redAccent))),
    );
  }

  Widget _buildPositionCard(String symbol, String side, String pnl, String roe, String size, String entry, String mark, String liq, bool isProfit) {
     final Color pnlColor = isProfit ? AppColors.green : Colors.redAccent;
     final Color sideColor = side == "LONG" ? AppColors.green : Colors.redAccent;
     
     return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
           color: AppColors.cardSurface,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
           children: [
              // Header
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Row(
                       children: [
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(
                                color: sideColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                             ),
                             child: Text(side, style: TextStyle(color: sideColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                       ],
                    ),
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                          Text(pnl, style: TextStyle(color: pnlColor, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(roe, style: TextStyle(color: pnlColor, fontSize: 10)),
                       ],
                    ),
                 ],
              ),
              const Divider(color: Colors.white10, height: 16),
              // Details Grid
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildDetailItem("Size", size),
                    _buildDetailItem("Entry", entry),
                    _buildDetailItem("Mark", mark),
                    _buildDetailItem("Liq. Price", liq, highlight: true),
                 ],
              ),
              const SizedBox(height: 12),
              // Footer Actions
              Row(
                 children: [
                    Expanded(
                       child: OutlinedButton(
                          onPressed: (){},
                          style: OutlinedButton.styleFrom(
                             side: BorderSide(color: Colors.white.withOpacity(0.1)),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                             minimumSize: const Size(0, 32),
                          ),
                          child: const Text("TP/SL", style: TextStyle(color: Colors.white70, fontSize: 11)),
                       ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                       child: ElevatedButton(
                          onPressed: (){},
                          style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.white.withOpacity(0.1),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                             minimumSize: const Size(0, 32),
                             elevation: 0,
                          ),
                          child: const Text("Close Position", style: TextStyle(color: Colors.white, fontSize: 11)),
                       ),
                    ),
                 ],
              ),
           ],
        ),
     );
  }

  // --- CLOSED POSITIONS TAB ---
  Widget _buildClosedPositionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
           _buildClosedPositionCard("BTC/USDT", "+ \$125.40", "1.2%", "LONG", "64,200", "64,500", "Oct 12, 10:30", true),
           const SizedBox(height: 12),
           _buildClosedPositionCard("ETH/USDT", "- \$22.50", "-0.5%", "SHORT", "3,450", "3,460", "Oct 11, 14:15", false),
           const SizedBox(height: 12),
           _buildClosedPositionCard("XRP/USDT", "+ \$55.00", "4.8%", "LONG", "0.5200", "0.5450", "Oct 10, 09:00", true),
        ],
      ),
    );
  }

  Widget _buildClosedPositionCard(String symbol, String pnl, String roe, String side, String entry, String exit, String date, bool isProfit) {
     final Color pnlColor = isProfit ? AppColors.green : Colors.redAccent;
     return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
           color: AppColors.cardSurface,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
           children: [
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Row(
                       children: [
                          Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 6),
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                             decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
                             child: Text(side, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9)),
                          ),
                       ],
                    ),
                    Text(pnl, style: TextStyle(color: pnlColor, fontWeight: FontWeight.bold, fontSize: 13)),
                 ],
              ),
              const SizedBox(height: 8),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildDetailItem("Entry", entry),
                    _buildDetailItem("Exit", exit),
                    _buildDetailItem("Date", date),
                    _buildDetailItem("ROE", roe, color: pnlColor),
                 ],
              ),
           ],
        ),
     );
  }

  // --- ORDER BOOK TAB (Integrated) ---
  Widget _buildOrderBookTab() {
     return ref.watch(orderProvider).when(
       data: (orders) {
         if (orders.isEmpty) {
            return const Center(child: Text("No items in order book", style: TextStyle(color: Colors.white54)));
         }
         return RefreshIndicator(
           onRefresh: () => ref.read(orderProvider.notifier).refresh(),
           child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                 final order = orders[index];
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 8.0),
                   child: _buildOrderCard(
                      order.symbol, 
                      order.quantity > 0 ? "BUY" : "SELL", 
                      order.price.toStringAsFixed(2), 
                      order.quantity.abs().toString(), 
                      order.timestamp, 
                      order.status, 
                      "AI Base", 
                      order.quantity > 0 ? "BUY" : "SELL", 
                      order.status
                   ),
                 );
              },
           ),
         );
       },
       loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
       error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
     );
  }

  Widget _buildOrderCard(String symbol, String sideStr, String price, String qty, String time, String statusStr, String strategy, String sideArg, String statusArg) {
     final bool isBuy = sideArg == "BUY";
     final Color sideColor = isBuy ? AppColors.green : Colors.redAccent;
     Color statusColor = statusArg == "FILLED" ? AppColors.green : (statusArg == "PENDING" ? Colors.orange : Colors.grey);
     
     return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
           color: AppColors.cardSurface,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
           children: [
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Row(
                       children: [
                          Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 8),
                          Text(sideStr, style: TextStyle(color: sideColor, fontSize: 11, fontWeight: FontWeight.bold)),
                       ],
                    ),
                    Text(time, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                 ],
              ),
              const SizedBox(height: 8),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildDetailItem("Price", price),
                    _buildDetailItem("Qty", qty),
                    _buildDetailItem("Strategy", strategy),
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                          Text("Status", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
                          Text(statusStr, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                       ],
                    ),
                 ],
              ),
           ],
        ),
     );
  }

  // --- P&L REPORT TAB (Integrated) ---
  Widget _buildPnLReportTab() {
     return ref.watch(pnlProvider).when(
       data: (pnl) {
         return RefreshIndicator(
           onRefresh: () => ref.read(pnlProvider.notifier).refresh(),
           child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    LayoutBuilder(
                       builder: (context, constraints) {
                          final double itemWidth = (constraints.maxWidth - 12) / 2;
                          return Wrap(
                             spacing: 12, runSpacing: 12,
                             children: [
                                _buildStatCard("Total P&L", "\$${pnl.totalProfit.toStringAsFixed(2)}", pnl.totalProfit >= 0 ? AppColors.green : Colors.redAccent, itemWidth),
                                _buildStatCard("Today P&L", "\$${pnl.todayProfit.toStringAsFixed(2)}", pnl.todayProfit >= 0 ? AppColors.green : Colors.redAccent, itemWidth),
                             ],
                          );
                       },
                    ),
                    const SizedBox(height: 16),
                    const Text("Performance Breakdown", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    // Missing live trades history in current pnl structure, keeping mock for UI
                    _buildClosedPositionCard("Mock/Trade", "+ \$0.00", "0%", "LONG", "0", "0", "Today", true),
                 ],
              ),
           ),
         );
       },
       loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
       error: (e, s) => Center(child: Text("Error fetching P&L: $e", style: const TextStyle(color: Colors.redAccent))),
     );
  }

  // --- SHARED HELPERS ---
  Widget _buildDetailItem(String label, String value, {bool highlight = false, Color? color}) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(label, style: TextStyle(color: highlight ? Colors.amber : Colors.white.withOpacity(0.4), fontSize: 9)),
           const SizedBox(height: 2),
           Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
     );
  }

  Widget _buildStatCard(String title, String value, Color color, double width) {
     return Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
           ],
        ),
     );
  }
  
  Widget _buildCompactDropdown(String value) {
     return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
           color: AppColors.cardSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.1))
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Text(value, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.white54),
           ],
        ),
     );
  }
}
