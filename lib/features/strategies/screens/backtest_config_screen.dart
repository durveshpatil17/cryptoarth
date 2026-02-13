import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'backtest_results_screen.dart';

class BacktestConfigScreen extends StatefulWidget {
  const BacktestConfigScreen({super.key});

  @override
  State<BacktestConfigScreen> createState() => _BacktestConfigScreenState();
}

class _BacktestConfigScreenState extends State<BacktestConfigScreen> {
  String _selectedTimeframe = '1h';
  String _selectedSymbol = 'BTC/USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Configure Backtest")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSectionHeader("Strategy Settings"),
            const SizedBox(height: 16),
            
            _buildDropdownInput("Symbol", ["BTC/USD", "ETH/USD", "SOL/USD"], _selectedSymbol, (val) {
              setState(() => _selectedSymbol = val!);
            }),
            const SizedBox(height: 12),
            _buildDropdownInput("Timeframe", ["1m", "5m", "15m", "1h", "4h", "1d"], _selectedTimeframe, (val) {
              setState(() => _selectedTimeframe = val!);
            }),

            const SizedBox(height: 24),
            _buildSectionHeader("Capital Management"),
            const SizedBox(height: 16),
            
            _buildTextInput("Initial Capital", "10000"),
            const SizedBox(height: 12),
            _buildTextInput("Order Size (%)", "10"),
            const SizedBox(height: 12),
            _buildTextInput("Leverage", "1x"),
             const SizedBox(height: 12),
            _buildTextInput("Commission", "0.1%"),

            const SizedBox(height: 32),
            CustomButton(
              text: "Run Backtest",
              icon: Icons.play_arrow,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BacktestResultsScreen()),
                );
              },
            ),
             const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDropdownInput(String label, List<String> items, String value, Function(String?) onChanged) {
    return GlassContainer(
      color: AppColors.cardSurface,
      opacity: 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          DropdownButton<String>(
            value: value,
            dropdownColor: AppColors.cardSurface,
            underline: Container(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(String label, String initialValue) {
    return GlassContainer(
      color: AppColors.cardSurface,
      opacity: 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          SizedBox(
            width: 100,
            child: TextField(
              controller: TextEditingController(text: initialValue),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}
