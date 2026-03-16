import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/tools/providers/crypto_price_provider.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  // Controllers
  final TextEditingController _capitalController = TextEditingController(text: "15000");
  final TextEditingController _leverageController = TextEditingController(text: "25");
  final TextEditingController _capitalUsedController = TextEditingController(text: "25");
  final TextEditingController _stopLossController = TextEditingController(text: "2");
  final TextEditingController _targetController = TextEditingController(text: "5");
  final TextEditingController _tradesController = TextEditingController(text: "4");
  final TextEditingController _usdRateController = TextEditingController(text: "83");

  String _selectedSymbol = "BTCUSD";
  String _orderType = "Taker"; // Maker 0.02% or Taker 0.05%
  String _stopLossUnit = "%";
  String _targetUnit = "%";

  final List<String> _symbols = [
    "BTCUSD", "ETHUSD", "RTCINR", "ETHINR", "BTCUSDT", "ETHUSDT", "BTCUSDC", "ETHUSDC"
  ];

  // Calculated Results
  bool _hasCalculated = false;
  double _margin = 0.0;
  double _risk = 0.0;
  double _reward = 0.0;
  double _totalFees = 0.0;
  double _netProfit = 0.0;
  double _positionSize = 0.0;
  double _totalCapitalUSD = 0.0;
  double _roe = 0.0;

  void _calculate() {
    HapticFeedback.lightImpact();
    setState(() {
      final double capitalINR = double.tryParse(_capitalController.text) ?? 0;
      final double usdRate = double.tryParse(_usdRateController.text) ?? 83;
      final double leverage = double.tryParse(_leverageController.text) ?? 1;
      final double capitalUsedPct = double.tryParse(_capitalUsedController.text) ?? 0;
      final double slValue = double.tryParse(_stopLossController.text) ?? 0;
      final double targetValue = double.tryParse(_targetController.text) ?? 0;
      final double tradesPerDay = double.tryParse(_tradesController.text) ?? 0;

      // 1. Convert Capital to USD
      _totalCapitalUSD = capitalINR / usdRate;
      
      // 2. Used Capital (Margin)
      _margin = _totalCapitalUSD * (capitalUsedPct / 100);
      
      // 3. Position Size
      _positionSize = _margin * leverage;

      // 4. Fees (Maker 0.02%, Taker 0.05% - per side)
      final double feeRate = _orderType == "Maker" ? 0.0002 : 0.0005;
      final double perTradeFees = _positionSize * feeRate * 2;
      _totalFees = perTradeFees * tradesPerDay;

      // 5. Risk & Reward
      _risk = _stopLossUnit == "%" ? _positionSize * (slValue / 100) : slValue;
      _reward = _targetUnit == "%" ? _positionSize * (targetValue / 100) : targetValue;

      // 6. ROE
      _roe = _margin > 0 ? (_reward / _margin) * 100 : 0;

      // 7. Net Profit per trade
      _netProfit = _reward - perTradeFees;
      
      _hasCalculated = true;
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _hasCalculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pricesAsync = ref.watch(cryptoPriceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "MARGIN CALCULATOR",
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildPricingBanner(pricesAsync),
              const SizedBox(height: 24),
              _buildTradingParametersModule(),
              const SizedBox(height: 24),
              _buildResultsModule(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
          ),
          child: const Text(
            "PRECISION TRADING ENGINE",
            style: TextStyle(color: AppColors.cyan, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Margin Calculator",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          "Calculate your trading margin, position size, and risk-reward ratio with precision.",
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildPricingBanner(AsyncValue<CryptoPrice> prices) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      color: Colors.black,
      opacity: 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          prices.when(
            data: (p) => _buildPriceItem("BTC/USD", "\$${p.btc.toStringAsFixed(0)}"),
            loading: () => _buildPriceItem("BTC/USD", "---"),
            error: (_,__) => _buildPriceItem("BTC/USD", "Offline"),
          ),
          Container(width: 1, height: 20, color: Colors.white10),
          prices.when(
            data: (p) => _buildPriceItem("ETH/USD", "\$${p.eth.toStringAsFixed(0)}"),
            loading: () => _buildPriceItem("ETH/USD", "---"),
            error: (_,__) => _buildPriceItem("ETH/USD", "Offline"),
          ),
          Container(width: 1, height: 20, color: Colors.white10),
          _buildPriceItem("USD/INR", "₹${_usdRateController.text}"),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()])),
      ],
    );
  }

  Widget _buildTradingParametersModule() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      color: AppColors.cardSurface,
      opacity: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.cyan, size: 18),
              const SizedBox(width: 12),
              const Text("Trading Parameters", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 24),
          _buildFieldLabel("Capital (₹)"),
          _buildInputField(_capitalController, "15000", suffix: "≈ \$${(_totalCapitalUSD).toStringAsFixed(1)}"),
          const SizedBox(height: 20),
          _buildFieldLabel("Symbol"),
          _buildSymbolDropdown(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildParamField("Leverage (X)", _leverageController)),
              const SizedBox(width: 16),
              Expanded(child: _buildParamField("Capital Used (%)", _capitalUsedController)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildParamToggleField("Stop Loss", _stopLossController, _stopLossUnit, (u) => setState(() => _stopLossUnit = u))),
              const SizedBox(width: 16),
              Expanded(child: _buildParamToggleField("Target", _targetController, _targetUnit, (u) => setState(() => _targetUnit = u))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildParamField("Trades per Day", _tradesController)),
              const SizedBox(width: 16),
              Expanded(child: _buildOrderTypeModule()),
            ],
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("USD to INR Rate"),
          _buildInputField(_usdRateController, "83"),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _calculate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calculate_outlined, size: 20),
                const SizedBox(width: 12),
                const Text("CALCULATE MARGIN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, {String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
            ),
            onChanged: (v) => setState(() {}),
          ),
        ),
        if (suffix != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4),
            child: Text(suffix, style: TextStyle(color: AppColors.cyan.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildSymbolDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSymbol,
          isExpanded: true,
          dropdownColor: AppColors.cardSurface,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          items: _symbols.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _selectedSymbol = v!),
        ),
      ),
    );
  }

  Widget _buildParamField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        _buildInputField(controller, "0"),
      ],
    );
  }

  Widget _buildParamToggleField(String label, TextEditingController controller, String currentUnit, Function(String) onUnitChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFieldLabel(label),
            Row(
              children: [
                _buildUnitItem("%", currentUnit == "%", onUnitChanged),
                _buildUnitItem("\$", currentUnit == "\$", onUnitChanged),
              ],
            ),
          ],
        ),
        _buildInputField(controller, "0"),
      ],
    );
  }

  Widget _buildUnitItem(String unit, bool isSelected, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(unit),
      child: Container(
        margin: const EdgeInsets.only(left: 6, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyan.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? AppColors.cyan.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
        ),
        child: Text(unit, style: TextStyle(color: isSelected ? AppColors.cyan : Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOrderTypeModule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Order Type"),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              _buildTypeOption("Maker", _orderType == "Maker", "0.02%"),
              _buildTypeOption("Taker", _orderType == "Taker", "0.05%"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(String text, bool isSelected, String sub) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _orderType = text),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.white24, fontSize: 10, fontWeight: FontWeight.w900)),
              Text(sub, style: TextStyle(color: isSelected ? AppColors.primary : Colors.white10, fontSize: 7, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsModule() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      color: AppColors.cardSurface,
      opacity: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: AppColors.cyan, size: 18),
                  const SizedBox(width: 12),
                  const Text("Calculation Results", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                ],
              ),
              if (_hasCalculated)
                IconButton(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white24, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (!_hasCalculated)
            _buildEmptyState()
          else
            _buildCalculationStats(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), shape: BoxShape.circle),
            child: Icon(Icons.calculate_outlined, size: 40, color: Colors.white.withOpacity(0.1)),
          ),
          const SizedBox(height: 16),
          Text(
            "Enter your trading parameters and click\n\"Calculate Margin\" to see results.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, height: 1.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationStats() {
    return Column(
      children: [
        Row(
          children: [
            _buildResultItem("Position Size", "\$${_positionSize.toStringAsFixed(0)}", Colors.white),
            const SizedBox(width: 12),
            _buildResultItem("Margin Required", "\$${_margin.toStringAsFixed(2)}", AppColors.cyan),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildResultItem("Risk (Stop Loss)", "\$${_risk.toStringAsFixed(2)}", Colors.redAccent),
            const SizedBox(width: 12),
            _buildResultItem("Reward (Target)", "\$${_reward.toStringAsFixed(2)}", AppColors.green),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildResultItem("Total Fees/Day", "\$${_totalFees.toStringAsFixed(2)}", Colors.orangeAccent),
            const SizedBox(width: 12),
            _buildResultItem("ROE (%)", "${_roe.toStringAsFixed(2)}%", AppColors.gold),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.green.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("NET PROJECTED PROFIT", style: TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Text("\$${_netProfit.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, fontFeatures: [FontFeature.tabularFigures()])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(String label, String value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: accentColor, fontSize: 15, fontWeight: FontWeight.w900, fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
      ),
    );
  }
}
