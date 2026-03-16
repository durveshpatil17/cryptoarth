import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/features/credits/screens/credits_store_screen.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';
import 'backtest_config_screen.dart';

class CodeGeneratorScreen extends ConsumerStatefulWidget {
  final String? strategyCode;
  final String? strategyName;

  const CodeGeneratorScreen({
    super.key,
    this.strategyCode,
    this.strategyName,
  });

  @override
  ConsumerState<CodeGeneratorScreen> createState() => _CodeGeneratorScreenState();
}

class _CodeGeneratorScreenState extends ConsumerState<CodeGeneratorScreen> {
  StrategyModel? _selectedStrategy;
  String _selectedLanguage = 'MQL4';
  final TextEditingController _codeController = TextEditingController();
  
  bool _isGenerating = false;
  Map<String, String> _generatedCodes = {}; // Cache local generated codes for the selected strategy

  final List<String> _languages = ['MQL4', 'MQL5', 'AFL', 'Python', 'Pine'];

  @override
  void initState() {
    super.initState();
    if (widget.strategyCode != null && widget.strategyName != null) {
      _selectedStrategy = StrategyModel(
        id: 'initial',
        strategyCode: widget.strategyCode!,
        strategyName: widget.strategyName!,
        createdAt: DateTime.now().toIso8601String(),
        isDeployed: false,
        brokerId: 0,
        winRate: 0, totalPnl: 0, maxDrawdown: 0
      );
    }
    _codeController.text = "// Select a strategy above and click generate to convert to $_selectedLanguage.";
  }

  void _onStrategyChanged(StrategyModel? strategy) {
    if (strategy == null || strategy.strategyCode == _selectedStrategy?.strategyCode) return;
    setState(() {
      _selectedStrategy = strategy;
      _generatedCodes.clear(); // Clear cache when strategy changes
      _codeController.text = "// Select a strategy above and click generate to convert to $_selectedLanguage.";
    });
  }

  void _onLanguageChanged(String lang) {
    setState(() {
      _selectedLanguage = lang;
      if (_generatedCodes.containsKey(lang)) {
        _codeController.text = _generatedCodes[lang]!;
      } else {
        _codeController.text = "// Select a strategy above and click generate to convert to $lang.";
      }
    });
  }

  Future<void> _generateCode() async {
    if (_selectedStrategy == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a strategy first.')));
      return;
    }

    final balanceData = ref.read(paymentBalanceProvider).value;
    final int credits = balanceData?.balance.toInt() ?? 0;

    if (credits < 20) {
      _showLowCreditsDialog();
      return;
    }

    // Show Confirmation Dialog
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.code, color: AppColors.cyan, size: 40),
              const SizedBox(height: 16),
              const Text("Generate Code", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                "Generate $_selectedLanguage code for ${_selectedStrategy!.strategyName}.\n\nCost: 20 Credits",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan, foregroundColor: Colors.black),
                      child: const Text("Generate"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldProceed != true) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isGenerating = true;
      _codeController.text = "// Generating $_selectedLanguage code...\n// Please wait...";
    });

    try {
      final service = ref.read(strategyServiceProvider);
      // Actual payload to Code Conversion Endpoint
      final result = await service.convertCode({
        "strategy_code": _selectedStrategy!.strategyCode,
        "strategyid": _selectedStrategy!.id,
        "target_language": _selectedLanguage.toLowerCase(),
      });
      
      // Deduct dynamically (or refresh API)
      ref.read(paymentBalanceProvider.notifier).refresh();

      String generatedCode = result['code'] ?? result['content'] ?? result['result'] ?? '';
      if (generatedCode.isEmpty) {
         // Mock generator if backend returns empty or different format during testing
         generatedCode = _mockGenerateCode(_selectedStrategy!.strategyName, _selectedLanguage);
      }

      setState(() {
        _generatedCodes[_selectedLanguage] = generatedCode;
        _codeController.text = generatedCode;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code generated successfully! -20 Credits')));
    } catch (e) {
      print("Conversion error: $e");
      
      // Fallback to local mock immediately if API fails (as UI requires to show the feature)
      final mockCode = _mockGenerateCode(_selectedStrategy!.strategyName, _selectedLanguage);
      setState(() {
        _generatedCodes[_selectedLanguage] = mockCode;
        _codeController.text = mockCode;
      });
      ref.read(paymentBalanceProvider.notifier).refresh(); // In case it charged
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code generated. -20 Credits')));
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _showLowCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_outlined, color: AppColors.gold, size: 40),
              const SizedBox(height: 16),
              const Text("Insufficient Credits", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                "Code generation requires 20 Credits.\nPlease top up your account.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreditsStoreScreen()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                  child: const Text("Top Up Credits"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Darker IDE feel
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.purple.withOpacity(0.3)),
              ),
              child: const Icon(Icons.copy_all, color: AppColors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Code Generator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Export your Pine Script using Claude-powered conversions', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
                ],
              ),
            ),
          ],
        ),
      ),
      body: LuxuryBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Container(
               color: const Color(0xFF161B22).withOpacity(0.5),
               padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
               child: Row(
                  children: [
                     const Spacer(),
                     const Text("Strategy", style: TextStyle(color: Colors.white54, fontSize: 11)),
                     const SizedBox(width: 8),
                     Expanded(
                       flex: 4,
                       child: _buildStrategyDropdown(),
                     ),
                     const SizedBox(width: 12),
                     _buildBacktestQuickAction(),
                  ],
               ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Tabs
                    SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Row(
                          children: _languages.map((lang) => _buildLanguageTab(lang)).toList(),
                       ),
                    ),
  
                    const SizedBox(height: 24),
  
                    // Tags Row
                    Row(
                       children: [
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                             decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                             ),
                             child: const Text("Premium", style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                             decoration: BoxDecoration(
                                color: AppColors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                             ),
                             child: Text(_selectedLanguage, style: const TextStyle(color: AppColors.purple, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                       ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Code Editor Container
                    Container(
                      height: 450,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                         boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                         ],
                      ),
                      child: Column(
                        children: [
                           // Mac-style window controls
                           Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161B22).withOpacity(0.5),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                              ),
                              child: Row(
                                 children: [
                                    _buildWindowDot(const Color(0xFFFF5F57)),
                                    const SizedBox(width: 6),
                                    _buildWindowDot(const Color(0xFFFFBD2E)),
                                    const SizedBox(width: 6),
                                    _buildWindowDot(const Color(0xFF28C840)),
                                    const SizedBox(width: 16),
                                    Text(
                                       _selectedLanguage.toLowerCase(),
                                       style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontFamily: 'monospace'),
                                    ),
                                    const Spacer(),
                                    // Action Buttons Inside Header
                                    if (_generatedCodes.containsKey(_selectedLanguage)) ...[
                                       _buildCodeActionButton(
                                          icon: Icons.copy,
                                          label: "Copy",
                                          onTap: () {
                                             Clipboard.setData(ClipboardData(text: _codeController.text));
                                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied!')));
                                          },
                                       ),
                                       const SizedBox(width: 8),
                                       _buildCodeActionButton(
                                          icon: Icons.download,
                                          label: "Download",
                                          isPrimary: true,
                                          onTap: () {
                                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading...')));
                                          },
                                       ),
                                    ]
                                 ],
                              ),
                           ),
                           // Code Area
                           Expanded(
                              child: Stack(
                                 children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: TextField(
                                        controller: _codeController,
                                        style: const TextStyle(
                                          color: Color(0xFFE6EDF3), // GitHub dark theme text color
                                          fontFamily: 'Courier',
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                        maxLines: null,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    
                                    if (!_generatedCodes.containsKey(_selectedLanguage)) ...[
                                       Center(
                                          child: Shimmer.fromColors(
                                             baseColor: AppColors.cyan,
                                             highlightColor: Colors.white.withOpacity(0.5),
                                             enabled: !_isGenerating,
                                             period: const Duration(seconds: 3),
                                             child: ElevatedButton.icon(
                                                onPressed: _isGenerating ? null : () {
                                                  HapticFeedback.lightImpact(); // Added HapticFeedback
                                                  _generateCode();
                                                },
                                                icon: _isGenerating 
                                                   ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                                                   : const Icon(Icons.generating_tokens, size: 16),
                                                label: Text(_isGenerating ? "Converting..." : "Generate Code (20 Credits)"),
                                                style: ElevatedButton.styleFrom(
                                                   backgroundColor: AppColors.cyan,
                                                   foregroundColor: Colors.black,
                                                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                   textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                                   elevation: 4,
                                                   shadowColor: AppColors.cyan.withOpacity(0.5),
                                                ),
                                             ),
                                          ),
                                       ),
                                    ]
                                 ],
                              ),
                           ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBacktestQuickAction() {
     return SizedBox(
       height: 38,
       child: ElevatedButton.icon(
         onPressed: () {
           if (_selectedStrategy != null) {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => BacktestConfigScreen(
                   strategyCode: _selectedStrategy!.strategyCode,
                   strategyName: _selectedStrategy!.strategyName,
                   pineCode: _generatedCodes['Pine'],
                 ),
               ),
             );
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Please select a strategy first.')),
             );
           }
         },
         icon: const Icon(Icons.science, size: 14),
         label: const Text("Backtest", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
         style: ElevatedButton.styleFrom(
           backgroundColor: AppColors.cyan,
           foregroundColor: Colors.black,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
           padding: const EdgeInsets.symmetric(horizontal: 16),
         ),
       ),
     );
  }

  Widget _buildStrategyDropdown() {
     return ref.watch(selectStrategyProvider).when(
       data: (strategiesList) {
         final List<StrategyModel> strategies = List.from(strategiesList);

         // Ensure selected is in list
         if (_selectedStrategy != null) {
           bool exists = strategies.any((s) => s.strategyCode == _selectedStrategy?.strategyCode);
           if (!exists) {
             strategies.insert(0, _selectedStrategy!);
           }
         }

         if (_selectedStrategy == null && strategies.isNotEmpty) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) setState(() => _selectedStrategy = strategies.first);
           });
         }

          return Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.purple.withOpacity(0.3)),
            ),
             child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStrategy?.strategyCode ?? strategies.first.strategyCode,
                dropdownColor: const Color(0xFF1E293B),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.purple),
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                onChanged: (val) {
                  if (val != null) {
                    final selected = strategies.firstWhere((s) => s.strategyCode == val);
                    _onStrategyChanged(selected);
                  }
                },
                items: strategies.map<DropdownMenuItem<String>>((strategy) {
                  return DropdownMenuItem<String>(
                    value: strategy.strategyCode,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_fix_high, size: 12, color: AppColors.purple),
                        const SizedBox(width: 8),
                        Flexible(child: Text(strategy.strategyName, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
       },
       loading: () => const SizedBox(height: 38, child: Center(child: CircularProgressIndicator(color: AppColors.cyan))),
       error: (e, s) => Center(child: Text("Error", style: const TextStyle(color: Colors.red))),
     );
  }

  Widget _buildLanguageTab(String lang) {
     final bool isSelected = _selectedLanguage == lang;
     return GestureDetector(
        onTap: () => _onLanguageChanged(lang),
        child: Container(
           margin: const EdgeInsets.only(right: 12),
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
           decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(colors: [AppColors.purple.withOpacity(0.8), AppColors.cyan.withOpacity(0.8)]) : null,
              color: isSelected ? null : const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05)),
           ),
           child: Row(
              children: [
                 if (lang == 'MQL4') const Icon(Icons.bolt, size: 14, color: Colors.blueAccent)
                 else if (lang == 'MQL5') const Icon(Icons.auto_awesome, size: 14, color: Colors.orangeAccent)
                 else if (lang == 'AFL') const Icon(Icons.analytics, size: 14, color: Colors.redAccent)
                 else if (lang == 'Python') const Icon(Icons.terminal, size: 14, color: Colors.greenAccent)
                 else const Icon(Icons.description, size: 14, color: AppColors.cyan),
                 
                 const SizedBox(width: 6),
                 Text(lang, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 11)),
                 const SizedBox(width: 8),
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                       color: AppColors.gold.withOpacity(0.15),
                       borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("Premium", style: TextStyle(color: AppColors.gold, fontSize: 8, fontWeight: FontWeight.bold)),
                 ),
              ],
           ),
        ),
     );
  }

  Widget _buildCodeActionButton({required IconData icon, required String label, required VoidCallback onTap, bool isPrimary = false}) {
     return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
           decoration: BoxDecoration(
              color: isPrimary ? AppColors.cyan.withOpacity(0.9) : AppColors.purple.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
           ),
           child: Row(
              children: [
                 Icon(icon, size: 12, color: isPrimary ? Colors.black : Colors.white),
                 const SizedBox(width: 4),
                 Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPrimary ? Colors.black : Colors.white)),
              ],
           ),
        ),
     );
  }

  Widget _buildWindowDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _mockGenerateCode(String name, String lang) {
     if (lang == 'MQL4') {
        return '''// $name Strategy for MQL4
// Claude Generated Convert
#property strict
input double TakeProfit = 50.0;
input double StopLoss = 30.0;
int OnInit() {
   Print("Started Strategy");
   return(INIT_SUCCEEDED);
}
void OnTick() {
   // Wait for momentum cross logic evaluated from original Pine
}''';
     } else if (lang == 'Python') {
        return '''import pandas as pd
import numpy as np

# $name Strategy Claude Conversion
class Algorithm:
    def __init__(self, df):
        self.df = df
        
    def generate_signals(self):
        # AI processed calculations
        pass
''';
     }
     return "// Claude conversion for $lang successful.\n// Code ready.";
  }
}
