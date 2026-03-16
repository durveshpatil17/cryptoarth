import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';
import 'package:cryptoarth/features/credits/providers/payment_ledger_provider.dart';
import 'package:cryptoarth/features/credits/models/payment_ledger_model.dart';
import 'package:cryptoarth/features/credits/screens/credits_store_screen.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:shimmer/shimmer.dart';

class CreditsDashboardScreen extends ConsumerStatefulWidget {
  const CreditsDashboardScreen({super.key});

  @override
  ConsumerState<CreditsDashboardScreen> createState() => _CreditsDashboardScreenState();
}

class _CreditsDashboardScreenState extends ConsumerState<CreditsDashboardScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMM yy, HH:mm');

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(paymentBalanceProvider);
    final ledgerAsync = ref.watch(paymentLedgerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "PAYMENTS & CREDITS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.8),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreditsStoreScreen())),
            icon: const Icon(Icons.add, color: AppColors.cyan, size: 18),
            label: const Text("Add Credits", style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(paymentBalanceProvider);
          ref.invalidate(paymentLedgerProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Manage your credits and view transactions",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Stats Cards
              balanceAsync.when(
                data: (balance) => _buildStatsRow(balance?.totalBalance ?? 0, balance?.balance ?? 0, balance?.usedCredit ?? 0),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
                error: (err, _) => Center(child: Text("Error loading balance", style: TextStyle(color: Colors.redAccent))),
              ),

              const SizedBox(height: 32),

              // Credit Transactions Table
              const Row(
                children: [
                   Icon(Icons.account_balance_wallet_outlined, color: AppColors.green, size: 16),
                   SizedBox(width: 8),
                   Text("CREDIT TRANSACTIONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8)),
                ],
              ),
              const SizedBox(height: 12),
              ledgerAsync.when(
                data: (ledger) => _buildTransactionsTable(ledger.where((t) => t.transactionType == 'CREDIT').toList(), true),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.green)),
                error: (err, _) => const Center(child: Text("Error loading history")),
              ),

              const SizedBox(height: 32),

              // Debit Transactions Table
              const Row(
                children: [
                  Icon(Icons.history_outlined, color: Colors.redAccent, size: 16),
                  SizedBox(width: 8),
                  Text("DEBIT TRANSACTIONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8)),
                ],
              ),
              const SizedBox(height: 12),
              ledgerAsync.when(
                data: (ledger) => _buildTransactionsTable(ledger.where((t) => t.transactionType == 'DEBIT').toList(), false),
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                error: (err, _) => const Center(child: Text("Error loading history")),
              ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(num total, num available, num used) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard("TOTAL BALANCE", "₹${total.toStringAsFixed(2)}", "All-time credits", const Color(0xFF1E293B)),
          const SizedBox(width: 12),
          Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.01),
            highlightColor: AppColors.cyan.withOpacity(0.05),
            period: const Duration(seconds: 3),
            child: _buildStatCard("AVAILABLE", "₹${available.toStringAsFixed(2)}", "Ready to use", const Color(0xFF1E293B), amountColor: AppColors.cyan),
          ),
          const SizedBox(width: 12),
          _buildStatCard("USED CREDIT", "₹${used.toStringAsFixed(2)}", "Total spent", const Color(0xFF2D1B2D), amountColor: Colors.redAccent.withOpacity(0.8)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color bgColor, {Color? amountColor}) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(
            value, 
            style: TextStyle(
              color: amountColor ?? Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            )
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.24), fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable(List<PaymentLedgerModel> items, bool isCredit) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text("No transactions yet", style: TextStyle(color: Colors.white24, fontSize: 12))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowHeight: 40,
          dataRowMaxHeight: 56,
          horizontalMargin: 20,
          headingTextStyle: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
          columns: const [
                DataColumn(label: Text("AVAILABLE", style: TextStyle(letterSpacing: 0.8))),
                DataColumn(label: Text("PAYMENT ID", style: TextStyle(letterSpacing: 0.8))),
                DataColumn(label: Text("DATE", style: TextStyle(letterSpacing: 0.8))),
                DataColumn(label: Text("AMOUNT", style: TextStyle(letterSpacing: 0.8))),
                DataColumn(label: Text("STATUS/DESC", style: TextStyle(letterSpacing: 0.8))),
              ],
          rows: items.take(10).map((t) {
            final dateStr = _formatDate(t.createdAt);
              return DataRow(cells: [
                DataCell(Text("₹${t.availableSnapshot.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 11, fontFeatures: [FontFeature.tabularFigures()]))),
                DataCell(Text(t.id.length > 8 ? "${t.id.substring(0, 8)}..." : t.id, style: const TextStyle(color: Colors.white54, fontSize: 11))),
                DataCell(Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 11))),
                DataCell(Text("${isCredit ? '₹' : '-₹'}${t.amount}", style: TextStyle(color: isCredit ? AppColors.green : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11, fontFeatures: const [FontFeature.tabularFigures()]))),
                DataCell(isCredit ? _buildStatusBadge(t.status) : Text(t.description, style: const TextStyle(color: Colors.white70, fontSize: 11), overflow: TextOverflow.ellipsis)),
              ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.green.withOpacity(0.2)),
      ),
      child: Text(status, style: const TextStyle(color: AppColors.green, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso);
      return _dateFormat.format(date);
    } catch (_) {
      return iso;
    }
  }
}
