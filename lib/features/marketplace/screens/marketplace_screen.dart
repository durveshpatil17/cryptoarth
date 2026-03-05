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
  int _selectedTab = 0; // 0: Discover, 1: My Strategies
  int _currentPage = 0;
  static const int _itemsPerPage = 4;

  void _undeployStrategy(StrategyModel strategy) {
    String? rawId = strategy.deploymentId;
    
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

              const SizedBox(height: 16), // Reduced from 24

              // Strategy List
              _buildStrategyList(),
              
              const SizedBox(height: 120), // Added significant bottom space
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
    final asyncData = _selectedTab == 0 
        ? ref.watch(dashboardStrategyProvider) 
        : ref.watch(strategyProvider);

    return asyncData.when(
      data: (allStrategies) {
        if (allStrategies.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Text(_selectedTab == 0 ? "No marketplace strategies" : "No user strategies", 
                style: const TextStyle(color: Colors.white54)),
            ),
          );
        }

        // Pagination Logic
        final startIndex = _currentPage * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage < allStrategies.length) 
            ? startIndex + _itemsPerPage 
            : allStrategies.length;
        
        final paginatedList = allStrategies.sublist(
          startIndex >= allStrategies.length ? 0 : startIndex,
          endIndex
        );

        final totalPages = (allStrategies.length / _itemsPerPage).ceil();

        return Column(
          children: [
            ...paginatedList.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: StrategyCard(
                data: s,
                isBrokerConnected: true,
                onAction: () => s.isDeployed ? _undeployStrategy(s) : _deployStrategy(s.id),
                isLive: s.isDeployed,
              ),
            )),
            
            if (totalPages > 1) ...[
              const SizedBox(height: 16),
              _buildPagination(totalPages),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalPages, (index) {
            final bool isSelected = _currentPage == index;
            return GestureDetector(
              onTap: () => setState(() => _currentPage = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cyan.withOpacity(0.1) : Colors.transparent,
                  border: Border.all(color: isSelected ? AppColors.cyan : Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      color: isSelected ? AppColors.cyan : Colors.white60,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
