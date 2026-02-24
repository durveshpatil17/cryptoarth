import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/gradient_button.dart';
import 'backtest_results_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';

class BacktestConfigScreen extends ConsumerStatefulWidget {
  final String strategyCode;
  final String strategyName;
  final String? pineCode;

  const BacktestConfigScreen({
    super.key, 
    this.strategyCode = 'MACD_CROSSOVER',
    this.strategyName = 'EMA 9/21 Crossover',
    this.pineCode,
  });

  @override
  ConsumerState<BacktestConfigScreen> createState() => _BacktestConfigScreenState();
}

class _BacktestConfigScreenState extends ConsumerState<BacktestConfigScreen> {
  // Form State
  bool _isExecuting = false;
  String _selectedSymbolName = 'BTCUSD';
  Map<String, dynamic>? _selectedSymbolObject;
  String _selectedTimeframe = '15 Minutes';
  String _selectedLeverage = '10x';
  String _selectedCapitalPercent = '25%';
  String _selectedCommission = 'Maker (0.02%)';
  final TextEditingController _initialCapitalController = TextEditingController(text: '10000');

  // Options
  List<Map<String, dynamic>> _symbols = [
    {'id': 1, 'symbol_name': 'BTCUSD'},
    {'id': 2, 'symbol_name': 'ETHUSD'},
  ];
  final List<String> _timeframes = ['1 Minute', '5 Minutes', '15 Minutes', '1 Hour', '4 Hours', '1 Day'];
  final List<String> _leverages = ['1x', '2x', '5x', '10x', '20x', '50x', '100x'];
  final List<String> _capitalPercents = ['10%', '25%', '50%', '75%', '100%'];
  final List<String> _commissionTypes = ['Maker (0.02%)', 'Taker (0.05%)', 'Zero Fee'];

  @override
  void initState() {
    super.initState();
    _fetchSymbols();
  }

  Future<void> _fetchSymbols() async {
    try {
      final srv = ref.read(strategyServiceProvider);
      final list = await srv.fetchBacktestSymbols();
      if (list.isNotEmpty && mounted) {
        setState(() {
          _symbols = List<Map<String, dynamic>>.from(list);
          final found = _symbols.firstWhere(
            (e) => (e['symbol_name']?.toString() ?? '') == _selectedSymbolName,
            orElse: () => _symbols.first,
          );
          _selectedSymbolName = found['symbol_name']?.toString() ?? '';
          _selectedSymbolObject = found;
        });
      }
    } catch (_) {
      // Keep defaults
    }
  }

  @override
  void dispose() {
    _initialCapitalController.dispose();
    super.dispose();
  }

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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.settings_outlined, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Backtest",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.strategyName,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          color: AppColors.cardSurface,
          opacity: 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // compact header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Configuration",
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Advanced >",
                    style: TextStyle(color: AppColors.cyan, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              // Form Grid
              Row(
                children: [
                   Expanded(
                      child: _buildDropdownField(
                        "Symbol", 
                        _selectedSymbolName, 
                        _symbols.map((e) => e['symbol_name']?.toString() ?? '').toList(), 
                        (v) {
                          setState(() {
                            _selectedSymbolName = v!;
                            _selectedSymbolObject = _symbols.firstWhere((e) => e['symbol_name'] == v);
                          });
                        }
                      )
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                      child: _buildDropdownField("Timeframe", _selectedTimeframe, _timeframes, (v) => setState(() => _selectedTimeframe = v!))
                   ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                 children: [
                    Expanded(
                       child: _buildDropdownField("Leverage", _selectedLeverage, _leverages, (v) => setState(() => _selectedLeverage = v!))
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                       child: _buildDropdownField("Capital %", _selectedCapitalPercent, _capitalPercents, (v) => setState(() => _selectedCapitalPercent = v!))
                    ),
                 ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                 children: [
                    Expanded(
                       child: _buildTextField("Initial Capital", _initialCapitalController)
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                       child: _buildDropdownField("Commission", _selectedCommission, _commissionTypes, (v) => setState(() => _selectedCommission = v!))
                    ),
                 ],
              ),

              const SizedBox(height: 24),

              // Date Range Info Compact
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.05),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                   children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Text(
                         "2024-01-10 -> 2026-02-09 (760 days)",
                         style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                      ),
                   ],
                ),
              ),
              
              const SizedBox(height: 16),

              // Run Button Compact
              SizedBox(
                width: double.infinity,
                height: 40,
                child: GradientButton(
                  text: _isExecuting ? "Executing..." : "Run Backtest",
                  icon: _isExecuting ? Icons.hourglass_empty : Icons.play_arrow,
                  onPressed: () {
                    if (!_isExecuting) _runBacktest();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runBacktest() async {
    setState(() => _isExecuting = true);
    try {
      final srv = ref.read(strategyServiceProvider);
      final payload = {
        "strategy_code": widget.strategyCode,
        "symbol": _selectedSymbolObject ?? {"symbol_name": _selectedSymbolName},
        "timeframe": _selectedTimeframe.replaceAll(' Minutes', 'MIN').replaceAll(' Minute', 'MIN'),
        "leverage": _selectedLeverage.replaceAll('x', ''),
        "capital_percent": _selectedCapitalPercent.replaceAll('%', ''),
        "initial_capital": _initialCapitalController.text,
        "commission_type": _selectedCommission.contains('Maker') ? 'maker' : 'taker',
        "commission_percent": '0.05',
        if (widget.pineCode != null) "pine_code": widget.pineCode,
      };
      
      // 1. Prepare Backtest
      final prepareData = await srv.prepareBacktest(payload);
      final strategyJson = prepareData["strategy_json"];
      
      // 2. Run Backtest
      final int leverageVal = int.tryParse(payload["leverage"].toString()) ?? 10;
      final int capitalPercentVal = double.tryParse(payload["capital_percent"].toString())?.round() ?? 25;
      final int capitalVal = double.tryParse(payload["initial_capital"].toString())?.round() ?? 1000;
      final double commissionPercentVal = double.tryParse(payload["commission_percent"].toString()) ?? 0.05;

      final Map<String, dynamic> runPayload = {
         if (!widget.strategyCode.startsWith('STRAT_'))
           "strategy_code": widget.strategyCode,
         "symbol": _selectedSymbolName, // Use String name as confirmed by manual curl test
         "timeframe": payload["timeframe"],
         "leverage": leverageVal,
         "capital_percent": capitalPercentVal,
         "capital": capitalVal, 
         "initial_capital": capitalVal,
         "commission_type": payload["commission_type"],
         "commission_percent": commissionPercentVal,
      };

      if (strategyJson != null) {
        // Flattened components for server's JSON engine
        runPayload.addAll(Map<String, dynamic>.from(strategyJson));
        if (strategyJson['risk'] != null && strategyJson['risk'] is Map) {
          runPayload.addAll(Map<String, dynamic>.from(strategyJson['risk']));
        }
        
        // Multi-path strategy representation
        runPayload["json_strategy_code"] = strategyJson;
        runPayload["strategy_json"] = strategyJson;
      }
      
      // Always include pine_code if available as a fallback
      if (widget.pineCode != null) {
        runPayload["pine_code"] = widget.pineCode;
      }

      final runData = await srv.runBacktest(runPayload);
      
      // Extract the system UUID for persistent operations (deployment)
      final String? uuid = runData["backtest_result"] is Map ? runData["backtest_result"]["id"]?.toString() : runData["id"]?.toString();
      final String? responseCode = runData["strategy"] is Map ? runData["strategy"]["strategy_code"]?.toString() : null;
      
      final backtestId = uuid ?? responseCode ?? widget.strategyCode;
      
      final resultsData = runData["backtest_json"] ?? runData;
      
      if (!mounted) return;
      Navigator.push(
        context,
                MaterialPageRoute(
                  builder: (context) => BacktestResultsScreen(
                    strategyCode: widget.strategyCode,
                    backtestId: uuid,
                    strategyName: "AI Strategy", // or from response
                    symbol: _selectedSymbolName,
                    timeframe: _selectedTimeframe,
                    leverage: _selectedLeverage,
                    capital: _initialCapitalController.text,
                    initialData: Map<String, dynamic>.from(resultsData is Map ? resultsData : {}), // Pass the full response for immediate display
                  ),
                ),
      );
    } catch (e) {
      // Fallback UI test for mock assessment completion
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      // Still allow navigation for testing if it's a known placeholder
      if (widget.strategyCode == 'MACD_CROSSOVER') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BacktestResultsScreen(strategyCode: 'MACD_CROSSOVER')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExecuting = false);
      }
    }
  }

  Widget _buildDropdownField(
      String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
        ),
        const SizedBox(height: 6),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.cardSurface,
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white.withOpacity(0.6)),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
        ),
        const SizedBox(height: 6),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 14), // Vertically center text in 36 height container
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
