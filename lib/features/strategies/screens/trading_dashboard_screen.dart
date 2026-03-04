import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/portfolio/providers/portfolio_provider.dart';
import 'package:cryptoarth/features/portfolio/models/position_model.dart';

class TradingDashboardScreen extends ConsumerWidget {
  const TradingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Trading Dashboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: AppColors.background,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: "Open Positions"),
              Tab(text: "Scanner"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PositionsTableView(),
            const _ScannerTable(),
          ],
        ),
      ),
    );
  }
}

class _PositionsTableView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionsAsync = ref.watch(portfolioProvider);

    return positionsAsync.when(
      data: (positions) {
        if (positions.isEmpty) {
          return const Center(child: Text("No open positions", style: TextStyle(color: Colors.white54)));
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(portfolioProvider.notifier).refresh(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassContainer(
                  color: AppColors.cardSurface,
                  opacity: 0.5,
                  padding: const EdgeInsets.all(16),
                  child: DataTable(
                    headingTextStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    dataTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    columns: const [
                      DataColumn(label: Text("Symbol")),
                      DataColumn(label: Text("Side")),
                      DataColumn(label: Text("Entry Price")),
                      DataColumn(label: Text("Current")),
                      DataColumn(label: Text("P&L (%)")),
                      DataColumn(label: Text("P&L (\$)")),
                    ],
                    rows: positions.map((pos) => _buildRow(pos)).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
    );
  }

  DataRow _buildRow(PositionModel pos) {
    final bool isLong = pos.quantity >= 0;
    final bool isProfit = pos.pnl >= 0;
    final pnlColor = isProfit ? AppColors.green : Colors.redAccent;

    return DataRow(cells: [
      DataCell(Text(pos.symbol, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(isLong ? "LONG" : "SHORT", style: TextStyle(color: isLong ? AppColors.green : Colors.redAccent))),
      DataCell(Text(pos.entryPrice.toStringAsFixed(2))),
      DataCell(Text(pos.currentPrice.toStringAsFixed(2))),
      DataCell(Text("${pos.pnlPercentage.toStringAsFixed(2)}%", style: TextStyle(color: pnlColor))),
      DataCell(Text("\$${pos.pnl.toStringAsFixed(2)}", style: TextStyle(color: pnlColor))),
    ]);
  }
}

class _ScannerTable extends StatelessWidget {
  const _ScannerTable();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Scanner Data Placeholder", style: TextStyle(color: Colors.white54)));
  }
}
