import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/portfolio/providers/portfolio_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/pnl_provider.dart';
import 'package:cryptoarth/features/orders/providers/order_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/watchlist_provider.dart';
import 'package:cryptoarth/features/broker/providers/broker_balance_provider.dart';

import 'package:cryptoarth/features/orders/providers/trade_history_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/trading_mode_provider.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/providers/backtest_provider.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Filter States
  String _selectedStrategy = "All Strategies";
  String _selectedSymbol = "All";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(tradingModeProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Portfolio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false, 
        elevation: 0,
        actions: [
          _buildModeToggle(context),
          const SizedBox(width: 8),
          const ProfileAvatar(),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
               _buildFilterBar(),
               Container(
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
                    color: mode == TradingMode.live ? const Color(0xFF8B5CF6).withOpacity(0.2) : AppColors.cyan.withOpacity(0.1), 
                    border: Border.all(color: mode == TradingMode.live ? const Color(0xFF8B5CF6).withOpacity(0.5) : AppColors.cyan.withOpacity(0.5)),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: mode == TradingMode.live ? const Color(0xFFD8B4FE) : AppColors.cyan,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Open Positions"))),
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Closed Positions"))),
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Order Book"))),
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("P&L Report"))),
                    Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Watchlist"))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOpenPositionsTab(),
          _buildClosedPositionsTab(),
          _buildOrderBookTab(),
          _buildPnLReportTab(),
          _buildWatchlistTab(),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    final mode = ref.watch(tradingModeProvider);
    final isLive = mode == TradingMode.live;
    
    return GestureDetector(
      onTap: () {
        ref.read(tradingModeProvider.notifier).state = isLive ? TradingMode.paper : TradingMode.live;
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isLive ? Colors.redAccent.withOpacity(0.1) : AppColors.cyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isLive ? Colors.redAccent.withOpacity(0.5) : AppColors.cyan.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: isLive ? Colors.redAccent : AppColors.cyan,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: (isLive ? Colors.redAccent : AppColors.cyan).withOpacity(0.5), blurRadius: 4, spreadRadius: 1)
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(isLive ? "LIVE" : "PAPER", style: TextStyle(color: isLive ? Colors.redAccent : AppColors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Symbol Filter
          ref.watch(backtestSymbolsProvider).when(
            data: (symbols) {
              final List<String> symbolNames = ["All", ...symbols.map((e) => e['symbol_name'].toString())];
              return Expanded(
                child: _buildDropDownFilter(
                  "Symbol", 
                  _selectedSymbol, 
                  symbolNames, 
                  (val) => setState(() => _selectedSymbol = val!)
                ),
              );
            },
            loading: () => const Expanded(child: SizedBox(height: 32)),
            error: (_,__) => const Expanded(child: SizedBox(height: 32)),
          ),
          const SizedBox(width: 12),
          // Strategy Filter
          ref.watch(strategyProvider).when(
            data: (strategies) {
              final List<String> strategyNames = ["All Strategies", ...strategies.map((e) => e.strategyName)];
              return Expanded(
                child: _buildDropDownFilter(
                  "Strategy", 
                  _selectedStrategy, 
                  strategyNames, 
                  (val) => setState(() => _selectedStrategy = val!)
                ),
              );
            },
            loading: () => const Expanded(child: SizedBox(height: 32)),
            error: (_,__) => const Expanded(child: SizedBox(height: 32)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropDownFilter(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
        const SizedBox(height: 4),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              dropdownColor: AppColors.cardSurface,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white54),
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // --- OPEN POSITIONS TAB ---
  Widget _buildOpenPositionsTab() {
    return ref.watch(portfolioProvider).when(
      data: (positions) {
        // Filter by Symbol
        var filteredPositions = positions;
        if (_selectedSymbol != "All") {
          filteredPositions = filteredPositions.where((p) => p.symbol.toUpperCase().contains(_selectedSymbol.toUpperCase())).toList();
        }

        final totalUnrealizedPnl = filteredPositions.fold<num>(0, (sum, pos) => sum + pos.pnl);
        return RefreshIndicator(
          onRefresh: () => ref.read(portfolioProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Broker Balance & Realized PnL Header Widget
                ref.watch(brokerBalanceProvider).when(
                  data: (balanceModel) {
                    final double totalBal = (balanceModel?.balance ?? 0).toDouble();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: AppColors.gold.withOpacity(0.8), size: 20),
                              const SizedBox(width: 8),
                              const Text("Broker Balance", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(totalBal > 0 ? "\$${totalBal.toStringAsFixed(2)}" : "Not Connected", 
                            style: TextStyle(
                              color: totalBal > 0 ? Colors.white : Colors.white54, 
                              fontSize: 14, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),

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
                            child: Text("${filteredPositions.length} Active", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                         ),
                      ],
                   ),
                ),
                const SizedBox(height: 16),
                
                if (filteredPositions.isEmpty)
                   Padding(padding: const EdgeInsets.only(top: 32), child: Center(child: Text(_selectedSymbol != "All" ? "No Positions for $_selectedSymbol" : "No Open Positions", style: const TextStyle(color: Colors.white54)))),

                // Position List
                ...filteredPositions.map((pos) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPositionCard(
                    pos.symbol, 
                    pos.quantity >= 0 ? "LONG" : "SHORT", 
                    "${pos.pnl >= 0 ? '+' : '-'}\$${pos.pnl.abs().toStringAsFixed(2)}", 
                    "${pos.pnlPercentage.toStringAsFixed(2)}%", 
                    pos.quantity.abs().toString(), 
                    pos.entryPrice.toStringAsFixed(2), 
                    pos.currentPrice.toStringAsFixed(2), 
                    "N/A", 
                     pos.pnl >= 0,
                  ),
                )).toList(),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.redAccent))),
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
                          child: const Text("Close", style: TextStyle(color: Colors.white, fontSize: 11)),
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
     return ref.watch(tradeHistoryProvider).when(
       data: (trades) {
         // Filter by Symbol
         var filteredTrades = trades;
         if (_selectedSymbol != "All") {
           filteredTrades = filteredTrades.where((t) => t.symbol.toUpperCase().contains(_selectedSymbol.toUpperCase())).toList();
         }

         if (filteredTrades.isEmpty) {
            return Center(child: Text(_selectedSymbol != "All" ? "No history for $_selectedSymbol" : "No closed positions", style: const TextStyle(color: Colors.white54)));
         }
         return RefreshIndicator(
           onRefresh: () => ref.read(tradeHistoryProvider.notifier).refresh(),
           child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: filteredTrades.length,
              itemBuilder: (context, index) {
                 final trade = filteredTrades[index];
                 final bool isBuy = trade.quantity > 0;
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 12.0),
                   child: _buildClosedPositionCard(
                      trade.symbol, 
                      "-", 
                      "-", 
                      isBuy ? "LONG" : "SHORT", 
                      trade.price.toStringAsFixed(2), 
                      trade.price.toStringAsFixed(2), 
                      trade.timestamp, 
                      true 
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
                    Expanded(child: _buildDetailItem("Date", date)),
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
         // Filter by Symbol & Strategy (Strategy not yet in model, placeholder)
         var filteredOrders = orders;
         if (_selectedSymbol != "All") {
           filteredOrders = filteredOrders.where((o) => o.symbol.toUpperCase().contains(_selectedSymbol.toUpperCase())).toList();
         }

         if (filteredOrders.isEmpty) {
            return Center(child: Text(_selectedSymbol != "All" ? "No orders for $_selectedSymbol" : "No items in order book", style: const TextStyle(color: Colors.white54)));
         }
         return RefreshIndicator(
           onRefresh: () => ref.read(orderProvider.notifier).refresh(),
           child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                 final order = filteredOrders[index];
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
                    ref.watch(orderProvider).when(
                      data: (orders) {
                        final closedOrders = orders.where((o) => o.status.toUpperCase() == 'FILLED' || o.status.toUpperCase() == 'COMPLETED' || o.status.toUpperCase() == 'CLOSED').toList();
                        if (closedOrders.isEmpty) {
                           return const Padding(padding: EdgeInsets.all(16), child: Text("No detailed performance history", style: TextStyle(color: Colors.white54, fontSize: 12)));
                        }
                        return Column(
                           children: closedOrders.take(3).map((order) {
                             final bool isBuy = order.quantity > 0;
                             return Padding(
                               padding: const EdgeInsets.only(bottom: 8.0),
                               child: _buildClosedPositionCard(order.symbol, "-", "-", isBuy ? "LONG" : "SHORT", order.price.toStringAsFixed(2), order.price.toStringAsFixed(2), order.timestamp, true),
                             );
                           }).toList(),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (e,s) => const SizedBox.shrink(),
                    ),
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

  // --- WATCHLIST TAB ---
  Widget _buildWatchlistTab() {
    return ref.watch(watchlistProvider).when(
      data: (watchlist) {
        if (watchlist.isEmpty) {
          return const Center(child: Text("Provide broker permissions to view watchlist.", style: TextStyle(color: Colors.white54, fontSize: 12)));
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(watchlistProvider.notifier).refresh(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              final item = watchlist[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildWatchlistCard(item),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      error: (e, s) => Center(child: Text("Error fetching watchlist: $e", style: const TextStyle(color: Colors.redAccent))),
    );
  }

  Widget _buildWatchlistCard(dynamic item) {
    // We attempt to map standard backend watchlist properties 
    final String symbol = item['symbol'] ?? item['name'] ?? 'UNKNOWN';
    final double ltp = num.tryParse(item['ltp']?.toString() ?? '0')?.toDouble() ?? 0.0;
    final double change = num.tryParse(item['change']?.toString() ?? '0')?.toDouble() ?? 0.0;
    final double changePct = num.tryParse(item['change_percentage']?.toString() ?? '0')?.toDouble() ?? 0.0;
    
    final bool isUp = change >= 0;
    final Color trendColor = isUp ? AppColors.green : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
         color: AppColors.cardSurface,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
               CircleAvatar(
                 radius: 16,
                 backgroundColor: Colors.white.withOpacity(0.1),
                 child: Text(symbol.isNotEmpty ? symbol[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
               ),
               const SizedBox(width: 12),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                   const SizedBox(height: 4),
                   Text("24H Vol: ${item['volume'] ?? 'N/A'}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                 ],
               ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${ltp.toStringAsFixed(2)}', style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('${isUp ? '+' : ''}${changePct.toStringAsFixed(2)}%', style: TextStyle(color: trendColor, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
