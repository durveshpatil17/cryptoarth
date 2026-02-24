import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/backtest_provider.dart';

class StrategyDetailedReport extends ConsumerStatefulWidget {
  final String strategyCode;
  final String? backtestId;
  
  const StrategyDetailedReport({
    super.key,
    required this.strategyCode,
    this.backtestId,
  });

  @override
  ConsumerState<StrategyDetailedReport> createState() => _StrategyDetailedReportState();
}

class _StrategyDetailedReportState extends ConsumerState<StrategyDetailedReport> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String idToUse = widget.backtestId ?? widget.strategyCode;
      final data = await ref.read(backtestProvider.notifier).fetchBacktestResult(idToUse);
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // In case of error, we can still show the UI with fallback data or an error message
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassContainer(
        width: double.infinity,
        borderRadius: 20,
        color: const Color(0xFF0F172A), // Dark slate like screenshot
        opacity: 0.95,
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Tab Bar
            _buildTabBar(),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                   _buildOverviewTab(),
                   _buildStatisticsTab(),
                   _buildChartTab("Equity"),
                   _buildYearMonthTab(),
                   _buildTradesTab(),
                ],
              ),
            ),
            
            // Footer Action
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bar_chart, color: Color(0xFF8B5CF6), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _data?['strategy_name'] ?? "BTCUSD Strategy",
                  style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(
                      widget.strategyCode,
                      style: const TextStyle(color: AppColors.cyan, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    _buildTag("BTCUSD"),
                    _buildTag("15MIN"),
                    _buildTag("10x"),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Commission: 0.05% (maker)",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.white.withOpacity(0.5), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.cyan,
        unselectedLabelColor: Colors.white.withOpacity(0.4),
        indicatorColor: AppColors.cyan,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: "Overview"),
          Tab(text: "Statistics"),
          Tab(text: "Equity"),
          Tab(text: "Year/Month"),
          Tab(text: "Trades"),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Grids
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 450;
            final crossAxisCount = isMobile ? 2 : 4;
            final w = (constraints.maxWidth - ((crossAxisCount - 1) * 16)) / crossAxisCount;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildCompactStatCard("Total Return", "${_data?['total_pnl']?.toStringAsFixed(2) ?? '0'}%", (_data?['total_pnl'] ?? 0) >= 0 ? AppColors.green : Colors.redAccent, w),
                _buildCompactStatCard("Win Rate", "${_data?['win_rate']?.toStringAsFixed(2) ?? '0'}%", AppColors.cyan, w),
                _buildCompactStatCard("Total Trades", "${_data?['total_trades'] ?? '0'}", Colors.white, w),
                _buildCompactStatCard("Max Drawdown", "${_data?['max_drawdown']?.toStringAsFixed(2) ?? '0'}%", Colors.orangeAccent, w),
              ],
            );
          }),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: [
                  _buildWideStatCard("Total Profit", "+\$${_data?['total_profit']?.toStringAsFixed(2) ?? '0.00'}", AppColors.green, Icons.arrow_upward),
                  const SizedBox(height: 12),
                  _buildWideStatCard("Total Loss", "-\$${_data?['total_loss']?.abs().toStringAsFixed(2) ?? '0.00'}", Colors.redAccent, Icons.arrow_downward),
                  const SizedBox(height: 12),
                  _buildWideStatCard("Net P&L", "\$${_data?['net_pnl']?.toStringAsFixed(2) ?? '0.00'}", (_data?['net_pnl'] ?? 0) >= 0 ? AppColors.green : Colors.orangeAccent, Icons.account_balance_wallet),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _buildWideStatCard("Total Profit", "+\$${_data?['total_profit']?.toStringAsFixed(2) ?? '0.00'}", AppColors.green, Icons.arrow_upward)),
                const SizedBox(width: 16),
                Expanded(child: _buildWideStatCard("Total Loss", "-\$${_data?['total_loss']?.abs().toStringAsFixed(2) ?? '0.00'}", Colors.redAccent, Icons.arrow_downward)),
                const SizedBox(width: 16),
                Expanded(child: _buildWideStatCard("Net P&L", "\$${_data?['net_pnl']?.toStringAsFixed(2) ?? '0.00'}", (_data?['net_pnl'] ?? 0) >= 0 ? AppColors.green : Colors.orangeAccent, Icons.account_balance_wallet)),
              ],
            );
          }),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 450;
            if (isMobile) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildDetailStat("Initial Capital", "\$${_data?['initial_capital'] ?? '0.00'}"),
                  _buildDetailStat("Final Capital", "\$${_data?['final_capital'] ?? '0.00'}"),
                  _buildDetailStat("Winning Trades", "${_data?['winning_trades'] ?? '0'}", color: AppColors.green),
                  _buildDetailStat("Losing Trades", "${_data?['losing_trades'] ?? '0'}", color: Colors.redAccent),
                ],
              );
            }
            return Row(
              children: [
                 Expanded(child: _buildDetailStat("Initial Capital", "\$${_data?['initial_capital'] ?? '0.00'}")),
                 const SizedBox(width: 16),
                 Expanded(child: _buildDetailStat("Final Capital", "\$${_data?['final_capital'] ?? '0.00'}")),
                 const SizedBox(width: 16),
                 Expanded(child: _buildDetailStat("Winning Trades", "${_data?['winning_trades'] ?? '0'}", color: AppColors.green)),
                 const SizedBox(width: 16),
                 Expanded(child: _buildDetailStat("Losing Trades", "${_data?['losing_trades'] ?? '0'}", color: Colors.redAccent)),
              ],
            );
          }),
          const SizedBox(height: 24),
          
          // Backtest Configuration Section
          _buildSectionHeader(Icons.settings_outlined, "Backtest Configuration"),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B), // Darker slate
              borderRadius: BorderRadius.circular(12),
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;
              if (isMobile) {
                return Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: [
                    _buildConfigItem("Symbol", "BTCUSD", AppColors.cyan),
                    _buildConfigItem("Timeframe", "15MIN", Colors.orangeAccent),
                    _buildConfigItem("Leverage", "10x", Colors.purpleAccent),
                    _buildConfigItem("Capital %", "25%", AppColors.green),
                    _buildConfigItem("Commission Type", "Maker", Colors.orangeAccent),
                    _buildConfigItem("Commission %", "0.05%", Colors.redAccent),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildConfigItem("Symbol", "BTCUSD", AppColors.cyan),
                  _buildConfigItem("Timeframe", "15MIN", Colors.orangeAccent),
                  _buildConfigItem("Leverage", "10x", Colors.purpleAccent),
                  _buildConfigItem("Capital %", "25%", AppColors.green),
                  _buildConfigItem("Commission Type", "Maker", Colors.orangeAccent),
                  _buildConfigItem("Commission %", "0.05%", Colors.redAccent),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.local_fire_department_outlined, "Trade Statistics"),
          const SizedBox(height: 12),
          _buildStatGrid([
            {'label': 'Best Trade', 'value': '+\$${_data?['best_trade']?.toStringAsFixed(2) ?? '0.00'}', 'color': AppColors.green},
            {'label': 'Worst Trade', 'value': '\$${_data?['worst_trade']?.toStringAsFixed(2) ?? '0.00'}', 'color': Colors.redAccent},
            {'label': 'Avg Win', 'value': '+\$${_data?['avg_win']?.toStringAsFixed(2) ?? '0.00'}', 'color': AppColors.green},
            {'label': 'Avg Loss', 'value': '\$${_data?['avg_loss']?.toStringAsFixed(2) ?? '0.00'}', 'color': Colors.redAccent},
            {'label': 'Max Win Streak', 'value': '${_data?['max_win_streak'] ?? '0'} trades', 'color': AppColors.green},
            {'label': 'Max Loss Streak', 'value': '${_data?['max_loss_streak'] ?? '0'} trades', 'color': Colors.redAccent},
            {'label': 'Profit Factor', 'value': '${_data?['profit_factor']?.toStringAsFixed(2) ?? '0.00'}', 'color': Colors.orangeAccent},
            {'label': 'Risk/Reward', 'value': '${_data?['risk_reward_ratio'] ?? '1:1'}', 'color': AppColors.green},
            {'label': 'Sharpe Ratio', 'value': '${_data?['sharpe_ratio']?.toStringAsFixed(2) ?? '0.00'}', 'color': Colors.redAccent},
            {'label': 'Sortino Ratio', 'value': '${_data?['sortino_ratio']?.toStringAsFixed(2) ?? '0.00'}', 'color': Colors.redAccent},
            {'label': 'Gross P&L', 'value': '\$${_data?['gross_pnl']?.toStringAsFixed(2) ?? '0.00'}', 'color': Colors.redAccent},
            {'label': 'Total Commission', 'value': '\$${_data?['total_commission']?.toStringAsFixed(2) ?? '0.00'}', 'color': Colors.orangeAccent},
            {'label': 'Net P&L', 'value': '\$${_data?['net_pnl']?.toStringAsFixed(2) ?? '0.00'}', 'color': Colors.redAccent},
          ]),
          const SizedBox(height: 24),
          
          _buildSectionHeader(Icons.access_time, "Time Analysis"),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildTimeAnalysisCard("Best Hour", "22:00 - 23:00", "+\$1782 (2 trades)", AppColors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTimeAnalysisCard("Worst Hour", "19:00 - 20:00", "\$-2167 (5 trades)", Colors.redAccent)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildTimeAnalysisCard("Best Day", "Monday", "+\$2478 (44% win)", AppColors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTimeAnalysisCard("Worst Day", "Thursday", "\$-3915 (15% win)", Colors.redAccent)),
                    ],
                  ),
                ],
              );
            }
            return Row(
              children: [
                 Expanded(child: _buildTimeAnalysisCard("Best Hour", "22:00 - 23:00", "+\$1782.25 (2 trades)", AppColors.green)),
                 const SizedBox(width: 12),
                 Expanded(child: _buildTimeAnalysisCard("Worst Hour", "19:00 - 20:00", "\$-2167.61 (5 trades)", Colors.redAccent)),
                 const SizedBox(width: 12),
                 Expanded(child: _buildTimeAnalysisCard("Best Day", "Monday", "+\$2478.05 (44% win)", AppColors.green)),
                 const SizedBox(width: 12),
                 Expanded(child: _buildTimeAnalysisCard("Worst Day", "Thursday", "\$-3915.96 (15% win)", Colors.redAccent)),
              ],
            );
          }),
          const SizedBox(height: 16),
          Text("Performance by Day of Week", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          const SizedBox(height: 8),
          _buildDayOfWeekHeatmap(),
          const SizedBox(height: 24),
          
          _buildSectionHeader(Icons.pie_chart_outline, "Win/Loss Distribution"),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 450;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: isMobile ? 3 : 2,
                  child: SizedBox(
                    height: isMobile ? 140 : 180,
                    child: _buildWinLossPieChart(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: isMobile ? 4 : 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem("Wins: 23 (28%)", AppColors.green),
                      const SizedBox(height: 12),
                      _buildLegendItem("Losses: 59 (72%)", Colors.redAccent),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildYearMonthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.calendar_today_outlined, "Yearly Performance"),
          const SizedBox(height: 4),
          Text(
            "Click on a year to view monthly breakdown",
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: [
                  _buildYearCard("2026", "32", "\$-3436.04", "21.9%"),
                  const SizedBox(height: 12),
                  _buildYearCard("2025", "50", "\$-2916.72", "32.0%"),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _buildYearCard("2026", "32", "\$-3436.04", "21.9%")),
                const SizedBox(width: 16),
                Expanded(child: _buildYearCard("2025", "50", "\$-2916.72", "32.0%")),
              ],
            );
          }),
          const SizedBox(height: 32),
          _buildSectionHeader(Icons.calendar_month_outlined, "Monthly Returns Heatmap"),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMonthlyReturnCard("Sept 25", "\$975", "1 trades", AppColors.green),
                _buildMonthlyReturnCard("Oct 25", "\$-2761", "19 trades", Colors.redAccent),
                _buildMonthlyReturnCard("Nov 25", "\$-1724", "18 trades", Colors.redAccent),
                _buildMonthlyReturnCard("Dec 25", "\$222", "13 trades", AppColors.green),
                _buildMonthlyReturnCard("Jan 26", "\$-1537", "13 trades", Colors.redAccent),
                _buildMonthlyReturnCard("Feb 26", "\$-1527", "18 trades", Colors.redAccent),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(Icons.grid_on_outlined, "Daily P&L Heatmap"),
          const SizedBox(height: 12),
          _buildDailyHeatmap(),
        ],
      ),
    );
  }

  Widget _buildYearCard(String year, String trades, String pnl, String winRate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(year, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3), size: 16),
            ],
          ),
          const SizedBox(height: 16),
          _buildYearStatRow("Trades:", trades, Colors.white.withOpacity(0.5)),
          const SizedBox(height: 8),
          _buildYearStatRow("P&L:", pnl, Colors.redAccent),
          const SizedBox(height: 8),
          _buildYearStatRow("Win Rate:", winRate, const Color(0xFFFFB800)),
        ],
      ),
    );
  }

  Widget _buildYearStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTradesTab() {
    final List<dynamic> trades = _data?['trades_list'] ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.calendar_today_outlined, "Yearly Performance"),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                children: [
                   _buildYearCard("2026", "31", "\$-3064.00", "22.6%"),
                   const SizedBox(height: 12),
                   _buildYearCard("2025", "51", "\$-3288.77", "31.4%"),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _buildYearCard("2026", "31", "\$-3064.00", "22.6%")),
                const SizedBox(width: 16),
                Expanded(child: _buildYearCard("2025", "51", "\$-3288.77", "31.4%")),
              ],
            );
          }),
          const SizedBox(height: 32),
          _buildSectionHeader(Icons.history, "Recent Trades"),
          const SizedBox(height: 12),
          ...List.generate(trades.length, (index) {
            final trade = trades[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trade['symbol'] ?? "BTCUSD", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(trade['time'] ?? "2024-02-09 14:30", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          (trade['pnl'] ?? 0) >= 0 ? "+\$${trade['pnl']}" : "\$${trade['pnl']}",
                          style: TextStyle(color: (trade['pnl'] ?? 0) >= 0 ? AppColors.green : Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                        Text(trade['action'] ?? "BUY", style: TextStyle(color: (trade['pnl'] ?? 0) >= 0 ? AppColors.green.withOpacity(0.5) : Colors.redAccent.withOpacity(0.5), fontSize: 10)),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChartTab(String type) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.auto_graph, "$type Curve"),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          'Trade #${barSpot.x.toInt()}\nBalance : \$${barSpot.y.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(color: Colors.white.withOpacity(0.5), strokeWidth: 1, dashArray: [4, 4]),
                        FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.redAccent, strokeWidth: 1, strokeColor: Colors.white)),
                      );
                    }).toList();
                  },
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 3000,
                  verticalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                  getDrawingVerticalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text("Trade #", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 10,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text("Balance (\$)", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 3000,
                      getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.white.withOpacity(0.1))),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getSpotsFromData(_data?['equity_curve'] ?? []),
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [Colors.redAccent.withOpacity(0.2), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<FlSpot> _getSpotsFromData(dynamic data) {
    if (data == null || data is! List) {
      return [const FlSpot(0, 10000), const FlSpot(10, 10000)];
    }
    
    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
       final item = data[i];
       if (item is Map) {
         final x = num.tryParse(item['x']?.toString() ?? item['trade_no']?.toString() ?? item['trade_num']?.toString() ?? i.toString())?.toDouble() ?? i.toDouble();
         final y = num.tryParse(item['y']?.toString() ?? item['balance']?.toString() ?? item['equity']?.toString() ?? '0')?.toDouble() ?? 0.0;
         spots.add(FlSpot(x, y));
       } else if (item is num) {
         spots.add(FlSpot(i.toDouble(), item.toDouble()));
       }
    }
    return spots.isEmpty ? [const FlSpot(0, 10000), const FlSpot(1, 10000)] : spots;
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.cyan, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCompactStatCard(String label, String value, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWideStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.5), size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildConfigItem(String label, String value, Color iconColor) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: iconColor, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatGrid(List<Map<String, dynamic>> items) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 450;
      final crossAxisCount = isMobile ? 2 : 4;
      final w = (constraints.maxWidth - ((crossAxisCount - 1) * 12)) / crossAxisCount;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items.map((item) => Container(
          width: w,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['label'], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
              const SizedBox(height: 4),
              Text(item['value'], style: TextStyle(color: item['color'], fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
      );
    });
  }

  Widget _buildTimeAnalysisCard(String title, String time, String details, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 10)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(details, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildDayOfWeekHeatmap() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final values = ["\$-1856", "\$2478", "\$-1090", "\$-1971", "\$-3916", "\$-777", "\$779"];
    final colors = [Colors.redAccent, AppColors.green, Colors.redAccent, Colors.redAccent, Colors.redAccent, Colors.redAccent, AppColors.green];
    
    return Row(
      children: List.generate(7, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i == 6 ? 0 : 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: colors[i].withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Text(days[i], style: TextStyle(color: Colors.white, fontSize: isMobile ? 8 : 10)),
              const SizedBox(height: 4),
              Text(values[i], style: TextStyle(color: colors[i], fontSize: isMobile ? 8 : 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildWinLossPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: AppColors.green,
            value: 28,
            title: '',
            radius: 20,
          ),
          PieChartSectionData(
            color: Colors.redAccent,
            value: 72,
            title: '',
            radius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMonthlyReturnCard(String month, String value, String count, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(month, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          Text(count, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildDailyHeatmap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 450;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 15 : 20,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
            ),
            itemCount: isMobile ? 60 : 80,
            itemBuilder: (context, index) {
              final colors = [Colors.redAccent, AppColors.green, Colors.grey.withOpacity(0.2)];
              final color = colors[index % 3].withOpacity(0.7);
              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text("Less", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
             Row(
               children: [
                 _buildHeatmapLegend(Colors.white.withOpacity(0.1)),
                 _buildHeatmapLegend(Colors.redAccent.withOpacity(0.3)),
                 _buildHeatmapLegend(Colors.redAccent.withOpacity(0.6)),
                 _buildHeatmapLegend(AppColors.green.withOpacity(0.3)),
                 _buildHeatmapLegend(AppColors.green.withOpacity(0.6)),
               ],
             ),
             Text("More", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
          ],
        )
      ],
    );
  }

  Widget _buildHeatmapLegend(Color color) {
    return Container(
      width: 10, height: 10,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Close Report", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
