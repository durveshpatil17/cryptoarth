import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/gradient_button.dart';
import 'backtest_results_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';
import 'package:cryptoarth/features/credits/screens/credits_store_screen.dart';
import 'code_generator_screen.dart';

import 'package:cryptoarth/shared/widgets/luxury_background.dart';

class BacktestConfigScreen extends ConsumerStatefulWidget {
  final String strategyCode;
  final String strategyName;
  final String? pineCode;
  final String? pythonCode;
  final dynamic strategySource;

  const BacktestConfigScreen({
    super.key, 
    this.strategyCode = 'COPILOT_STRAT',
    this.strategyName = 'AI Generated Strategy',
    this.pineCode,
    this.pythonCode,
    this.strategySource,
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

  // Selected Strategy State
  late String _currentStrategyName;
  late String _currentStrategyCode;
  String? _currentPineCode;
  String? _currentPythonCode;
  dynamic _currentStrategySource;

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
    _currentStrategyName = widget.strategyName;
    _currentStrategyCode = widget.strategyCode;
    _currentPineCode = widget.pineCode;
    _currentPythonCode = widget.pythonCode;
    _currentStrategySource = widget.strategySource;
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
      backgroundColor: AppColors.digitalVoidBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "BACKTEST LAB",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              "STRATEGY PERFORMANCE SIMULATOR",
              style: TextStyle(
                fontSize: 8,
                color: AppColors.cyan.withOpacity(0.5),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: LuxuryBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 40),
        child: Column(
          children: [
            // Header Strategy Selector Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                   Row(
                      children: [
                         Expanded(
                            flex: 3,
                            child: _buildStrategySelectionDropdown(),
                         ),
                         const SizedBox(width: 12),
                         SizedBox(
                            height: 38,
                            child: ElevatedButton.icon(
                               onPressed: () {
                                  Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                        builder: (context) => CodeGeneratorScreen(
                                           strategyCode: _currentStrategyCode,
                                           strategyName: _currentStrategyName,
                                        ),
                                     ),
                                  );
                               },
                               icon: const Icon(Icons.code, size: 14),
                               label: const Text("View Code", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                               style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                               ),
                            ),
                         ),
                      ],
                   ),
                   const SizedBox(height: 12),
                   Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                         color: Colors.black.withOpacity(0.2),
                         borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                         children: [
                            const Icon(Icons.info_outline, size: 16, color: AppColors.cyan),
                            const SizedBox(width: 12),
                            Expanded(
                               child: Text(
                                  "Backtest '$_currentStrategyName' across deep liquidity pools using optimized historical data.",
                                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), height: 1.4),
                               ),
                            ),
                         ],
                      ),
                   ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form Grid Container
            GlassContainer(
              borderRadius: 24,
              color: AppColors.cardSurface,
              opacity: 0.5,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // compact header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Execution Setup",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                         "Live Simulation V1.2",
                         style: TextStyle(color: AppColors.cyan.withOpacity(0.5), fontSize: 10),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

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
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _runBacktest() async {
    final balanceData = ref.read(paymentBalanceProvider).value;
    final int credits = balanceData?.balance.toInt() ?? 0;

    if (credits < 20) {
      _showLowCreditsDialog();
      return;
    }

    _showConfirmationDialog(() => _executeBacktest());
  }

  Future<void> _executeBacktest() async {
    setState(() => _isExecuting = true);
    try {
      final srv = ref.read(strategyServiceProvider);
      final payload = {
        "strategy_code": _currentStrategyCode,
        "symbol": _selectedSymbolObject ?? {"symbol_name": _selectedSymbolName},
        "timeframe": _selectedTimeframe.replaceAll(' Minutes', 'MIN').replaceAll(' Minute', 'MIN'),
        "leverage": _selectedLeverage.replaceAll('x', ''),
        "capital_percent": _selectedCapitalPercent.replaceAll('%', ''),
        "initial_capital": _initialCapitalController.text,
        "commission_type": _selectedCommission.contains('Maker') ? 'maker' : 'taker',
        "commission_percent": '0.05',
        if (_currentPineCode != null) "pine_code": _currentPineCode,
      };
      
      // 1. Resolve Script/Source (Fetch if missing)
      if (_currentPineCode == null && _currentPythonCode == null && _currentStrategySource == null) {
        try {
          // Try to fetch detail which might have strategy_json or code
          final detail = await srv.fetchBacktestDetailRaw(_currentStrategyCode);
          if (detail != null) {
            if (detail['pine_code'] != null) _currentPineCode = detail['pine_code'];
            if (detail['strategy_json'] != null) _currentStrategySource = detail['strategy_json'];
          }
          
          // If still no source and we are owner/authorized, try specific pine endpoint
          if (_currentPineCode == null && _currentStrategySource == null) {
            final fetchedCode = await srv.fetchPineCode(_currentStrategyCode);
            if (fetchedCode.isNotEmpty) {
              _currentPineCode = fetchedCode;
            }
          }
        } catch (e) {
          debugPrint("Note: Could not resolve strategy source: $e");
        }
      }

      // 2. Prepare Backtest (only for temporary AI strategies without source)
      dynamic strategyJson;
      if (_currentStrategySource != null) {
        strategyJson = _currentStrategySource;
      } else if (_currentPineCode == null && _currentPythonCode == null) {
         if (_currentStrategyCode.startsWith('COPILOT_STRAT')) {
           final prepareData = await srv.prepareBacktest(payload);
           strategyJson = prepareData["strategy_json"];
           if (prepareData["pine_code"] != null) {
             _currentPineCode = prepareData["pine_code"];
           }
         }
      }
      
      // 3. Run Backtest
      final int leverageVal = int.tryParse(payload["leverage"].toString()) ?? 10;
      final int capitalPercentVal = double.tryParse(payload["capital_percent"].toString())?.round() ?? 25;
      final int capitalVal = double.tryParse(payload["initial_capital"].toString())?.round() ?? 1000;
      final double commissionPercentVal = double.tryParse(payload["commission_percent"].toString()) ?? 0.05;

      final Map<String, dynamic> runPayload = {
         "strategy_code": _currentStrategyCode,
         "symbol": _selectedSymbolName, 
         "timeframe": payload["timeframe"],
         "leverage": leverageVal,
         "capital_percent": capitalPercentVal,
         "capital": capitalVal, 
         "initial_capital": capitalVal,
         "commission_type": payload["commission_type"],
         "commission_percent": commissionPercentVal,
      };

      if (strategyJson != null) {
        runPayload["json_strategy_code"] = strategyJson;
        if (strategyJson is Map && strategyJson['risk'] != null && strategyJson['risk'] is Map) {
           runPayload.addAll(Map<String, dynamic>.from(strategyJson['risk']));
        }
      }
      
      if (_currentPineCode != null) {
        runPayload["pine_code"] = _currentPineCode;
      }
      if (_currentPythonCode != null) {
        runPayload["python_backtest_code"] = _currentPythonCode;
      }

      final runData = await srv.runBacktest(runPayload);
      
      final String? uuid = runData["backtest_result"] is Map ? runData["backtest_result"]["id"]?.toString() : runData["id"]?.toString();
      final resultsData = runData["backtest_json"] ?? runData;
      
      if (!mounted) return;
      
      // Deduct credits locally for UI feedback
      ref.read(paymentBalanceProvider.notifier).refresh();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BacktestResultsScreen(
            strategyCode: _currentStrategyCode,
            backtestId: uuid,
            strategyName: _currentStrategyName,
            symbol: _selectedSymbolName,
            timeframe: _selectedTimeframe,
            leverage: _selectedLeverage,
            capital: _initialCapitalController.text,
            initialData: Map<String, dynamic>.from(resultsData is Map ? resultsData : {}),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      if (_currentStrategyCode == 'MACD_CROSSOVER') {
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

  Widget _buildStrategySelectionDropdown() {
    return ref.watch(selectStrategyProvider).when(
      data: (strategiesList) {
        // Create a copy and ensure current is included
        final List<StrategyModel> strategies = strategiesList.cast<StrategyModel>().toList();
        
        bool currentExists = strategies.any((s) => s.strategyCode == _currentStrategyCode);
        if (!currentExists) {
          strategies.insert(0, StrategyModel(
            id: 'temp', 
            strategyCode: _currentStrategyCode, 
            strategyName: _currentStrategyName,
            createdAt: DateTime.now().toIso8601String(),
            isDeployed: false,
            brokerId: 0,
            winRate: 0, totalPnl: 0, maxDrawdown: 0
          ));
        }

        return Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentStrategyCode,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white54),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              items: strategies.map<DropdownMenuItem<String>>((s) {
                return DropdownMenuItem<String>(
                  value: s.strategyCode,
                  child: Text(s.strategyName, maxLines: 1, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final selected = strategies.firstWhere((s) => s.strategyCode == val);
                  setState(() {
                    _currentStrategyName = selected.strategyName;
                    _currentStrategyCode = selected.strategyCode;
                    _currentPineCode = null;
                    _currentPythonCode = null;
                    _currentStrategySource = null;
                  });
                }
              },
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 38, child: Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showLowCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          color: AppColors.cardSurface,
          opacity: 0.95,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on_outlined, color: AppColors.gold, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Insufficient Credits",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Running a detailed backtest requires 20 Credits.\nPlease top up to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreditsStoreScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Purchase Credits"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          color: AppColors.cardSurface,
          opacity: 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.science_outlined, color: AppColors.cyan, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Confirm Backtest",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Running backtest for '$_currentStrategyName' will deduct 20 credits from your balance.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan, foregroundColor: Colors.black),
                      child: const Text("Execute (20C)"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
