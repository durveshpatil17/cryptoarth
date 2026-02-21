import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';
import 'package:cryptoarth/features/credits/providers/payment_ledger_provider.dart';
import 'package:cryptoarth/features/credits/screens/credits_store_screen.dart';

class CreditsScreen extends ConsumerStatefulWidget {
  const CreditsScreen({super.key});

  @override
  ConsumerState<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends ConsumerState<CreditsScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payments & Credits',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Manage your credits',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              height: 32,
              child: ElevatedButton.icon(
                onPressed: () async {
                   final newCredits = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreditsStoreScreen()),
                  );
                  
                  if (newCredits != null && newCredits is int) {
                    ref.read(paymentBalanceProvider.notifier).refresh();
                    ref.read(paymentLedgerProvider.notifier).refresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Success! Added $newCredits Credits.")),
                    );
                  }
                },
                icon: const Icon(Icons.add, size: 14),
                label: const Text("Add", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Balance Row
            SizedBox(
              height: 80,
              child: ref.watch(paymentBalanceProvider).when(
                data: (balanceModel) {
                  final balance = balanceModel?.balance ?? 0.0;
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCompactBalanceCard("TOTAL CREDITS", "${balance.toStringAsFixed(2)}", AppColors.green),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
                error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.redAccent))),
              ),
            ),

            const SizedBox(height: 24),

            // Ledger History
            _buildSectionHeader("Transaction History", Icons.history, Colors.white70),
            const SizedBox(height: 8),
            
            ref.watch(paymentLedgerProvider).when(
              data: (ledgerItems) {
                if (ledgerItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No transactions yet.", style: TextStyle(color: Colors.white54)),
                  );
                }
                return Column(
                  children: ledgerItems.map((item) {
                     final isCredit = item.transactionType.toUpperCase() == "CREDIT";
                     final amountStr = isCredit ? "+${item.amount}" : "-${item.amount}";
                     final amountColor = isCredit ? AppColors.green : Colors.redAccent;
                     return _buildTransactionItem(
                       item.description.isNotEmpty ? item.description : item.transactionType,
                       item.createdAt,
                       amountStr,
                       amountColor,
                       item.status,
                     );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
              error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.redAccent))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBalanceCard(String title, String value, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount, Color amountColor, String status) {
     return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
           color: AppColors.cardSurface,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
           children: [
              Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                    color: amountColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                 ),
                 child: Icon(
                    amountColor == AppColors.green ? Icons.arrow_downward : Icons.arrow_upward,
                    color: amountColor, 
                    size: 14
                 ),
              ),
              const SizedBox(width: 12),
              Expanded(
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                       const SizedBox(height: 2),
                       Text(date, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                    ],
                 ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                     amount,
                     style: TextStyle(color: amountColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(color: amountColor.withOpacity(0.7), fontSize: 9),
                  ),
                ],
              ),
           ],
        ),
     );
  }
}
