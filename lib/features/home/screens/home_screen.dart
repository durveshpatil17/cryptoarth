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
import 'package:cryptoarth/features/strategies/providers/copilot_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/pnl_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/watchlist_provider.dart';
import 'package:cryptoarth/core/utils/time_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  // Persisted Chat History (Static for simple cross-screen access)

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _currentSessionTitle;

  // Credit System State

  // Ticker State
  Timer? _tickerTimer;
  int _currentTickerIndex = 0;

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
    // Note: Backend handles session history now.
    // Local static list in HomeScreen is deprecated but keeping for now as per navigation logic if needed.
  }

  String _getMonth(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  void _startLiveTicker() {
    _tickerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        final watchlist = ref.read(watchlistProvider).value ?? [];
        if (watchlist.isNotEmpty) {
          setState(() {
            _currentTickerIndex = (_currentTickerIndex + 1) % watchlist.length;
          });
        }
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref.read(copilotProvider.notifier).sendMessage(text);
    _controller.clear();
    _scrollToBottom();
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
    final chatState = ref.watch(copilotProvider);
    
    ref.listen(copilotProvider, (prev, next) {
      if (next.hasValue && prev?.value?.length != next.value?.length) {
        _scrollToBottom();
      }
    });

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
          Center(child: _buildCreditBalance()),
          const SizedBox(width: 12),
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
            Expanded(
              child: chatState.when(
                data: (messages) => messages.isEmpty 
                  ? _buildWelcomeCenter() 
                  : _buildChatList(messages, false),
                loading: () {
                   return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
                },
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text("Failed to send message: $err", style: const TextStyle(color: Colors.white70)),
                      TextButton(onPressed: () => ref.invalidate(copilotProvider), child: const Text("Retry")),
                    ],
                  ),
                ),
              ),
            ),

            // Persistent Input Area (Always Visible)
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(List<Map<String, dynamic>> messages, bool isActuallyLoading) {
    final notifier = ref.read(copilotProvider.notifier);
    final showLoading = ref.watch(copilotProvider).isLoading || notifier.isGenerating;
    
    return ListView.builder(
       controller: _scrollController,
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
       itemCount: messages.length + (showLoading ? 1 : 0),
       itemBuilder: (context, index) {
         if (index == messages.length) {
            if (notifier.isGenerating) {
              return _buildGeneratingBubble();
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyan)),
            );
         }
         final message = messages[index];
         final bool isUser = message['role'] == 'user';
         
         if (isUser) {
           return _buildUserMessage(message['content'] ?? '');
         } else {
           return _buildAssistantMessage(message);
         }
       },
    );
  }

  Widget _buildGeneratingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "AI is generating your strategy...",
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
            const SizedBox(width: 12),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantMessage(Map<String, dynamic> message) {
    final String text = message['content'] ?? '';
    
    final hasStructuredData =
        (message["python"] is String && message["python"].toString().isNotEmpty) ||
        (message["pine_script"] is String && message["pine_script"].toString().isNotEmpty) ||
        (message["strategy_json"] is Map) ||
        (message["backtest_result"] is Map) ||
        (message["metrics"] is Map);

    // If structured data exists (synced from history) or text contains strategy code
    if (hasStructuredData || (text.contains('strategy(') && text.contains('//@version='))) {
      return StrategyResponseCard(message: message);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
        ),
      ),
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
    final balanceAsync = ref.watch(paymentBalanceProvider);

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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: balanceAsync.when(
          data: (balanceModel) {
            final int credits = balanceModel?.balance.floor() ?? 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on_outlined, size: 14, color: AppColors.gold.withOpacity(0.8)),
                const SizedBox(width: 6),
                Text(
                  "Available: $credits",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.add_circle_outline, size: 10, color: AppColors.cyan.withOpacity(0.6)),
              ],
            );
          },
          loading: () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold.withOpacity(0.5)),
              ),
              const SizedBox(width: 8),
              Text(
                "Loading...",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
            ],
          ),
          error: (e, s) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 12, color: Colors.redAccent),
              const SizedBox(width: 4),
              Text(
                "Error",
                style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 11),
              ),
            ],
          ),
        ),
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
    final pnlModel = ref.watch(pnlProvider).value;
    final double livePnL = (pnlModel?.todayProfit ?? 0.0).toDouble();

    return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       decoration: BoxDecoration(
         color: livePnL >= 0 ? AppColors.green.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
         borderRadius: BorderRadius.circular(12),
         border: Border.all(
           color: livePnL >= 0 ? AppColors.green.withOpacity(0.5) : Colors.redAccent.withOpacity(0.5),
           width: 1
         ),
       ),
       child: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           Icon(
             livePnL >= 0 ? Icons.trending_up : Icons.trending_down, 
             size: 12, 
             color: livePnL >= 0 ? AppColors.green : Colors.redAccent
           ),
           const SizedBox(width: 4),
           Text(
             "${livePnL >= 0 ? '+' : ''}\$${livePnL.toStringAsFixed(2)}",
             style: TextStyle(
               fontWeight: FontWeight.bold,
               fontSize: 10,
               color: livePnL >= 0 ? AppColors.green : Colors.redAccent,
             ),
           ),
         ],
       ),
    );
  }

  Widget _buildAnimatedCoinTicker() {
    final watchlist = ref.watch(watchlistProvider).value ?? [];
    if (watchlist.isEmpty) {
      return const Text("CryptoArth", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16));
    }

    final data = watchlist[_currentTickerIndex % watchlist.length];
    final String symbol = data['symbol'] ?? data['name'] ?? 'UNKNOWN';
    final double price = num.tryParse(data['ltp']?.toString() ?? '0')?.toDouble() ?? 0.0;
    final double change = num.tryParse(data['change']?.toString() ?? '0')?.toDouble() ?? 0.0;
    final bool isPositive = change >= 0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
      },
      child: Container(
        key: ValueKey<String>(symbol),
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
              symbol,
              style: const TextStyle(
                color: AppColors.cyan, 
                fontSize: 12, 
                fontWeight: FontWeight.w900
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "\$${price.toStringAsFixed(2)}",
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
