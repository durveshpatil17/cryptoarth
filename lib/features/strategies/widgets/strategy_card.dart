import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/strategies/widgets/technical_chart_screen.dart';
import 'package:cryptoarth/features/strategies/widgets/strategy_detailed_report.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/broker/providers/broker_provider.dart';

class StrategyCard extends ConsumerStatefulWidget {
  final StrategyModel data;
  final bool isBrokerConnected;
  final VoidCallback onAction;
  final bool isLive;

  const StrategyCard({
    super.key,
    required this.data,
    required this.isBrokerConnected,
    required this.onAction,
    this.isLive = false,
  });

  @override
  ConsumerState<StrategyCard> createState() => _StrategyCardState();
}

class _StrategyCardState extends ConsumerState<StrategyCard> {
  bool _isLiveMode = false;

  @override
  void initState() {
    super.initState();
    _isLiveMode = widget.isLive;
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Recent";
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays > 0) return "${diff.inDays} days ago";
      if (diff.inHours > 0) return "${diff.inHours} hours ago";
      return "${diff.inMinutes} mins ago";
    } catch (e) {
      return "Recent";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map isDeployed to isActive logic
    final bool isStrategyRunning = widget.data.isDeployed;
    final String symbol = widget.data.strategyCode.split('_').last;
    
    final brokerState = ref.watch(brokerProvider);
    final connectedBrokers = brokerState.value ?? [];
    final hasBrokers = connectedBrokers.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Premium Deep Navy
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section: Scaled for mobile
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.strategyCode.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.data.strategyName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // P&L Badge: Compact
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.data.totalPnl >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: widget.data.totalPnl >= 0 ? const Color(0xFF34D399) : Colors.redAccent,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.data.totalPnl >= 0 ? '+' : ''}${widget.data.totalPnl.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: widget.data.totalPnl >= 0 ? const Color(0xFF34D399) : Colors.redAccent,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${_isLiveMode ? 'LIVE' : 'PAPER'} PROFIT",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Meta Row: Streamlined
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildMetaItem(Icons.person_outline, widget.data.userName ?? "Admin"),
                const SizedBox(width: 10),
                Text("•", style: TextStyle(color: Colors.white.withOpacity(0.1))),
                const SizedBox(width: 10),
                _buildMetaItem(Icons.access_time, _formatTime(widget.data.createdAt)),
                const Spacer(),
                // Status Glow
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isStrategyRunning ? const Color(0xFF10B981) : const Color(0xFFFBBF24)).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isStrategyRunning ? const Color(0xFF10B981) : const Color(0xFFFBBF24),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isStrategyRunning ? "RUNNING" : "WAITING",
                        style: TextStyle(
                          color: isStrategyRunning ? const Color(0xFF10B981) : const Color(0xFFFBBF24),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Metrics: Grid look
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMainMetric("${widget.data.winRate.toStringAsFixed(0)}%", "Win Rate"),
                _buildDivider(),
                _buildMainMetric("-${widget.data.maxDrawdown.toStringAsFixed(1)}%", "Max DD", isNegative: true),
                _buildDivider(),
                _buildMainMetric(symbol, "Symbol"),
                _buildDivider(),
                _buildMainMetric("1H", "Interval"),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Toggle: Compact Segmented look
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildToggleBtn("PAPER", !_isLiveMode, () => setState(() => _isLiveMode = false))),
                Expanded(child: _buildToggleBtn("LIVE", _isLiveMode, () => setState(() => _isLiveMode = true))),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.04), height: 1),

          // Actions
          IntrinsicHeight(
            child: Row(
              children: [
                _buildActionButton(Icons.auto_graph_outlined, "Chart", () {
                  showDialog(
                    context: context,
                    builder: (context) => TechnicalChartScreen(
                      strategyCode: widget.data.strategyCode,
                      strategyName: widget.data.strategyName,
                      backtestId: widget.data.id,
                    ),
                  );
                }),
                _buildVerticalDivider(),
                _buildActionButton(Icons.description_outlined, "Report", () {
                   showDialog(
                    context: context,
                    builder: (context) => StrategyDetailedReport(
                      strategyCode: widget.data.strategyCode,
                      backtestId: widget.data.id,
                    ),
                  );
                }),
                _buildVerticalDivider(),
                _buildActionButton(
                  isStrategyRunning ? Icons.stop_circle : Icons.rocket_launch,
                  isStrategyRunning ? "Stop" : "Deploy",
                  widget.onAction,
                  color: isStrategyRunning ? Colors.redAccent.shade200 : const Color(0xFF10B981),
                ),
              ],
            ),
          ),

          Divider(color: Colors.white.withOpacity(0.04), height: 1),

          // Broker footer: Dynamic connected brokers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (hasBrokers)
                  SizedBox(
                    height: 32,
                    child: Stack(
                      children: connectedBrokers.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final broker = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(left: idx * 22.0),
                          child: _buildBrokerLogo(broker.brokerName),
                        );
                      }).toList(),
                    ),
                  )
                else
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: hasBrokers ? const Color(0xFF10B981) : Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasBrokers 
                              ? "${connectedBrokers.length} Broker${connectedBrokers.length > 1 ? 's' : ''} Connected"
                              : "No Brokers Connected",
                            style: TextStyle(
                              color: hasBrokers ? const Color(0xFF10B981) : Colors.redAccent.withOpacity(1.0), // Reverted to more visible
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        hasBrokers 
                          ? connectedBrokers.map((b) => b.brokerName).join(", ")
                          : "Setup broker in settings to start trading",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.cyan.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: active ? Border.all(color: AppColors.cyan.withOpacity(0.4)) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.cyan : Colors.white24,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.cyan.withOpacity(0.8), size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainMetric(String value, String label, {bool isNegative = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isNegative ? Colors.redAccent.shade100 : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 16, color: Colors.white.withOpacity(0.04));

  Widget _buildVerticalDivider() => VerticalDivider(color: Colors.white.withOpacity(0.04), width: 1, thickness: 1);

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color ?? AppColors.cyan, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color ?? AppColors.cyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrokerLogo(String name) {
    Color color = Colors.grey;
    String letter = "B";
    
    final n = name.toLowerCase();
    if (n.contains("delta")) {
      color = const Color(0xFF3B82F6); // Blue
      letter = "D";
    } else if (n.contains("coindcx")) {
      color = const Color(0xFFEF4444); // Red
      letter = "C";
    } else if (n.contains("mudrex")) {
      color = const Color(0xFFF59E0B); // Amber
      letter = "M";
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF111827), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
        ),
      ),
    );
  }
}
