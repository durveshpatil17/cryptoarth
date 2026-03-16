import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/portfolio/providers/pnl_provider.dart';
import 'package:cryptoarth/features/orders/providers/order_provider.dart';
import 'package:cryptoarth/core/utils/report_generator.dart';
import 'package:cryptoarth/features/portfolio/providers/trading_mode_provider.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';

import 'package:cryptoarth/features/portfolio/models/user_order_details_model.dart';
import 'package:cryptoarth/features/portfolio/providers/user_order_details_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class PnLReportScreen extends ConsumerStatefulWidget {
  const PnLReportScreen({super.key});

  @override
  ConsumerState<PnLReportScreen> createState() => _PnLReportScreenState();
}

class _PnLReportScreenState extends ConsumerState<PnLReportScreen> {
  final DateFormat _df = DateFormat('yyyy-MM-dd');
  
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final filter = ref.read(userOrderDetailsFilterProvider);
    final initialDate = isStart 
        ? DateTime.parse(filter.startDate) 
        : DateTime.parse(filter.endDate);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.cyan,
              onPrimary: Colors.black,
              surface: AppColors.cardSurface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      if (isStart) {
        ref.read(userOrderDetailsFilterProvider.notifier).state = 
            filter.copyWith(startDate: _df.format(picked));
      } else {
        ref.read(userOrderDetailsFilterProvider.notifier).state = 
            filter.copyWith(endDate: _df.format(picked));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(userOrderDetailsFilterProvider);
    final isLive = filter.tradeMode == "1";
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("P&L REPORT (USER)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
            const SizedBox(height: 2),
            Text("Analyze your profit and loss performance", style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
           IconButton(
             onPressed: () {
                // Implement PDF download if needed or use existing logic
             }, 
             icon: const Icon(Icons.download_rounded, size: 20, color: Colors.white70)
           ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              ref.watch(userOrderDetailsProvider).when(
                data: (orders) {
                  final totalPnL = orders.fold<num>(0, (sum, item) => sum + item.profit);
                  final winCount = orders.where((o) => o.profit > 0).length;
                  final lossCount = orders.where((o) => o.profit < 0).length;
                  final winRate = orders.isEmpty ? 0.0 : (winCount / orders.length) * 100;
                  final avgPnL = orders.isEmpty ? 0.0 : totalPnL / orders.length;

                  return LayoutBuilder(
                     builder: (context, constraints) {
                        final double itemWidth = (constraints.maxWidth - 12) / 2;
                        return Wrap(
                           spacing: 12,
                           runSpacing: 12,
                           children: [
                              _buildStatCard("OVERALL P&L", "${totalPnL >= 0 ? '+' : ''}${totalPnL.toStringAsFixed(2)}", totalPnL >= 0 ? AppColors.green : Colors.redAccent, itemWidth),
                              _buildStatCard("TOTAL TRADES", "${orders.length}", Colors.white, itemWidth),
                              _buildStatCard("WIN RATE", "${winRate.toStringAsFixed(1)}% ($winCount W / $lossCount L)", AppColors.cyan, itemWidth),
                              _buildStatCard("AVG P&L", "${avgPnL >= 0 ? '+' : ''}${avgPnL.toStringAsFixed(2)}", avgPnL >= 0 ? AppColors.green : Colors.orangeAccent, itemWidth),
                           ],
                        );
                     },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
                error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.redAccent))),
              ),

              const SizedBox(height: 20),

              // Filter Section
              Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                 ),
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("FILTERS", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                            _buildCompactTradeModeToggle(isLive),
                          ],
                       ),
                       const SizedBox(height: 16),
                       
                       // Strategy Dropdown
                       const Text("Select Strategy", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 6),
                       ref.watch(strategyProvider).when(
                        data: (strategies) {
                          final List<String> strategyNames = ["All Strategies", ...strategies.map((e) => e.strategyName)];
                          final String currentStrategy = filter.strategy.isEmpty ? "All Strategies" : filter.strategy;
                          
                          return _buildCompactDropdown(currentStrategy, strategyNames, (v) {
                             ref.read(userOrderDetailsFilterProvider.notifier).state = 
                                filter.copyWith(strategy: v == "All Strategies" ? "" : v);
                          });
                        },
                        loading: () => const SizedBox(height: 40),
                        error: (_,__) => _buildCompactDropdown("All Strategies", ["All Strategies"], (v){}),
                       ),
                       
                       const SizedBox(height: 16),
                       
                       // Dates
                       Row(
                          children: [
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const Text("Start Date", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                                   const SizedBox(height: 6),
                                   _buildCompactDate(filter.startDate, () => _selectDate(context, true)),
                                 ],
                               ),
                             ),
                             const SizedBox(width: 12),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const Text("End Date", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                                   const SizedBox(height: 6),
                                   _buildCompactDate(filter.endDate, () => _selectDate(context, false)),
                                 ],
                               ),
                             ),
                          ],
                       ),
                       const SizedBox(height: 20),
                       
                       // Search Button
                       ElevatedButton(
                         onPressed: () => ref.refresh(userOrderDetailsProvider),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.primary,
                           foregroundColor: Colors.white,
                           minimumSize: const Size(double.infinity, 45),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           elevation: 0,
                         ),
                         child: const Text("SEARCH ORDERS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                       ),
                    ],
                 ),
              ),

              const SizedBox(height: 24),

              // Trade History Header
              const Text("TRADE HISTORY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 12),

              // Trade List
              ref.watch(userOrderDetailsProvider).when(
                data: (details) {
                  if (details.isEmpty) {
                     return _buildEmptyState();
                  }
                  return ListView.builder(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     itemCount: details.length,
                     itemBuilder: (context, index) {
                        return _buildEnhancedTradeCard(details[index]);
                     },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
                error: (e, s) => Center(child: Text("Error loading trades", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11))),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor, double width) {
     return Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
           color: AppColors.cardSurface,
           borderRadius: BorderRadius.circular(16),
           border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(
                 value,
                 style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w900),
              ),
           ],
        ),
     );
  }

  Widget _buildCompactTradeModeToggle(bool isLive) {
     return Container(
        height: 28,
        decoration: BoxDecoration(
           color: AppColors.background,
           borderRadius: BorderRadius.circular(8),
           border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
           children: [
              _buildCompactToggle("Live Trades", isLive, () {
                ref.read(userOrderDetailsFilterProvider.notifier).state = 
                  ref.read(userOrderDetailsFilterProvider).copyWith(tradeMode: "1");
              }),
              _buildCompactToggle("Paper Trades", !isLive, () {
                ref.read(userOrderDetailsFilterProvider.notifier).state = 
                  ref.read(userOrderDetailsFilterProvider).copyWith(tradeMode: "0");
              }),
           ],
        ),
     );
  }

  Widget _buildCompactToggle(String text, bool isSelected, VoidCallback onTap) {
     return GestureDetector(
        onTap: onTap,
        child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 12),
           alignment: Alignment.center,
           decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
           ),
           child: Text(
              text,
              style: TextStyle(
                 color: isSelected ? AppColors.primary : Colors.white24,
                 fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                 fontSize: 9,
              ),
           ),
        ),
     );
  }
  
  Widget _buildCompactDropdown(String value, List<String> items, Function(String?) onChanged) {
     return Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
           color: AppColors.background,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: DropdownButtonHideUnderline(
           child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.cardSurface,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white24, size: 18),
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
           ),
        ),
     );
  }

  Widget _buildCompactDate(String dateStr, VoidCallback onTap) {
     return GestureDetector(
       onTap: onTap,
       child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
             color: AppColors.background,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
                Text(
                   dateStr,
                   style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.calendar_today, size: 14, color: Colors.white24),
             ],
          ),
       ),
     );
  }

  Widget _buildEnhancedTradeCard(UserOrderDetailsModel detail) {
     final bool isProfit = detail.profit >= 0;
     final Color pnlColor = isProfit ? AppColors.green : Colors.redAccent;
     
     return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: AppColors.cardSurface,
           borderRadius: BorderRadius.circular(20),
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
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                             decoration: BoxDecoration(
                                color: (detail.side.toUpperCase() == "BUY" ? AppColors.green : Colors.redAccent).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                             ),
                             child: Text(detail.side.toUpperCase(), style: TextStyle(color: detail.side.toUpperCase() == "BUY" ? AppColors.green : Colors.redAccent, fontSize: 8, fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(width: 10),
                          Text(detail.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                       ],
                    ),
                    Text(
                      "${isProfit ? '+' : ''}${detail.profit.toStringAsFixed(2)}",
                      style: TextStyle(color: pnlColor, fontWeight: FontWeight.w900, fontSize: 13)
                    ),
                 ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildInfoColumn("Buy Price", detail.buyPrice.toStringAsFixed(2)),
                    _buildInfoColumn("Sell Price", detail.sellPrice.toStringAsFixed(2)),
                    _buildInfoColumn("Quantity", detail.quantity.toStringAsFixed(2)),
                    _buildInfoColumn("Order ID", "#${detail.orderId}", alignRight: true),
                 ],
              ),
              const SizedBox(height: 12),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildInfoColumn("Strategy", detail.strategyName.isEmpty ? "Direct Trade" : detail.strategyName),
                    _buildInfoColumn("Datetime", detail.datetime, alignRight: true),
                 ],
              ),
           ],
        ),
     );
  }

  Widget _buildEmptyState() {
     return Center(
       child: Padding(
         padding: const EdgeInsets.symmetric(vertical: 60),
         child: Column(
           children: [
             Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), shape: BoxShape.circle),
               child: Icon(Icons.description_outlined, size: 40, color: Colors.white.withOpacity(0.1)),
             ),
             const SizedBox(height: 20),
             Text("No orders found", style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
             const SizedBox(height: 6),
             Text("No P&L data available for selected filters.", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w500)),
           ],
         ),
       ),
     );
  }
  
  Widget _buildInfoColumn(String label, String value, {bool alignRight = false}) {
     return Column(
        crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
           Text(label, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
           const SizedBox(height: 4),
           Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
     );
   }
}
