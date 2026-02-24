import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/gradient_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/backtest_provider.dart';
import 'package:cryptoarth/features/strategies/models/backtest_model.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/gradient_button.dart';
import 'package:cryptoarth/core/utils/report_generator.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/marketplace/screens/marketplace_screen.dart';

class BacktestResultsScreen extends ConsumerStatefulWidget {
  final String strategyCode;
  final String? backtestId;
  final String? strategyName;
  final String? symbol;
  final String? timeframe;
  final String? leverage;
  final String? capital;
  final Map<String, dynamic>? initialData;

  const BacktestResultsScreen({
    super.key, 
    required this.strategyCode,
    this.backtestId,
    this.strategyName,
    this.symbol,
    this.timeframe,
    this.leverage,
    this.capital,
    this.initialData,
  });

  @override
  ConsumerState<BacktestResultsScreen> createState() => _BacktestResultsScreenState();
}

class _BacktestResultsScreenState extends ConsumerState<BacktestResultsScreen> {
  BacktestModel? _backtestData;
  Map<String, dynamic>? _resultData;
  List<FlSpot> _chartSpots = [];
  List<FlSpot> _equitySpots = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (widget.initialData != null) {
        final data = widget.initialData!;
        final List<dynamic> points = data['equity_curve'] ?? data['points'] ?? data['data'] ?? [];
        
        setState(() {
          _backtestData = BacktestModel.fromJson(data);
          _resultData = data;
          _chartSpots = points.asMap().entries.map((e) {
            final val = num.tryParse(e.value.toString()) ?? 
                        num.tryParse(e.value['value']?.toString() ?? e.value['pnl']?.toString() ?? '0') ?? 0.0;
            return FlSpot(e.key.toDouble(), val.toDouble());
          }).toList();
          
          final List<dynamic> equityPoints = data['equity_curve'] ?? [];
          _equitySpots = equityPoints.asMap().entries.map((e) {
             final val = num.tryParse(e.value['y']?.toString() ?? e.value['balance']?.toString() ?? '0') ?? 0.0;
             final x = num.tryParse(e.value['x']?.toString() ?? e.value['trade_no']?.toString() ?? e.key.toString())?.toDouble() ?? e.key.toDouble();
             return FlSpot(x, val.toDouble());
          }).toList();

          if (_chartSpots.isEmpty) {
            _chartSpots = [const FlSpot(0, 0), const FlSpot(1, 10), const FlSpot(2, 5)];
          }
          if (_equitySpots.isEmpty) {
            _equitySpots = [const FlSpot(0, 0), const FlSpot(5, 2000), const FlSpot(10, -1000)];
          }
          _isLoading = false;
        });
        return;
      }

      final notifier = ref.read(backtestProvider.notifier);
      
      // Attempt to fetch result first
    Map<String, dynamic> result;
    try {
      final String idToUse = widget.backtestId ?? widget.strategyCode;
      result = await notifier.fetchBacktestResult(idToUse);
    } catch (_) {
        // Fallback to detail if result fails (might be a code, not an ID)
        final detail = await notifier.fetchBacktestDetail(widget.strategyCode);
        result = detail.toJson();
      }

      // Fetch Chart Data
      final chartData = await notifier.fetchBacktestChart(widget.strategyCode);
      final List<dynamic> points = chartData['points'] ?? chartData['data'] ?? [];
      
      if (mounted) {
        setState(() {
          _backtestData = BacktestModel.fromJson(result);
          _resultData = result;
          _chartSpots = points.asMap().entries.map((e) {
            final val = num.tryParse(e.value['value']?.toString() ?? e.value['pnl']?.toString() ?? '0') ?? 0.0;
            return FlSpot(e.key.toDouble(), val.toDouble());
          }).toList();
          
          final List<dynamic> equityPoints = result['equity_curve'] ?? [];
          _equitySpots = equityPoints.asMap().entries.map((e) {
             final val = num.tryParse(e.value['y']?.toString() ?? e.value['balance']?.toString() ?? '0') ?? 0.0;
             final x = num.tryParse(e.value['x']?.toString() ?? e.value['trade_no']?.toString() ?? e.key.toString())?.toDouble() ?? e.key.toDouble();
             return FlSpot(x, val.toDouble());
          }).toList();

          if (_chartSpots.isEmpty) {
            // Default spots if empty
            _chartSpots = [const FlSpot(0, 0), const FlSpot(1, 10), const FlSpot(2, 5)];
          }
          if (_equitySpots.isEmpty) {
            _equitySpots = [const FlSpot(0, 0), const FlSpot(5, 2000), const FlSpot(10, -1000)];
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _backtestData = BacktestModel(strategyCode: widget.strategyCode, status: 'MOCK', pnl: -10021235.0, winRate: 50.0, drawdown: 100.0);
          _chartSpots = [const FlSpot(0, 0), const FlSpot(1, -2), const FlSpot(2, -5), const FlSpot(3, -10)];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.cyan)),
      );
    }
    
    final backtest = _backtestData!;
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
              "${widget.strategyName ?? 'Custom Strategy'} • ${widget.symbol ?? 'BTCUSD'} • ${widget.timeframe ?? '15MIN'}",
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
            _buildMetricsGrid(backtest),
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
            
            // Deployment Actions
            _buildDeploymentActions(context),
            
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
              child: _buildActionButton("Export to CSV", Icons.download, AppColors.cyan, onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exporting CSV...")));
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton("Export PDF Report", Icons.picture_as_pdf, AppColors.pink, onTap: () {
                 if (_backtestData != null) {
                   ReportGenerator.downloadBacktestReport(
                     _backtestData!.strategyCode ?? "Strategy",
                     _backtestData!.winRate?.toDouble() ?? 0.0,
                     _backtestData!.pnl?.toDouble() ?? 0.0,
                     _backtestData!.drawdown?.toDouble() ?? 0.0,
                   );
                 }
              }),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
            // Dynamic Chart
            LineChartBarData(
              spots: _chartSpots,
              isCurved: true,
              color: AppColors.cyan,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.cyan.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BacktestModel backtest) {
    // Attempt to pull richer data from _resultData if available
    final String sharpe = _resultData?['trade_statistics']?['sharpe_ratio']?.toStringAsFixed(2) ?? 
                          _resultData?['sharpe_ratio']?.toStringAsFixed(2) ?? "N/A";
    final String profitFactor = _resultData?['trade_statistics']?['profit_factor']?.toStringAsFixed(2) ??
                                _resultData?['profit_factor']?.toStringAsFixed(2) ?? "N/A";
    final String totalTrades = _resultData?['trade_statistics']?['total_trades']?.toString() ??
                               _resultData?['total_trades']?.toString() ?? "N/A";
    final String avgWin = _resultData?['trade_statistics']?['avg_win']?.toStringAsFixed(2) ?? 
                          _resultData?['avg_win']?.toStringAsFixed(2) ?? "N/A";
    final String avgLoss = _resultData?['trade_statistics']?['avg_loss']?.toStringAsFixed(2) ?? 
                           _resultData?['avg_loss']?.toStringAsFixed(2) ?? "N/A";
    final String totalFees = _resultData?['trade_statistics']?['total_commission']?.toStringAsFixed(2) ?? 
                             _resultData?['total_commission']?.toStringAsFixed(2) ?? "N/A";
    final double grossPnl = num.tryParse(_resultData?['trade_statistics']?['gross_pnl']?.toString() ?? '')?.toDouble() ?? backtest.pnl.toDouble();

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard("NET P&L (AFTER FEES)", "\$${backtest.pnl.toStringAsFixed(2)}", backtest.pnl >= 0 ? AppColors.green : Colors.redAccent, "Final profit/loss")),
            const SizedBox(width: 8),
            Expanded(child: _buildMetricCard("GROSS P&L", "\$${grossPnl.toStringAsFixed(2)}", AppColors.purple, "(BEFORE FEES)")),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildMetricCard("TOTAL FEES PAID", "\$${totalFees}", AppColors.orange, "")),
            const SizedBox(width: 8),
            Expanded(child: _buildMetricCard("WIN RATE %", "${backtest.winRate.toStringAsFixed(2)}%", AppColors.purple, "")),
          ],
        ),
         const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildSmallMetric("Total Trades", totalTrades)),
            const SizedBox(width: 8),
            Expanded(child: _buildSmallMetric("Max Drawdown", "${backtest.drawdown.toStringAsFixed(2)}%", valueColor: Colors.redAccent)),
             const SizedBox(width: 8),
            Expanded(child: _buildSmallMetric("Sharpe Ratio", sharpe, valueColor: AppColors.cyan)),
          ],
        ),
        const SizedBox(height: 8),
         Row(
          children: [
             Expanded(child: _buildSmallMetric("Profit Factor", profitFactor, valueColor: AppColors.gold)),
            const SizedBox(width: 8),
            Expanded(child: _buildSmallMetric("Avg Win \$", "\$${avgWin}", valueColor: AppColors.green)),
             const SizedBox(width: 8),
            Expanded(child: _buildSmallMetric("Avg Loss \$", "\$${avgLoss}", valueColor: Colors.redAccent)),
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
    final String totalFees = _resultData?['trade_statistics']?['total_commission']?.toStringAsFixed(2) ?? 
                             _resultData?['total_commission']?.toStringAsFixed(2) ?? "0.00";
    final String tradesCount = _resultData?['trade_statistics']?['total_trades']?.toString() ??
                               _resultData?['total_trades']?.toString() ?? "0";

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
               Text("-\$${totalFees}", style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 16)),
               Text("($tradesCount trades)", style: const TextStyle(color: Colors.white30, fontSize: 10)),
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
                 Text("-\$${totalFees}", style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
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
           _buildConfigChip("Symbol", widget.symbol ?? "BTCUSD"),
           _buildConfigChip("Timeframe", widget.timeframe ?? "15MIN"),
           _buildConfigChip("Leverage", widget.leverage ?? "10x"),
           _buildConfigChip("Capital", widget.capital != null ? "${widget.capital}" : "10k"),
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
     final isProfit = (_equitySpots.isNotEmpty && _equitySpots.last.y >= (_equitySpots.first.y)) || (_backtestData?.pnl ?? 0) >= 0;
     final mainColor = isProfit ? AppColors.green : Colors.redAccent;

     return GlassContainer(
      height: 180,
      width: double.infinity,
      color: AppColors.cardSurface,
      opacity: 0.5,
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, 
                reservedSize: 40, 
                getTitlesWidget: (v, m) => Text('\$${(v/1000).toStringAsFixed(0)}k', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8)),
              )
            ),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
             topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _equitySpots,
              isCurved: true,
              color: mainColor,
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
    final bestHour = _resultData?['time_analysis']?['best_hour'] ?? "N/A";
    final worstHour = _resultData?['time_analysis']?['worst_hour'] ?? "N/A";
    final bestDay = _resultData?['time_analysis']?['best_day'] ?? "N/A";
    final worstDay = _resultData?['time_analysis']?['worst_day'] ?? "N/A";

    return Column(
      children: [
        Row(
          children: [
             Expanded(child: _buildTimeCard("Best Hour", bestHour, "", AppColors.green)),
             const SizedBox(width: 8),
             Expanded(child: _buildTimeCard("Worst Hour", worstHour, "", Colors.redAccent)),
          ],
        ),
         const SizedBox(height: 8),
         Row(
          children: [
             Expanded(child: _buildTimeCard("Best Day", bestDay, "", AppColors.green)),
             const SizedBox(width: 8),
             Expanded(child: _buildTimeCard("Worst Day", worstDay, "", Colors.redAccent)),
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

  Widget _buildDeploymentActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Next Steps",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          color: AppColors.cardSurface,
          child: Column(
            children: [
              const Text(
                "Great! Your backtest is complete.",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "You can now save this strategy to your collection or deploy it immediately.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                   Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Strategy added to My Strategies!")),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.cyan,
                        side: const BorderSide(color: AppColors.cyan),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Add to Marketplace"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text("Deploying Strategy to Live Market...")),
                         );
                         ref.read(strategyProvider.notifier).deployStrategy(widget.strategyCode, 1).then((_) {
                           if (!mounted) return;
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text("Strategy deployed successfully!"), backgroundColor: AppColors.green),
                           );
                          }).catchError((e) {
                            if (!mounted) return;
                            final errorMsg = e.toString().replaceFirst('Exception: ', '').replaceFirst('Failed to deploy strategy: ', '');
                            
                            if (errorMsg.contains('already') && errorMsg.contains('active deployment')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMsg),
                                  backgroundColor: Colors.orange,
                                  action: SnackBarAction(
                                    label: 'MANAGE',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketplaceScreen()));
                                    },
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Deployment failed: $errorMsg"), backgroundColor: Colors.redAccent),
                              );
                            }
                          });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: AppColors.green.withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Icon(Icons.rocket_launch, size: 18),
                           SizedBox(width: 8),
                           Text("Deploy Live"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
