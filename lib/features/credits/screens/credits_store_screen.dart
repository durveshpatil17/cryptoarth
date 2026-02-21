import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';

class CreditsStoreScreen extends StatefulWidget {
  const CreditsStoreScreen({super.key});

  @override
  State<CreditsStoreScreen> createState() => _CreditsStoreScreenState();
}

class _CreditsStoreScreenState extends State<CreditsStoreScreen> {
  // 0 = Default Plan, 1 = Custom Amount
  int _selectedPlan = 0;
  final TextEditingController _customAmountController = TextEditingController();
  
  // Pricing Constants
  static const double gstRate = 0.18;
  static const double defaultBaseAmount = 500.0;
  
  double get _baseAmount {
    if (_selectedPlan == 0) return defaultBaseAmount;
    final val = double.tryParse(_customAmountController.text);
    return val ?? 0.0;
  }
  
  double get _gstAmount => _baseAmount * gstRate;
  double get _totalPayable => _baseAmount + _gstAmount;
  int get _credits => _baseAmount.floor(); // 1 Rupee = 1 Credit implementation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Add Credits", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add credits to continue using AI Strategy Builder and Backtesting features.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Base price ₹1 = 1 Credit. GST (18%) will be added at checkout.",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Default Plan Card
            GestureDetector(
              onTap: () => setState(() => _selectedPlan = 0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _selectedPlan == 0 
                      ? AppColors.green.withOpacity(0.1) 
                      : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _selectedPlan == 0 ? AppColors.green : Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedPlan == 0 ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: _selectedPlan == 0 ? AppColors.green : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Default Plan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "₹590",
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 36.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "₹500 base + ₹90 GST (18%)",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You will receive 500 credits",
                            style: TextStyle(
                              color: _selectedPlan == 0 ? AppColors.green : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Custom Amount Card
            GestureDetector(
              onTap: () => setState(() => _selectedPlan = 1),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _selectedPlan == 1 
                      ? AppColors.cardSurface 
                      : AppColors.cardSurface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _selectedPlan == 1 ? AppColors.primary : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedPlan == 1 ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: _selectedPlan == 1 ? AppColors.primary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Custom Amount",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Input Field
                    IgnorePointer(
                      ignoring: _selectedPlan != 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: TextField(
                          controller: _customAmountController,
                          onChanged: (_) => setState(() {}),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Enter amount (min ₹500)",
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            border: InputBorder.none,
                            prefixText: "₹ ",
                            prefixStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Summary Calculation
            GlassContainer(
               borderRadius: 24,
               color: AppColors.cardSurface,
               opacity: 0.5,
               padding: const EdgeInsets.all(24),
               child: Column(
                 children: [
                   _buildSummaryRow("Plan Type:", _selectedPlan == 0 ? "Default Plan" : "Custom Plan"),
                   _buildSummaryRow("Base Amount:", "₹${_baseAmount.toStringAsFixed(2)}"),
                   _buildSummaryRow("GST (18%):", "₹${_gstAmount.toStringAsFixed(2)}"),
                   const Divider(color: Colors.white12, height: 32),
                   _buildSummaryRow("Credits:", "$_credits Credits", isHighlight: true),
                   const SizedBox(height: 16),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text(
                         "Total Payable:",
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                       Text(
                         "₹${_totalPayable.toStringAsFixed(2)}",
                         style: const TextStyle(
                           color: AppColors.green,
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
            ),
            
            const SizedBox(height: 32),
            
            CustomButton(
              text: "Pay ₹${_totalPayable.toStringAsFixed(0)} (incl. GST)",
              icon: Icons.payment,
              onPressed: () {
                // Simulate Payment Success
                Navigator.pop(context, _credits); // Return purchased credits
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? AppColors.green : Colors.white,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
