import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';

class StrategyResponseCard extends StatefulWidget {
  final String title;
  final String description;
  final String winRate;
  final String profitFactor;
  final String? codeSnippet;
  final VoidCallback onBacktest;

  const StrategyResponseCard({
    super.key,
    required this.title,
    required this.description,
    required this.winRate,
    required this.profitFactor,
    this.codeSnippet,
    required this.onBacktest,
  });

  @override
  State<StrategyResponseCard> createState() => _StrategyResponseCardState();
}

class _StrategyResponseCardState extends State<StrategyResponseCard> {
  int _selectedTab = 0; // 0: Overview, 1: Code

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: GlassContainer(
        borderRadius: 20,
        color: const Color(0xFF0F172A), // Deep premium navy/black
        opacity: 0.8,
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Gradient Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [
                    AppColors.cyan.withOpacity(0.15),
                    Colors.transparent
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.insights, color: AppColors.cyan, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text("HIGH PROBABILITY", style: TextStyle(color: AppColors.green, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text("PINE SCRIPT v5", style: TextStyle(color: AppColors.purple, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tabs
            Row(
              children: [
                _buildTab(0, "Overview & Metrics"),
                if (widget.codeSnippet != null) _buildTab(1, "Source Code"),
              ],
            ),
            
            // Content Area
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedTab == 0 ? _buildOverviewTab() : _buildCodeTab(),
            ),
            
            // Actions
            Padding(
               padding: const EdgeInsets.all(20),
               child: SizedBox(
                 width: double.infinity,
                 child: OutlinedButton.icon(
                   onPressed: widget.onBacktest,
                   icon: const Icon(Icons.science_outlined, size: 18),
                   label: const Text("Run Backtest"),
                   style: OutlinedButton.styleFrom(
                     foregroundColor: AppColors.cyan,
                     side: BorderSide(color: AppColors.cyan.withOpacity(0.5)),
                     padding: const EdgeInsets.symmetric(vertical: 14),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   ),
                 ),
               ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.transparent : Colors.black12,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.cyan : Colors.white.withOpacity(0.05),
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.cyan : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Strategy Logic Summary",
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Expected Performance Profile (Backtested)",
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard("Win Rate", widget.winRate, AppColors.green, Icons.pie_chart_outline)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard("Profit Factor", widget.profitFactor, AppColors.cyan, Icons.trending_up)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard("Max Drawdown", "-12.4%", Colors.redAccent, Icons.waterfall_chart)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
             width: double.infinity,
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
             decoration: BoxDecoration(
               color: AppColors.gold.withOpacity(0.05),
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: AppColors.gold.withOpacity(0.2)),
             ),
             child: Row(
               children: [
                 Icon(Icons.warning_amber_rounded, color: AppColors.gold.withOpacity(0.8), size: 16),
                 const SizedBox(width: 12),
                 const Expanded(
                   child: Text(
                     "Risk Warning: This strategy exhibits high volatility in sideways markets. Strict stop-loss is recommended.",
                     style: TextStyle(color: AppColors.gold, fontSize: 11, height: 1.4),
                   ),
                 ),
               ],
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF09090B), // Very dark editor background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.code, color: AppColors.textSecondary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "strategy.pine",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontFamily: 'Courier',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.codeSnippet!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Code copied to clipboard"), backgroundColor: AppColors.green),
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.copy, size: 12, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text("COPY", style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 24),
                Text(
                  widget.codeSnippet!,
                  style: TextStyle(
                    color: Colors.blue[100],
                    fontFamily: 'Courier', // Monospace font
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 16),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

