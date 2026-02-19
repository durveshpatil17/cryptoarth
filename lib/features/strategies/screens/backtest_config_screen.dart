import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/gradient_button.dart';
import 'backtest_results_screen.dart';

class BacktestConfigScreen extends StatefulWidget {
  const BacktestConfigScreen({super.key});

  @override
  State<BacktestConfigScreen> createState() => _BacktestConfigScreenState();
}

class _BacktestConfigScreenState extends State<BacktestConfigScreen> {
  // Form State
  String _selectedSymbol = 'BTCUSD';
  String _selectedTimeframe = '15 Minutes';
  String _selectedLeverage = '10x';
  String _selectedCapitalPercent = '25%';
  String _selectedCommission = 'Maker (0.02%)';
  final TextEditingController _initialCapitalController = TextEditingController(text: '10000');

  // Options
  final List<String> _symbols = ['BTCUSD', 'ETHUSD', 'SOLUSD', 'XRPUSD'];
  final List<String> _timeframes = ['1 Minute', '5 Minutes', '15 Minutes', '1 Hour', '4 Hours', '1 Day'];
  final List<String> _leverages = ['1x', '2x', '5x', '10x', '20x', '50x', '100x'];
  final List<String> _capitalPercents = ['10%', '25%', '50%', '75%', '100%'];
  final List<String> _commissionTypes = ['Maker (0.02%)', 'Taker (0.05%)', 'Zero Fee'];

  @override
  void dispose() {
    _initialCapitalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.settings_outlined, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Backtest",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "EMA 9/21 Crossover (signal_based)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          color: AppColors.cardSurface,
          opacity: 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings_outlined, color: AppColors.purple, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Backtest\nConfiguration",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Show\nAdvanced",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: AppColors.cyan, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Strategy Info
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  children: const [
                    TextSpan(text: "Strategy: "),
                    TextSpan(
                      text: "EMA 9/21 Crossover •\nsignal_based",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Config
              _buildDropdownField("Symbol *", _selectedSymbol, _symbols, (val) {
                setState(() => _selectedSymbol = val!);
              }),
              const SizedBox(height: 16),
              _buildDropdownField("Timeframe *", _selectedTimeframe, _timeframes, (val) {
                setState(() => _selectedTimeframe = val!);
              }),
              const SizedBox(height: 16),
              _buildTextField("Initial Capital (\$) *", _initialCapitalController),
              const SizedBox(height: 16),
              _buildDropdownField("Leverage *", _selectedLeverage, _leverages, (val) {
                setState(() => _selectedLeverage = val!);
              }),
              const SizedBox(height: 16),
              _buildDropdownField("Capital % *", _selectedCapitalPercent, _capitalPercents, (val) {
                setState(() => _selectedCapitalPercent = val!);
              }),
              const SizedBox(height: 16),
              _buildDropdownField("Commission Type *", _selectedCommission, _commissionTypes, (val) {
                setState(() => _selectedCommission = val!);
              }),

              const SizedBox(height: 32),

              // Date Range Info
              Text(
                "Date: 2024-01-10 -> 2026-02-09 (760.82\ndays)",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Run Button
              GradientButton(
                text: "Run Backtest",
                icon: Icons.play_arrow,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BacktestResultsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.cardSurface,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.6)),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
