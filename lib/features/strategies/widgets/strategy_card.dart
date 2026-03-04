import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/strategies/widgets/technical_chart_screen.dart';
import 'package:cryptoarth/features/strategies/widgets/strategy_detailed_report.dart';
import 'package:cryptoarth/features/strategies/screens/backtest_config_screen.dart';

class StrategyCard extends StatefulWidget {
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
  State<StrategyCard> createState() => _StrategyCardState();
}

class _StrategyCardState extends State<StrategyCard> {
  bool _isLiveMode = false;

  @override
  void initState() {
    super.initState();
    _isLiveMode = widget.isLive;
  }

  @override
  Widget build(BuildContext context) {
    bool? isActive = widget.data.isDeployed;

    return GlassContainer(
       padding: const EdgeInsets.all(16),
       borderRadius: 20,
       color: AppColors.cardSurface,
       opacity: 0.8,
       child: Column(
          children: [
             Row(
                children: [
                   Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                         color: AppColors.cyan.withOpacity(0.1),
                         shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.rocket_launch, color: AppColors.cyan, size: 20),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text(
                               widget.data.strategyName,
                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                               maxLines: 1, 
                               overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${widget.data.userName ?? 'Author'} • ${widget.data.strategyCode}", 
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)
                            ),
                         ],
                      ),
                   ),
                   const SizedBox(width: 8),
                   // Compact Status Badge
                   Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                         color: (isActive == true) ? AppColors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                         borderRadius: BorderRadius.circular(4),
                         border: Border.all(color: (isActive == true) ? AppColors.green.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        (isActive == true) ? "ACTIVE" : "DRAFT", 
                        style: TextStyle(color: (isActive == true) ? AppColors.green : Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)
                      ),
                   ),
                ],
             ),

             const SizedBox(height: 12),
             
             // Key Stats Row (Compact)
             Container(
               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
               decoration: BoxDecoration(
                 color: Colors.black.withOpacity(0.2),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     _buildCompactStat("Win Rate", "${widget.data.winRate.toStringAsFixed(1)}%", AppColors.cyan),
                     Container(width: 1, height: 20, color: Colors.white10),
                     _buildCompactStat("Total P&L", "\$${widget.data.totalPnl.toStringAsFixed(2)}", (widget.data.totalPnl >= 0) ? AppColors.green : Colors.redAccent),
                     Container(width: 1, height: 20, color: Colors.white10),
                     _buildCompactStat("Max DD", "\$${widget.data.maxDrawdown.toStringAsFixed(1)}", Colors.redAccent),
                   ],
               ),
             ),

             const SizedBox(height: 12),

             // Toggle (Visible only if not active)
             if (isActive != true)
             Padding(
               padding: const EdgeInsets.only(bottom: 12.0),
               child: Container(
                 height: 28,
                 padding: const EdgeInsets.all(2),
                 decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.05), 
                   borderRadius: BorderRadius.circular(6),
                 ),
                 child: Row(
                   children: [
                     Expanded(child: _buildModeOptionCompact("Paper", !_isLiveMode, AppColors.cyan, () { setState(() { _isLiveMode = false; }); })),
                     Expanded(child: _buildModeOptionCompact("Live", _isLiveMode, Colors.redAccent, () { setState(() { _isLiveMode = true; }); })),
                   ],
                 ),
               ),
             ),

             // Action Buttons (Compact)
             Row(
                children: [
                   Expanded(child: _buildOutlineButton(Icons.show_chart_outlined, "Chart", onTap: () {
                     showDialog(
                       context: context,
                        builder: (context) => TechnicalChartScreen(
                          strategyCode: widget.data.strategyCode,
                          strategyName: widget.data.strategyName,
                          backtestId: widget.data.id,
                        ),
                     );
                   })),
                   const SizedBox(width: 8),
                   Expanded(child: _buildOutlineButton(Icons.description_outlined, "Report", onTap: () {
                     showDialog(
                       context: context,
                        builder: (context) => StrategyDetailedReport(
                          strategyCode: widget.data.strategyCode,
                          backtestId: widget.data.id,
                        ),
                     );
                   })),
                   const SizedBox(width: 8),
                   Expanded(child: _buildOutlineButton(Icons.science_outlined, "Run", onTap: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => BacktestConfigScreen(
                           strategyCode: widget.data.strategyCode,
                           strategyName: widget.data.strategyName,
                         ),
                       ),
                     );
                   })),
                   const SizedBox(width: 8),
                   Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: (widget.isBrokerConnected == true) ? widget.onAction : () {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please connect broker first!")));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (isActive == true) ? Colors.redAccent : ((_isLiveMode == true) ? Colors.redAccent : AppColors.cyan),
                             foregroundColor: Colors.white,
                             padding: EdgeInsets.zero,
                             elevation: 0,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                             (isActive == true) ? "Stop" : "Deploy",
                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                   ),
                ],
             ),
          ],
       ),
    );
  }

  Widget _buildCompactStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
      ],
    );
  }

  Widget _buildModeOptionCompact(String title, bool isSelected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title, 
          style: TextStyle(
            color: isSelected ? color : Colors.white38, 
            fontSize: 10, 
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
          )
        ),
      ),
    );
  }

  Widget _buildOutlineButton(IconData icon, String label, {VoidCallback? onTap}) {
    bool isSmallMobile = MediaQuery.of(context).size.width < 380;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            if (!isSmallMobile) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
