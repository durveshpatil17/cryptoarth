import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';

class BacktestResultsScreen extends StatelessWidget {
  const BacktestResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Backtest Results")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // KPI Cards
             Row(
              children: [
                Expanded(child: _buildKpiCard("Net Profit", "+\$4,250", AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _buildKpiCard("Win Rate", "68%", AppColors.cyan)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildKpiCard("Max Drawdown", "-12%", Colors.redAccent)),
                const SizedBox(width: 12),
                Expanded(child: _buildKpiCard("Sharpe Ratio", "1.85", AppColors.purple)),
              ],
            ),
             const SizedBox(height: 24),

            // Equity Curve Chart
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Equity Curve", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 10000),
                        const FlSpot(1, 10500),
                        const FlSpot(2, 10200),
                        const FlSpot(3, 11000),
                        const FlSpot(4, 11500),
                        const FlSpot(5, 11200),
                        const FlSpot(6, 12500),
                        const FlSpot(7, 13000),
                        const FlSpot(8, 14250),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            // Monthly Heatmap (Visual Placeholder)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Monthly Returns", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              color: AppColors.cardSurface,
              opacity: 0.5,
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  // Simulate random monthly returns colors
                  final isProfit = index % 3 != 0;
                  return Container(
                    decoration: BoxDecoration(
                      color: isProfit ? AppColors.primary.withOpacity(0.6) : Colors.redAccent.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return GlassContainer(
      color: AppColors.cardSurface,
      opacity: 0.5,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
