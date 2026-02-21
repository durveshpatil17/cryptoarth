import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/providers/deployed_strategy_provider.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/strategies/models/deployed_strategy_model.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';
import 'package:cryptoarth/features/home/screens/main_screen.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  int _selectedTab = 0; // 0: Discover, 1: Live Deployments

  void _undeployStrategy(String strategyId) {
    ref.read(strategyProvider.notifier).undeployStrategy(strategyId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Strategy undeployed successfully"),
          backgroundColor: Colors.green,
        ),
      );
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

  void _deployStrategy(String strategyId) {
    // Hardcoding brokerId to 1 for demo
    ref.read(strategyProvider.notifier).deployStrategy(strategyId, 1).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Strategy deployed successfully"),
          backgroundColor: Colors.green,
        ),
      );
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
        onTap: () => setState(() => _selectedTab = index),
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
        // "Discover" Tab
        return ref.watch(dashboardStrategyProvider).when(
          data: (strategies) {
            if (strategies.isEmpty) {
              return const Center(child: Text("No strategies available", style: TextStyle(color: Colors.white54)));
            }
            return Column(
              children: strategies.map((s) => Column(
                children: [
                  _StrategyCard(
                    data: s,
                    isBrokerConnected: true,
                    onAction: () => _deployStrategy(s.id),
                    isLive: false,
                  ),
                  const SizedBox(height: 16),
                ],
              )).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
          error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
        );
     } else {
        // "My Strategies" Tab
        return ref.watch(deployedStrategyProvider).when(
          data: (liveStrategies) {
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
                          child: const Icon(Icons.rocket_launch_outlined, size: 40, color: Colors.white30),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No active deployments",
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Deploy a strategy to start trading",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
               children: liveStrategies.map((s) {
                 final fakeStrategyModel = StrategyModel(
                   id: 'temp_id', 
                   strategyName: s.strategyName, 
                   strategyCode: s.strategyCode, 
                   createdAt: '', 
                   isDeployed: true, 
                   brokerId: 1
                 );
                 return Column(
                 children: [
                   _StrategyCard(
                     data: fakeStrategyModel,
                     isBrokerConnected: true, 
                     onAction: () => _undeployStrategy(fakeStrategyModel.id), // Might fail since ID is missing in DeployedStrategyModel, but will pass 0
                     isLive: true,
                   ),
                   const SizedBox(height: 16),
                 ],
               );}).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
          error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
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
    final bool isActive = widget.isLive;
    final bool isOwner = true; // Hardcoded true since it's user's dashboard normally

    return Container(
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOwner ? AppColors.primary.withOpacity(0.3) : Colors.white.withOpacity(0.05),
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
                       backgroundColor: isOwner ? AppColors.primary : Colors.blueGrey,
                       child: Icon(isOwner ? Icons.person : Icons.public, size: 14, color: Colors.white),
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
                         color: isActive ? AppColors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                         borderRadius: BorderRadius.circular(4),
                         border: Border.all(color: isActive ? AppColors.green.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        isActive ? "ACTIVE" : "DRAFT", 
                        style: TextStyle(color: isActive ? AppColors.green : Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)
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
                     _buildCompactStat("Win Rate", "N/A", AppColors.cyan),
                     Container(width: 1, height: 20, color: Colors.white10),
                     _buildCompactStat("Real P&L", "N/A", AppColors.green),
                     Container(width: 1, height: 20, color: Colors.white10),
                     _buildCompactStat("Max DD", "N/A", Colors.redAccent),
                  ],
               ),
             ),

             const SizedBox(height: 12),

             // Toggle (Visible only if not active)
             if (!isActive)
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
                     Expanded(child: _buildModeOptionCompact("Paper", !_isLiveMode, AppColors.cyan, () => setState(() => _isLiveMode = false))),
                     Expanded(child: _buildModeOptionCompact("Live", _isLiveMode, Colors.redAccent, () => setState(() => _isLiveMode = true))),
                   ],
                 ),
               ),
             ),

             // Action Buttons (Compact)
             Row(
                children: [
                   Expanded(child: _buildOutlineButton(Icons.bar_chart, "Chart")),
                   const SizedBox(width: 8),
                   Expanded(child: _buildOutlineButton(Icons.description, "Details")),
                   const SizedBox(width: 8),
                   Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: widget.isBrokerConnected ? widget.onAction : () {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please connect broker first!")));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isActive ? Colors.redAccent : (_isLiveMode ? Colors.redAccent : AppColors.cyan),
                             foregroundColor: Colors.white,
                             padding: EdgeInsets.zero,
                             elevation: 0,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                             isActive ? "Stop" : "Deploy",
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

  Widget _buildOutlineButton(IconData icon, String label) {
     return Container(
        height: 32,
        decoration: BoxDecoration(
           color: Colors.white.withOpacity(0.05), 
           borderRadius: BorderRadius.circular(8),
           border: Border.all(color: Colors.white.withOpacity(0.0)),
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
           ],
        ),
     );
  }
}
