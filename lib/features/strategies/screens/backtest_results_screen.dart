import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/gradient_button.dart';

class BacktestResultsScreen extends StatelessWidget {
  const BacktestResultsScreen({super.key});

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Backtest Results",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "EMA 9/21 Crossover • BTCUSD • 15MIN",
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Filter & Exports
            _buildHeaderActions(),
            const SizedBox(height: 24),

            // Main Chart Section
            _buildSectionTitle("Backtest Chart", "Signals: 3  Indicators: 2"),
            const SizedBox(height: 12),
            _buildMainChart(),
            const SizedBox(height: 24),

            // Key Metrics Grid
             _buildSectionTitle("Performance Metrics", null),
            const SizedBox(height: 12),
            _buildMetricsGrid(),
            const SizedBox(height: 24),

            // Fees & Configuration
             _buildSectionTitle("Fees & Commission", null),
            const SizedBox(height: 12),
            _buildFeesCard(),
            const SizedBox(height: 12),
            _buildConfigSummary(),
            const SizedBox(height: 24),

            // Equity Curve
            _buildSectionTitle("Equity Curve", null),
            const SizedBox(height: 12),
            _buildEquityCurve(),
            const SizedBox(height: 24),

            // Monthly Heatmap
            _buildSectionTitle("Monthly Returns Heatmap", null),
            const SizedBox(height: 12),
            _buildMonthlyHeatmap(),
            const SizedBox(height: 24),

            // Time Analysis
            _buildSectionTitle("Time Analysis", null),
            const SizedBox(height: 12),
            _buildTimeAnalysis(),
             const SizedBox(height: 24),

             // Win/Loss Dist
             _buildSectionTitle("Win/Loss Distribution", null),
             const SizedBox(height: 12),
             _buildWinLossChart(),


            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 12,
          color: AppColors.cardSurface,
          child: Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: AppColors.cyan, size: 18),
              const SizedBox(width: 8),
              Text(
                "From: 2024-01-01  To: 2024-02-09",
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton("Export to CSV", Icons.download, AppColors.cyan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton("Export PDF Report", Icons.picture_as_pdf, AppColors.pink),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildMainChart() {
    return GlassContainer(
      height: 250,
      width: double.infinity,
      color: AppColors.cardSurface,
      opacity: 0.5,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Price Line (Simplification)
             LineChartBarData(
              spots: [
                const FlSpot(0, 42000),
                const FlSpot(1, 42200),
                const FlSpot(2, 41800),
                const FlSpot(3, 42500),
                const FlSpot(4, 43000),
                const FlSpot(5, 42800),
                const FlSpot(6, 43500),
              ],
              isCurved: true,
              color: Colors.white.withOpacity(0.2),
              barWidth: 1,
              dotData: const FlDotData(show: false),
            ),
            // EMA Fast
            LineChartBarData(
              spots: [
                const FlSpot(0, 42100),
                const FlSpot(1, 42300),
                const FlSpot(2, 42000),
                const FlSpot(3, 42600),
                const FlSpot(4, 43100),
                const FlSpot(5, 42900),
                const FlSpot(6, 43600),
              ],
              isCurved: true,
              color: AppColors.cyan,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
            // EMA Slow
            LineChartBarData(
              spots: [
                const FlSpot(0, 41900),
                const FlSpot(1, 42000),
                const FlSpot(2, 42100),
                const FlSpot(3, 42200),
                const FlSpot(4, 42400),
                const FlSpot(5, 42600),
                const FlSpot(6, 42800),
              ],
              isCurved: true,
              color: AppColors.orange,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard("NET P&L (AFTER FEES)", "-\$10,021,235.00", Colors.redAccent, "Final profit/loss")),
            const SizedBox(width: 8),
            Expanded(child: _buildMetricCard("GROSS P&L", "-\$9,175,000.00", AppColors.purple, "(BEFORE FEES)")),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildMetricCard("TOTAL FEES PAID", "-\$846,235.00", AppColors.orange, "")),
            const SizedBox(width: 8),
            Expanded(child: _buildMetricCard("WIN RATE %", "50.00%", AppColors.purple, "")),
          ],
        ),
         const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildSmallMetric("Total Trades", "2")),
            const SizedBox(width: 8),
            Expanded(child: _buildSmallMetric("Max Drawdown", "100.00%", valueColor: Colors.redAccent)),
             const SizedBox(width: 8),
            Expanded(child: _buildSmallMetric("Sharpe Ratio", "-0.77", valueColor: AppColors.cyan)),
          ],
        ),
        const SizedBox(height: 8),
         Row(
          children: [
             Expanded(child: _buildSmallMetric("Profit Factor", "0.13", valueColor: AppColors.gold)),
            const SizedBox(width: 8),
            Expanded(child: _buildSmallMetric("Avg Win \$", "\$1,490,682", valueColor: AppColors.green)),
             const SizedBox(width: 8),
            Expanded(child: _buildSmallMetric("Avg Loss \$", "\$11,511,917", valueColor: Colors.redAccent)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color valueColor, String subtitle) {
    return GlassContainer(
      color: valueColor.withOpacity(0.1),
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: valueColor, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
          ]
        ],
      ),
    );
  }

  Widget _buildSmallMetric(String title, String value, {Color valueColor = Colors.white}) {
    return GlassContainer(
      color: AppColors.cardSurface,
      padding: const EdgeInsets.all(10),
      borderRadius: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeesCard() {
    return GlassContainer(
      width: double.infinity,
      color: AppColors.cardSurface,
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text("Total Commission", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
               const SizedBox(height: 4),
               const Text("-\$846,235.00", style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 16)),
               const Text("(2 trades)", style: TextStyle(color: Colors.white30, fontSize: 10)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.orange.withOpacity(0.3)),
            ),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text("TOTAL FEES", style: TextStyle(color: AppColors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 4),
                 const Text("-\$846,235.00", style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildConfigSummary() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
           _buildConfigChip("Symbol", "BTCUSD"),
           _buildConfigChip("Timeframe", "15MIN"),
           _buildConfigChip("Leverage", "10x"),
           _buildConfigChip("Capital %", "25%"),
           _buildConfigChip("Commission", "0.02%"),
        ],
      ),
    );
  }

  Widget _buildConfigChip(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          const SizedBox(height: 2),
           Text(value, style: const TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEquityCurve() {
     return GlassContainer(
      height: 180,
      width: double.infinity,
      color: AppColors.cardSurface,
      opacity: 0.5,
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 5000000)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 0),
                const FlSpot(5, -2000000),
                const FlSpot(10, -5000000),
                const FlSpot(15, -8000000),
                const FlSpot(20, -10000000),
              ],
              isCurved: false,
              color: Colors.redAccent,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [Colors.redAccent.withOpacity(0.3), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyHeatmap() {
    return GlassContainer(
      color: Colors.redAccent.withOpacity(0.1),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("2024", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("-\$10,021,235", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("2 Trades", style: TextStyle(color: Colors.white, fontSize: 12)),
                   Text("50.0% Win", style: TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              )
            ],
          )
        ],
      )
    );
  }

  Widget _buildTimeAnalysis() {
    return Column(
      children: [
        Row(
          children: [
             Expanded(child: _buildTimeCard("Best Hour", "9:00 - 10:00", "\$1.4M", AppColors.green)),
             const SizedBox(width: 8),
             Expanded(child: _buildTimeCard("Worst Hour", "14:00 - 15:00", "-\$11.5M", Colors.redAccent)),
          ],
        ),
         const SizedBox(height: 8),
         Row(
          children: [
             Expanded(child: _buildTimeCard("Best Day", "Thursday", "-\$10M", AppColors.green)), // Logic from screenshot showing loss but green? sticking to screenshot
             const SizedBox(width: 8),
             Expanded(child: _buildTimeCard("Worst Day", "Thursday", "-\$10M", Colors.redAccent)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeCard(String title, String time, String value, Color color) {
    return GlassContainer(
       color: color.withOpacity(0.1),
       padding: const EdgeInsets.all(12),
       borderRadius: 8,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(title, style: TextStyle(color: color, fontSize: 10)),
           const SizedBox(height: 4),
            Text(time, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
             Text(value, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
         ],
       ),
    );
  }

  Widget _buildWinLossChart() {
    return GlassContainer(
      height: 200,
      width: double.infinity,
      color: AppColors.cardSurface,
      opacity: 0.5,
      child: Center(
        child: SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              sections: [
                 PieChartSectionData(
                  color: AppColors.green,
                  value: 50,
                  title: '50%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.redAccent,
                  value: 50,
                  title: '50%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
      ),
    );
  }

}
