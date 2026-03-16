import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptoarth/features/orders/providers/trade_history_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/trading_mode_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  // Filter States
  String _selectedStrategy = "All";
  String _selectedSymbol = "All";

  final List<String> _strategies = ["All", "RSI Strategy", "MACD Strategy"];
  final List<String> _symbols = ["All", "BTC/USDT", "ETH/USDT"];

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(tradingModeProvider);
    final ordersState = ref.watch(tradeHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ORDER BOOK",
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w800, 
                fontSize: 14, 
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'CHRONOLOGICAL TRANSACTION ARCHIVE',
              style: TextStyle(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.w700, letterSpacing: 1.2),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white70),
          onPressed: () {
            final ScaffoldState? root = context.findRootAncestorStateOfType<ScaffoldState>();
            root?.openDrawer();
          },
        ),
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      body: LuxuryBackground(
        child: Column(
          children: [
            // Filters & Controls Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                 color: AppColors.cardSurface.withOpacity(0.5),
                 border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Column(
                 children: [
                    // Row 1: Strategy & Symbol Filters
                    Row(
                       children: [
                          Expanded(child: _buildCompactDropdown("Strategy", _selectedStrategy, _strategies, (v) => setState(() => _selectedStrategy = v!))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCompactDropdown("Symbol", _selectedSymbol, _symbols, (v) => setState(() => _selectedSymbol = v!))),
                       ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Mode Toggle & Refresh
                    Row(
                       children: [
                          Expanded(
                             child: Container(
                                height: 38,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                   color: AppColors.background.withOpacity(0.3),
                                   borderRadius: BorderRadius.circular(10),
                                   border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Row(
                                    children: [
                                       Expanded(child: _buildModeOption("LIVE", mode == TradingMode.live, AppColors.green, () => ref.read(tradingModeProvider.notifier).state = TradingMode.live)),
                                       const SizedBox(width: 8),
                                       Expanded(child: _buildModeOption("PAPER", mode == TradingMode.paper, AppColors.cyan, () => ref.read(tradingModeProvider.notifier).state = TradingMode.paper)),
                                    ],
                                ),
                             ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                             height: 38,
                             width: 38,
                             child: IconButton(
                                onPressed: () => ref.read(tradeHistoryProvider.notifier).refresh(),
                                icon: const Icon(Icons.refresh, size: 20, color: Colors.white70),
                                style: IconButton.styleFrom(
                                   backgroundColor: AppColors.cardSurface.withOpacity(0.3),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.white.withOpacity(0.1))),
                                   padding: EdgeInsets.zero,
                                ),
                             ),
                          ),
                       ],
                    ),
                 ],
              ),
            ),
  
            // Order List
            Expanded(
               child: ordersState.when(
                 data: (orders) {
                   if (orders.isEmpty) {
                     return const Center(child: Text("No orders found", style: TextStyle(color: Colors.white54)));
                   }
                   return RefreshIndicator(
                     onRefresh: () => ref.read(tradeHistoryProvider.notifier).refresh(),
                     child: ListView.builder(
                       padding: const EdgeInsets.all(12),
                       itemCount: orders.length,
                       itemBuilder: (context, index) {
                         final order = orders[index];
                         return Padding(
                           padding: const EdgeInsets.only(bottom: 8.0),
                           child: _buildOrderCard(
                             symbol: order.symbol, 
                             side: order.quantity > 0 ? "BUY" : "SELL", 
                             price: "\$${order.price.toStringAsFixed(2)}", 
                             qty: order.quantity.abs().toString(), 
                             time: order.timestamp, 
                             status: order.status,
                             strategy: "AI Strategy" // Assuming strategy missing in pure order payload
                           ),
                         );
                       },
                     ),
                   );
                 },
                 loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
                 error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
               ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
     return Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
           color: AppColors.background,
           borderRadius: BorderRadius.circular(10),
           border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: DropdownButtonHideUnderline(
           child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.cardSurface,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 16),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: onChanged,
              hint: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
           ),
        ),
     );
  }

   Widget _buildModeOption(String text, bool isSelected, Color color, VoidCallback onTap) {
     return GestureDetector(
        onTap: () {
           HapticFeedback.selectionClick();
           onTap();
        },
        child: Container(
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? color.withOpacity(0.3) : Colors.transparent),
           ),
           alignment: Alignment.center,
           child: Text(
              text, 
              style: TextStyle(
                 color: isSelected ? color : Colors.white12, 
                 fontSize: 9, 
                 fontWeight: FontWeight.w900,
                 letterSpacing: 0.5,
              )
           ),
        ),
     );
  }

  Widget _buildOrderCard({
     required String symbol, 
     required String side, 
     required String price, 
     required String qty, 
     required String time, 
     required String status,
     required String strategy
  }) {
     final bool isBuy = side == "BUY";
     final Color sideColor = isBuy ? AppColors.green : Colors.redAccent;
     
     return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
           color: AppColors.cardSurface.withOpacity(0.5),
           borderRadius: BorderRadius.circular(16),
           border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
           children: [
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
                                border: Border.all(color: sideColor.withOpacity(0.3)),
                             ),
                             child: Text(side, style: TextStyle(color: sideColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                       ],
                    ),
                    Text(time, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                 ],
              ),
              const SizedBox(height: 8),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildOrderStat("Price", price),
                    _buildOrderStat("Qty", qty),
                    _buildOrderStat("Filled", price), // Just repeating price as filled price for mock
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                          Text("Status", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
                          const SizedBox(height: 2),
                          Text(status, style: TextStyle(color: status == "FILLED" ? AppColors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                       ],
                    ),
                 ],
              ),
              const SizedBox(height: 8),
              Row(
                 children: [
                    Icon(Icons.candlestick_chart, size: 10, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(strategy, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                 ],
              )
           ],
        ),
     );
  }
  
  Widget _buildOrderStat(String label, String value) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
           const SizedBox(height: 2),
           Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
     );
  }
}
