import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class PromptBlueprint {
  final String name;
  final String prompt;
  final List<String> tags;

  PromptBlueprint({required this.name, required this.prompt, required this.tags});
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<PromptBlueprint> _allBlueprints = [
    PromptBlueprint(
      name: "Accumulation Distribution",
      tags: ["#Indicator", "#Volume"],
      prompt: "Create A/D strategy: Enter when accumulation distribution confirms price trend, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "ADX Trend Strength",
      tags: ["#Indicator", "#Trend"],
      prompt: "Create ADX strategy: Enter when ADX above 25 with trend direction confirmation, Risk 1%, Max trades 3/day, Trailing SL 12 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "ATR Volatility",
      tags: ["#Indicator", "#Volatility"],
      prompt: "Create ATR strategy: Trade breakout when ATR expands above average, Risk 1%, Max trades 4/day, Trailing SL ATR based, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Bollinger Reversal",
      tags: ["#Volatility", "#Reversal"],
      prompt: "Create Bollinger Bands strategy: Period 20, Deviation 2, Buy when price touches lower band and closes above, Sell when price touches upper band and closes below, TF 15m, Risk 1%, Max trades 4/day, Trailing SL 10 points",
    ),
    PromptBlueprint(
      name: "CCI Strategy",
      tags: ["#Indicator", "#Momentum"],
      prompt: "Build CCI strategy: Buy when CCI crosses above 100 and sell below -100, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "Chandelier Exit",
      tags: ["#Indicator", "#Trend"],
      prompt: "Create chandelier exit strategy: Trail stop based on ATR chandelier exit in trending market, Risk 1%, Max trades 3/day, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Donchian Channel",
      tags: ["#Indicator", "#Breakout"],
      prompt: "Build Donchian channel strategy: Buy on upper band breakout and sell on lower band breakout, Risk 1%, Max trades 4/day, Trailing SL 12 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Elder Ray Index",
      tags: ["#Indicator", "#Trend"],
      prompt: "Create Elder Ray strategy: Buy when bull power positive and bear power rising, Risk 1%, Max trades 3/day, Trailing SL 12 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "EMA Crossover Pro",
      tags: ["#Trend", "#Intraday", "#Indicator"],
      prompt: "Create a trading strategy using EMA crossover: Fast EMA 9, Slow EMA 21, Buy when fast crosses above slow, Sell when fast crosses below slow, Timeframe 5m, Risk per trade 1%, Max trades per day 5, Trailing SL 10",
    ),
    PromptBlueprint(
      name: "EMA RSI MACD Combo",
      tags: ["#Confirmation", "#Pro"],
      prompt: "Create multi indicator strategy using EMA 20, RSI 14 and MACD: Buy when EMA bullish, RSI above 50 and MACD positive, Sell opposite, TF 5m, Risk 1%, Max trades 4/day, Trailing SL 10 points, Loss limit 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Fibonacci Retracement",
      tags: ["#Indicator", "#Retracement"],
      prompt: "Create Fibonacci strategy: Trade retracement from 38.2% or 61.8% with trend filter, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Ichimoku Cloud",
      tags: ["#Indicator", "#Trend"],
      prompt: "Create Ichimoku strategy: Buy when price above cloud and Tenkan crosses Kijun, Risk 1%, Max trades 4/day, Trailing SL 12 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Keltner Channel",
      tags: ["#Indicator", "#Volatility"],
      prompt: "Build Keltner channel strategy: Buy above upper band and sell below lower band, Risk 1%, Max trades 4/day, Trailing SL 12 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "MACD Momentum",
      tags: ["#Momentum", "#Trend"],
      prompt: "Build MACD strategy: MACD 12,26,9, Buy when MACD crosses above signal, Sell when crosses below, TF 10m, Risk 1%, Max trades 5/day, Trailing SL 12 points, Daily loss limit 3%, Daily profit 6%",
    ),
    PromptBlueprint(
      name: "Momentum Indicator",
      tags: ["#Indicator", "#Momentum"],
      prompt: "Build momentum strategy: Buy when momentum positive and rising, sell when negative, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "On Balance Volume",
      tags: ["#Indicator", "#Volume"],
      prompt: "Create OBV strategy: Enter trade when OBV confirms price breakout, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "Parabolic SAR",
      tags: ["#Indicator", "#Trend"],
      prompt: "Build Parabolic SAR strategy: Buy when price above SAR and sell when below, Risk 1%, Max trades 4/day, Trailing SL using SAR, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "Pivot Points",
      tags: ["#Indicator", "#SupportResistance"],
      prompt: "Build pivot points strategy: Buy above pivot support and sell below pivot resistance, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "ROC Momentum",
      tags: ["#Indicator", "#Momentum"],
      prompt: "Create ROC strategy: Trade when ROC crosses above or below zero with trend filter, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "RSI Reversal",
      tags: ["#Momentum", "#Reversal"],
      prompt: "Build an RSI based strategy: RSI 14, Buy when RSI crosses above 30, Sell when RSI crosses below 70, Timeframe 15m, Risk per trade 1.5%, Max trades per day 4, Trailing SL 12 points, Daily loss limit 3%, Daily profit 6%",
    ),
  ];

  List<PromptBlueprint> _filteredBlueprints = [];

  @override
  void initState() {
    super.initState();
    _filteredBlueprints = _allBlueprints;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredBlueprints = _allBlueprints
          .where((b) => b.name.toLowerCase().contains(_searchController.text.toLowerCase()) || 
                       b.prompt.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Prompt Blueprints',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: -0.5),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search blueprints...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.2), size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _filteredBlueprints.isEmpty 
              ? const Center(child: Text("No blueprints found", style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredBlueprints.length,
                  itemBuilder: (context, index) {
                    return _buildTemplateCard(_filteredBlueprints[index]);
                  },
                ),
          ),
        ],
      ),
    );
  }

  // Removed banner and footer methods for cleaner experience

  Widget _buildTopBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("AI Strategy Builder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(width: 8),
                        _buildSmallBadge("LIVE", AppColors.green),
                        const SizedBox(width: 4),
                        _buildSmallBadge("HOT", Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text("Create for ANY market in 30 seconds", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBannerStat("STRATEGIES", "10,245+", Icons.account_tree_outlined),
              _buildBannerStat("AVG TIME", "30s", Icons.timer_outlined),
              _buildBannerStat("MARKETS", "All", Icons.public),
              _buildCreditsChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildBannerStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white24, size: 10),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildCreditsChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: AppColors.cyan, size: 12),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("CREDITS", style: TextStyle(color: Colors.white24, fontSize: 7, fontWeight: FontWeight.bold)),
              Text("48.89", style: TextStyle(color: AppColors.cyan.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter() {
     return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
           color: Colors.black.withOpacity(0.2),
           border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              TextButton.icon(
                 onPressed: () {},
                 icon: const Icon(Icons.chevron_left, color: Colors.white38),
                 label: const Text("Previous", style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
              Text(
                 "Page 1 of 7",
                 style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                 onPressed: () {},
                 icon: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 12)),
                 label: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ),
           ],
        ),
     );
  }

  Widget _buildTemplateCard(PromptBlueprint blueprint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  blueprint.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                 ),
                 child: const Text(
                    "Prompt Blueprint",
                    style: TextStyle(color: AppColors.cyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                 ),
              ),
            ],
          ),
           
          const SizedBox(height: 12),
          
          Wrap(
             spacing: 12,
             children: blueprint.tags.map<Widget>((tag) {
                return Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                      Icon(Icons.tag, color: AppColors.purple.withOpacity(0.5), size: 10),
                      const SizedBox(width: 4),
                      Text(
                         tag.replaceAll('#', ''),
                         style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                   ],
                );
             }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          Text(
             blueprint.prompt,
             style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.6, fontWeight: FontWeight.w400),
             maxLines: 4,
             overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 24),
          
          InkWell(
            onTap: () {
               Navigator.pop(context, blueprint.prompt);
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                   colors: [AppColors.cyan, AppColors.cyan.withOpacity(0.7)],
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: AppColors.cyan.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Center(
                child: Text(
                  "Use This Prompt Blueprint",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
