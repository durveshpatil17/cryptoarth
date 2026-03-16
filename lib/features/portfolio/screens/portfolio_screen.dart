import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptoarth/features/portfolio/providers/portfolio_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/watchlist_provider.dart';
import 'package:cryptoarth/features/broker/providers/broker_balance_provider.dart';

import 'package:cryptoarth/features/portfolio/providers/trading_mode_provider.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/strategies/providers/backtest_provider.dart';
import 'package:cryptoarth/features/portfolio/models/position_model.dart';
import 'package:cryptoarth/features/portfolio/models/user_order_details_model.dart';
import 'package:cryptoarth/features/portfolio/providers/user_order_details_provider.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
      backgroundColor: AppColors.digitalVoidBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white70),
            onPressed: () {
              final ScaffoldState? root = context.findRootAncestorStateOfType<ScaffoldState>();
              root?.openDrawer();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PORTFOLIO',
              style: TextStyle(
                fontWeight: FontWeight.w800, 
                fontSize: 14, 
                color: Colors.white, 
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'MANAGED WEALTH PERFORMANCE',
              style: TextStyle(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.w700, letterSpacing: 1.2),
            ),
          ],
        ),
        actions: [
          SvgPicture.asset("assets/images/favicon.svg", height: 22, width: 22),
          const SizedBox(width: 16),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: SizedBox.shrink(),
        ),
      ),
      body: LuxuryBackground(
        child: Column(
          children: [
            const SizedBox(height: 120),
            _buildHeaderPanel(),
            const SizedBox(height: 16),
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: mode == TradingMode.live ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.1),
                  border: Border.all(color: mode == TradingMode.live ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.2)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: mode == TradingMode.live ? Colors.redAccent : Colors.white,
                unselectedLabelColor: Colors.white12,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                dividerColor: Colors.transparent,
                onTap: (index) => HapticFeedback.lightImpact(),
                tabs: const [
                  Tab(text: "OPEN POSITIONS"),
                  Tab(text: "CLOSED POSITIONS"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                   _buildOpenPositionsTab(),
                   _buildClosedPositionsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildModeToggle(BuildContext context) {
    final mode = ref.watch(tradingModeProvider);
    final bool isLive = mode == TradingMode.live;
    
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption("PAPER", !isLive, AppColors.cyan, () {
            ref.read(tradingModeProvider.notifier).state = TradingMode.paper;
          }),
          _buildToggleOption("LIVE", isLive, Colors.redAccent, () {
            ref.read(tradingModeProvider.notifier).state = TradingMode.live;
          }),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected, Color activeColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.white24,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCompactFilterBar(),
          Row(
            children: [
              _buildModeToggle(context),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await Future.wait([
                    ref.read(portfolioProvider.notifier).refresh(),
                  ]);
                  ref.invalidate(userOrderDetailsProvider);
                },
                icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white30),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterBar() {
    return Row(
      children: [
        // Symbol Filter
        GestureDetector(
           onTap: () {
              ref.read(backtestSymbolsProvider).whenData((symbols) {
                 final list = ["All", ...symbols.map((e) => e['symbol_name'].toString())];
                 _showPicker("Symbol", list, _selectedSymbol, (val) => setState(() => _selectedSymbol = val));
              });
           },
           child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.cardSurface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 12, color: Colors.white54),
                  const SizedBox(width: 6),
                  Text(_selectedSymbol, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  const Icon(Icons.keyboard_arrow_down, size: 12, color: Colors.white54),
                ],
              ),
           ),
        ),
        const SizedBox(width: 8),
        // Strategy Filter
        GestureDetector(
           onTap: () {
              ref.read(deployedStrategyListProvider).whenData((strategies) {
                 final list = ["All Strategies", ...strategies.map((e) => e.strategyName)];
                 _showPicker("Strategy", list, _selectedStrategy, (val) => setState(() => _selectedStrategy = val));
              });
           },
           child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                   Center(
                      child: Text(
                         _selectedStrategy, 
                         style: const TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.1)
                      )
                   ),
                   const SizedBox(width: 4),
                   const Icon(Icons.keyboard_arrow_down, size: 12, color: AppColors.cyan),
                ],
              ),
           ),
        ),
      ],
    );
  }

  void _showPicker(String title, List<String> items, String current, Function(String) onSelect) {
     showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.cardSurface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) {
           return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                    Text("Select $title", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 20),
                    Flexible(
                       child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                             final s = items[idx];
                             final bool isSel = s == current;
                             return ListTile(
                                dense: true,
                                title: Text(s, style: TextStyle(color: isSel ? AppColors.cyan : Colors.white70, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                                trailing: isSel ? const Icon(Icons.check_circle, color: AppColors.cyan, size: 18) : null,
                                onTap: () {
                                   HapticFeedback.selectionClick();
                                   onSelect(s);
                                   if (title == "Strategy") {
                                      final filter = ref.read(userOrderDetailsFilterProvider);
                                      ref.read(userOrderDetailsFilterProvider.notifier).state = filter.copyWith(strategy: s == "All Strategies" ? "" : s);
                                   }
                                   Navigator.pop(context);
                                },
                             );
                          },
                       ),
                    ),
                 ],
              ),
           );
        },
     );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Symbol Filter
            ref.watch(backtestSymbolsProvider).when(
              data: (symbols) {
                final List<String> symbolNames = ["All", ...symbols.map((e) => e['symbol_name'].toString())];
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: _buildDropDownFilter(
                    "Symbol", 
                    _selectedSymbol, 
                    symbolNames, 
                    (val) => setState(() => _selectedSymbol = val!)
                  ),
                );
              },
              loading: () => const SizedBox(width: 100, height: 32),
              error: (_,__) => const SizedBox(width: 100, height: 32),
            ),
            const SizedBox(width: 8),
            ref.watch(selectStrategyProvider).when(
              data: (strategies) {
                final List<String> strategyNames = ["All Strategies", ...strategies.map((e) => e.strategyName)];
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: _buildDropDownFilter(
                    "Strategy", 
                    _selectedStrategy, 
                    strategyNames, 
                    (val) => setState(() => _selectedStrategy = val!)
                  ),
                );
              },
              loading: () => const SizedBox(width: 120, height: 32),
              error: (_,__) => const SizedBox(width: 120, height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropDownFilter(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.cardSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              dropdownColor: AppColors.cardSurface,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white54),
              style: const TextStyle(color: Colors.white, fontSize: 11),
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
        var filteredPositions = positions;
        if (_selectedSymbol != "All") {
          filteredPositions = filteredPositions.where((p) => p.symbol.toUpperCase().contains(_selectedSymbol.toUpperCase())).toList();
        }
        if (_selectedStrategy != "All Strategies") {
          filteredPositions = filteredPositions.where((p) => p.strategyName == _selectedStrategy).toList();
        }

        final totalUnrealizedPnl = filteredPositions.fold<num>(0, (sum, pos) => sum + pos.pnl);
        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            await Future.wait([
              ref.read(portfolioProvider.notifier).refresh(),
              ref.read(strategyProvider.notifier).refresh(),
              ref.read(backtestProvider.notifier).refresh(),
            ]);
          },
          color: AppColors.cyan,
          backgroundColor: AppColors.cardSurface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Enhanced Total Unrealized P&L
                Container(
                   padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                   ),
                   child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text("TOTAL UNREALIZED P&L", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                               const SizedBox(height: 8),
                               Text(
                                 "${totalUnrealizedPnl >= 0 ? '+' : '-'}\$${totalUnrealizedPnl.abs().toStringAsFixed(2)}", 
                                 style: TextStyle(
                                   color: totalUnrealizedPnl >= 0 ? AppColors.green : Colors.redAccent, 
                                   fontSize: 22, 
                                   fontWeight: FontWeight.w900,
                                   fontFeatures: const [FontFeature.tabularFigures()],
                                 )
                               ),
                            ],
                         ),
                         Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                               color: AppColors.cyan.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text("${filteredPositions.length} POSITIONS", style: const TextStyle(color: AppColors.cyan, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                         ),
                      ],
                   ),
                ),
                const SizedBox(height: 16),
                
                if (filteredPositions.isEmpty)
                   _buildEmptyState("No data available", "Monitor all currently open trading positions based on strategy and symbol, including price, quantity, side, order ID, and execution time."),

                // Position List
                ...filteredPositions.map((pos) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEnhancedPositionCard(pos),
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

  Widget _buildEmptyState(String title, String subtitle) {
     return Container(
        height: 240,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
           color: Colors.white.withOpacity(0.02),
           borderRadius: BorderRadius.circular(20),
           border: Border.all(color: Colors.white10),
        ),
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
              Icon(Icons.layers_clear_outlined, size: 40, color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 10, height: 1.5)),
              ),
           ],
        ),
     );
  }

  Widget _buildEnhancedPositionCard(PositionModel pos) {
     final bool isBuy = (pos.side?.toUpperCase() == "BUY" || pos.quantity >= 0);
     final Color sideColor = isBuy ? AppColors.green : Colors.redAccent;
     final Color pnlColor = pos.pnl >= 0 ? AppColors.green : Colors.redAccent;
     
     return Container(
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
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Text(pos.strategyName?.toUpperCase() ?? "MANUAL TRADE", style: const TextStyle(color: AppColors.cyan, fontSize: 8, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(pos.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                       ],
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                           Text(
                             "${pos.pnl >= 0 ? '+' : '-'}\$${pos.pnl.abs().toStringAsFixed(2)}", 
                             style: TextStyle(color: pnlColor, fontWeight: FontWeight.w900, fontSize: 14, fontFeatures: const [FontFeature.tabularFigures()])
                           ),
                           Text("${pos.pnlPercentage.toStringAsFixed(2)}%", style: TextStyle(color: pnlColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                    ),
                 ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Colors.white10, height: 1),
              ),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildPosDetail("SIDE", pos.side?.toUpperCase() ?? "-", color: sideColor),
                    _buildPosDetail("ENTRY", "\$${pos.entryPrice.toStringAsFixed(2)}"),
                    _buildPosDetail("MARK", "\$${pos.currentPrice.toStringAsFixed(2)}"),
                    _buildPosDetail("QTY", pos.quantity.toStringAsFixed(2)),
                 ],
              ),
              const SizedBox(height: 16),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildCompactMeta("BROKER", pos.brokerName ?? "COINDCX"),
                    _buildCompactMeta("ID", pos.orderId ?? "-", flex: 2),
                    _buildCompactMeta("TIME", pos.dateTime?.split('T').first ?? "-"),
                 ],
              ),
           ],
        ),
     );
  }

  Widget _buildPosDetail(String label, String value, {Color? color}) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(label, style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 8, fontWeight: FontWeight.w900)),
           const SizedBox(height: 4),
           Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
        ],
     );
  }

  Widget _buildCompactMeta(String label, String value, {int flex = 1}) {
     return Expanded(
       flex: flex,
       child: Text("$label: $value", style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 8, fontWeight: FontWeight.bold)),
     );
  }

  // --- CLOSED POSITIONS TAB ---
  Widget _buildClosedPositionsTab() {
     final mode = ref.watch(tradingModeProvider);
     
     // Update filter tradeMode when mode changes
     WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentFilter = ref.read(userOrderDetailsFilterProvider);
        final String targetMode = mode == TradingMode.live ? "1" : "0";
        if (currentFilter.tradeMode != targetMode) {
           ref.read(userOrderDetailsFilterProvider.notifier).state = currentFilter.copyWith(tradeMode: targetMode);
        }
     });

     return ref.watch(userOrderDetailsProvider).when(
       data: (trades) {
         var filteredTrades = trades;
         if (_selectedSymbol != "All") {
           filteredTrades = filteredTrades.where((t) => t.symbol.toUpperCase().contains(_selectedSymbol.toUpperCase())).toList();
         }

          if (filteredTrades.isEmpty) {
             return _buildEmptyState("No data available", "View all completed trades based on strategy and symbol, including buy/sell price, quantity, execution time, and profit or loss.");
          }

         return RefreshIndicator(
           onRefresh: () async {
              HapticFeedback.mediumImpact();
              ref.invalidate(userOrderDetailsProvider);
           },
           color: AppColors.cyan,
           backgroundColor: AppColors.cardSurface,
           child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: filteredTrades.length,
              itemBuilder: (context, index) {
                 final trade = filteredTrades[index];
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 16.0),
                   child: _buildEnhancedClosedPositionCard(trade),
                 );
              },
           ),
         );
       },
       loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
       error: (err, stack) => _buildEmptyState("Unable to fetch trades", "Failed to retrieve order history from the server."),
     );
  }

  Widget _buildEnhancedClosedPositionCard(UserOrderDetailsModel trade) {
     final bool isProfit = trade.profit >= 0;
     final Color pnlColor = isProfit ? AppColors.green : Colors.redAccent;
     final Color sideColor = trade.side.toUpperCase() == "BUY" ? AppColors.green : Colors.redAccent;
     
     return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: AppColors.cardSurface,
           borderRadius: BorderRadius.circular(20),
           border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
           children: [
              // Strategy Header
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Text(trade.strategyName.toUpperCase(), style: const TextStyle(color: AppColors.cyan, fontSize: 8, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(trade.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                       ],
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                           Text(
                             "${trade.profit >= 0 ? '+' : '-'}\$${trade.profit.abs().toStringAsFixed(2)}", 
                             style: TextStyle(color: pnlColor, fontWeight: FontWeight.w900, fontSize: 14, fontFeatures: const [FontFeature.tabularFigures()])
                           ),
                           Text("REALIZED P&L", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 7, fontWeight: FontWeight.w900)),
                        ],
                    ),
                 ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Colors.white10, height: 1),
              ),
              // Institutional Info Grid
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildPosDetail("SIDE", trade.side.toUpperCase(), color: sideColor),
                    _buildPosDetail("BUY PRICE", "\$${trade.buyPrice.toStringAsFixed(2)}"),
                    _buildPosDetail("SELL PRICE", "\$${trade.sellPrice.toStringAsFixed(2)}"),
                    _buildPosDetail("QTY", trade.quantity.toStringAsFixed(2)),
                 ],
              ),
              const SizedBox(height: 16),
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildCompactMeta("ORDER ID", trade.orderId, flex: 1),
                    _buildCompactMeta("TIME", trade.datetime.split('T').first, flex: 1),
                 ],
              ),
           ],
        ),
     );
  }

  // --- UNUSED TAB BUILDERS (DECOUPLED TO STANDALONE SCREENS) ---

  // --- END OF CORE PORTFOLIO LOGIC ---
}
