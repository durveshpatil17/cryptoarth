import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';
import 'package:cryptoarth/features/broker/providers/broker_balance_provider.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/marketplace/screens/marketplace_screen.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/features/portfolio/providers/watchlist_provider.dart';
import 'dart:async';

import 'package:cryptoarth/features/strategies/widgets/strategy_card.dart';

class MarketplaceHomeScreen extends ConsumerStatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  ConsumerState<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends ConsumerState<MarketplaceHomeScreen> {
  int _selectedTab = 0; // 0: Pre-defined, 1: My Strategies
  int _currentPage = 0;
  static const int _itemsPerPage = 2;

  void _deployStrategy(String strategyId) {
    ref.read(strategyProvider.notifier).deployStrategy(strategyId, 1).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Strategy deployed successfully"), backgroundColor: Colors.green),
      );
      _refreshAll();
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Deploy failed: $e"), backgroundColor: Colors.redAccent),
      );
    });
  }

  void _undeployStrategy(StrategyModel strategy) {
    String? rawId = strategy.deploymentId;
    if (rawId == null) {
      final userStrategies = ref.read(strategyProvider).value ?? [];
      for (var s in userStrategies) {
        if (s.id == strategy.id) {
          rawId = s.deploymentId;
          break;
        }
      }
    }

    if (rawId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Active deployment record not found locally."), backgroundColor: Colors.orange),
      );
      return;
    }

    final idToPass = int.tryParse(rawId) ?? rawId;
    ref.read(strategyProvider.notifier).undeployStrategy(idToPass).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Strategy undeployed successfully"), backgroundColor: Colors.green),
      );
      _refreshAll();
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Undeploy failed: $e"), backgroundColor: Colors.redAccent),
      );
    });
  }

  void _refreshAll() {
    ref.read(strategyProvider.notifier).refresh();
    ref.read(dashboardStrategyProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final brokerBalance = (ref.watch(brokerBalanceProvider).value?.balance ?? 0.0).toDouble();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _buildTopNav(brokerBalance),
      ),
      body: Column(
        children: [
          _buildLivePrices(),
          const SizedBox(height: 12),
          _buildTabToggle(),
          const SizedBox(height: 8),
          Expanded(
            child: _buildStrategyList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(double balance) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white70),
        onPressed: () {
          final ScaffoldState? root = context.findRootAncestorStateOfType<ScaffoldState>();
          root?.openDrawer();
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("assets/images/favicon.svg", height: 22, width: 22),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              "Marketplace",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.purple.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.purple, size: 10),
                const SizedBox(width: 4),
                Text(
                  "\$${balance.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  Widget _buildLivePrices() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildPriceItem("BTC/USD", "\$64.2k", "+1.2%"),
          const SizedBox(width: 8),
          _buildPriceItem("ETH/USD", "\$3.4k", "-0.5%"),
        ],
      ),
    );
  }


  Widget _buildPriceItem(String pair, String price, String change) {
    final bool isPositive = change.startsWith('+');
    return Expanded(
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.cardSurface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(pair, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 8), overflow: TextOverflow.ellipsis),
                  Text(price, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(change, style: TextStyle(color: isPositive ? AppColors.green : Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }



  Widget _buildTabToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildTabItem("Pre-defined", 0),
          const SizedBox(width: 12),
          _buildTabItem("My Strategies", 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _currentPage = 0; // Reset page on tab change
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? AppColors.cyan.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.cyan : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyList() {
    final strategiesAsync = _selectedTab == 0 
        ? ref.watch(dashboardStrategyProvider) 
        : ref.watch(strategyProvider);

    return strategiesAsync.when(
      data: (strategies) {
        if (strategies.isEmpty) {
          return Center(child: Text(_selectedTab == 0 ? "No pre-defined strategies" : "You haven't created any strategies yet", style: const TextStyle(color: Colors.white54)));
        }

        final int totalItems = strategies.length;
        final int totalPages = (totalItems / _itemsPerPage).ceil();
        final int startIdx = _currentPage * _itemsPerPage;
        final int endIdx = (startIdx + _itemsPerPage).clamp(0, totalItems);
        final currentStrategies = strategies.sublist(startIdx, endIdx);

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: currentStrategies.length,
                itemBuilder: (context, index) {
                  final strategy = currentStrategies[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: StrategyCard(
                      data: strategy,
                      isBrokerConnected: true,
                      isLive: strategy.isDeployed,
                      onAction: () {
                        if (strategy.isDeployed) {
                          _undeployStrategy(strategy);
                        } else {
                          _deployStrategy(strategy.id);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            if (totalPages > 1) _buildPaginationControls(totalPages),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            icon: Icon(Icons.arrow_back_ios_new, size: 14, color: _currentPage > 0 ? AppColors.cyan : Colors.white10),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 24),
          Text(
            "${_currentPage + 1} / $totalPages",
            style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: (_currentPage + 1) < totalPages ? () => setState(() => _currentPage++) : null,
            icon: Icon(Icons.arrow_forward_ios, size: 14, color: (_currentPage + 1) < totalPages ? AppColors.cyan : Colors.white10),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
