import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/features/signals/providers/signal_provider.dart';
import 'package:cryptoarth/features/signals/models/signal_model.dart';

import 'package:cryptoarth/features/strategies/models/deployed_strategy_model.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:intl/intl.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  String _selectedStrategy = "All Strategies";
  String _selectedSymbol = "All Symbols";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "MARKET SCANNER",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
              ),
              const SizedBox(height: 2),
              Text(
                "REAL-TIME SIGNAL INTELLIGENCE",
                style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
            ],
          ),
          bottom: TabBar(
            isScrollable: false,
            indicatorColor: AppColors.cyan,
            indicatorWeight: 2,
            unselectedLabelColor: Colors.white24,
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            tabs: const [
              Tab(text: "SIGNAL LOGS"),
              Tab(text: "LIVE SCANNERS"),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(signalProvider.notifier).refresh();
                ref.invalidate(deployedStrategiesProvider);
              },
              icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white70),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await ref.read(signalProvider.notifier).refresh();
              },
              color: AppColors.cyan,
              backgroundColor: AppColors.cardSurface,
              child: _buildSignalLogsTab(),
            ),
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(deployedStrategiesProvider);
              },
              color: AppColors.cyan,
              backgroundColor: AppColors.cardSurface,
              child: _buildLiveScannersTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalLogsTab() {
    final signalsAsync = ref.watch(signalProvider);

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: signalsAsync.when(
            data: (signals) {
              final filtered = signals.where((s) {
                bool strategyMatch = _selectedStrategy == "All Strategies" || s.strategyName.contains(_selectedStrategy);
                bool symbolMatch = _selectedSymbol == "All Symbols" || s.symbol.contains(_selectedSymbol);
                return strategyMatch && symbolMatch;
              }).toList();

              if (filtered.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildEmptyState("No signals detected", "Try adjusting your filters or wait for market movements."),
                  ),
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildSignalCard(filtered[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
            error: (e, _) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: _buildEmptyState("Scanner Offline", "Failed to connect to signal server. Check connection."),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveScannersTab() {
    final deployedAsync = ref.watch(deployedStrategiesProvider);

    return deployedAsync.when(
      data: (deployed) {
        if (deployed.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildEmptyState("No Scanners Active", "Deploy a strategy to start real-time market scanning."),
            ),
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: deployed.length,
          itemBuilder: (context, index) => _buildScannerCard(deployed[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      error: (e, _) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: _buildEmptyState("Scanners Offline", "Failed to fetch deployed strategies."),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(child: _buildCompactDropdown(_selectedStrategy, ["All Strategies", "RSI", "MACD"], (v) => setState(() => _selectedStrategy = v!))),
          const SizedBox(width: 12),
          Expanded(child: _buildCompactDropdown(_selectedSymbol, ["All Symbols", "BTCUSD", "ETHUSD"], (v) => setState(() => _selectedSymbol = v!))),
        ],
      ),
    );
  }

  Widget _buildSignalCard(SignalModel sig) {
    final bool isBuy = sig.side.toUpperCase() == "BUY" || sig.side.toUpperCase() == "LONG";
    final Color accent = isBuy ? AppColors.green : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(sig.side.toUpperCase(), style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                  const SizedBox(width: 12),
                  Text(sig.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
              Text(sig.timestamp.split('T').first, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetric("ENTRY", sig.entryPrice.toStringAsFixed(2)),
              _buildMetric("TARGET", sig.targetPrice.toStringAsFixed(2)),
              _buildMetric("STOP LOSS", sig.stopLoss.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _buildBadge(sig.strategyName),
               _buildBadge(sig.status.toUpperCase(), isStatus: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerCard(DeployedStrategyModel deployed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyan.withOpacity(0.1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cyan.withOpacity(0.02), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.radar_rounded, color: AppColors.cyan, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deployed.strategyName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(height: 4),
                Text("SCANNING FOR OPPORTUNITIES", style: TextStyle(color: AppColors.cyan.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text("LIVE", style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, {bool isStatus = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isStatus ? AppColors.cyan : Colors.white24,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildCompactDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
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

  Widget _buildEmptyState(String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), shape: BoxShape.circle),
            child: Icon(Icons.radar_rounded, size: 40, color: Colors.white.withOpacity(0.1)),
          ),
          const SizedBox(height: 20),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(sub, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w500, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
