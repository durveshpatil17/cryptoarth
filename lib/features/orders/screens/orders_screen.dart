import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Filter States
  String _selectedStrategy = "All";
  String _selectedSymbol = "All";
  String _mode = "Live"; // Live or Paper

  final List<String> _strategies = ["All", "RSI Strategy", "MACD Strategy"];
  final List<String> _symbols = ["All", "BTC/USDT", "ETH/USDT"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("CryptoArth AI", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false, // No back button
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
              "Order Book",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "View all buy and sell orders with price, quantity, status, and execution time.",
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
            const SizedBox(height: 24),

            // Filters Row
            Row(
              children: [
                // Strategy Filter
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Strategy", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      _buildDropdown(_selectedStrategy, _strategies, (val) => setState(() => _selectedStrategy = val!)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Symbol Filter
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Symbol", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 8),
                      _buildDropdown(_selectedSymbol, _symbols, (val) => setState(() => _selectedSymbol = val!)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Controls Row (Mode + Refresh)
            Row(
              children: [
                const Text("Mode", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      _buildModeButton("Live", _mode == "Live"),
                      _buildModeButton("Paper", _mode == "Paper"),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // Data Table Container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  // Table Header
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildHeaderCell("Strategy Name", 100),
                          _buildHeaderCell("Symbol", 60),
                          _buildHeaderCell("Side", 50),
                          _buildHeaderCell("Price", 70),
                          _buildHeaderCell("Quantity", 70),
                          _buildHeaderCell("Entry", 70),
                        ],
                      ),
                    ),
                  ),
                  
                  // Empty State Body
                  Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: Text(
                      "No data available",
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
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

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.cardSurface,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _mode = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD946EF) : Colors.transparent, // Purple/Pink/Magenta for active
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
