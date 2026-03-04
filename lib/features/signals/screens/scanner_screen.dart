import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/features/signals/providers/signal_provider.dart';
import 'package:cryptoarth/features/signals/models/signal_model.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  String _selectedStrategy = "All";
  String _selectedSymbol = "All";

  @override
  Widget build(BuildContext context) {
    final signalsAsync = ref.watch(signalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Strategy Signals Scanner",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Subheader
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 12,
              color: AppColors.cardSurface,
              opacity: 0.3,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "This scanner shows strategy-wise BUY and SELL signals, including entry, exit, and execution time.",
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: _buildFilterDropdown("Strategy", _selectedStrategy, ["All", "RSI", "MACD"]),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: _buildFilterDropdown("Symbol", _selectedSymbol, ["All", "BTC/USDT", "ETH/USDT"]),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => ref.read(signalProvider.notifier).refresh(),
                      child: const Icon(Icons.refresh, size: 16, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Data Table
          Expanded(
            child: signalsAsync.when(
              data: (signals) {
                if (signals.isEmpty) {
                  return const Center(child: Text("No signals found", style: TextStyle(color: Colors.white54)));
                }

                // Filter Logic (Simple mock)
                final filtered = signals.where((s) {
                  bool strategyMatch = _selectedStrategy == "All" || s.strategyName.contains(_selectedStrategy);
                  bool symbolMatch = _selectedSymbol == "All" || s.symbol.contains(_selectedSymbol);
                  return strategyMatch && symbolMatch;
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    child: GlassContainer(
                      color: AppColors.cardSurface,
                      opacity: 0.5,
                      borderRadius: 16,
                      padding: const EdgeInsets.all(0),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
                        headingTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                        dataTextStyle: const TextStyle(color: Colors.white70, fontSize: 11),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text("Symbol")),
                          DataColumn(label: Text("Side")),
                          DataColumn(label: Text("Entry")),
                          DataColumn(label: Text("Target")),
                          DataColumn(label: Text("Stoploss")),
                          DataColumn(label: Text("Leverage")),
                          DataColumn(label: Text("Capital")),
                          DataColumn(label: Text("Type")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Timestamp")),
                          DataColumn(label: Text("Strategy Name")),
                        ],
                        rows: filtered.map((sig) => _buildRow(sig)).toList(),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.cardSurface,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 16),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() {
                if (label.contains("Strategy")) _selectedStrategy = v!;
                else _selectedSymbol = v!;
              }),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildRow(SignalModel sig) {
    final bool isBuy = sig.side.toUpperCase() == "BUY" || sig.side.toUpperCase() == "LONG";
    final sideColor = isBuy ? AppColors.green : Colors.redAccent;

    return DataRow(cells: [
      DataCell(Text(sig.symbol, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: sideColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: sideColor.withOpacity(0.5)),
        ),
        child: Text(sig.side.toUpperCase(), style: TextStyle(color: sideColor, fontWeight: FontWeight.bold, fontSize: 10)),
      )),
      DataCell(Text(sig.entryPrice.toStringAsFixed(2))),
      DataCell(Text(sig.targetPrice.toStringAsFixed(2))),
      DataCell(Text(sig.stopLoss.toStringAsFixed(2))),
      DataCell(Text("${sig.leverage}x")),
      DataCell(Text("\$${sig.capital}")),
      DataCell(Text(sig.orderType)),
      DataCell(Text(sig.status.toUpperCase(), style: TextStyle(color: sig.status.toUpperCase() == "SUCCESS" ? AppColors.green : Colors.orange))),
      DataCell(Text(sig.timestamp)),
      DataCell(Text(sig.strategyName)),
    ]);
  }
}
