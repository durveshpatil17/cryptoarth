import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/portfolio/providers/pnl_provider.dart';
import 'package:cryptoarth/features/orders/providers/order_provider.dart';
import 'package:cryptoarth/core/utils/report_generator.dart';

class PnLReportScreen extends ConsumerStatefulWidget {
  const PnLReportScreen({super.key});

  @override
  ConsumerState<PnLReportScreen> createState() => _PnLReportScreenState();
}

class _PnLReportScreenState extends ConsumerState<PnLReportScreen> {
  String _selectedTradeCategory = "Live Trades"; // 'Live Trades' or 'Paper Trades'
  String _selectedStrategy = "All Strategies";
  final List<String> _strategies = ["All Strategies"];
  
  // Mock Dates
  final DateTime _startDate = DateTime.now();
  final DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("P&L Report", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
           IconButton(
             onPressed: () {
               final pnlState = ref.read(pnlProvider);
               pnlState.whenData((pnl) {
                 ReportGenerator.downloadPnLReport(pnl.totalProfit.toDouble(), pnl.todayProfit.toDouble(), pnl.trades);
               });
             }, 
             icon: const Icon(Icons.download_rounded, size: 20, color: Colors.white)
           ),
           IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, size: 20, color: Colors.white))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              ref.watch(pnlProvider).when(
                data: (pnl) {
                  return LayoutBuilder(
                     builder: (context, constraints) {
                        final double itemWidth = (constraints.maxWidth - 12) / 2;
                        return Wrap(
                           spacing: 12,
                           runSpacing: 12,
                           children: [
                              _buildStatCard("Total P&L", "\$${pnl.totalProfit.toStringAsFixed(2)}", pnl.totalProfit >= 0 ? AppColors.green : Colors.redAccent, itemWidth),
                              _buildStatCard("Today P&L", "\$${pnl.todayProfit.toStringAsFixed(2)}", pnl.todayProfit >= 0 ? AppColors.green : Colors.redAccent, itemWidth),
                              _buildStatCard("Total Trades", "${pnl.trades}", Colors.white, itemWidth),
                           ],
                        );
                     },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
                error: (e, s) => Center(child: Text("Error loading P&L: $e", style: const TextStyle(color: Colors.redAccent))),
              ),

              const SizedBox(height: 16),

              // Filter Section
              Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                 ),
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       // Row 1: Filters Title + Live/Paper Toggle
                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             const Text("Filters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                             Container(
                                height: 32,
                                decoration: BoxDecoration(
                                   color: AppColors.background,
                                   borderRadius: BorderRadius.circular(8),
                                   border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Row(
                                   children: [
                                      _buildCompactToggle("Live", _selectedTradeCategory == "Live Trades"),
                                      _buildCompactToggle("Paper", _selectedTradeCategory == "Paper Trades"),
                                   ],
                                ),
                             ),
                          ],
                       ),
                       const SizedBox(height: 12),
                       
                       // Row 2: Strategy Dropdown
                       _buildCompactDropdown(_selectedStrategy, _strategies, (v) => setState(() => _selectedStrategy = v!)),
                       
                       const SizedBox(height: 12),
                       
                       // Row 3: Dates & Search
                       Row(
                          children: [
                             Expanded(child: _buildCompactDate(_startDate)),
                             const SizedBox(width: 8),
                             Expanded(child: _buildCompactDate(_endDate)),
                             const SizedBox(width: 8),
                             SizedBox(
                                height: 36,
                                width: 36,
                                child: IconButton(
                                   onPressed: () {},
                                   icon: const Icon(Icons.search, size: 18),
                                   style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B5CF6),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.zero,
                                   ),
                                ),
                             )
                          ],
                       ),
                    ],
                 ),
              ),

              const SizedBox(height: 16),

              // P&L List Header
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    const Text("Trade History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("Last 30 Days", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                 ],
              ),
              const SizedBox(height: 8),

              // List of Trade Cards (Real Data)
              ref.watch(orderProvider).when(
                data: (orders) {
                  final closedOrders = orders.where((o) => o.status.toUpperCase() == 'FILLED' || o.status.toUpperCase() == 'COMPLETED' || o.status.toUpperCase() == 'CLOSED').toList();
                  if (closedOrders.isEmpty) {
                     return const Padding(
                       padding: EdgeInsets.only(top: 24),
                       child: Center(child: Text("No trade history available", style: TextStyle(color: Colors.white54))),
                     );
                  }
                  return ListView(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     children: closedOrders.take(15).map((o) {
                        final bool isBuy = o.quantity > 0;
                        return Padding(
                           padding: const EdgeInsets.only(bottom: 8.0),
                           child: _buildTradeCard(
                             o.symbol, 
                             isBuy ? "BUY" : "SELL", 
                             "-", // PnL placeholder since orders don't store individual PnL
                             o.quantity.abs().toString(), 
                             o.price.toStringAsFixed(2), 
                             o.price.toStringAsFixed(2), 
                             "AI Trade", 
                             isBuy // mock profit color fallback
                           )
                        );
                     }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
                error: (e,s) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor, double width) {
     return Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
           color: AppColors.cardSurface,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
              const SizedBox(height: 6),
              Text(
                 value,
                 style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
           ],
        ),
     );
  }

  Widget _buildCompactToggle(String text, bool isSelected) {
     return GestureDetector(
        onTap: () => setState(() => _selectedTradeCategory = "$text Trades"),
        child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 12),
           alignment: Alignment.center,
           decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
           ),
           child: Text(
              text,
              style: TextStyle(
                 color: isSelected ? const Color(0xFF8B5CF6) : Colors.white54,
                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                 fontSize: 11,
              ),
           ),
        ),
     );
  }
  
  Widget _buildCompactDropdown(String value, List<String> items, Function(String?) onChanged) {
     return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
           color: AppColors.background,
           borderRadius: BorderRadius.circular(8),
           border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: DropdownButtonHideUnderline(
           child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.cardSurface,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 16),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
           ),
        ),
     );
  }

  Widget _buildCompactDate(DateTime date) {
     return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
           color: AppColors.background,
           borderRadius: BorderRadius.circular(8),
           border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Text(
                 "${date.day}/${date.month}/${date.year}",
                 style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
              ),
              const Icon(Icons.calendar_today, size: 12, color: Colors.white54),
           ],
        ),
     );
  }
  
  Widget _buildTradeCard(String symbol, String side, String pnl, String qty, String entry, String exit, String strategy, bool isProfit) {
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
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                             decoration: BoxDecoration(
                                color: (side == "BUY" ? AppColors.green : Colors.redAccent).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                             ),
                             child: Text(side, style: TextStyle(color: side == "BUY" ? AppColors.green : Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                       ],
                    ),
                    Text(pnl, style: TextStyle(color: pnlColor, fontWeight: FontWeight.bold, fontSize: 13)),
                 ],
              ),
              const SizedBox(height: 8),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildInfoColumn("Entry", entry),
                    _buildInfoColumn("Exit", exit),
                    _buildInfoColumn("Qty", qty),
                    _buildInfoColumn("Strategy", strategy, alignRight: true),
                 ],
              ),
           ],
        ),
     );
  }
  
  Widget _buildInfoColumn(String label, String value, {bool alignRight = false}) {
     return Column(
        crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
           Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
           const SizedBox(height: 2),
           Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
     );
  }
}
