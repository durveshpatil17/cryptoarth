import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';

class TradingDashboardScreen extends StatelessWidget {
  const TradingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Trading Dashboard"),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: "Open Positions"),
              Tab(text: "Scanner"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PositionsTable(),
            _ScannerTable(),
          ],
        ),
      ),
    );
  }
}

class _PositionsTable extends StatelessWidget {
  const _PositionsTable();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              ),
              dataTextStyle: const TextStyle(color: Colors.white),
              columns: const [
                DataColumn(label: Text("Symbol")),
                DataColumn(label: Text("Side")),
                DataColumn(label: Text("Entry Price")),
                DataColumn(label: Text("Current")),
                DataColumn(label: Text("P&L (%)")),
                DataColumn(label: Text("Status")),
              ],
              rows: _generateMockPositions(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> _generateMockPositions() {
    return [
      _buildRow("BTC/USD", "LONG", "45,230.50", "46,100.00", "+1.92%", true),
      _buildRow("ETH/USD", "SHORT", "3,200.00", "3,150.00", "+1.56%", true),
      _buildRow("SOL/USD", "LONG", "110.50", "108.20", "-2.08%", false),
      _buildRow("ADA/USD", "LONG", "0.45", "0.45", "0.00%", true),
      _buildRow("XRP/USD", "SHORT", "0.62", "0.60", "+3.22%", true),
    ];
  }

  DataRow _buildRow(String symbol, String side, String entry, String current, String pnl, bool isProfit) {
    return DataRow(cells: [
      DataCell(Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(side, style: TextStyle(color: side == "LONG" ? AppColors.primary : Colors.redAccent))),
      DataCell(Text(entry)),
      DataCell(Text(current)),
      DataCell(Text(pnl, style: TextStyle(color: isProfit ? AppColors.primary : Colors.redAccent))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (isProfit ? AppColors.primary : Colors.redAccent).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(isProfit ? "PROFIT" : "LOSS", style: const TextStyle(fontSize: 10)),
      )),
    ]);
  }
}

class _ScannerTable extends StatelessWidget {
  const _ScannerTable();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Scanner Data Placeholder"));
  }
}
