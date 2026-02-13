import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';


class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Filter States
  String _selectedStrategy = "All Strategies";
  String _selectedSymbol = "All";
  String _mode = "Live"; // Live or Paper

  final List<String> _strategies = ["All Strategies", "RSI Strategy", "MACD Strategy"];
  final List<String> _symbols = ["All", "BTC/USDT", "ETH/USDT"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF8B5CF6).withOpacity(0.2), // Light Purple
                border: Border.all(color: const Color(0xFF8B5CF6)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF8B5CF6),
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: "Open Positions"),
                Tab(text: "Closed Positions"),
                Tab(text: "Order Book"),
                Tab(text: "P&L Report"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOpenPositionsTab(),
          const Center(child: Text("Closed Positions Placeholder", style: TextStyle(color: Colors.white))),
          const Center(child: Text("Order Book Placeholder", style: TextStyle(color: Colors.white))),
          const Center(child: Text("P&L Report Placeholder", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildOpenPositionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Open Positions",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Monitor all currently open trading positions based on strategy and symbol, including price, quantity, side, order ID, and execution time. Use the filters below to focus on specific strategies or instruments and track your active trades in real-time.",
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
               const Text("Mode", style: TextStyle(color: Colors.white70, fontSize: 12)),
               const SizedBox(width: 8),
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

          // Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.black.withOpacity(0.2)),
                headingTextStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold),
                dataTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
                columns: const [
                  DataColumn(label: Text("Strategy Name")),
                  DataColumn(label: Text("Symbol")),
                  DataColumn(label: Text("Broker Name")),
                  DataColumn(label: Text("Price")),
                  DataColumn(label: Text("Quantity")),
                  DataColumn(label: Text("Side")),
                  DataColumn(label: Text("Order ID")),
                  DataColumn(label: Text("Date & Time")),
                  DataColumn(label: Text("Action")),
                ],
                rows: const [], // Empty for now as per "No data available" in screenshot
              ),
            ),
          ),
          
          if (true) // Show empty state if rows are empty
            Container(
              height: 150,
              alignment: Alignment.center,
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
        ],
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
          color: isSelected ? const Color(0xFFD946EF) : Colors.transparent, // Purple/Pink for active
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
}
