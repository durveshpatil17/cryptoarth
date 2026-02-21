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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Calculator", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, size: 20, color: Colors.white)),
          const ProfileAvatar(),
          const SizedBox(width: 16),
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
                         "Margin & Risk",
                         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                       ),
                       Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                             color: AppColors.cyan.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("BTC/USD", style: TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),

                   // Input Grid
                   Row(
                      children: [
                         Expanded(child: _buildCompactInput("Capital (₹)", _capitalController)),
                         const SizedBox(width: 12),
                         Expanded(child: _buildCompactDropdown("Symbol", _selectedSymbol, _symbols)),
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
                     height: 40,
                     child: ElevatedButton(
                       onPressed: () {},
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.primary,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       ),
                       child: const Text("Calculate", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
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
                     "Results Preview",
                     style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 16),
                   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                         _buildResultItem("Margin", "\$180.72", AppColors.cyan),
                         _buildResultItem("Risk", "\$45.18", Colors.redAccent),
                         _buildResultItem("Reward", "\$112.95", AppColors.green),
                      ],
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
