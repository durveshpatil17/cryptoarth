import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/strategies/widgets/technical_chart_screen.dart';
import 'package:cryptoarth/features/strategies/widgets/strategy_detailed_report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/broker/providers/broker_provider.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';

class StrategyCard extends ConsumerStatefulWidget {
  final StrategyModel data;
  final bool isBrokerConnected;
  final Function(bool isLive) onAction; 
  final Function(bool isLive)? onModeAction;
  final bool isLive;

  const StrategyCard({
    super.key,
    required this.data,
    required this.isBrokerConnected,
    required this.onAction,
    this.onModeAction,
    this.isLive = false,
  });

  @override
  ConsumerState<StrategyCard> createState() => _StrategyCardState();
}

class _StrategyCardState extends ConsumerState<StrategyCard> with SingleTickerProviderStateMixin {
  bool _isLiveMode = false;
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _isLiveMode = widget.data.tradeMode == 1;
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isStrategyRunning = widget.data.isDeployed;
    final brokerState = ref.watch(brokerProvider);
    final connectedBrokers = brokerState.value ?? [];

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardSurface, 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 20),
              blurRadius: 40,
              spreadRadius: -10,
            ), // Wide ambient
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ), // Medium soft
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_pin, size: 10, color: AppColors.cyan.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                (widget.data.userName ?? "PUBLIC").toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.cyan.withOpacity(0.7),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.data.strategyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPnlBadge(),
                ],
              ),
            ),
  
            // Metrics (Ultra-Glass style)
            _buildMetricsGrid(),
  
            const SizedBox(height: 12),
  
            // Actions Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Mode Toggle (Elegant Pill)
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildToggleItem("PAPER", !_isLiveMode, Colors.blueAccent, () {
                              setState(() => _isLiveMode = false);
                              if (widget.onModeAction != null) widget.onModeAction!(false);
                            })),
                            Expanded(child: _buildToggleItem("LIVE", _isLiveMode, Colors.orangeAccent, () {
                              setState(() => _isLiveMode = true);
                              if (widget.onModeAction != null) widget.onModeAction!(true);
                            })),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action Buttons (Glass style)
                    _buildActionButton(Icons.auto_graph_outlined, "CHART", () {
                      showDialog(context: context, builder: (context) => TechnicalChartScreen(strategyCode: widget.data.strategyCode, strategyName: widget.data.strategyName, backtestId: widget.data.id));
                    }),
                    const SizedBox(width: 6),
                    _buildActionButton(Icons.article_outlined, "REPORT", () {
                      showDialog(context: context, builder: (context) => StrategyDetailedReport(strategyCode: widget.data.strategyCode, backtestId: widget.data.id));
                    }),
                  ],
                ),
              ),
            ),
  
            const SizedBox(height: 12),
            Divider(color: Colors.white.withOpacity(0.03), height: 1, thickness: 0.5),
  
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusIndicator(isStrategyRunning),
                        const SizedBox(height: 4),
                        _buildBrokerStatus(connectedBrokers),
                      ],
                    ),
                  ),
                  // Broker Logos or Placeholder
                  _buildBrokerLogos(connectedBrokers),
                  const SizedBox(width: 12),
                  // Deploy Button (Luxury Themed)
                  SizedBox(
                    height: 36,
                    child: CustomButton(
                      width: 100,
                      height: 36,
                      text: isStrategyRunning ? "STOP" : "DEPLOY",
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onAction(_isLiveMode);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPnlBadge() {
    final bool isPos = widget.data.totalPnl >= 0;
    final color = isPos ? AppColors.jewelGreen : AppColors.jewelRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "${isPos ? '+' : ''}${widget.data.totalPnl.toStringAsFixed(1)}",
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            "PNL",
            style: TextStyle(color: color.withOpacity(0.5), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _buildMetric("${widget.data.winRate.toStringAsFixed(1)}%", "WIN RATE")),
          _buildRefinedDivider(),
          Expanded(child: _buildMetric("${widget.data.maxDrawdown.toStringAsFixed(1)}%", "MAX DD")),
          _buildRefinedDivider(),
          Expanded(child: _buildMetric("--", "TRADES")),
        ],
      ),
    );
  }

  Widget _buildRefinedDivider() {
    return Container(
      width: 1,
      height: 12,
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildMetric(String val, String lab) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()])),
        const SizedBox(height: 2),
        Text(lab, style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildToggleItem(String lab, bool active, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)
          ] : [],
        ),
        child: Center(
          child: Text(
            lab,
            style: TextStyle(
              color: active ? color : Colors.white.withOpacity(0.2),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      flex: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              FittedBox(
                child: Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool running) {
    final statusColor = running ? AppColors.jewelGreen : Colors.amberAccent;
    return Row(
      children: [
        FadeTransition(
          opacity: _breatheAnimation,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: statusColor.withOpacity(0.5), blurRadius: 6, spreadRadius: 1)
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          running ? "RUNNING" : "READY",
          style: TextStyle(
            color: statusColor.withOpacity(0.9),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildBrokerStatus(List<dynamic> brokers) {
    if (brokers.isEmpty) {
      return Text(
        "NOT CONNECTED",
        style: TextStyle(color: AppColors.jewelRed.withOpacity(0.7), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1),
      );
    }
    return Text(
      "BROKERS ACTIVE: ${brokers.length}",
      style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
    );
  }

  Widget _buildBrokerLogos(List<dynamic> brokers) {
    if (brokers.isEmpty) return const SizedBox.shrink();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: brokers.take(2).map((b) {
        final name = (b.brokerName ?? "B").toString().toUpperCase();
        final firstChar = name.isNotEmpty ? name[0] : "B";
        
        return Container(
          margin: const EdgeInsets.only(left: 4),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cyan.withOpacity(0.08),
            border: Border.all(color: AppColors.cyan.withOpacity(0.3), width: 0.5),
          ),
          child: Center(
            child: Text(
              firstChar,
              style: const TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
        );
      }).toList(),
    );
  }
}
