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
        title: const Text("CryptoArth AI", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
          const ProfileAvatar(),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Margin Calculator",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Calculate your trading margin, position size, and risk-reward ratio with precision. Professional-grade calculations for informed trading decisions.",
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Trading Parameters Card
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
                     children: [
                       Icon(Icons.bar_chart, color: AppColors.cyan, size: 20),
                       const SizedBox(width: 8),
                       const Text(
                         "Trading Parameters",
                         style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 16),
                       ),
                     ],
                   ),
                   const SizedBox(height: 20),

                   // Capital Input
                   _buildLabel("Capital (₹) *"),
                   _buildTextField(_capitalController, prefix:15, prefixText: "\$ ", hint: "Enter Capial"),
                   Padding(
                     padding: const EdgeInsets.only(top: 8, bottom: 16),
                     child: Text("= \$180.72 USD", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                   ),

                   // Symbol Dropdown
                   _buildLabel("Symbol *"),
                   Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSymbol,
                          dropdownColor: AppColors.cardSurface,
                          icon: const Icon(Icons.unfold_more, color: Colors.white70),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          items: _symbols.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() => _selectedSymbol = val!),
                        ),
                      ),
                   ),
                   const SizedBox(height: 16),

                   // Leverage and Capital Used Row
                   Row(
                     children: [
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _buildLabel("Leverage (×) *"),
                             _buildTextField(_leverageController),
                           ],
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _buildLabel("Capital Used (%) *"),
                             _buildTextField(_capitalUsedController, suffixText: "%"),
                           ],
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),

                   // Stop Loss
                   _buildLabel("Stop Loss *"),
                   Row(
                     children: [
                       Expanded(child: _buildTextField(_stopLossController, suffixText: _stopLossUnit == "%" ? "%" : "")),
                       const SizedBox(width: 8),
                       _buildUnitToggle(_stopLossUnit, (val) => setState(() => _stopLossUnit = val)),
                     ],
                   ),
                   const SizedBox(height: 16),

                   // Target
                   _buildLabel("Target *"),
                   Row(
                     children: [
                       Expanded(child: _buildTextField(_targetController, suffixText: _targetUnit == "%" ? "%" : "")),
                       const SizedBox(width: 8),
                       _buildUnitToggle(_targetUnit, (val) => setState(() => _targetUnit = val)),
                     ],
                   ),
                   const SizedBox(height: 16),

                   // Trades per Day and Order Type
                   Row(
                     children: [
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _buildLabel("Trades per Day *"),
                             _buildTextField(_tradesController),
                           ],
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             _buildLabel("Order Type *"),
                             Container(
                               height: 50, // Match text field height roughly
                               decoration: BoxDecoration(
                                 color: AppColors.background,
                                 borderRadius: BorderRadius.circular(12),
                                 border: Border.all(color: Colors.white.withOpacity(0.1)),
                               ),
                               child: Row(
                                 children: [
                                   Expanded(child: _buildOrderTypeButton("Maker", "0.02%")),
                                   Expanded(child: _buildOrderTypeButton("Taker", "0.05%")),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),

                   const SizedBox(height: 16),
                   _buildLabel("USD to INR Rate"),
                   _buildTextField(_usdRateController),
                   Padding(
                     padding: const EdgeInsets.only(top: 8, bottom: 24),
                     child: Text("You can adjust USD/INR if required", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                   ),

                   // Calculate Button
                   SizedBox(
                     width: double.infinity,
                     height: 50,
                     child: ElevatedButton(
                       onPressed: () {},
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.primary,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       ),
                       child: const Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.calculate_outlined, color: Colors.white),
                           SizedBox(width: 8),
                           Text("Calculate Margin", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     ),
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Results Section (Empty State)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                   Row(
                     children: [
                       Icon(Icons.balance, color: AppColors.purple, size: 20),
                       const SizedBox(width: 8),
                       const Text(
                         "Calculation Results",
                         style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold, fontSize: 16),
                       ),
                     ],
                   ),
                   const SizedBox(height: 40),
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.05),
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: Icon(Icons.calculate_outlined, size: 40, color: Colors.white.withOpacity(0.3)),
                   ),
                   const SizedBox(height: 16),
                   Text(
                     "Enter your trading parameters and click \"Calculate Margin\" to see results.",
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                   ),
                   const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? prefixText, String? suffixText, double? prefix, String? hint}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixText: prefixText,
          suffixText: suffixText,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixStyle: const TextStyle(color: Colors.white70),
          suffixStyle: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildUnitToggle(String current, Function(String) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildUnitOption("%", current == "%", onChanged),
          Container(width: 1, height: 20, color: Colors.white.withOpacity(0.1)),
          _buildUnitOption("\$", current == "\$", onChanged),
        ],
      ),
    );
  }

  Widget _buildUnitOption(String text, bool isSelected, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
        child: Column(
          children: [
             Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
             if (isSelected) 
               const Icon(Icons.unfold_more, size: 12, color: Colors.white)
             else
               const SizedBox(height: 12), // Placeholder for alignment
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeButton(String type, String rate) {
    bool isSelected = _orderType == type;
    return GestureDetector(
      onTap: () => setState(() => _orderType = type),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 2),
            Text(rate, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
