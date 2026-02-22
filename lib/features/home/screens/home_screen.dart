import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';
import 'package:cryptoarth/shared/widgets/strategy_response_card.dart';
import 'package:cryptoarth/features/strategies/screens/backtest_config_screen.dart';
import 'package:cryptoarth/features/credits/screens/credits_store_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  // Persisted Chat History (Static for simple cross-screen access)
  static List<Map<String, dynamic>> savedSessions = [];

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Widget> _messages = [];
  bool _isChatActive = false;
  bool _isLoading = false;
  
  String? _currentSessionTitle;

  // Credit System State
  static const int _strategyCost = 20;

  // Ticker State
  Timer? _tickerTimer;
  int _currentTickerIndex = 0;
  double _livePnL = 154.50; 
  List<Map<String, dynamic>> _tickerData = [
    {"symbol": "BTC", "price": 42350.00, "change": 1.2},
    {"symbol": "ETH", "price": 2240.50, "change": -0.5},
    {"symbol": "SOL", "price": 98.75, "change": 2.4},
    {"symbol": "BNB", "price": 305.20, "change": 0.1},
    {"symbol": "AXG", "price": 1305.50, "change": 5.1},
  ];

  @override
  bool get wantKeepAlive => true; // Prevent disposal on tab switch

  @override
  void initState() {
    super.initState();
    _startLiveTicker();
  }

  @override
  void dispose() {
    _saveCurrentSession();
    _tickerTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveCurrentSession() {
    if (_messages.isNotEmpty) {
      // Add current session to history
      final now = DateTime.now();
      HomeScreen.savedSessions.insert(0, {
        "id": now.millisecondsSinceEpoch,
        "title": _currentSessionTitle ?? "New Strategy Session",
        "date": "${_getMonth(now.month)} ${now.day} at ${now.hour}:${now.minute.toString().padLeft(2, '0')}", // e.g. Feb 19 at 14:30
        "messageCount": _messages.length,
        "isActive": false, // Mark as inactive when saved
      });
    }
  }

  String _getMonth(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  void _startLiveTicker() {
    _tickerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentTickerIndex = (_currentTickerIndex + 1) % _tickerData.length;
          for (var item in _tickerData) {
            double change = (DateTime.now().millisecond % 10 - 5) / 10;
            item["price"] += change;
            item["change"] += change / 100;
          }
          _livePnL += (DateTime.now().millisecond % 20 - 10) / 10;
        });
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final _credits = ref.read(paymentBalanceProvider).value?.balance.floor() ?? 0;

    if (_credits < _strategyCost) {
      _showLowCreditsDialog();
      return;
    }

    if (_messages.isEmpty) {
       _currentSessionTitle = text; // Use first message as title
    }

    setState(() {
      _isChatActive = true;
      _messages.add(_buildUserMessage(text));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate AI Response with dynamic logic
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final strategyCode = "STRAT_${DateTime.now().millisecondsSinceEpoch % 100000}";
        final String strategyName;
        final String pineCode;
        final String description;
        final String winRate;
        final String profitFactor;

        final input = text.toLowerCase();
        
        if (input.contains('bollinger') || input.contains('reversion')) {
          strategyName = "Bollinger Mean Reversion";
          description = "A standard mean reversion strategy using Bollinger Bands (20, 2). Enters long on lower band touch and short on upper band touch, optimized for Range-bound markets.";
          winRate = "68.5%";
          profitFactor = "2.10";
          pineCode = '''//@version=5
strategy("Bollinger Mean Reversion", overlay=true)
src = close
length = input.int(20, minval=1)
mult = input.float(2.0, minval=0.001, maxval=50)
basis = ta.sma(src, length)
dev = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev

if (ta.crossunder(src, lower))
    strategy.entry("BB Long", strategy.long)
if (ta.crossover(src, upper))
    strategy.entry("BB Short", strategy.short)''';
        } else if (input.contains('trend') || input.contains('breakout')) {
          strategyName = "Volatility Breakout Trend";
          description = "Trend-following system that uses ATR-based volatility channels to identify major momentum shifts. Best used during high liquidity sessions.";
          winRate = "54.2%";
          profitFactor = "4.25";
          pineCode = '''//@version=5
strategy("Volatility Breakout Trend", overlay=true)
atrLength = input(14, "ATR Length")
multiplier = input(3, "Multiplier")
atr = ta.atr(atrLength)
upBand = high + atr * multiplier
dnBand = low - atr * multiplier

if (close > upBand[1])
    strategy.entry("Trend Buy", strategy.long)
if (close < dnBand[1])
    strategy.entry("Trend Sell", strategy.short)''';
        } else {
          strategyName = "Institutional Alpha (MACD/RSI)";
          description = "Combines MACD momentum with RSI oversold/overbought filters to capture high-probability institutional pivots.";
          winRate = "82.4%";
          profitFactor = "3.15";
          pineCode = '''//@version=5
strategy("Institutional Alpha", overlay=true)
rsiVal = ta.rsi(close, 14)
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)

if (ta.crossover(macdLine, signalLine) and rsiVal < 30)
    strategy.entry("Long", strategy.long)
if (ta.crossunder(macdLine, signalLine) and rsiVal > 70)
    strategy.entry("Short", strategy.short)''';
        }
        
        setState(() {
          _isLoading = false;
          _messages.add(
            StrategyResponseCard(
              title: strategyName,
              description: description,
              winRate: winRate,
              profitFactor: profitFactor,
              codeSnippet: pineCode,
              onBacktest: () => _showBacktestOverlay(strategyCode, strategyName, pineCode), 
            ),
          );
        });
        _scrollToBottom();
        
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _showBacktestOverlay(strategyCode, strategyName, pineCode);
        });
      }
    });
  }



  void _showBacktestOverlay(String strategyCode, String strategyName, String pineCode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          color: AppColors.cardSurface,
          opacity: 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.science_outlined, color: AppColors.cyan, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Ready to Validate?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Run a backtest on historical data to verify this strategy's performance before deploying.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                         Navigator.pop(context); // Close dialog
                         Navigator.push(
                           context, 
                           MaterialPageRoute(builder: (context) => BacktestConfigScreen(
                             strategyCode: strategyCode,
                             strategyName: strategyName,
                             pineCode: pineCode, // Assume we pass it here
                           ))
                         );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Start Backtest"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLowCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          color: AppColors.cardSurface,
          opacity: 0.95,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on_outlined, color: AppColors.gold, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Insufficient Credits",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Strategy generation requires 20 Credits.\nPlease purchase more credits to continue using AI features.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Close dialog
                    final newCredits = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreditsStoreScreen()),
                    );
                    
                    if (newCredits != null && newCredits is int) {
                      ref.read(paymentBalanceProvider.notifier).refresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Success! Added $newCredits Credits.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Purchase Credits"),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Later",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cyan.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white70),
              onPressed: () {
                final ScaffoldState? root = context.findRootAncestorStateOfType<ScaffoldState>();
                root?.openDrawer();
              },
            );
          },
        ),
        title: _buildAnimatedCoinTicker(), 
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(child: _buildLivePnL()),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ProfileAvatar(radius: 16),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
             // Minimal Header Row (Credits)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                   _buildCreditBalance(),
                ],
              ),
            ),

            Expanded(
              child: _messages.isEmpty 
                ? _buildWelcomeCenter() 
                : _buildChatList(),
            ),

            // Persistent Input Area (Always Visible)
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
       controller: _scrollController,
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
       itemCount: _messages.length + (_isLoading ? 1 : 0),
       itemBuilder: (context, index) {
         if (index == _messages.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyan)),
            );
         }
         return _messages[index];
       },
    );
  }

  Widget _buildWelcomeCenter() {
     return LayoutBuilder(
       builder: (context, constraints) {
         return SingleChildScrollView(
           child: ConstrainedBox(
             constraints: BoxConstraints(minHeight: constraints.maxHeight),
             child: IntrinsicHeight(
               child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
                 child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Spacer(),
                       const Icon(
                         Icons.insights,
                         size: 36,
                         color: AppColors.cyan,
                       ),
              const SizedBox(height: 16),
              const Text(
                 "Algorithmic Trading,\nDemocratized.",
                 style: TextStyle(
                   color: Colors.white, 
                   fontSize: 24, 
                   fontWeight: FontWeight.w800, 
                   letterSpacing: -0.5, 
                   height: 1.2
                 ),
                 textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                 "Institutional-grade algorithmic power for retail traders.\nDesign, backtest, and deploy sophisticated strategies.",
                 style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
                 textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: AppColors.gold, size: 14),
                    SizedBox(width: 8),
                    Text("Only 20 Credits / Generation", style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Suggestions
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "EXAMPLE STRATEGIES", 
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0)
                ),
              ),

              const SizedBox(height: 6),
              _buildSuggestionPrompt("Long BTC when RSI < 30 and MACD crosses up"),
              const SizedBox(height: 6),
              _buildSuggestionPrompt("Mean reversion using Bollinger Bands on ETH 15m"),
              const SizedBox(height: 24),
                 
                 // Deep Marketing Addictive Nudge
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   decoration: BoxDecoration(
                     color: const Color(0xFF0F172A), // Dark navy
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.white.withOpacity(0.05)),
                   ),
                   child: Row(
                     children: [
                       Icon(Icons.trending_up, color: AppColors.green.withOpacity(0.8), size: 18),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text(
                               "Why use CryptoArth AI?",
                               style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                             ),
                             const SizedBox(height: 2),
                             Text(
                               "Traders using our backtested AI models see on average a 43% increase in win-rate.",
                               style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, height: 1.4),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
                 const Spacer(),
              ],
           ),
        ),
             ),
           ),
         );
       },
     );
  }

  Widget _buildInputArea() {
     return Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
        decoration: BoxDecoration(
           color: AppColors.background,
           border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Column(
          children: [
            // Prompt Modifiers for Retail Traders
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPromptModifierChip(Icons.bolt, "Scalping", AppColors.gold),
                  _buildPromptModifierChip(Icons.shield_outlined, "Low Risk", AppColors.cyan),
                  _buildPromptModifierChip(Icons.show_chart, "Trend Following", AppColors.green),
                  _buildPromptModifierChip(Icons.monetization_on_outlined, "High Yield", AppColors.purple),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GlassContainer(
               borderRadius: 20,
               color: AppColors.cardSurface,
               opacity: 0.6,
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
               child: Row(
                  children: [
                     Expanded(
                        child: TextField(
                           controller: _controller,
                           style: const TextStyle(color: Colors.white, fontSize: 14),
                           onSubmitted: (_) => _sendMessage(),
                           decoration: InputDecoration(
                              hintText: "Build a strategy... (e.g. 'RSI < 30 buy')",
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                           ),
                        ),
                     ),
                     IconButton(
                        icon: const Icon(Icons.mic_none, color: Colors.white38),
                        onPressed: () {},
                     ),
                     Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                           color: AppColors.cyan.withOpacity(0.8),
                           borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                           icon: const Icon(Icons.send, color: Colors.black, size: 16),
                           onPressed: _sendMessage,
                        ),
                     ),
                  ],
               ),
            ),
          ],
        ),
     );
  }

  Widget _buildPromptModifierChip(IconData icon, String label, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          _controller.text = "${_controller.text} $label".trim();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditBalance() {
    final balanceModel = ref.watch(paymentBalanceProvider).value;
    final _credits = balanceModel?.balance.floor() ?? 0;

    return GestureDetector(
      onTap: () async {
        final newCredits = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreditsStoreScreen()),
        );
        if (newCredits != null && newCredits is int) {
          ref.read(paymentBalanceProvider.notifier).refresh();
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on_outlined, size: 16, color: AppColors.gold.withOpacity(0.8)),
          const SizedBox(width: 6),
          Text(
            "$_credits Credits",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.add_circle_outline, size: 12, color: AppColors.cyan.withOpacity(0.6)),
        ],
      ),
    );
  }

  Widget _buildSuggestionPrompt(String text) {
    return InkWell(
      onTap: () {
        _controller.text = text;
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 16, color: Colors.white.withOpacity(0.5)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePnL() {
    return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       decoration: BoxDecoration(
         color: _livePnL >= 0 ? AppColors.green.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
         borderRadius: BorderRadius.circular(12),
         border: Border.all(
           color: _livePnL >= 0 ? AppColors.green.withOpacity(0.5) : Colors.redAccent.withOpacity(0.5),
           width: 1
         ),
       ),
       child: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           Icon(
             _livePnL >= 0 ? Icons.trending_up : Icons.trending_down, 
             size: 12, 
             color: _livePnL >= 0 ? AppColors.green : Colors.redAccent
           ),
           const SizedBox(width: 4),
           Text(
             "${_livePnL >= 0 ? '+' : ''}\$${_livePnL.toStringAsFixed(2)}",
             style: TextStyle(
               fontWeight: FontWeight.bold,
               fontSize: 10,
               color: _livePnL >= 0 ? AppColors.green : Colors.redAccent,
             ),
           ),
         ],
       ),
    );
  }

  Widget _buildAnimatedCoinTicker() {
    final data = _tickerData[_currentTickerIndex];
    final double change = data['change'];
    final bool isPositive = change >= 0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
      },
      child: Container(
        key: ValueKey<String>(data['symbol']),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data['symbol'],
              style: const TextStyle(
                color: AppColors.cyan, 
                fontSize: 12, 
                fontWeight: FontWeight.w900
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "\$${data['price'].toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              "${change.abs().toStringAsFixed(1)}%",
              style: TextStyle(
                color: isPositive ? AppColors.green : Colors.redAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}
