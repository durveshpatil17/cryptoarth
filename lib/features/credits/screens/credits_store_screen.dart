import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/custom_button.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cryptoarth/features/credits/services/payment_service.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';

class CreditsStoreScreen extends ConsumerStatefulWidget {
  const CreditsStoreScreen({super.key});

  @override
  ConsumerState<CreditsStoreScreen> createState() => _CreditsStoreScreenState();
}

class _CreditsStoreScreenState extends ConsumerState<CreditsStoreScreen> {
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
  
  late Razorpay _razorpay;
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _customAmountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final verified = await _paymentService.verifyPayment({
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
      });
      
      if (mounted) {
         setState(() => _isProcessing = false);
         Navigator.pop(context, _credits); // Return purchased credits on success
      }
    } catch (e) {
       if (mounted) {
         setState(() => _isProcessing = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Failed: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
       }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
       setState(() => _isProcessing = false);
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: ${response.message}', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
     if (mounted) {
       setState(() => _isProcessing = false);
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('External Wallet Selected: ${response.walletName}')));
     }
  }

  Future<void> _initiatePayment() async {
    if (_baseAmount < 500) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum base amount is ₹500'), backgroundColor: Colors.redAccent));
      return;
    }
    
    setState(() => _isProcessing = true);
    try {
       // Create Order
       final orderResponse = await _paymentService.createOrder(_totalPayable);
       final orderId = orderResponse['id'] ?? orderResponse['order_id'];
       final rzpKey = orderResponse['key_id'] ?? orderResponse['razorpay_key'] ?? 'rzp_test_p0rTrr8N1Hj7h0'; // Fallback to a mock key if needed for UI flow
       
       final user = ref.read(authProvider).user;
       
       var options = {
        'key': rzpKey,
        'amount': (_totalPayable * 100).toInt(),
        'name': 'CryptoArth',
        'description': 'Purchase $_credits Credits',
        'order_id': orderId,
        'prefill': {
          'contact': user?.phone ?? '',
          'email': user?.email ?? ''
        },
        'theme': {
           'color': '#8B5CF6'
        }
      };
      
      _razorpay.open(options);
    } catch(e) {
       setState(() => _isProcessing = false);
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not initiate payment: $e'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(paymentBalanceProvider);

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
            // Current Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purple.withOpacity(0.2), AppColors.cyan.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: balanceAsync.when(
                data: (balanceModel) {
                  final totalCredits = balanceModel?.balance.floor() ?? 0;
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.monetization_on_outlined, color: AppColors.gold, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Available Credits",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          Text(
                            "$totalCredits Credits",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
                error: (e, s) => Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Failed to load balance",
                        style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

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
            
            _isProcessing 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : CustomButton(
                  text: "Pay ₹${_totalPayable.toStringAsFixed(0)} (incl. GST)",
                  icon: Icons.payment,
                  onPressed: _initiatePayment,
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
