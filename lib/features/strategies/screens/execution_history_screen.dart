import 'package:flutter/material.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';
import 'package:cryptoarth/shared/widgets/glass_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/providers/backtest_provider.dart';
import 'package:cryptoarth/features/strategies/models/backtest_model.dart';
import 'package:cryptoarth/features/strategies/screens/backtest_config_screen.dart';
import 'package:cryptoarth/features/strategies/screens/backtest_results_screen.dart';
import 'package:cryptoarth/features/strategies/screens/code_generator_screen.dart';
import 'package:cryptoarth/core/utils/report_generator.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/marketplace/screens/marketplace_screen.dart';

class ExecutionHistoryScreen extends ConsumerStatefulWidget {
  const ExecutionHistoryScreen({super.key});

  @override
  ConsumerState<ExecutionHistoryScreen> createState() => _ExecutionHistoryScreenState();
}

class _ExecutionHistoryScreenState extends ConsumerState<ExecutionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Execution History",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Backtest results",
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => ref.read(backtestProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ref.watch(backtestProvider).when(
        data: (results) {
          final items = results.isEmpty ? _getMockData() : results;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final result = items[index];
              return _buildExecutionCard(result);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
        error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  List<BacktestModel> _getMockData() {
    return [
      BacktestModel(
        strategyCode: "STRG-F2FDFB",
        status: "Success",
        pnl: -63.53,
        winRate: 28.1,
        drawdown: 69.6,
      ),
      BacktestModel(
        strategyCode: "STRG-E5DF75",
        status: "Success",
        pnl: -63.53,
        winRate: 28.1,
        drawdown: 69.6,
      ),
    ];
  }

  void _showShareWithPhoneDialog(BuildContext outerContext, BacktestModel strategy, Function(String) onShared) {
    final phoneController = TextEditingController();
    bool isSearching = false;
    bool isFound = false;
    String searchedPhone = "";
    String searchedUserName = "";

    showDialog(
      context: outerContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Share Strategy Access", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(strategy.strategyCode, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: Colors.white.withOpacity(0.5), size: 20),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.cyan, width: 2),
                            right: BorderSide(color: Colors.white.withOpacity(0.05)),
                            bottom: const BorderSide(color: Colors.transparent),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.cyan.withOpacity(0.1), Colors.transparent],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add_outlined, color: AppColors.cyan, size: 16),
                            const SizedBox(width: 8),
                            const Text("Add User", style: TextStyle(color: AppColors.cyan, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list, color: Colors.white.withOpacity(0.4), size: 16),
                            const SizedBox(width: 8),
                            Text("Access List (0)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mobile Number", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Text("+91", style: TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                                  bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                              ),
                              child: TextField(
                                controller: phoneController,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: "Enter number...",
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (phoneController.text.isEmpty) return;
                              setDialogState(() {
                                isSearching = true;
                                isFound = false;
                              });

                              final userMap = await ref.read(backtestProvider.notifier).checkUserPhone(phoneController.text);
                              
                              if (outerContext.mounted) {
                                setDialogState(() {
                                  isSearching = false;
                                  isFound = userMap != null;
                                  searchedPhone = phoneController.text;
                                  if (userMap != null) {
                                    searchedUserName = userMap['name']?.toString() ?? userMap['username']?.toString() ?? userMap['first_name']?.toString() ?? "CryptoArth User";
                                  }
                                });

                                if (userMap == null) {
                                  ScaffoldMessenger.of(outerContext).showSnackBar(
                                    const SnackBar(content: Text("User not found"), backgroundColor: Colors.redAccent),
                                  );
                                }
                              }
                            },
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: const BoxDecoration(
                                color: AppColors.cyan,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                              ),
                              child: Row(
                                children: [
                                  if (isSearching)
                                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                  else
                                    const Icon(Icons.search, color: Colors.black, size: 16),
                                  const SizedBox(width: 6),
                                  const Text("Search", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isFound) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2922),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, color: AppColors.green, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(searchedUserName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text("+91 $searchedPhone", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  onShared(searchedPhone);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text("Add Access", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text("Close", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditStrategyDialog(BacktestModel strategy) {
    // Initial values from strategy or defaults
    final nameController = TextEditingController(text: "BTCUSD Strategy");
    final descController = TextEditingController(text: "Dual EMA crossover strategy using 9-period and 21-period exponential moving averages. Generates long signals when fast EMA crosses above slow EMA and short signals when fast EMA crosses below slow EMA.");
    String symbol = "BTCUSD (27)";
    String timeframe = "15 Minutes";
    final capitalController = TextEditingController(text: "10000");
    String accessType = "Limited (Private)";
    String tradingType = "Automatic";
    final leverageController = TextEditingController(text: "10");
    final capitalPercentController = TextEditingController(text: "25");
    String commissionType = "Maker";
    final commissionPercentController = TextEditingController(text: "0.05");
    String deployStatus = "Not Deployed";
    String tradeMode = "Paper";
    List<String> sharedWith = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: GlassContainer(
            borderRadius: 24,
            color: const Color(0xFF0F172A),
            opacity: 0.98,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Edit Strategy",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            strategy.strategyCode,
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildDialogTextField("Strategy Name", nameController),
                  const SizedBox(height: 16),
                  
                  _buildDialogTextField("Description", descController, maxLines: 3),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildDialogDropdown("Symbol", symbol, ["BTCUSD (27)", "ETHUSD", "SOLUSD"], (val) => setDialogState(() => symbol = val!))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDialogDropdown("Timeframe", timeframe, ["1 Minute", "5 Minutes", "15 Minutes", "1 Hour"], (val) => setDialogState(() => timeframe = val!))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildDialogTextField("Initial Capital", capitalController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDialogDropdown(
                        "Access Type", 
                        accessType, 
                        ["Limited (Private)", "Public", "Shared"], 
                        (val) {
                          setDialogState(() => accessType = val!);
                          if (val == "Shared") {
                            _showShareWithPhoneDialog(context, strategy, (phone) {
                              setDialogState(() {
                                sharedWith.add(phone);
                              });
                            });
                          }
                        }
                      )),
                    ],
                  ),
                  
                  // Show shared users if mode is Shared
                  if (accessType == "Shared" && sharedWith.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Shared with:", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: sharedWith.map((phone) => Chip(
                              label: Text(phone, style: const TextStyle(fontSize: 10, color: Colors.white)),
                              backgroundColor: Colors.white.withOpacity(0.1),
                              deleteIcon: const Icon(Icons.close, size: 10, color: Colors.white54),
                              onDeleted: () => setDialogState(() => sharedWith.remove(phone)),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildDialogDropdown("Trading Type", tradingType, ["Automatic", "Manual"], (val) => setDialogState(() => tradingType = val!))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDialogTextField("Leverage", leverageController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildDialogTextField("Capital %", capitalPercentController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDialogDropdown("Commission Type", commissionType, ["Maker", "Taker"], (val) => setDialogState(() => commissionType = val!))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildDialogTextField("Commission %", commissionPercentController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDialogDropdown("Deploy Status", deployStatus, ["Not Deployed", "Deployed"], (val) => setDialogState(() => deployStatus = val!))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDialogDropdown("Trade Mode", tradeMode, ["Paper", "Live"], (val) => setDialogState(() => tradeMode = val!)),
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.purple, AppColors.cyan]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              String mode = accessType.split(" ").first; // "Limited", "Public", "Shared"
                              await ref.read(backtestProvider.notifier).updateStrategyAccess(
                                strategy.strategyCode,
                                mode,
                                sharedWith,
                              );
                              
                              if (context.mounted) {
                                Navigator.pop(context);
                                String msg = "Strategy updated successfully!";
                                if (accessType == "Shared" && sharedWith.isNotEmpty) {
                                  msg = "Strategy updated and shared with ${sharedWith.length} users!";
                                } else if (accessType == "Public") {
                                  msg = "Strategy is now Public!";
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(msg), backgroundColor: AppColors.green),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Failed to update strategy."), backgroundColor: Colors.redAccent),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 16),
                              SizedBox(width: 8),
                              Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.white38),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExecutionCard(BacktestModel result) {
    // Determine status color
    final Color statusColor = result.status.toLowerCase() == 'success' ? AppColors.green : Colors.redAccent;
    final bool isProfit = result.pnl >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        borderRadius: 20,
        color: const Color(0xFF0F172A), // Deeper navy for premium feel
        opacity: 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "BTCUSD Strategy", // Fallback name
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showEditStrategyDialog(result),
                            child: const Icon(Icons.edit_outlined, color: Colors.white38, size: 12)
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${result.strategyCode}  •  BTCUSD  •  15MIN",
                        style: const TextStyle(color: AppColors.purple, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Activating Strategy...")),
                    );
                    ref.read(strategyProvider.notifier).deployStrategy(result.strategyCode, 1).then((_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Strategy Activated successfully!"), backgroundColor: AppColors.green),
                      );
                    }).catchError((e) {
                      if (!mounted) return;
                      final errorMsg = e.toString().replaceFirst('Exception: ', '').replaceFirst('Failed to deploy strategy: ', '');
                      
                      if (errorMsg.contains('already') && errorMsg.contains('active deployment')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            backgroundColor: Colors.orange,
                            action: SnackBarAction(
                              label: 'MANAGE',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketplaceScreen()));
                              },
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Activation failed: $errorMsg"), backgroundColor: Colors.redAccent),
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green.withOpacity(0.1),
                    foregroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: AppColors.green.withOpacity(0.3)),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text("Activate", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem("82", "TRADES"),
                _buildStatItem("${result.winRate.toStringAsFixed(1)}%", "WIN RATE", color: AppColors.green),
                _buildStatItem("${isProfit ? '+' : ''}${result.pnl.toStringAsFixed(2)}%", "RETURN", color: isProfit ? AppColors.green : Colors.redAccent),
                _buildStatItem("${result.drawdown.toStringAsFixed(1)}%", "MAX DD", color: Colors.orangeAccent),
              ],
            ),
            
            const SizedBox(height: 24),
            Divider(color: Colors.white.withOpacity(0.05), height: 1),
            const SizedBox(height: 16),
            
            // Action Grid
            GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 1.1,
              children: [
                _buildActionItem(Icons.science_outlined, "Backtest", const Color(0xFFFFB800), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BacktestConfigScreen()))),
                _buildActionItem(Icons.show_chart_outlined, "Chart", AppColors.cyan, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BacktestResultsScreen(strategyCode: result.strategyCode)))),
                _buildActionItem(Icons.edit_outlined, "Edit", const Color(0xFFFFB800), onTap: () => _showEditStrategyDialog(result)),
                _buildActionItem(Icons.code, "Pine", const Color(0xFF10B981), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CodeGeneratorScreen()))),
                _buildActionItem(Icons.insert_chart_outlined, "Report", const Color(0xFF8B5CF6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BacktestResultsScreen(strategyCode: result.strategyCode)))),
                _buildActionItem(Icons.share_outlined, "Share", AppColors.cyan, onTap: () {
                  _showShareWithPhoneDialog(context, result, (phone) async {
                    try {
                      await ref.read(backtestProvider.notifier).updateStrategyAccess(result.strategyCode, "Shared", [phone]);
                      if (mounted) {
                        Navigator.pop(context); // Close the dialog
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Strategy Shared Successfully!"), backgroundColor: AppColors.green));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to share strategy."), backgroundColor: Colors.redAccent));
                      }
                    }
                  });
                }),
                _buildActionItem(Icons.auto_awesome_outlined, "Improve", const Color(0xFF8B5CF6), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI Improvement started...")))),
                _buildActionItem(Icons.psychology_outlined, "Deep Think", const Color(0xFF8B5CF6), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deep Think analyzing...")))),
                _buildActionItem(Icons.picture_as_pdf_outlined, "PDF", const Color(0xFFEF4444), onTap: () => ReportGenerator.downloadBacktestReport(result.strategyCode, result.winRate.toDouble(), result.pnl.toDouble(), result.drawdown.toDouble())),
                _buildActionItem(Icons.delete_outline, "Delete", const Color(0xFFEF4444), onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleting strategy...")));
                  // Add delete logic here
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
