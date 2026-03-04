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
import 'package:cryptoarth/features/strategies/screens/backtest_config_screen.dart';

import 'package:cryptoarth/features/strategies/widgets/strategy_card.dart';

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
        title: const Text(
          "Strategy Marketplace",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.search, color: Colors.white70),
          ),
          const SizedBox(width: 8),
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
                      StrategyCard(
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
      // "My Strategies" Tab
      final allStrategiesAsync = ref.watch(strategyProvider);
      final deployedListAsync = ref.watch(deployedStrategyProvider);

      return allStrategiesAsync.when(
        data: (userStrategies) => deployedListAsync.when(
          data: (deployedStrategies) {
            final deployedStrategiesInUserList = userStrategies.where((s) => s.isDeployed).toList();

            if (deployedStrategiesInUserList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Column(
                    children: [
                      Icon(Icons.rocket_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      const Text("No active deployments", style: TextStyle(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => setState(() => _selectedTab = 0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text("Deploy a Strategy", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: deployedStrategiesInUserList.map((s) {
                return Column(
                  children: [
                    StrategyCard(
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
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
          error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
        error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      );
    }
  }
}
