import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/profile_avatar.dart';
import 'package:cryptoarth/shared/widgets/strategy_response_card.dart';
import 'package:cryptoarth/features/strategies/screens/backtest_config_screen.dart';
import 'package:cryptoarth/features/credits/screens/credits_store_screen.dart';

import 'package:cryptoarth/features/strategies/screens/templates_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/providers/copilot_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/pnl_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/watchlist_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/portfolio_provider.dart';
import 'package:cryptoarth/features/broker/providers/broker_balance_provider.dart';
import 'package:cryptoarth/core/utils/time_utils.dart';
import 'package:cryptoarth/features/home/screens/chat_history_screen.dart';
import 'package:cryptoarth/features/strategies/screens/code_generator_screen.dart';
import 'package:cryptoarth/features/strategies/screens/execution_history_screen.dart';

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

  // Ticker Logic
  Timer? _tickerTimer;
  int _currentTickerIndex = 0;

  // Carousel Logic
  int _currentCarouselIndex = 0;
  final PageController _pageController = PageController();
  Timer? _carouselTimer;

  @override
  bool get wantKeepAlive => true; // Prevent disposal on tab switch

  @override
  void initState() {
    super.initState();
    _startLiveTicker();
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        final nextIndex = (_currentCarouselIndex + 1) % 4; // Based on homeBlueprints.length
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _saveCurrentSession();
    _tickerTimer?.cancel();
    _carouselTimer?.cancel();
    _pageController.dispose();
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
      body: Stack(
        children: [
          // Background Depth Effects
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Precisely Aligned Top Nav
                _buildTopNav(),
                
                const SizedBox(height: 16),
                
                // Precisely Aligned Account Ribbon
                _buildAccountRibbon(),
                
                const SizedBox(height: 32),

                Expanded(
                  child: chatState.when(
                    data: (messages) => messages.isEmpty 
                      ? _buildWelcomeCenter() 
                      : _buildChatList(messages, false),
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
                    error: (err, stack) => _buildErrorState(err.toString()),
                  ),
                ),

                // Floating Input (Only when active chat)
                if (chatState.value != null && chatState.value!.isNotEmpty)
                   _buildFloatingInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white70),
        onPressed: () {
          final ScaffoldState? root = context.findRootAncestorStateOfType<ScaffoldState>();
          root?.openDrawer();
        },
      ),
      title: const Text(
        "AI Builder",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_outlined, color: AppColors.cyan, size: 24),
          onPressed: _showAISettingsMenu,
          tooltip: "AI Strategy Builder Settings",
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showAISettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassContainer(
        borderRadius: 32,
        color: AppColors.background,
        opacity: 0.95,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "AI BUILDER SETTINGS",
              style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 24),
            _buildSettingsItem(Icons.chat_bubble_outline, "New Chat", () {
              Navigator.pop(context);
              ref.read(copilotProvider.notifier).startNewChat();
            }),
            _buildSettingsItem(Icons.science_outlined, "Backtest", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BacktestConfigScreen()));
            }),
            _buildSettingsItem(Icons.code, "Code Generator", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CodeGeneratorScreen()));
            }),
            _buildSettingsItem(Icons.history_outlined, "Chat History", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatHistoryScreen()));
            }),
            _buildSettingsItem(Icons.list_alt_outlined, "Execution History", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ExecutionHistoryScreen()));
            }),
            _buildSettingsItem(Icons.dashboard_customize_outlined, "Templates", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TemplatesScreen()));
            }),
            _buildSettingsItem(Icons.monetization_on_outlined, "Credits", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreditsStoreScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white10, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildAccountRibbon() {
    final brokerBalance = ref.watch(brokerBalanceProvider).value?.balance ?? 0.0;
    final credits = ref.watch(paymentBalanceProvider).value?.balance.floor() ?? 0;
    final todayPnL = ref.watch(pnlProvider).value?.todayProfit ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.035)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildRibbonItem("PORTFOLIO", "\$${brokerBalance.toStringAsFixed(0)}", Colors.white),
          Container(width: 1, height: 16, color: Colors.white.withOpacity(0.06)),
          _buildRibbonItem("TODAY PNL", "${todayPnL >= 0 ? '+' : ''}\$${todayPnL.toStringAsFixed(1)}", todayPnL >= 0 ? AppColors.green : Colors.redAccent),
          Container(width: 1, height: 16, color: Colors.white.withOpacity(0.06)),
          _buildRibbonItem("CREDITS", "$credits", AppColors.gold),
        ],
      ),
    );
  }

  Widget _buildRibbonItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 16),
          Text("Something went wrong", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
          TextButton(onPressed: () => ref.invalidate(copilotProvider), child: const Text("Tap to retry")),
        ],
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

  // Cleaned up redundant builders...

  Widget _buildWelcomeCenter() {
     return SingleChildScrollView(
       physics: const BouncingScrollPhysics(),
       padding: const EdgeInsets.symmetric(horizontal: 24),
       child: Column(
         children: [
            const SizedBox(height: 48),
            
            // Hero Title: Precision Scaled
            ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
              child: const Text(
                "Build Your Alpha.",
                style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.2, height: 1.1),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Describe your trading idea.\nAI handles code and execution.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 48),

            // Precisely Refined Command Bar
            _buildCommandIsland(),

            const SizedBox(height: 32),

            // Premium Decorative Blueprint Carousel
            _buildBlueprintCarousel(),

            const SizedBox(height: 80),
         ],
       ),
     );
  }

  void _handleTemplateSelection() async {
     final String? selectedPrompt = await Navigator.push(
       context, 
       MaterialPageRoute(builder: (context) => const TemplatesScreen())
     );
     
     if (selectedPrompt != null && mounted) {
       setState(() {
         _controller.text = selectedPrompt;
       });
       // Focus the input automatically
       // (Assuming FocusNode would be better but simple setState works for now given the architecture)
     }
  }

  Widget _buildCommandIsland() {
    return Container(
      height: 64,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 40, offset: const Offset(0, 12)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(Icons.add, color: Colors.white.withOpacity(0.2), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: "Describe a strategy...",
                hintStyle: TextStyle(color: Colors.white24, fontSize: 14, fontWeight: FontWeight.w400),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_upward, color: Colors.black, size: 20),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildFloatingBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () => _controller.text = text,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalTemplatePreview() {
    // A very high-end looking single card preview
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_graph, color: AppColors.cyan, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Trend Reversal V2", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Text("High accuracy mean reversion logic", style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
        ],
      ),
    );
  }

  Widget _buildFloatingInputArea() {
     return ClipRect(
       child: BackdropFilter(
         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
         child: Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            decoration: BoxDecoration(
               color: AppColors.background.withOpacity(0.8),
            ),
            child: _buildCommandIsland(),
         ),
       ),
     );
  }

  Widget _buildStatusBadge(String text, Color color) {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
       decoration: BoxDecoration(
         color: color.withOpacity(0.1),
         borderRadius: BorderRadius.circular(4),
         border: Border.all(color: color.withOpacity(0.3)),
       ),
       child: Text(
         text, 
         style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)
       ),
     );
  }

  Widget _buildBlueprintCarousel() {
     final List<Map<String, dynamic>> homeBlueprints = [
        {"name": "EMA Crossover Pro", "icon": Icons.timeline, "prompt": "Create a trading strategy using EMA crossover: Fast EMA 9, Slow EMA 21, Buy when fast crosses above slow, Sell when fast crosses below slow, Timeframe 5m, Risk per trade 1%, Max trades per day 5, Trailing SL 10"},
        {"name": "Bollinger Reversal", "icon": Icons.waves, "prompt": "Create Bollinger Bands strategy: Period 20, Deviation 2, Buy when price touches lower band and closes above, Sell when price touches upper band and closes below, TF 15m, Risk 1%, Max trades 4/day, Trailing SL 10 points"},
        {"name": "EMA RSI MACD", "icon": Icons.hub_outlined, "prompt": "Create multi indicator strategy using EMA 20, RSI 14 and MACD: Buy when EMA bullish, RSI above 50 and MACD positive, Sell opposite, TF 5m, Risk 1%, Max trades 4/day, Trailing SL 10 points, Loss limit 3%, Profit target 6%"},
        {"name": "RSI Reversal", "icon": Icons.auto_graph, "prompt": "Build an RSI based strategy: RSI 14, Buy when RSI crosses above 30, Sell when RSI crosses below 70, Timeframe 15m, Risk per trade 1.5%, Max trades per day 4, Trailing SL 12 points, Daily loss limit 3%, Daily profit 6%"},
     ];

     return Column(
        children: [
           SizedBox(
              height: 120,
              child: PageView.builder(
                 controller: _pageController,
                 onPageChanged: (index) => setState(() => _currentCarouselIndex = index),
                 itemCount: homeBlueprints.length,
                 itemBuilder: (context, index) {
                    return _buildDecorativeBlueprintCard(homeBlueprints[index]);
                 },
              ),
           ),
           const SizedBox(height: 16),
           // Modern Pagination Dots
           Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(homeBlueprints.length, (index) {
                 final bool isActive = _currentCarouselIndex == index;
                 return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    width: isActive ? 20 : 6,
                    decoration: BoxDecoration(
                       color: isActive ? AppColors.cyan : Colors.white.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(2),
                    ),
                 );
              }),
           ),
           const SizedBox(height: 24),
           // "More Templates" Action Button
           InkWell(
              onTap: _handleTemplateSelection,
              child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                 decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                 ),
                 child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Text(
                          "Explore More Blueprints", 
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold)
                       ),
                       const SizedBox(width: 8),
                       Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.2), size: 10),
                    ],
                 ),
              ),
           ),
        ],
     );
  }

  Widget _buildDecorativeBlueprintCard(Map<String, dynamic> blueprint) {
     return InkWell(
        onTap: () {
           setState(() {
              _controller.text = blueprint['prompt'];
           });
        },
        child: Container(
           width: double.infinity,
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
              ],
           ),
           child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                       color: AppColors.cyan.withOpacity(0.05),
                       shape: BoxShape.circle,
                    ),
                    child: Icon(blueprint['icon'], color: AppColors.cyan, size: 16),
                 ),
                 const SizedBox(height: 12),
                 Text(
                    blueprint['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.2),
                 ),
                 const SizedBox(height: 4),
                 Text(
                    "Prompt Blueprint",
                    style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                 ),
              ],
           ),
        ),
     );
  }

  Widget _buildBubbleChip(String text) {
     return InkWell(
       onTap: () => _controller.text = text,
       borderRadius: BorderRadius.circular(20),
       child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
         decoration: BoxDecoration(
           color: Colors.white.withOpacity(0.03),
           borderRadius: BorderRadius.circular(20),
           border: Border.all(color: Colors.white.withOpacity(0.1)),
         ),
         child: Text(
           text,
           style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
         ),
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
