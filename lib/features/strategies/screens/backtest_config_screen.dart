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
              child: const Icon(Icons.settings_outlined, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
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
                  "EMA 9/21 Crossover",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          color: AppColors.cardSurface,
          opacity: 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // compact header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Configuration",
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Advanced >",
                    style: TextStyle(color: AppColors.cyan, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              // Form Grid
              Row(
                children: [
                   Expanded(
                      child: _buildDropdownField("Symbol", _selectedSymbol, _symbols, (v) => setState(() => _selectedSymbol = v!))
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                      child: _buildDropdownField("Timeframe", _selectedTimeframe, _timeframes, (v) => setState(() => _selectedTimeframe = v!))
                   ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                 children: [
                    Expanded(
                       child: _buildDropdownField("Leverage", _selectedLeverage, _leverages, (v) => setState(() => _selectedLeverage = v!))
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                       child: _buildDropdownField("Capital %", _selectedCapitalPercent, _capitalPercents, (v) => setState(() => _selectedCapitalPercent = v!))
                    ),
                 ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                 children: [
                    Expanded(
                       child: _buildTextField("Initial Capital", _initialCapitalController)
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                       child: _buildDropdownField("Commission", _selectedCommission, _commissionTypes, (v) => setState(() => _selectedCommission = v!))
                    ),
                 ],
              ),

              const SizedBox(height: 24),

              // Date Range Info Compact
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.05),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                   children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Text(
                         "2024-01-10 -> 2026-02-09 (760 days)",
                         style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                      ),
                   ],
                ),
              ),
              
              const SizedBox(height: 16),

              // Run Button Compact
              SizedBox(
                width: double.infinity,
                height: 40,
                child: GradientButton(
                  text: "Run Backtest",
                  icon: Icons.play_arrow,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BacktestResultsScreen(strategyCode: 'MACD_CROSSOVER')),
                    );
                  },
                ),
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
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
        ),
        const SizedBox(height: 6),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.cardSurface,
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white.withOpacity(0.6)),
              style: const TextStyle(color: Colors.white, fontSize: 12),
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
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
        ),
        const SizedBox(height: 6),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 14), // Vertically center text in 36 height container
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
