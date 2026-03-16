import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cryptoarth/features/strategies/providers/backtest_provider.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:candlesticks/candlesticks.dart';

class TechnicalChartScreen extends ConsumerStatefulWidget {
  final String strategyCode;
  final String strategyName;
  final String? backtestId;

  const TechnicalChartScreen({
    super.key,
    required this.strategyCode,
    required this.strategyName,
    this.backtestId,
  });

  @override
  ConsumerState<TechnicalChartScreen> createState() => _TechnicalChartScreenState();
}

class _TechnicalChartScreenState extends ConsumerState<TechnicalChartScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  Map<String, dynamic>? _chartData;
  List<Candle> _candles = [];
  
  // Controllers for edit fields
  final TextEditingController _emaFastController = TextEditingController(text: "9");
  final TextEditingController _emaSlowController = TextEditingController(text: "21");
  final TextEditingController _entryController = TextEditingController();
  final TextEditingController _exitController = TextEditingController();
  final TextEditingController _riskController = TextEditingController();
  final TextEditingController _pineController = TextEditingController();

  Map<String, dynamic>? _rawDetails;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final notifier = ref.read(backtestProvider.notifier);
      // Fetching raw data for extra fields
      final service = ref.read(strategyServiceProvider);
      final idToUse = widget.backtestId ?? widget.strategyCode;
      final detailsMap = await service.fetchBacktestResult(idToUse); // Using result for more data
      final chart = await notifier.fetchBacktestChart(widget.strategyCode);
      
      if (mounted) {
        setState(() {
          _rawDetails = detailsMap;
          _chartData = chart;
          
          // Populate controllers
          _emaFastController.text = _rawDetails?['ema_fast_period']?.toString() ?? "9";
          _emaSlowController.text = _rawDetails?['ema_slow_period']?.toString() ?? "21";
          _entryController.text = _rawDetails?['entry_conditions']?.toString() ?? '[{"name":"EMA Bullish Cross","type":"crossover"}]';
          _exitController.text = _rawDetails?['exit_conditions']?.toString() ?? '[]';
          _riskController.text = _rawDetails?['risk_parameters']?.toString() ?? '{"stop_loss_percent":2,"take_profit_percent":4}';
          _pineController.text = _rawDetails?['pine_code'] ?? '// @version=5\nstrategy("EMA Cross")';
        });

        // Fetch Candles based on provided requirements
        final String symbol = _rawDetails?['symbol']?.toString() ?? "BTCUSD";
        final String timeframe = _rawDetails?['timeframe']?.toString() ?? "1H";
        
        try {
          final int endTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
          final int startTimestamp = endTimestamp - (180 * 24 * 60 * 60); // 180 days ago
          
          final candleData = await service.fetchBacktestCandles(
            symbol: symbol,
            timeframe: timeframe,
            start: startTimestamp,
            end: endTimestamp,
          );

          if (mounted) {
            setState(() {
              _candles = candleData.map((e) {
                // Expected format: [time, open, high, low, close, volume] or map
                if (e is List && e.length >= 5) {
                  return Candle(
                    date: DateTime.fromMillisecondsSinceEpoch((e[0] as num).toInt() * (e[0].toString().length > 10 ? 1 : 1000)),
                    open: (e[1] as num).toDouble(),
                    high: (e[2] as num).toDouble(),
                    low: (e[3] as num).toDouble(),
                    close: (e[4] as num).toDouble(),
                    volume: e.length > 5 ? (e[5] as num).toDouble() : 0,
                  );
                } else if (e is Map) {
                  final t = e['time'] ?? e['timestamp'] ?? e['date'] ?? 0;
                  return Candle(
                    date: DateTime.fromMillisecondsSinceEpoch((t as num).toInt() * (t.toString().length > 10 ? 1 : 1000)),
                    open: (e['open'] as num).toDouble(),
                    high: (e['high'] as num).toDouble(),
                    low: (e['low'] as num).toDouble(),
                    close: (e['close'] as num).toDouble(),
                    volume: (e['volume'] as num?)?.toDouble() ?? 0,
                  );
                }
                return null;
              }).whereType<Candle>().toList();
              
              // Candlesticks usually expects newest first
              _candles.sort((a, b) => b.date.compareTo(a.date));
              
              _isLoading = false;
            });
          }
        } catch (e) {
          debugPrint("Candle Fetch Error: $e");
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    try {
      setState(() => _isLoading = true);
      
      final int emaFast = int.tryParse(_emaFastController.text) ?? 9;
      final int emaSlow = int.tryParse(_emaSlowController.text) ?? 21;

      final updates = {
        "ema_fast_period": emaFast,
        "ema_slow_period": emaSlow,
        "entry_conditions": _entryController.text,
        "exit_conditions": _exitController.text,
        "risk_parameters": _riskController.text,
        "pine_code": _pineController.text,
      };
      
      // Update basic strategy details
      await ref.read(backtestProvider.notifier).editStrategy(widget.strategyCode, updates);
      
      // Update indicators specifically using the indicator-specific endpoint
      await ref.read(backtestProvider.notifier).updateBacktestIndicators(
        widget.strategyCode, 
        [
          {"name": "EMA_FAST", "period": emaFast},
          {"name": "EMA_SLOW", "period": emaSlow},
        ]
      );
      
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        _loadData(); // Refresh
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changes saved successfully!"), backgroundColor: AppColors.green));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save failed: $e"), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: GlassContainer(
        width: double.infinity,
        borderRadius: 16,
        color: const Color(0xFF0F172A),
        opacity: 0.98,
        child: Column(
          children: [
            _buildHeader(),
            if (_isEditing) _buildEditPanel(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.cyan))
                : _buildChartArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: AppColors.cyan, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.strategyName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        Text(widget.strategyCode, style: const TextStyle(color: AppColors.cyan, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text("BTCUSD • 15MIN", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                      ],
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
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHeaderStat("Trades", _rawDetails?['total_trades']?.toString() ?? "0"),
                _buildHeaderStat("Signals", _rawDetails?['total_signals']?.toString() ?? "0"),
                _buildHeaderStat("Indicators", (_rawDetails?['indicators'] as List?)?.length.toString() ?? "2"),
                _buildHeaderStat("P&L", "\$${_rawDetails?['total_pnl'] ?? '0.00'}", color: (_rawDetails?['total_pnl'] ?? 0) >= 0 ? AppColors.green : Colors.redAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEditPanel() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Indicator Parameters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isEditing = false),
                    child: const Text("Hide", style: TextStyle(color: AppColors.cyan)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildEditField("EMA_FAST PERIOD", _emaFastController)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildEditField("EMA_SLOW PERIOD", _emaSlowController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("ENTRY / EXIT CONDITIONS", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTextArea("ENTRIES", _entryController)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextArea("EXITS", _exitController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTextArea("RISK PARAMETERS", _riskController)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextArea("PINE_SCRIPT", _pineController)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
          const SizedBox(height: 6),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
        const SizedBox(height: 6),
        Container(
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace'),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
          ),
        ),
      ],
    );
  }

  Widget _buildChartArea() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Indicator Parameters", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  if (!_isEditing) 
                    GestureDetector(
                      onTap: () => setState(() => _isEditing = true),
                      child: const Text("Edit", style: TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _candles.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_graph, color: Colors.white.withOpacity(0.1), size: 64),
                          const SizedBox(height: 16),
                          Text("No candle data available", style: TextStyle(color: Colors.white.withOpacity(0.3))),
                        ],
                      ),
                    )
                  : Candlesticks(
                      candles: _candles,
                    ),
              ),
            ],
          ),
        ),
        if (_isLoading) 
          Center(
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              borderRadius: 16,
              color: Colors.black,
              opacity: 0.5,
              child: const CircularProgressIndicator(color: AppColors.cyan),
            ),
          ),
      ],
    );
  }

  List<FlSpot> _getSpotsFromData(dynamic data) {
    if (data == null || data is! List) {
      return [const FlSpot(0, 0), const FlSpot(10, 0)];
    }
    
    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
       final item = data[i];
       if (item is Map) {
         final x = num.tryParse(item['x']?.toString() ?? item['trade_no']?.toString() ?? i.toString())?.toDouble() ?? i.toDouble();
         final y = num.tryParse(item['y']?.toString() ?? item['balance']?.toString() ?? item['value']?.toString() ?? '0')?.toDouble() ?? 0.0;
         spots.add(FlSpot(x, y));
       } else if (item is num) {
         spots.add(FlSpot(i.toDouble(), item.toDouble()));
       }
    }
    return spots.isEmpty ? [const FlSpot(0, 0), const FlSpot(1, 0)] : spots;
  }
}
