import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

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
      tags: ["#INDICATORS", "#VOLUME"],
      prompt: "Create A/D strategy: Enter when accumulation distribution confirms price trend, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "ADX Trend Strength",
      tags: ["#INDICATORS", "#TREND"],
      prompt: "Create ADX strategy: Enter when ADX above 25 with trend direction confirmation, Risk 1%, Max trades 3/day, Trailing SL 12 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "ATR Volatility",
      tags: ["#INDICATORS", "#VOLATILITY"],
      prompt: "Create ATR strategy: Trade breakout when ATR expands above average, Risk 1%, Max trades 4/day, Trailing SL ATR based, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Bollinger Reversal",
      tags: ["#CHART PATTERNS", "#REVERSAL"],
      prompt: "Create Bollinger Bands strategy: Period 20, Deviation 2, Buy when price touches lower band and closes above, Sell when price touches upper band and closes below, TF 15m, Risk 1%, Max trades 4/day, Trailing SL 10 points",
    ),
    PromptBlueprint(
      name: "CCI Strategy",
      tags: ["#INDICATORS", "#MOMENTUM"],
      prompt: "Build CCI strategy: Buy when CCI crosses above 100 and sell below -100, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "Chandelier Exit",
      tags: ["#INDICATORS", "#TREND"],
      prompt: "Create chandelier exit strategy: Trail stop based on ATR chandelier exit in trending market, Risk 1%, Max trades 3/day, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Donchian Channel",
      tags: ["#INDICATORS", "#BREAKOUT"],
      prompt: "Build Donchian channel strategy: Buy on upper band breakout and sell on lower band breakout, Risk 1%, Max trades 4/day, Trailing SL 12 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Elder Ray Index",
      tags: ["#INDICATORS", "#TREND"],
      prompt: "Create Elder Ray strategy: Buy when bull power positive and bear power rising, Risk 1%, Max trades 3/day, Trailing SL 12 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "EMA Crossover Pro",
      tags: ["#TREND", "#INDICATORS"],
      prompt: "Create a trading strategy using EMA crossover: Fast EMA 9, Slow EMA 21, Buy when fast crosses above slow, Sell when fast crosses below slow, Timeframe 5m, Risk per trade 1%, Max trades per day 5, Trailing SL 10",
    ),
    PromptBlueprint(
      name: "EMA RSI MACD Combo",
      tags: ["#INDICATORS", "#TREND"],
      prompt: "Create multi indicator strategy using EMA 20, RSI 14 and MACD: Buy when EMA bullish, RSI above 50 and MACD positive, Sell opposite, TF 5m, Risk 1%, Max trades 4/day, Trailing SL 10 points, Loss limit 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Fibonacci Retracement",
      tags: ["#INDICATORS", "#RETRACEMENT"],
      prompt: "Create Fibonacci strategy: Trade retracement from 38.2% or 61.8% with trend filter, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Ichimoku Cloud",
      tags: ["#INDICATORS", "#TREND"],
      prompt: "Create Ichimoku strategy: Buy when price above cloud and Tenkan crosses Kijun, Risk 1%, Max trades 4/day, Trailing SL 12 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "Keltner Channel",
      tags: ["#INDICATORS", "#VOLATILITY"],
      prompt: "Build Keltner channel strategy: Buy above upper band and sell below lower band, Risk 1%, Max trades 4/day, Trailing SL 12 points, Daily loss 3%, Profit target 6%",
    ),
    PromptBlueprint(
      name: "MACD Momentum",
      tags: ["#INDICATORS", "#MOMENTUM"],
      prompt: "Build MACD strategy: MACD 12,26,9, Buy when MACD crosses above signal, Sell when crosses below, TF 10m, Risk 1%, Max trades 5/day, Trailing SL 12 points, Daily loss limit 3%, Daily profit 6%",
    ),
    PromptBlueprint(
      name: "Momentum Indicator",
      tags: ["#INDICATORS", "#MOMENTUM"],
      prompt: "Build momentum strategy: Buy when momentum positive and rising, sell when negative, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "On Balance Volume",
      tags: ["#INDICATORS", "#VOLUME"],
      prompt: "Create OBV strategy: Enter trade when OBV confirms price breakout, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "Parabolic SAR",
      tags: ["#INDICATORS", "#TREND"],
      prompt: "Build Parabolic SAR strategy: Buy when price above SAR and sell when below, Risk 1%, Max trades 4/day, Trailing SL using SAR, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "Pivot Points",
      tags: ["#INDICATORS", "#PRICE ACTION"],
      prompt: "Build pivot points strategy: Buy above pivot support and sell below pivot resistance, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "ROC Momentum",
      tags: ["#INDICATORS", "#MOMENTUM"],
      prompt: "Create ROC strategy: Trade when ROC crosses above or below zero with trend filter, Risk 1%, Max trades 4/day, Trailing SL 10 points, Daily loss 3%, Profit target 5%",
    ),
    PromptBlueprint(
      name: "RSI Reversal",
      tags: ["#INDICATORS", "#REVERSAL"],
      prompt: "Build an RSI based strategy: RSI 14, Buy when RSI crosses above 30, Sell when RSI crosses below 70, Timeframe 15m, Risk per trade 1.5%, Max trades per day 4, Trailing SL 12 points, Daily loss limit 3%, Daily profit 6%",
    ),
  ];

  List<PromptBlueprint> _filteredBlueprints = [];
  String _selectedFilter = "All";

  final List<String> _categories = [
    "All",
    "Indicators",
    "Chart Patterns",
    "Candlestick Patterns",
    "Price Action",
    "Crypto Institutional",
    "Forex & Commodities",
    "Options Sell",
    "Mathematical",
    "Wave Theory",
  ];

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
      _filteredBlueprints = _allBlueprints.where((b) {
        final matchesSearch = b.name.toLowerCase().contains(_searchController.text.toLowerCase()) || 
                             b.prompt.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final filterTag = "#${_selectedFilter.toUpperCase()}";
        final matchesFilter = _selectedFilter == "All" || b.tags.contains(filterTag);
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.digitalVoidBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI TEMPLATES',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 0.8),
                    ),
                    Text(
                      'READY TO DEPLOY STRATEGY BLUEPRINTS',
                      style: TextStyle(fontSize: 8, color: AppColors.cyan.withOpacity(0.5), fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: LuxuryBackground(
        child: Column(
          children: [
            const SizedBox(height: 120),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: "SEARCH BLUEPRINTS...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.2), size: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterButton(),
                ],
              ),
            ),
            
            if (_selectedFilter != "All")
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_selectedFilter.toUpperCase(), style: const TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = "All";
                                _onSearchChanged();
                              });
                            },
                            child: const Icon(Icons.close, color: AppColors.cyan, size: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: _filteredBlueprints.isEmpty 
                ? const Center(child: Text("NO BLUEPRINTS MATCH YOUR SEARCH", style: TextStyle(color: Colors.white10, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredBlueprints.length,
                    itemBuilder: (context, index) {
                      return _buildTemplateCard(_filteredBlueprints[index]);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _selectedFilter = value;
          _onSearchChanged();
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E293B),
      offset: const Offset(0, 48),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _selectedFilter == "All" ? Colors.white.withOpacity(0.04) : AppColors.cyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _selectedFilter == "All" ? Colors.white.withOpacity(0.08) : AppColors.cyan.withOpacity(0.3)),
        ),
        child: Icon(
          Icons.tune_outlined, 
          color: _selectedFilter == "All" ? Colors.white.withOpacity(0.3) : AppColors.cyan, 
          size: 20
        ),
      ),
      itemBuilder: (context) {
        return _categories.map((cat) {
          return PopupMenuItem<String>(
            value: cat,
            child: Row(
              children: [
                if (_selectedFilter == cat)
                  const Icon(Icons.check, color: AppColors.cyan, size: 16)
                else
                  const SizedBox(width: 28),
                Text(
                  cat,
                  style: TextStyle(
                    color: _selectedFilter == cat ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: _selectedFilter == cat ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  blueprint.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(Icons.auto_awesome, color: AppColors.cyan, size: 14),
            ],
          ),
           
          const SizedBox(height: 12),
          
          Wrap(
             spacing: 12,
             children: blueprint.tags.map<Widget>((tag) {
                return Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                      Text(
                         tag.replaceAll('#', '').toUpperCase(),
                         style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                   ],
                );
             }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          Text(
             blueprint.prompt,
             style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, height: 1.6, fontWeight: FontWeight.w600),
             maxLines: 4,
             overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 24),
          
          InkWell(
            onTap: () {
               HapticFeedback.heavyImpact();
               Navigator.pop(context, blueprint.prompt);
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "SELECT BLUEPRINT",
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
