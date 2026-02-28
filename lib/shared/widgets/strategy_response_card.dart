import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cryptoarth/features/strategies/screens/backtest_config_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/code_snippet_card.dart';
import 'package:cryptoarth/features/strategies/providers/copilot_provider.dart';

class StrategyResponseCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> message;

  const StrategyResponseCard({
    super.key,
    required this.message,
  });

  @override
  ConsumerState<StrategyResponseCard> createState() => _StrategyResponseCardState();
}

class _StrategyResponseCardState extends ConsumerState<StrategyResponseCard> {
  int _selectedTab = 0; // 0: Overview, 1: Code
  bool _isBacktesting = false;
  bool _isDeploying = false;

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final String text = msg['content'] ?? '';
    final dynamic strategyJson = msg['strategy_json'];
    final dynamic backtestResult = msg['backtest_result'];

    String title = "AI Strategy";
    String description = text;

    if (strategyJson is Map) {
      title = strategyJson['name'] ?? strategyJson['strategy_name'] ?? title;
      description = strategyJson['description'] ?? strategyJson['strategy_description'] ?? description;
    }

    final hasPython = msg['python'] is String && (msg['python'] as String).isNotEmpty;
    final hasPine = (msg['pine_script'] is String && (msg['pine_script'] as String).isNotEmpty) || 
                    (msg['pine_code'] is String && (msg['pine_code'] as String).isNotEmpty);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: GlassContainer(
        borderRadius: 20,
        color: const Color(0xFF0F172A),
        opacity: 0.8,
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [AppColors.cyan.withOpacity(0.15), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Row(
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
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "AI GENERATED STRATEGY",
                          style: TextStyle(color: AppColors.cyan.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
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
                _buildTab(0, "Overview"),
                if (hasPython || hasPine) _buildTab(1, "Source Code"),
              ],
            ),

            // Content
            _selectedTab == 0 ? _buildOverview(description, backtestResult) : _buildCodeTab(hasPython, hasPine),

            // Footer Actions
            _buildFooterActions(backtestResult),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? AppColors.cyan : Colors.transparent, width: 2)),
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

  Widget _buildOverview(String description, dynamic backtestResult) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          _buildMetricsGrid(backtestResult),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(dynamic result) {
    final Map<String, dynamic> metrics = {};
    
    if (result is Map) {
      metrics.addAll(Map<String, dynamic>.from(result));
      if (result['metrics'] is Map) {
        metrics.addAll(Map<String, dynamic>.from(result['metrics']));
      }
    } else if (widget.message['metrics'] is Map) {
      metrics.addAll(Map<String, dynamic>.from(widget.message['metrics']));
    }

    if (metrics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.query_stats, color: Colors.white24, size: 16),
            SizedBox(width: 8),
            Text("Ready for backtest analysis", style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (metrics.containsKey('win_rate')) _buildMetricItem("Win Rate", "${metrics['win_rate']}%", AppColors.green),
        if (metrics.containsKey('profit_factor')) _buildMetricItem("Profit Factor", "${metrics['profit_factor']}", AppColors.cyan),
        if (metrics.containsKey('total_pnl') || metrics.containsKey('pnl')) 
          _buildMetricItem("Total PnL", "${metrics['total_pnl'] ?? metrics['pnl']}%", 
          (double.tryParse((metrics['total_pnl'] ?? metrics['pnl']).toString()) ?? 0) >= 0 ? AppColors.green : Colors.redAccent),
        if (metrics.containsKey('max_drawdown') || metrics.containsKey('drawdown')) 
          _buildMetricItem("Max DD", "${metrics['max_drawdown'] ?? metrics['drawdown']}%", Colors.orangeAccent),
        if (metrics.containsKey('return_percent')) _buildMetricItem("Return", "${metrics['return_percent']}%", AppColors.green),
        
        // Dynamic Fallback for other keys
        ...metrics.entries.where((e) => !['win_rate', 'profit_factor', 'total_pnl', 'pnl', 'max_drawdown', 'drawdown', 'return_percent', 'id', 'strategy_code', 'status', 'metrics'].contains(e.key) && e.value is! Map && e.value is! List)
            .map((e) => _buildMetricItem(e.key.replaceAll('_', ' ').toUpperCase(), e.value.toString(), Colors.white54)),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCodeTab(bool hasPython, bool hasPine) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (hasPython) ...[
            CodeSnippetCard(code: widget.message['python'], language: "Python"),
            const SizedBox(height: 12),
          ],
          if (hasPine) ...[
            CodeSnippetCard(code: widget.message['pine_code'] ?? widget.message['pine_script'], language: "Pine Script"),
          ],
        ],
      ),
    );
  }

  Widget _buildFooterActions(dynamic backtestResult) {
    final bool hasResult = backtestResult != null;
    final message = widget.message;
    final hasStrategy =
        (message["python"] is String && message["python"].toString().isNotEmpty) ||
        (message["pine_script"] is String && message["pine_script"].toString().isNotEmpty) ||
        (message["pine_code"] is String && message["pine_code"].toString().isNotEmpty);
    
    if (!hasStrategy && !hasResult) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (hasStrategy && !hasResult)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isBacktesting ? null : _handleBacktest,
                icon: _isBacktesting 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.science, size: 18),
                label: Text(_isBacktesting ? "RUNNING..." : "RUN BACKTEST"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          if (hasResult) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _selectedTab = 0),
                icon: const Icon(Icons.analytics_outlined, size: 18),
                label: const Text("VIEW RESULTS"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleDeploy("paper"),
                icon: _isDeploying
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.bolt, size: 18),
                label: Text(_isDeploying ? "DEPLOYING..." : "DEPLOY TO PAPER"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleDeploy("live"),
                icon: _isDeploying
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.bolt, size: 18),
                label: Text(_isDeploying ? "DEPLOYING..." : "DEPLOY TO LIVE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Future<void> _handleBacktest() async {
    final pineCode = widget.message['pine_code'] ?? widget.message['pine_script'];
    final pythonCode = widget.message['python'];
    final jsonCode = widget.message['strategy_json'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
           // We are reusing BacktestConfigScreen which normally accepts:
           // final String strategyCode; 
           // final String strategyName;
           // final String? pineCode;
           return BacktestConfigScreen(
             strategyCode: jsonCode != null ? 'COPILOT_STRAT' : 'COPILOT_STRAT',
             strategyName: 'AI Generated Strategy',
             pineCode: pineCode,
           );
        }
      ),
    );
  }

  Future<void> _handleDeploy(String mode) async {
    setState(() => _isDeploying = true);
    try {
      await ref.read(copilotProvider.notifier).deployStrategy(widget.message['id'], mode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Strategy deployed to $mode!"), backgroundColor: AppColors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deployment failed: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeploying = false);
    }
  }
}

