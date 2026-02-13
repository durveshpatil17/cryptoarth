import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

class PnLReportScreen extends StatefulWidget {
  const PnLReportScreen({super.key});

  @override
  State<PnLReportScreen> createState() => _PnLReportScreenState();
}

class _PnLReportScreenState extends State<PnLReportScreen> {
  String _selectedTradeCategory = "Live Trades"; // 'Live Trades' or 'Paper Trades'
  String _selectedStrategy = "All Strategies";
  final List<String> _strategies = ["All Strategies", "SuperTrend", "RSI Pro", "Breakout"];
  
  // Mock Dates
  final DateTime _startDate = DateTime.now();
  final DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'P&L Report (User)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Analyze your profit and loss performance',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
           IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              LayoutBuilder(
                 builder: (context, constraints) {
                    // Responsive Grid: 2 columns on mobile
                    return Wrap(
                       spacing: 16,
                       runSpacing: 16,
                       children: [
                          _buildStatCard("TOTAL P&L", "+0.00", AppColors.green, constraints.maxWidth / 2 - 9),
                          _buildStatCard("TOTAL TRADES", "0", Colors.white, constraints.maxWidth / 2 - 9),
                          _buildStatCard("WIN RATE", "0.0%", Colors.white, constraints.maxWidth / 2 - 9),
                          _buildStatCard("AVG P&L", "+0.00", AppColors.green, constraints.maxWidth / 2 - 9),
                       ],
                    );
                 },
              ),

              const SizedBox(height: 24),

              // Filters Container
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
                       const Text("Trade Category", style: TextStyle(color: Colors.white70, fontSize: 12)),
                       const SizedBox(height: 8),
                       // Live / Paper Toggle Buttons
                       Row(
                          children: [
                             Expanded(child: _buildToggleButton("Live Trades", _selectedTradeCategory == "Live Trades")),
                             const SizedBox(width: 12),
                             Expanded(child: _buildToggleButton("Paper Trades", _selectedTradeCategory == "Paper Trades")),
                          ],
                       ),
                       
                       const SizedBox(height: 16),
                       
                       const Text("Select Strategy", style: TextStyle(color: Colors.white70, fontSize: 12)),
                       const SizedBox(height: 8),
                       Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.05),
                             borderRadius: BorderRadius.circular(8),
                             border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: DropdownButtonHideUnderline(
                             child: DropdownButton<String>(
                                value: _selectedStrategy,
                                dropdownColor: AppColors.cardSurface,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                                style: const TextStyle(color: Colors.white),
                                items: _strategies.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                onChanged: (val) => setState(() => _selectedStrategy = val!),
                             ),
                          ),
                       ),
                       
                       const SizedBox(height: 16),
                       
                       // Date Filters
                       Row(
                          children: [
                             Expanded(
                                child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                      const Text("Start Date", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      const SizedBox(height: 8),
                                      _buildDatePicker(_startDate),
                                   ],
                                ),
                             ),
                             const SizedBox(width: 12),
                             Expanded(
                                child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                      const Text("End Date", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      const SizedBox(height: 8),
                                      _buildDatePicker(_endDate),
                                   ],
                                ),
                             ),
                          ],
                       ),

                       const SizedBox(height: 24),
                       
                       // Search Button
                       SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                             onPressed: () {},
                             style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6), // Purple
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             ),
                             child: const Text("Search", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                       ),
                    ],
                 ),
              ),

              const SizedBox(height: 24),

              // Orders Table (Placeholder)
              Container(
                 width: double.infinity,
                 padding: const EdgeInsets.only(bottom: 40),
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
                             color: Colors.black.withOpacity(0.2),
                             child: Row(
                                children: [
                                   _buildHeaderCell("Symbol", 80),
                                   _buildHeaderCell("Order Id", 100),
                                   _buildHeaderCell("Buy Price", 80),
                                   _buildHeaderCell("Sell Price", 80),
                                   _buildHeaderCell("Quantity", 70),
                                   _buildHeaderCell("Side", 50),
                                   _buildHeaderCell("Datetime", 120),
                                   _buildHeaderCell("Profit", 80),
                                   _buildHeaderCell("Strategy Name", 120),
                                ],
                             ),
                          ),
                       ),
                       
                       const SizedBox(height: 40),
                       
                       // Empty State
                       Icon(Icons.bar_chart, size: 48, color: Colors.white.withOpacity(0.2)),
                       const SizedBox(height: 16),
                       const Text(
                          "No orders found",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                       ),
                       const SizedBox(height: 4),
                       Text(
                          "No P&L data available.",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                       ),
                    ],
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor, double width) {
     return Container(
        width: width,
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
                    Container(
                       width: 6, height: 6,
                       decoration: BoxDecoration(
                          color: valueColor == Colors.white ? const Color(0xFFD946EF) : valueColor, // Pink dot for neutral, Green for success
                          shape: BoxShape.circle,
                       ),
                    ),
                    const SizedBox(width: 8),
                    Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold)),
                 ],
              ),
              const SizedBox(height: 12),
              Text(
                 value,
                 style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.bold),
              ),
           ],
        ),
     );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
     return GestureDetector(
        onTap: () => setState(() => _selectedTradeCategory = text),
        child: Container(
           height: 48,
           decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF1E293B), // Active Purple, Inactive Slate
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1)),
           ),
           alignment: Alignment.center,
           child: Text(
              text,
              style: TextStyle(
                 color: isSelected ? Colors.white : Colors.white70,
                 fontWeight: FontWeight.bold,
              ),
           ),
        ),
     );
  }

  Widget _buildDatePicker(DateTime date) {
     return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
           color: Colors.white.withOpacity(0.05),
           borderRadius: BorderRadius.circular(8),
           border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Text(
                 "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}",
                 style: const TextStyle(color: Colors.white),
              ),
              const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
           ],
        ),
     );
  }

  Widget _buildHeaderCell(String text, double width) {
     return SizedBox(
        width: width,
        child: Text(
           text,
           style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold),
        ),
     );
  }
}
