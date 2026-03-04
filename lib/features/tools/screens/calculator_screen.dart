import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Controllers
  final TextEditingController _capitalController = TextEditingController(text: "15000");
  final TextEditingController _leverageController = TextEditingController(text: "25");
  final TextEditingController _capitalUsedController = TextEditingController(text: "25");
  final TextEditingController _stopLossController = TextEditingController(text: "2");
  final TextEditingController _targetController = TextEditingController(text: "5");
  final TextEditingController _tradesController = TextEditingController(text: "4");
  final TextEditingController _usdRateController = TextEditingController(text: "83");

  String _selectedSymbol = "BTCUSD";
  String _orderType = "Maker"; // Maker or Taker
  String _stopLossUnit = "%";
  String _targetUnit = "%";

  final List<String> _symbols = ["BTCUSD", "ETHUSD", "SOLUSD"];

  // Calculated Results
  double _margin = 0.0;
  double _risk = 0.0;
  double _reward = 0.0;
  double _totalFees = 0.0;
  double _netProfit = 0.0;
  double _positionSize = 0.0;
  double _totalCapitalUSD = 0.0;

  void _calculate() {
    setState(() {
      final double capitalINR = double.tryParse(_capitalController.text) ?? 15000;
      final double usdRate = double.tryParse(_usdRateController.text) ?? 83;
      final double leverage = double.tryParse(_leverageController.text) ?? 25;
      final double capitalUsedPct = double.tryParse(_capitalUsedController.text) ?? 25;
      final double slValue = double.tryParse(_stopLossController.text) ?? 2;
      final double targetValue = double.tryParse(_targetController.text) ?? 5;
      final double tradesPerDay = double.tryParse(_tradesController.text) ?? 4;

      // 1. Convert Capital to USD
      _totalCapitalUSD = capitalINR / usdRate;
      
      // 2. Used Capital (Margin)
      _margin = _totalCapitalUSD * (capitalUsedPct / 100);
      
      // 3. Position Size
      _positionSize = _margin * leverage;

      // 4. Fees (Maker 0.02%, Taker 0.05% - per side)
      final double feeRate = _orderType == "Maker" ? 0.0002 : 0.0005;
      // Fee on entry + Fee on exit
      final double perTradeFees = _positionSize * feeRate * 2;
      _totalFees = perTradeFees * tradesPerDay;

      // 5. Risk & Reward
      if (_stopLossUnit == "%") {
        _risk = _positionSize * (slValue / 100);
      } else {
        _risk = slValue;
      }

      if (_targetUnit == "%") {
        _reward = _positionSize * (targetValue / 100);
      } else {
        _reward = targetValue;
      }

      // 6. Net Profit per trade
      _netProfit = _reward - perTradeFees;
    });
  }

  void _reset() {
    setState(() {
      _capitalController.text = "15000";
      _leverageController.text = "25";
      _capitalUsedController.text = "25";
      _stopLossController.text = "2";
      _targetController.text = "5";
      _tradesController.text = "4";
      _usdRateController.text = "83";
      _calculate();
    });
  }

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Margin Calculator", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _reset, 
            icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white70)
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text(
                         "Trade Configuration",
                         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                       ),
                       Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                             color: AppColors.cyan.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_selectedSymbol, style: const TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),

                   // Input Grid
                   Row(
                      children: [
                         Expanded(child: _buildCompactInput("Capital (₹)", _capitalController)),
                         const SizedBox(width: 12),
                         Expanded(child: _buildCompactInput("USD Rate (₹)", _usdRateController)),
                      ],
                   ),
                   const SizedBox(height: 12),
                   
                   Row(
                      children: [
                         Expanded(child: _buildCompactInput("Leverage (x)", _leverageController)),
                         const SizedBox(width: 12),
                         Expanded(child: _buildCompactInput("Capital Used (%)", _capitalUsedController)),
                      ],
                   ),
                   const SizedBox(height: 12),

                   Row(
                      children: [
                         Expanded(child: _buildCompactInputWithToggle("Stop Loss", _stopLossController, _stopLossUnit, (v) => setState(() => _stopLossUnit = v))),
                         const SizedBox(width: 12),
                         Expanded(child: _buildCompactInputWithToggle("Target", _targetController, _targetUnit, (v) => setState(() => _targetUnit = v))),
                      ],
                   ),
                   const SizedBox(height: 12),

                   Row(
                      children: [
                         Expanded(child: _buildCompactInput("Trades / Day", _tradesController)),
                         const SizedBox(width: 12),
                         Expanded(child: _buildOrderTypeSelector()),
                      ],
                   ),
                   
                   const SizedBox(height: 20),

                   // Calculate Button
                   SizedBox(
                     width: double.infinity,
                     height: 44,
                     child: ElevatedButton(
                       onPressed: _calculate,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.primary,
                         foregroundColor: Colors.white,
                         elevation: 0,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       ),
                       child: const Text("Update Calculation", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                     ),
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                   const Text(
                     "ESTIMATED TRADING METRICS (USD)",
                     style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                   ),
                   const SizedBox(height: 20),
                   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                         _buildResultItem("Position Size", "\$${_positionSize.toStringAsFixed(2)}", Colors.white),
                         _buildResultItem("Risk (Loss)", "\$${_risk.toStringAsFixed(2)}", Colors.redAccent),
                         _buildResultItem("Reward (Profit)", "\$${_reward.toStringAsFixed(2)}", AppColors.green),
                      ],
                   ),
                   const Padding(
                     padding: EdgeInsets.symmetric(vertical: 16.0),
                     child: Divider(color: Colors.white10, height: 1),
                   ),
                   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                         _buildResultItem("Margin Used", "\$${_margin.toStringAsFixed(2)}", AppColors.cyan),
                         _buildResultItem("ROE / Trade", "${((_reward/_margin)*100).toStringAsFixed(1)}%", AppColors.green),
                         _buildResultItem("Est. Daily Fees", "\$${_totalFees.toStringAsFixed(2)}", Colors.orangeAccent),
                      ],
                   ),
                   const SizedBox(height: 16),
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.03),
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Text("Net Profit (Target hit - Fees)", style: TextStyle(color: Colors.white60, fontSize: 11)),
                         Text("\$${_netProfit.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                       ],
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

  Widget _buildCompactInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 10, bottom: 14), 
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDropdown(String label, String value, List<String> items) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
           const SizedBox(height: 4),
           Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                 color: AppColors.background,
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                 child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    dropdownColor: AppColors.cardSurface,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 18),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _selectedSymbol = val!),
                 ),
              ),
           ),
        ],
     );
  }

  Widget _buildCompactInputWithToggle(String label, TextEditingController controller, String unit, Function(String) onUnitChanged) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                 GestureDetector(
                    onTap: () => onUnitChanged(unit == "%" ? "\$" : "%"),
                    child: Text(
                       unit, 
                       style: const TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                 ),
              ],
           ),
           const SizedBox(height: 4),
           Container(
              height: 36,
              decoration: BoxDecoration(
                 color: AppColors.background,
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                 controller: controller,
                 style: const TextStyle(color: Colors.white, fontSize: 12),
                 keyboardType: TextInputType.number,
                 decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10, bottom: 14),
                    isDense: true,
                 ),
              ),
           ),
        ],
     );
  }

  Widget _buildOrderTypeSelector() {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text("Order Type", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
           const SizedBox(height: 4),
           Container(
              height: 36,
              decoration: BoxDecoration(
                 color: AppColors.background,
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                 children: [
                    Expanded(child: _buildTypeOption("Maker", _orderType == "Maker")),
                    Container(width: 1, color: Colors.white10),
                    Expanded(child: _buildTypeOption("Taker", _orderType == "Taker")),
                 ],
              ),
           ),
        ],
     );
  }

  Widget _buildTypeOption(String text, bool isSelected) {
     return GestureDetector(
        onTap: () => setState(() => _orderType = text),
        child: Container(
           color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
           alignment: Alignment.center,
           child: Text(
              text, 
              style: TextStyle(
                 color: isSelected ? Colors.white : Colors.white54, 
                 fontSize: 10, 
                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              )
           ),
        ),
     );
  }
  
  Widget _buildResultItem(String label, String value, Color color) {
     return Column(
        children: [
           Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
           const SizedBox(height: 4),
           Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
     );
  }
}
