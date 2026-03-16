import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';
import 'package:flutter/services.dart';

class WebhookScreen extends StatefulWidget {
  const WebhookScreen({super.key});

  @override
  State<WebhookScreen> createState() => _WebhookScreenState();
}

class _WebhookScreenState extends State<WebhookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text(
          "WEBHOOK INTEGRATION",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 2.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LuxuryBackground(
        child: Column(
          children: [
            _buildTabHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSetupGuide(),
                  _buildExamples(),
                  _buildParameters(),
                  _buildCryptoBroker(),
                  _buildSupport(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppColors.primary.withOpacity(0.2),
          border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
        ),
        labelColor: AppColors.cyan,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: "SETUP GUIDE"),
          Tab(text: "EXAMPLES"),
          Tab(text: "PARAMETERS"),
          Tab(text: "CRYPTOBROKER"),
          Tab(text: "SUPPORT"),
        ],
      ),
    );
  }

  Widget _buildSetupGuide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(
            "Webhook Integration",
            "Plug your TradingView alerts and Python strategy signals into any supported exchange and auto-execute every trade.",
          ),
          const SizedBox(height: 32),
          _buildActionCard(
            "How to integrate",
            [
              "1. Deploy a strategy in Marketplace (set to Manual or Copy).",
              "2. Copy strategy_code from the strategy card.",
              "3. Send POST to https://trade-api.cryptoarth.in/auth/signal/ with JSON body.",
              "4. Use TradingView alert, Python, curl, or any HTTP client.",
            ],
            icon: Icons.electrical_services_outlined,
          ),
          const SizedBox(height: 24),
          _buildIntegrationSteps(),
          const SizedBox(height: 24),
          _buildSignalEndpoints(),
          const SizedBox(height: 24),
          _buildProductionWebhookSection(),
          const SizedBox(height: 24),
          _buildTradingViewInstructions(),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(String title, String subtitle) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
            ),
            child: const Text(
              "UNIFIED API TRADING BRIDGE",
              style: TextStyle(color: AppColors.cyan, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, List<String> steps, {required IconData icon}) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      color: AppColors.cardSurface,
      opacity: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.cyan, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  step,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.5),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildIntegrationSteps() {
    return Column(
      children: [
        Row(
          children: [
            _buildStepItem("01", "Get Your Webhook URL", Icons.link, "Copy your unique webhook URL from below"),
            const SizedBox(width: 12),
            _buildStepItem("02", "Configure TradingView", Icons.show_chart, "Add the webhook URL to your alert settings"),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStepItem("03", "Set Alert Conditions", Icons.query_stats_outlined, "Define your trading strategy/conditions in TradingView"),
            const SizedBox(width: 12),
            _buildStepItem("04", "Start Trading Auto", Icons.rocket_launch_outlined, "Your alerts will execute trades on connected exchange"),
          ],
        ),
      ],
    );
  }

  Widget _buildStepItem(String number, String title, IconData icon, String desc) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        color: Colors.black,
        opacity: 0.3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.cyan.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text(number, style: const TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                Icon(icon, color: AppColors.cyan.withOpacity(0.5), size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalEndpoints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Signal Endpoints",
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 16),
        _buildEndpointItem("1. External (Webhook)", "https://trade-api.cryptoarth.in/auth/signal/", "TradingView, Python, any HTTP client. JSON body. Strategy must be Manual or Copy."),
        const SizedBox(height: 12),
        _buildEndpointItem("2. Copy Signal", "https://trade-api.cryptoarth.in/auth/copy-signal/", "Copy-trade signal providers. JSON format. Strategy must be Copy."),
      ],
    );
  }

  Widget _buildEndpointItem(String title, String url, String desc) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      color: Colors.black,
      opacity: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
            child: Text(url, style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace')),
          ),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildProductionWebhookSection() {
    const url = "https://trade-api.cryptoarth.in/auth/signal/";
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      color: AppColors.cardSurface,
      opacity: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, color: AppColors.green, size: 20),
              const SizedBox(width: 12),
              const Text("Production Webhook URL", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: const Text(url, style: TextStyle(color: AppColors.green, fontSize: 11, fontFamily: 'monospace')),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Webhook URL copied"), duration: Duration(seconds: 1)));
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text("Copy Webhook URL"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white10)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.cyan.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cyan.withOpacity(0.1))),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.cyan, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("Deploy your strategy in Marketplace first. Connect broker before use.", style: TextStyle(color: AppColors.cyan.withOpacity(0.7), fontSize: 9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingViewInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TradingView Setup Instructions", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTvStep(1, "Create Trading Bot in Crypto Arth", "Deploy a strategy in manual/copy mode and copy the strategy_code."),
        _buildTvStep(2, "Create an Alert in TradingView", "Click the 'Alert' button on the chart. Set your conditions."),
        _buildTvStep(3, "Add Webhook URL", "In alert settings, check 'Webhook URL' and paste the URL from above."),
        _buildTvStep(4, "Configure Alert Message (JSON)", "Paste the JSON body with your strategy_code and side."),
      ],
    );
  }

  Widget _buildTvStep(int num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
            child: Center(child: Text("$num", style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamples() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader("Webhook Examples", "Copy and customize these examples for your TradingView alerts or Python scripts."),
          const SizedBox(height: 32),
          _buildExampleCard("TradingView Buy Alert", "Shows how to structure parameters for entering long positions.", Icons.arrow_upward, AppColors.green),
          const SizedBox(height: 16),
          _buildCodeBlock("ENTRY - BUY SIGNAL", "{\n  \"strategy_code\": \"STRG-XXXX\",\n  \"symbol\": \"BTCUSD\",\n  \"side\": \"buy\",\n  \"type\": \"Entry\",\n  \"datetime\": \"2024-02-15 10:30:00\"\n}"),
          const SizedBox(height: 24),
          _buildExampleCard("TradingView Sell Alert", "Demonstrates short position entry or position exit parameters.", Icons.arrow_downward, Colors.redAccent),
          const SizedBox(height: 16),
          _buildCodeBlock("EXIT - SELL SIGNAL", "{\n  \"strategy_code\": \"STRG-XXXX\",\n  \"symbol\": \"BTCUSD\",\n  \"side\": \"sell\",\n  \"type\": \"Exit\",\n  \"datetime\": \"2024-02-15 11:00:00\"\n}"),
          const SizedBox(height: 24),
          _buildExampleCard("Python Strategy Signal", "Connect your algorithmic trading models to execute trades automatically.", Icons.code, AppColors.cyan),
          const SizedBox(height: 16),
          _buildCodeBlock("PYTHON SCRIPT", "import requests\n\nurl = 'https://trade-api.cryptoarth.in/auth/signal/'\npayload = {\n    'strategy_code': 'STRG-XXXX',\n    'symbol': 'BTCUSD',\n    'side': 'buy',\n    'type': 'Entry'\n}\n\nr = requests.post(url, json=payload)\nprint(r.json())"),
          const SizedBox(height: 24),
          _buildExampleCard("cURL Request", "Minimal command line request to trigger a trade signal.", Icons.terminal_outlined, Colors.purpleAccent),
          const SizedBox(height: 16),
          _buildCodeBlock("CURL COMMAND", "curl -X POST https://trade-api.cryptoarth.in/auth/signal/ \\\n-H \"Content-Type: application/json\" \\\n-d '{\"strategy_code\":\"STRG-XXXX\", \"symbol\":\"BTCUSD\", \"side\":\"buy\", \"type\":\"Entry\"}'"),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String title, String desc, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      color: Colors.black,
      opacity: 0.3,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String title, String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code copied"), duration: Duration(seconds: 1)));
              },
              child: const Icon(Icons.copy, color: Colors.white24, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Text(
            code,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace', height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildParameters() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader("Parameters", "Complete reference for all available webhook parameters and their usage."),
          const SizedBox(height: 32),
          _buildParamTable(),
          const SizedBox(height: 24),
          _buildNoteCard("All parameters should be URL-encoded when used in TradingView alerts."),
          _buildNoteCard("The webhook URL format: ?parameter1=value1&parameter2=value2"),
          _buildNoteCard("Make sure you're logged in to your Crypto Arth account before using the webhook."),
          _buildNoteCard("Test your webhook with small quantities first to verify the connection."),
        ],
      ),
    );
  }

  Widget _buildParamTable() {
    return Column(
      children: [
        _buildParamRow("strategy_code", "STRG-A50F05", "Required. Your deployed strategy code from Marketplace.", isHeader: true),
        _buildParamRow("symbol", "BTCUSD", "Optional. Trading pair. Loaded from strategy if omitted."),
        _buildParamRow("side", "buy / sell", "Required. Use 'buy' for long or 'sell' for short."),
        _buildParamRow("type", "Entry / Exit", "Required. 'Entry' to open, 'Exit' to close."),
        _buildParamRow("datetime", "YYYY-MM-DD HH:MM:SS", "Optional. Signal timestamp."),
      ],
    );
  }

  Widget _buildParamRow(String name, String example, String desc, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: AppColors.cyan, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(example, style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.gold, size: 14),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildCryptoBroker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(
            "Our Trusted Partner Brokers",
            "Connect your exchange account and start trading with our webhook integration",
          ),
          const SizedBox(height: 32),
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 450;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              childAspectRatio: isMobile ? 0.8 : 1.1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildInfoCard("Supported Brokers", Icons.account_balance_outlined, "CoinDCX, Delta Exchange, Mudrex, and other major exchanges."),
                _buildInfoCard("API Authentication", Icons.lock_outline, "Secure API key & secret usage with bank-grade encryption."),
                _buildInfoCard("Margin & Order Types", Icons.list_alt_outlined, "Market, Limit, SL, SL-M support for spot and futures."),
                _buildInfoCard("Webhook Readiness", Icons.bolt_outlined, "Real-time order routing with sub-50ms latency."),
              ],
            );
          }),
          const SizedBox(height: 32),
          _buildBrokerCard("CoinDCX", "https://cryptologos.cc/logos/coindcx-logo.png", "Open your CoinDCX trading account through Crypto Arth and get free AI system access.", AppColors.cyan, "Connect CoinDCX"),
          const SizedBox(height: 16),
          _buildBrokerCard("Delta Exchange", "https://cryptologos.cc/logos/delta-exchange-deto-logo.png", "Trade Futures & Options on Delta Exchange using AI bots with ZERO platform fee.", AppColors.primary, "Connect Delta Exchange"),
          const SizedBox(height: 16),
          _buildBrokerCard("Mudrex", "https://cryptologos.cc/logos/mudrex-logo.png", "Connect Mudrex for crypto trading with Crypto Arth webhooks and automated strategies.", Colors.deepPurpleAccent, "Connect Mudrex"),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, String desc) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      color: Colors.black,
      opacity: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cyan, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Expanded(child: Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, height: 1.3))),
        ],
      ),
    );
  }

  Widget _buildBrokerCard(String name, String logoUrl, String desc, Color color, String btnText) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      color: AppColors.cardSurface,
      opacity: 0.5,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                child: Icon(Icons.account_balance, color: color, size: 24), // Placeholder for real logo
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.2),
              foregroundColor: color,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3))),
            ),
            child: Text(btnText, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSupport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(
            "Need Help with Webhook Setup?",
            "Our support team is available 24/7 to help you set up and troubleshoot your webhook integration",
          ),
          const SizedBox(height: 32),
          LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 450;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 4,
              childAspectRatio: isMobile ? 0.8 : 1.1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildInfoCard("Setup Assistance", Icons.people_outline, "Step-by-step onboarding help. Get personalized guidance."),
                _buildInfoCard("Error & Logs", Icons.bug_report, "Debug webhook and order failures. Access detailed logs."),
                _buildInfoCard("API Documentation", Icons.menu_book_outlined, "Complete webhook API reference. Detailed guides."),
                _buildInfoCard("Contact Support", Icons.headset_mic_outlined, "Reach support via email or ticket 24/7."),
              ],
            );
          }),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildContactSquare(Icons.phone_outlined, "Phone Support", "+91 9321446611", "Available 24/7"),
              const SizedBox(width: 12),
              _buildContactSquare(Icons.email_outlined, "Email Support", "support@cryptoarth.in", "Response within 2 hours"),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text("Chat on WhatsApp"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366).withOpacity(0.15),
              foregroundColor: const Color(0xFF25D366),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Color(0xFF25D366), width: 0.5)),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Common Questions", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFaqItem("How do I test my webhook?", "You can test your webhook by creating a test alert in TradingView with a small quantity to verify connection."),
          _buildFaqItem("Is there a rate limit?", "Free accounts have a rate limit of 100 webhook calls per hour. Premium accounts have unlimited calls."),
          _buildFaqItem("Which exchanges are supported?", "We support CoinDCX, Delta Exchange, Mudrex, and other major exchanges. Check settings for latest."),
          _buildFaqItem("Can I use multiple webhooks?", "Yes, you can create multiple TradingView alerts with different webhook configurations for different strategies."),
        ],
      ),
    );
  }

  Widget _buildContactSquare(IconData icon, String title, String value, String sub) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        color: Colors.black,
        opacity: 0.3,
        child: Column(
          children: [
            Icon(icon, color: AppColors.cyan, size: 24),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(color: AppColors.cyan.withOpacity(0.5), fontSize: 8)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(answer, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, height: 1.5)),
        ],
      ),
    );
  }
}
