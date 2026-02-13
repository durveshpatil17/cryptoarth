import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Mock Data
  final List<Map<String, dynamic>> _templates = [
    {
      "title": "Accumulation Distribution",
      "tags": ["Indicator", "Volume"],
      "description": "Create A/D strategy: Enter when accumulation distribution confirms price trend, Risk 1%, Max trades 4/day, Trailing SL 10 points...",
    },
    {
      "title": "ADX Trend Strength",
      "tags": ["Indicator", "Trend"],
      "description": "Create ADX strategy: Enter when ADX above 25 with trend direction confirmation, Risk 1%, Max trades 3/day, Trailing SL 12 points...",
    },
    {
      "title": "ATR Volatility",
      "tags": ["Indicator", "Volatility"],
      "description": "Create ATR strategy: Trade breakout when ATR expands above average, Risk 1%, Max trades 4/day, Trailing SL ATR based...",
    },
    {
      "title": "Bollinger Reversal",
      "tags": ["Volatility", "Reversal"],
      "description": "Create Bollinger Bands strategy: Period 20, Deviation 2, Buy when price touches lower band and closes above...",
    },
    {
      "title": "CCI Strategy",
      "tags": ["Indicator", "Momentum"],
      "description": "Build CCI strategy: Buy when CCI crosses above 100 and sell below -100, Risk 1%, Max trades 4/day...",
    },
    {
      "title": "Chandelier Exit",
      "tags": ["Indicator", "Trend"],
      "description": "Create chandelier exit strategy: Trail stop based on ATR chandelier exit in trending market, Risk 1%...",
    },
    {
       "title": "Donchian Channel",
       "tags": ["Indicator", "Breakout"],
       "description": "Build Donchian channel strategy: Buy on upper band breakout and sell on lower band breakout, Risk 1%...",
    },
    {
       "title": "Elder Ray Index",
       "tags": ["Indicator", "Trend"],
       "description": "Create Elder Ray strategy: Buy when bull power positive and bear power rising, Risk 1%...",
    },
    {
       "title": "EMA Crossover Pro",
       "tags": ["Trend", "Intraday", "Indicator"],
       "description": "Create a trading strategy using EMA crossover: Fast EMA 9, Slow EMA 21, Buy when fast crosses above slow...",
    },
    {
       "title": "EMA RSI MACD Combo",
       "tags": ["Confirmation", "Pro"],
       "description": "Create multi indicator strategy using EMA 20, RSI 14 and MACD: Buy when EMA bullish, RSI above 50...",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Strategy Templates',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'AI-powered strategy blueprints ready to use',
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
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.purple.withOpacity(0.5)),
                color: AppColors.purple.withOpacity(0.1),
              ),
              child: const Icon(Icons.lightbulb_outline, color: AppColors.purple, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
               children: [
                  Expanded(
                     child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                           color: AppColors.cardSurface,
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: TextField(
                           controller: _searchController,
                           style: const TextStyle(color: Colors.white),
                           decoration: InputDecoration(
                              hintText: "Search templates...",
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.3)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           ),
                        ),
                     ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                     height: 48,
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                     ),
                     child: Row(
                        children: [
                           Icon(Icons.filter_list, color: Colors.white.withOpacity(0.7), size: 20),
                           const SizedBox(width: 8),
                           Text(
                              "Indicators", 
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold)
                           ),
                        ],
                     ),
                  ),
               ],
            ),
          ),
          
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 Columns
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Adjust card aspect ratio for better fit
              ),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                return _buildTemplateCard(_templates[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
                Expanded(
                  child: Text(
                    template['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
             ],
          ),
           
          const SizedBox(height: 8),
          
          // Header Badge
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
             decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.cyan.withOpacity(0.5)),
             ),
             child: const Text(
                "Indicators", 
                style: TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.bold)
             ),
          ),
          
          const SizedBox(height: 12),
          
          // Tags
          Wrap(
             spacing: 6,
             runSpacing: 6,
             children: (template['tags'] as List).take(2).map<Widget>((tag) {
                return Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                   ),
                   child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         const Icon(Icons.tag, size: 10, color: AppColors.purple),
                         const SizedBox(width: 4),
                         Text(
                            "$tag",
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                         ),
                      ],
                   ),
                );
             }).toList(),
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
             child: Text(
                template['description'],
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, height: 1.4),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
             ),
          ),
          
          const SizedBox(height: 12),
          
          Container(
            width: double.infinity,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.cyan],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Using template: ${template['title']}")),
                 );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Use Template",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
