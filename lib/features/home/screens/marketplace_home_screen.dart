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
import 'package:cryptoarth/shared/widgets/luxury_background.dart';
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
  int _currentCarouselIndex = 0;
  final PageController _marketplacePageController = PageController();

  @override
  void dispose() {
    _marketplacePageController.dispose();
    super.dispose();
  }

  void _deployStrategy(String strategyCode, bool isLive) {
    ref.read(strategyProvider.notifier).deployStrategy(strategyCode, isLive: isLive).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Strategy deployed in ${isLive ? 'LIVE' : 'PAPER'} mode"),
          backgroundColor: isLive ? Colors.orangeAccent : Colors.blueAccent,
        ),
      );
      _refreshAll();
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Deploy failed: $e"), backgroundColor: Colors.redAccent),
      );
    });
  }

  void _switchMode(String strategyCode, bool isLive) {
    ref.read(strategyProvider.notifier).switchTradeMode(strategyCode, isLive).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Trade mode switched to ${isLive ? 'LIVE' : 'PAPER'}"),
          backgroundColor: isLive ? Colors.orangeAccent : Colors.blueAccent,
          duration: const Duration(seconds: 1),
        ),
      );
      _refreshAll();
    }).catchError((e) {
       // Silent fail or minimal feedback as it's a toggle
    });
  }

  void _undeployStrategy(StrategyModel strategy) {
    final String code = strategy.strategyCode;
    
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Strategy code not found. Refreshing..."), backgroundColor: Colors.orange),
      );
      _refreshAll();
      return;
    }

    ref.read(strategyProvider.notifier).undeployStrategy(code).then((_) {
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
      body: LuxuryBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshAll();
            // Also refresh balance explicitly just in case
            ref.read(brokerBalanceProvider.notifier).refresh();
          },
          color: AppColors.secondary,
          backgroundColor: AppColors.cardSurface,
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildLivePrices(),
              const SizedBox(height: 12),
              _buildTabToggle(),
              const SizedBox(height: 8),
              Expanded(
                child: _buildStrategyList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav(double balance) {
    return AppBar(
      backgroundColor: Colors.transparent,
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary.withOpacity(0.2), width: 1),
            ),
            child: SvgPicture.asset("assets/images/favicon.svg", height: 20, width: 20),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              "MARKETPLACE",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w800, 
                fontSize: 14, 
                letterSpacing: 2.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.hub_outlined, size: 20, color: AppColors.secondary),
        ),
        const SizedBox(width: 8),
      ],
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
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(pair, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.bold)),
                Text(price, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
              ],
            ),
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
               decoration: BoxDecoration(
                 color: (isPositive ? AppColors.green : Colors.redAccent).withOpacity(0.1),
                 borderRadius: BorderRadius.circular(4),
               ),
               child: Text(change, style: TextStyle(color: isPositive ? AppColors.green : Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
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
          _currentCarouselIndex = 0; // Reset page on tab change
          if (_marketplacePageController.hasClients) {
             _marketplacePageController.jumpToPage(0);
          }
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
    final dashboardAsync = ref.watch(dashboardStrategyProvider);
    final userAsync = ref.watch(strategyProvider);

    return dashboardAsync.when(
      data: (dashboardStrategies) => userAsync.when(
        data: (userStrategies) {
          final List<StrategyModel> strategiesToShow;

          if (_selectedTab == 0) {
            // Pre-defined: Show all from dashboard
            strategiesToShow = dashboardStrategies;
          } else {
            // My Strategies: User ones + Deployed ones from dashboard
            // Combine and deduplicate by strategyCode
            final Map<String, StrategyModel> myMap = {};
            
            // 1. All user local strategies
            for (var s in userStrategies) {
              myMap[s.strategyCode] = s;
            }
            
            // 2. Add deployed marketplace ones if they aren't already there
            for (var s in dashboardStrategies) {
              if (s.isDeployed && !myMap.containsKey(s.strategyCode)) {
                myMap[s.strategyCode] = s;
              }
            }
            
            strategiesToShow = myMap.values.toList();
          }

          if (strategiesToShow.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  _selectedTab == 0 ? "No pre-defined strategies" : "No personal or deployed strategies", 
                  style: const TextStyle(color: Colors.white54, fontSize: 13)
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: strategiesToShow.length,
                  itemBuilder: (context, index) {
                    final strategy = strategiesToShow[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: StrategyCard(
                        data: strategy,
                        isBrokerConnected: true,
                        isLive: strategy.isDeployed,
                        onModeAction: (isLive) {
                          if (strategy.isDeployed) {
                            _switchMode(strategy.strategyCode, isLive);
                          }
                        },
                        onAction: (isLive) {
                          if (strategy.isDeployed) {
                            _undeployStrategy(strategy);
                          } else {
                            _deployStrategy(strategy.strategyCode, isLive);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
    ),
    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
    error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
    );
  }
}
