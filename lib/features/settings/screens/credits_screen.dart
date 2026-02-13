import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Manage your credits and view transactions',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Cards Row
              SizedBox(
                height: 140, 
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildBalanceCard(
                      "TOTAL BALANCE",
                      "₹500.00",
                      "All-time credits",
                      const Color(0xFF2E1065).withOpacity(0.4), // Dark Purple bg
                      AppColors.purple,
                      280,
                    ),
                    const SizedBox(width: 16),
                    _buildBalanceCard(
                      "AVAILABLE",
                      "₹438.79",
                      "Ready to use",
                      Colors.blueGrey.withOpacity(0.1),
                      AppColors.cyan,
                      280,
                    ),
                    const SizedBox(width: 16),
                    _buildBalanceCard(
                      "USED CREDIT",
                      "₹61.21",
                      "Total spent",
                      Colors.redAccent.withOpacity(0.1),
                      Colors.redAccent,
                      280,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Credit Transactions Header
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Credit Transactions",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              // Credit Transactions Table
              _buildScrollableTable(
                columns: ["BALANCE", "AVAILABLE", "PAYMENT ID", "DATE", "AMOUNT", "STATUS", "INVOICE"],
                columnWidths: [100, 100, 180, 150, 100, 100, 80],
                rows: [
                   _buildTransactionRow(
                      ["₹500.00", "₹438.79", "pay_SB8yZ11SP8iyAR", "02 Feb 26 at 09:53", "₹500.00", "Completed", ""],
                      [100, 100, 180, 150, 100, 100, 80],
                      isCredit: true,
                      isLast: true,
                    ),
                ],
              ),

              const SizedBox(height: 32),

              // Debit Transactions Header
              const Row(
                children: [
                  Icon(Icons.layers, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Debit Transactions",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              // Debit Transactions Table
              _buildScrollableTable(
                 columns: ["BALANCE", "AVAILABLE", "DATE", "AMOUNT", "DESCRIPTION", "REF ID"],
                 columnWidths: [100, 100, 150, 100, 150, 200],
                 rows: [
                    _buildTransactionRow(
                      ["₹500.00", "₹438.79", "10 Feb 26 at 18:25", "-₹18.71", "Strategy building", "d46ea97d..."],
                      [100, 100, 150, 100, 150, 200],
                      isCredit: false,
                    ),
                    _buildTransactionRow(
                      ["₹500.00", "₹457.50", "10 Feb 26 at 18:24", "-₹1.35", "Strategy Validation", "57144cd1..."],
                      [100, 100, 150, 100, 150, 200],
                      isCredit: false,
                    ),
                    _buildTransactionRow(
                      ["₹500.00", "₹458.85", "09 Feb 26 at 14:49", "-₹19.29", "Strategy building", "b6b46c23..."],
                      [100, 100, 150, 100, 150, 200],
                      isCredit: false,
                      isLast: true,
                    ),
                 ]
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String value, String subtitle, Color bgColor, Color accentColor, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accentColor.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableTable({
     required List<String> columns, 
     required List<double> columnWidths,
     required List<Widget> rows
  }) {
     return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
           decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
           ),
           child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 _buildTableHeaderRow(columns, columnWidths),
                 ...rows,
              ],
           ),
        ),
     );
  }

  Widget _buildTableHeaderRow(List<String> columns, List<double> widths) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(columns.length, (index) {
          return SizedBox(
            width: widths[index],
            child: Text(
              columns[index],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTransactionRow(List<String> values, List<double> widths, {bool isCredit = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
         mainAxisSize: MainAxisSize.min,
        children: List.generate(values.length, (index) {
          final value = values[index];
          Widget content;
          
          if (value == "Completed") {
            content = Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4D3E), // Dark Green
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
              ),
              child: const Text(
                "Completed",
                style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            );
          } else if (value.isEmpty && index == values.length - 1 && isCredit) { 
             content = Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                   color: AppColors.cyan.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.download, color: AppColors.cyan, size: 14)
             );
          } else {
             Color textColor = Colors.white;
             
             // Amount Color Logic
             // Credit Table: Amount is at index 4
             if (isCredit && index == 4) textColor = Colors.greenAccent;
             
             // Debit Table: Amount is at index 3
             if (!isCredit && index == 3) textColor = Colors.redAccent;
             
             // Muted text for secondary columns
             if (!isCredit && (index == 5 || index == 4)) textColor = Colors.white.withOpacity(0.7); // Description/RefID
             if (isCredit && index == 2) textColor = Colors.white.withOpacity(0.7); // Payment ID

             content = Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: (isCredit && index == 4) || (!isCredit && index == 3) ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }

          return SizedBox(
            width: widths[index],
            child: Align(
               alignment: Alignment.centerLeft,
               child: content,
            ),
          );
        }),
      ),
    );
  }
}
