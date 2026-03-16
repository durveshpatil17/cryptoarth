import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

class TourStep {
  final String title;
  final String? subtitle;
  final List<String> bulletPoints;
  final String? tip;
  final String? warning;
  final String contentTitle;

  TourStep({
    required this.title,
    this.subtitle,
    this.bulletPoints = const [],
    this.tip,
    this.warning,
    required this.contentTitle,
  });
}

class AppTour extends StatefulWidget {
  final VoidCallback onFinish;
  const AppTour({super.key, required this.onFinish});

  @override
  State<AppTour> createState() => _AppTourState();
}

class _AppTourState extends State<AppTour> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<TourStep> _steps = [
    TourStep(
      title: "Welcome to Crypto Arth! 🚀",
      subtitle: "Let's take a quick tour to help you get started with trading bots and strategies.",
      contentTitle: "This tour will guide you through the essential steps to start trading:",
      bulletPoints: [
        "Connect your broker account",
        "Browse and activate trading strategies",
        "Monitor your positions and profits"
      ],
    ),
    TourStep(
      title: "Step 1: Dashboard Overview",
      subtitle: "Your main control center for all trading activities.",
      contentTitle: "Welcome to your Dashboard! This is your main control center.",
      bulletPoints: [
        "Your account balance and margin",
        "Active strategies and positions",
        "Market Place to browse strategies",
        "Quick stats and performance metrics"
      ],
      tip: "Use the sidebar menu to navigate to different sections.",
    ),
    TourStep(
      title: "Step 2: Connect Your Broker",
      subtitle: "First, you need to connect your crypto exchange broker account to start trading.",
      contentTitle: "Click on \"Broker Login\" from the sidebar menu to connect your exchange account.",
      bulletPoints: [
        "Delta Exchange",
        "CoinDCX"
      ],
      warning: "You must connect a broker before activating any trading strategies.",
    ),
    TourStep(
      title: "Step 3: Browse Strategies",
      subtitle: "Explore available trading strategies in the Market Place.",
      contentTitle: "Go to \"Market Place\" tab on your dashboard to see all available trading strategies.",
      bulletPoints: [
        "Strategy name and creator",
        "Expected returns and risk level",
        "Trading symbol and description"
      ],
      tip: "Read strategy details carefully before activating.",
    ),
    TourStep(
      title: "Step 4: Activate a Strategy",
      subtitle: "Activate a trading strategy to start automated trading.",
      contentTitle: "Click the \"Activate\" button on any strategy card to start automated trading.",
      bulletPoints: [
        "Your broker is connected",
        "You have sufficient margin (at least 30% free)",
        "You understand the strategy's risk level"
      ],
      warning: "Always keep at least 30% margin free for safety.",
    ),
    TourStep(
      title: "Step 5: Monitor Your Positions",
      subtitle: "Keep track of your active trades and profits.",
      contentTitle: "Use \"Open Position\" to monitor all your active trades in real-time.",
      bulletPoints: [
        "Current profit/loss for each position",
        "Entry price vs current market price",
        "Strategy name and broker information"
      ],
      tip: "Check positions regularly, especially during market hours.",
    ),
    TourStep(
      title: "Step 6: Close Positions",
      subtitle: "Close your active trading positions when needed.",
      contentTitle: "Use \"Close Position\" to manually close any active trading position.",
      bulletPoints: [
        "View all open positions",
        "Close individual positions",
        "See profit/loss before closing",
        "Close all positions at once"
      ],
      warning: "Closing a position will stop trading for that strategy on that broker.",
    ),
    TourStep(
      title: "Step 7: Order Book",
      subtitle: "View all your trading orders and their status.",
      contentTitle: "Check \"Order Book\" to see all your trading orders, including executed and pending orders.",
      bulletPoints: [
        "All buy and sell orders",
        "Order status (executed, pending, cancelled)",
        "Entry and exit prices",
        "Order timestamps"
      ],
      tip: "Review your order history to track trading performance.",
    ),
    TourStep(
      title: "Step 8: P&L Report",
      subtitle: "Analyze your profit and loss statements.",
      contentTitle: "Access \"P&L Report\" to view detailed profit and loss analysis for your trading activities.",
      bulletPoints: [
        "Daily, weekly, monthly P&L",
        "Strategy-wise performance",
        "Broker-wise breakdown",
        "Downloadable PDF reports"
      ],
      tip: "Use P&L reports to track your trading performance over time.",
    ),
    TourStep(
      title: "Step 9: Create Your Strategy",
      subtitle: "Build your own custom trading strategy.",
      contentTitle: "Use \"Create Strategy\" to build your own custom trading strategy with your preferred settings.",
      bulletPoints: [
        "Trading symbol and strategy name",
        "Entry and exit times",
        "Risk level and capital requirement",
        "Target and stop loss levels"
      ],
      warning: "Test your strategy thoroughly before deploying with real funds.",
    ),
    TourStep(
      title: "Step 10: View Your Strategies",
      subtitle: "Manage and edit all your created strategies.",
      contentTitle: "Go to \"View Strategy\" to see, edit, and manage all your created trading strategies.",
      bulletPoints: [
        "View all your strategies",
        "Edit strategy parameters",
        "Activate or deactivate strategies",
        "Delete unused strategies"
      ],
      tip: "Keep your strategy list organized for better management.",
    ),
    TourStep(
      title: "Step 11: Trade Signal Scanner",
      subtitle: "Scan the market for trading opportunities.",
      contentTitle: "Use \"Scanner\" to scan the market for potential trading signals and opportunities.",
      bulletPoints: [
        "Find trading opportunities",
        "Analyze market signals",
        "Filter by symbols and timeframes",
        "Get real-time market alerts"
      ],
      tip: "Use scanner to discover new trading opportunities.",
    ),
    TourStep(
      title: "Step 12: Margin Calculator",
      subtitle: "Calculate required margin for your trades.",
      contentTitle: "Access \"Margin\" calculator to determine how much margin you need for your trading positions.",
      bulletPoints: [
        "Required margin for positions",
        "Available margin balance",
        "Margin utilization percentage",
        "Risk assessment"
      ],
      warning: "Always maintain at least 30% free margin for safety.",
    ),
    TourStep(
      title: "Step 13: Tutorial & Help",
      subtitle: "Learn more with detailed tutorials and guides.",
      contentTitle: "Visit \"Tutorial\" for comprehensive guides, video tutorials, and step-by-step instructions.",
      bulletPoints: [
        "Video tutorials",
        "Step-by-step guides",
        "Common mistakes to avoid",
        "Best practices"
      ],
      tip: "Refer to tutorials whenever you need help.",
    ),
    TourStep(
      title: "Step 14: Contact Support",
      subtitle: "Get help from our support team.",
      contentTitle: "Use \"Contact Us\" to reach out to our support team for any questions or issues.",
      bulletPoints: [
        "Submit support tickets",
        "Live chat (if available)",
        "Email support",
        "FAQ section"
      ],
      tip: "Our support team is here to help you succeed.",
    ),
    TourStep(
      title: "You're All Set! 🎉",
      subtitle: "You now know the basics. Start trading and grow your portfolio!",
      contentTitle: "Congratulations! You've completed the tour. Here are some quick tips:",
      bulletPoints: [
        "Start with low-risk strategies if you're a beginner",
        "Monitor your positions at least twice daily",
        "Never use 100% of your margin - keep a safety buffer",
        "Check the Tutorial section for detailed guides"
      ],
      tip: "Happy Trading! 🚀",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    final cardColor = AppColors.getCardSurface(context);
    final totalSteps = 16; // As per screenshots "Step X of 16"
    final currentStep = _currentIndex + 1;
    final progress = currentStep / totalSteps;
    final percent = (progress * 100).toInt();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cyan.withOpacity(0.2), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Flexible(
                  child: PageView.builder(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      return _buildStepContent(_steps[index]);
                    },
                  ),
                ),
                _buildFooter(currentStep, totalSteps, percent, progress),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _steps[_currentIndex].title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onFinish,
            icon: Icon(Icons.close, color: Colors.white.withOpacity(0.3), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(TourStep step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (step.subtitle != null) ...[
            Text(
              step.subtitle!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.contentTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...step.bulletPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.green, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          point,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          if (step.tip != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.tip!,
                    style: const TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
          if (step.warning != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.warning!,
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(int currentStep, int totalSteps, int percent, double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Step $currentStep of $totalSteps",
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Text(
                "$percent% Complete",
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_currentIndex > 0)
                _buildNavButton(
                  icon: Icons.arrow_back,
                  label: "Previous",
                  onPressed: () {
                    _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                ),
              if (_currentIndex == 0)
                const Spacer(),
              const Spacer(),
              TextButton(
                onPressed: widget.onFinish,
                child: Text(
                  "Skip Tour",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              _buildPrimaryButton(
                label: _currentIndex == _steps.length - 1 ? "Finish" : "Next",
                onPressed: () {
                  if (_currentIndex < _steps.length - 1) {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  } else {
                    widget.onFinish();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.6), size: 16),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cyan,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16),
        ],
      ),
    );
  }
}
