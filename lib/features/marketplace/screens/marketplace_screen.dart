import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/providers/deployed_strategy_provider.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/strategies/models/deployed_strategy_model.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';
import 'package:cryptoarth/features/home/screens/main_screen.dart';

import 'package:cryptoarth/core/utils/report_generator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/features/strategies/widgets/strategy_detailed_report.dart';
import 'package:cryptoarth/features/strategies/screens/backtest_results_screen.dart';
import 'package:cryptoarth/features/strategies/widgets/technical_chart_screen.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  int _selectedTab = 0; // 0: Discover, 1: Live Deployments

  void _undeployStrategy(StrategyModel strategy) {
    // The backend confirmed that undeployment requires the integer record ID 
    // from the user's deployed list, passed under the key 'strategyid'.
    // Important: It likely needs to be an actual integer type in the JSON.
    String? rawId = strategy.deploymentId;
    
    // If we're on the discover tab, we might not have the deploymentId directly.
    // We search the user's active deployments by strategy ID or code.
    if (rawId == null) {
      final userStrategies = ref.read(strategyProvider).value ?? [];
      for (var s in userStrategies) {
        if (s.id == strategy.id || (s.strategyCode.isNotEmpty && s.strategyCode == strategy.strategyCode)) {
          rawId = s.deploymentId;
          break;
        }
      }
    }

    if (rawId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Active deployment record not found locally. Refreshing..."), backgroundColor: Colors.orange),
      );
      _refreshAll();
      return;
    }

    // Try to parse to int, fallback to string if not numeric
    final idToPass = int.tryParse(rawId) ?? rawId;

    ref.read(strategyProvider.notifier).undeployStrategy(idToPass).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Strategy undeployed successfully"),
          backgroundColor: Colors.green,
        ),
      );
      _refreshAll();
    }).catchError((e) {
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Strategy already stopped or not found on server"), backgroundColor: Colors.orange),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Undeploy failed: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      _refreshAll();
    });
  }

  void _refreshAll() {
    ref.read(strategyProvider.notifier).refresh();
    ref.read(deployedStrategyProvider.notifier).refresh();
    ref.read(dashboardStrategyProvider.notifier).refresh();
  }

  void _deployStrategy(String strategyId) {
    // Hardcoding brokerId to 1 for demo
    ref.read(strategyProvider.notifier).deployStrategy(strategyId, 1).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Strategy deployed successfully"),
          backgroundColor: Colors.green,
        ),
      );
      ref.read(strategyProvider.notifier).refresh();
      ref.read(deployedStrategyProvider.notifier).refresh();
    }).catchError((e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    });
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
             Navigator.pushAndRemoveUntil(
               context,
               MaterialPageRoute(builder: (context) => const MainScreen()),
               (route) => false,
             );
          },
        ),
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
                       Expanded(child: _buildTabButton(0, "Pre-Defined", "All", const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)]))), // Purple-Pink Gradient
                       Expanded(child: _buildTabButton(1, "My Strategies", "Active", null)),
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
        onTap: () { setState(() { _selectedTab = index; }); },
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
              ],
           ),
        ),
     );
  }

  Widget _buildStrategyList() {
    if (_selectedTab == 0) {
      // "Discover" Tab - Shows Dashboard Strategies
      return ref.watch(dashboardStrategyProvider).when(
            data: (strategies) {
              if (strategies.isEmpty) {
                return const Center(
                    child: Text("No strategies available",
                        style: TextStyle(color: Colors.white54)));
              }
              return Column(
                children: strategies.map((s) {
                  return Column(
                    children: [
                      _StrategyCard(
                        data: s,
                        isBrokerConnected: true,
                        onAction: () {
                          if (s.isDeployed) {
                            _undeployStrategy(s);
                          } else {
                            _deployStrategy(s.id);
                          }
                        },
                        isLive: false,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
            error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
          );
    } else {
      // "My Strategies" Tab - Only show strategies currently deployed on backend
      final allStrategiesAsync = ref.watch(strategyProvider);
      final deployedListAsync = ref.watch(deployedStrategyProvider);

      return allStrategiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
        error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
        data: (allStrategies) {
          return deployedListAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
            error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
            data: (deployedList) {
              // Exact filtering against the official active deployment list
              final liveStrategies = allStrategies.where((s) {
                return deployedList.any((d) =>
                    d.strategyCode == s.strategyCode ||
                    d.strategyName == s.strategyName);
              }).toList();

              if (liveStrategies.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.rocket_launch_outlined,
                              size: 40, color: Colors.white30),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No active deployments",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Deploy a strategy to start trading",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5), fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTab = 0; // Switch to Discover
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("Deploy a Strategy",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: liveStrategies.map((s) {
                  return Column(
                    children: [
                      _StrategyCard(
                        data: s,
                        isBrokerConnected: true,
                        onAction: () => _undeployStrategy(s),
                        isLive: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              );
            },
          );
        },
      );
    }
  }
}

class _StrategyCard extends StatefulWidget {
   final StrategyModel data;
   final VoidCallback onAction;
   final bool isBrokerConnected;
   final bool isLive;

  const _StrategyCard({
    required this.data,
    required this.onAction,
    this.isBrokerConnected = false,
    required this.isLive,
  });

  @override
  State<_StrategyCard> createState() => _StrategyCardState();
}

class _StrategyCardState extends State<_StrategyCard> {
  bool _isLiveMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLive) {
      _isLiveMode = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = (widget.data.isDeployed == true);
    final bool isOwner = true; // Hardcoded true since it's user's dashboard normally

    return Container(
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isOwner == true) ? AppColors.primary.withOpacity(0.3) : Colors.white.withOpacity(0.05),
            width: 1,
          ),
       ),
       child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
             // Header: Avatar + Title + Status
             Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    CircleAvatar(
                       radius: 12,
                       backgroundColor: (isOwner == true) ? AppColors.primary : Colors.blueGrey,
                       child: Icon((isOwner == true) ? Icons.person : Icons.public, size: 14, color: Colors.white),
                    ),
                   const SizedBox(width: 8),
                   Expanded(
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text(
                               widget.data.strategyName,
                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                               maxLines: 1, 
                               overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Author • ${widget.data.strategyCode}", 
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)
                            ),
                         ],
                      ),
                   ),
                   const SizedBox(width: 8),
                   // Compact Status Badge
                   Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                         color: (isActive == true) ? AppColors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                         borderRadius: BorderRadius.circular(4),
                         border: Border.all(color: (isActive == true) ? AppColors.green.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        (isActive == true) ? "ACTIVE" : "DRAFT", 
                        style: TextStyle(color: (isActive == true) ? AppColors.green : Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)
                      ),
                   ),
                ],
             ),

             const SizedBox(height: 12),
             
             // Key Stats Row (Compact)
             Container(
               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
               decoration: BoxDecoration(
                 color: Colors.black.withOpacity(0.2),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     _buildCompactStat("Win Rate", "${widget.data.winRate.toStringAsFixed(1)}%", AppColors.cyan),
                     Container(width: 1, height: 20, color: Colors.white10),
                     _buildCompactStat("Total P&L", "\$${widget.data.totalPnl.toStringAsFixed(2)}", (widget.data.totalPnl >= 0) ? AppColors.green : Colors.redAccent),
                     Container(width: 1, height: 20, color: Colors.white10),
                     _buildCompactStat("Max DD", "\$${widget.data.maxDrawdown.toStringAsFixed(1)}", Colors.redAccent),
                   ],
               ),
             ),

             const SizedBox(height: 12),

             // Toggle (Visible only if not active)
             if (isActive != true)
             Padding(
               padding: const EdgeInsets.only(bottom: 12.0),
               child: Container(
                 height: 28,
                 padding: const EdgeInsets.all(2),
                 decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.05), 
                   borderRadius: BorderRadius.circular(6),
                 ),
                 child: Row(
                   children: [
                     Expanded(child: _buildModeOptionCompact("Paper", !_isLiveMode, AppColors.cyan, () { setState(() { _isLiveMode = false; }); })),
                     Expanded(child: _buildModeOptionCompact("Live", _isLiveMode, Colors.redAccent, () { setState(() { _isLiveMode = true; }); })),
                   ],
                 ),
               ),
             ),

             // Action Buttons (Compact)
             Row(
                children: [
                   Expanded(child: _buildOutlineButton(Icons.show_chart_outlined, "Chart", onTap: () {
                     showDialog(
                       context: context,
                        builder: (context) => TechnicalChartScreen(
                          strategyCode: widget.data.strategyCode,
                          strategyName: widget.data.strategyName,
                          backtestId: widget.data.id,
                        ),
                     );
                   })),
                   const SizedBox(width: 8),
                   Expanded(child: _buildOutlineButton(Icons.description_outlined, "Report", onTap: () {
                     showDialog(
                       context: context,
                        builder: (context) => StrategyDetailedReport(
                          strategyCode: widget.data.strategyCode,
                          backtestId: widget.data.id,
                        ),
                     );
                   })),
                   const SizedBox(width: 8),
                   Expanded(child: _buildOutlineButton(Icons.picture_as_pdf_outlined, "PDF", onTap: () {
                     ReportGenerator.downloadBacktestReport(
                       widget.data.strategyName,
                       widget.data.winRate.toDouble(),
                       widget.data.totalPnl.toDouble(),
                       widget.data.maxDrawdown.toDouble(),
                     );
                   })),
                   const SizedBox(width: 8),
                   Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: (widget.isBrokerConnected == true) ? widget.onAction : () {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please connect broker first!")));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (isActive == true) ? Colors.redAccent : ((_isLiveMode == true) ? Colors.redAccent : AppColors.cyan),
                             foregroundColor: Colors.white,
                             padding: EdgeInsets.zero,
                             elevation: 0,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                             (isActive == true) ? "Stop" : "Deploy",
                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                   ),
                ],
             ),
          ],
       ),
    );
  }

  Widget _buildCompactStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
      ],
    );
  }

  Widget _buildModeOptionCompact(String title, bool isSelected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title, 
          style: TextStyle(
            color: isSelected ? color : Colors.white38, 
            fontSize: 10, 
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
          )
        ),
      ),
    );
  }

  Widget _buildOutlineButton(IconData icon, String label, {VoidCallback? onTap}) {
    bool isSmallMobile = MediaQuery.of(context).size.width < 380;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            if (!isSmallMobile) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
