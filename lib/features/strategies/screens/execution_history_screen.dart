import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:cryptoarth/features/strategies/widgets/strategy_detailed_report.dart';
import 'package:cryptoarth/features/strategies/widgets/technical_chart_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cryptoarth/core/utils/time_utils.dart';

class ExecutionHistoryScreen extends ConsumerStatefulWidget {
  const ExecutionHistoryScreen({super.key});

  @override
  ConsumerState<ExecutionHistoryScreen> createState() =>
      _ExecutionHistoryScreenState();
}

class _ExecutionHistoryScreenState
    extends ConsumerState<ExecutionHistoryScreen> {
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Backtest results",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.cyan),
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Syncing AI strategies...")),
                );
                await ref.read(backtestProvider.notifier).syncDeepThink();
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sync completed!"),
                      backgroundColor: AppColors.green,
                    ),
                  );
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Sync failed: $e"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
              }
            },
            tooltip: "Sync AI Strategies",
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => ref.read(backtestProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ref
          .watch(backtestProvider)
          .when(
            data: (results) {
              if (results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        color: Colors.white.withOpacity(0.1),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No execution history found",
                        style: TextStyle(color: Colors.white.withOpacity(0.3)),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return _buildExecutionCard(result);
                },
              );
            },
            loading:
                () => const Center(
                  child: CircularProgressIndicator(color: AppColors.cyan),
                ),
            error:
                (e, s) => Center(
                  child: Text(
                    "Error: $e",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
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

  void _showShareWithPhoneDialog(
    BuildContext outerContext,
    BacktestModel strategy,
    Function(Map<String, dynamic>) onShared,
  ) async {
    final phoneController = TextEditingController();
    int activeTab = 0; // 0: Add, 1: List
    bool isSearching = false;
    bool isFound = false;
    String searchedPhone = "";
    String searchedUserName = "";
    Map<String, dynamic>? foundUser;

    // Access List State
    List<dynamic> accessList = [];
    bool isLoadingList = false;

    // PRE-FETCH Access List to get count
    try {
      accessList = await ref
          .read(backtestProvider.notifier)
          .fetchShareList(strategy.strategyCode);
    } catch (e) {
      // Silent catch
    }

    if (!outerContext.mounted) return;

    showDialog(
      context: outerContext,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> fetchList() async {
                setDialogState(() => isLoadingList = true);
                try {
                  final list = await ref
                      .read(backtestProvider.notifier)
                      .fetchShareList(strategy.strategyCode);
                  setDialogState(() {
                    accessList = list;
                    isLoadingList = false;
                  });
                } catch (e) {
                  setDialogState(() => isLoadingList = false);
                }
              }

              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
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
                                const Text(
                                  "Share Strategy Access",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  strategy.strategyCode,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.close,
                                color: Colors.white.withOpacity(0.5),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tabs
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setDialogState(() => activeTab = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          activeTab == 0
                                              ? AppColors.cyan
                                              : Colors.white.withOpacity(0.1),
                                      width: 2,
                                    ),
                                  ),
                                  gradient:
                                      activeTab == 0
                                          ? LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.cyan.withOpacity(0.1),
                                              Colors.transparent,
                                            ],
                                          )
                                          : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_add_outlined,
                                      color:
                                          activeTab == 0
                                              ? AppColors.cyan
                                              : Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Add User",
                                      style: TextStyle(
                                        color:
                                            activeTab == 0
                                                ? AppColors.cyan
                                                : Colors.white70,
                                        fontSize: 13,
                                        fontWeight:
                                            activeTab == 0
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() => activeTab = 1);
                                fetchList();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          activeTab == 1
                                              ? AppColors.cyan
                                              : Colors.white.withOpacity(0.1),
                                      width: 2,
                                    ),
                                  ),
                                  gradient:
                                      activeTab == 1
                                          ? LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.cyan.withOpacity(0.1),
                                              Colors.transparent,
                                            ],
                                          )
                                          : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.list_alt_outlined,
                                      color:
                                          activeTab == 1
                                              ? AppColors.cyan
                                              : Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Access List (${accessList.length})",
                                      style: TextStyle(
                                        color:
                                            activeTab == 1
                                                ? AppColors.cyan
                                                : Colors.white70,
                                        fontSize: 13,
                                        fontWeight:
                                            activeTab == 1
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (activeTab == 0) // SEARCH TAB
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Find user by phone number",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "+91",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: phoneController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                          hintText: "Enter number...",
                                          hintStyle: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                              ),
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

                                      final userMap = await ref
                                          .read(backtestProvider.notifier)
                                          .checkUserPhone(phoneController.text);

                                      if (outerContext.mounted) {
                                        setDialogState(() {
                                          isSearching = false;
                                          isFound = userMap != null;
                                          foundUser = userMap;
                                          searchedPhone = phoneController.text;
                                          if (userMap != null) {
                                            searchedUserName =
                                                userMap['name']?.toString() ??
                                                userMap['username']
                                                    ?.toString() ??
                                                userMap['first_name']
                                                    ?.toString() ??
                                                "CryptoArth User";
                                          }
                                        });

                                        if (userMap == null) {
                                          ScaffoldMessenger.of(
                                            outerContext,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("User not found"),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AppColors.cyan,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          if (isSearching)
                                            const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                color: Colors.black,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          else
                                            const Icon(
                                              Icons.search,
                                              color: Colors.black,
                                              size: 16,
                                            ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            "Search",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isFound) ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F2922),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.green.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.green.withOpacity(
                                            0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: AppColors.green,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              searchedUserName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "+91 $searchedPhone",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (foundUser != null) {
                                            await onShared(foundUser!);
                                            await fetchList();
                                            setDialogState(() => activeTab = 1);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                          minimumSize: Size.zero,
                                        ),
                                        child: const Text(
                                          "Add Access",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      else // ACCESS LIST TAB
                        Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          child:
                              isLoadingList
                                  ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(40),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : accessList.isEmpty
                                  ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(40),
                                      child: Text(
                                        "No users found.",
                                        style: TextStyle(color: Colors.white38),
                                      ),
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    padding: const EdgeInsets.all(20),
                                    child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(1.5),
                                        3: FixedColumnWidth(50),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: [
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: Text(
                                                "Name",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: Text(
                                                "Phone",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: Text(
                                                "Status",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: Text(
                                                "Action",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                        ...accessList.map((user) {
                                          final name =
                                              user['name']?.toString() ??
                                              user['username']?.toString() ??
                                              "User";
                                          final phone =
                                              user['phone']?.toString() ??
                                              "N/A";
                                          final userId =
                                              user['id'] ?? user['user_id'];

                                          return TableRow(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: Text(
                                                  name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: Text(
                                                  phone,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.green
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    "Active",
                                                    style: TextStyle(
                                                      color: AppColors.green,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                child: InkWell(
                                                  onTap: () async {
                                                    try {
                                                      await ref
                                                          .read(
                                                            backtestProvider
                                                                .notifier,
                                                          )
                                                          .removeShareAccess(
                                                            strategy
                                                                .strategyCode,
                                                            userId,
                                                          );
                                                      fetchList();
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                        outerContext,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "Failed to remove access",
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.redAccent,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ],
                                    ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Close",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showEditStrategyDialog(BacktestModel strategy, {String? pineCode}) {
    // Initial values from strategy or defaults
    final nameController = TextEditingController(text: "BTCUSD Strategy");
    final descController = TextEditingController(
      text:
          "Dual EMA crossover strategy using 9-period and 21-period exponential moving averages. Generates long signals when fast EMA crosses above slow EMA and short signals when fast EMA crosses below slow EMA.",
    );
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
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
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
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    strategy.strategyCode,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildDialogTextField(
                            "Strategy Name",
                            nameController,
                          ),
                          const SizedBox(height: 16),

                          _buildDialogTextField(
                            "Description",
                            descController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildDialogDropdown(
                                  "Symbol",
                                  symbol,
                                  ["BTCUSD (27)", "ETHUSD", "SOLUSD"],
                                  (val) => setDialogState(() => symbol = val!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDialogDropdown(
                                  "Timeframe",
                                  timeframe,
                                  [
                                    "1 Minute",
                                    "5 Minutes",
                                    "15 Minutes",
                                    "1 Hour",
                                  ],
                                  (val) =>
                                      setDialogState(() => timeframe = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildDialogTextField(
                                  "Initial Capital",
                                  capitalController,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDialogDropdown(
                                  "Access Type",
                                  accessType,
                                  ["Limited (Private)", "Public", "Shared"],
                                  (val) {
                                    setDialogState(() => accessType = val!);
                                    if (val == "Shared") {
                                      _showShareWithPhoneDialog(
                                        context,
                                        strategy,
                                        (userMap) {
                                          setDialogState(() {
                                            sharedWith.add(
                                              userMap['phone']?.toString() ??
                                                  userMap['username']
                                                      ?.toString() ??
                                                  "User",
                                            );
                                          });
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          // Show shared users if mode is Shared
                          if (accessType == "Shared" && sharedWith.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Shared with:",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        sharedWith
                                            .map(
                                              (phone) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.05),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.1),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      phone,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    InkWell(
                                                      onTap:
                                                          () => setDialogState(
                                                            () => sharedWith
                                                                .remove(phone),
                                                          ),
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.white
                                                            .withOpacity(0.5),
                                                        size: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildDialogDropdown(
                                  "Trading Type",
                                  tradingType,
                                  ["Automatic", "Manual", "Semi-Auto"],
                                  (val) =>
                                      setDialogState(() => tradingType = val!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDialogTextField(
                                  "Leverage",
                                  leverageController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildDialogTextField(
                                  "Capital % per Trade",
                                  capitalPercentController,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDialogDropdown(
                                  "Commission Type",
                                  commissionType,
                                  ["Maker", "Taker", "Fixed"],
                                  (val) => setDialogState(
                                    () => commissionType = val!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildDialogTextField(
                            "Commission Value",
                            commissionPercentController,
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.purple, AppColors.cyan],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      String mode =
                                          accessType
                                              .split(" ")
                                              .first; // "Limited", "Public", "Shared"

                                      // Use editStrategy for full updates
                                      await ref
                                          .read(backtestProvider.notifier)
                                          .editStrategy(strategy.strategyCode, {
                                            "strategy_name":
                                                nameController.text,
                                            "description": descController.text,
                                            "access_type": mode,
                                            "capital": capitalController.text,
                                            "leverage": leverageController.text,
                                            "capital_percent":
                                                capitalPercentController.text,
                                          });

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        String msg =
                                            "Strategy updated successfully!";
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(msg),
                                            backgroundColor: AppColors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Failed to update strategy.",
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        "Save Changes",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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

  Widget _buildDialogTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
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
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
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
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.white38,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items:
                  items
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExecutionCard(BacktestModel result) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    bool isProfit = result.pnl >= 0;
    final String timeStr = TimeUtils.formatRelativeTime(result.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.strategyCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "COMPLETED",
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "• $timeStr",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _showDeployDialog(result),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green.withOpacity(0.1),
                    foregroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
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
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Activate",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                _buildStatItem(result.totalTrades.toString(), "TRADES"),
                _buildStatItem(
                  "${result.winRate.toStringAsFixed(1)}%",
                  "WIN RATE",
                  color: AppColors.green,
                ),
                _buildStatItem(
                  "${isProfit ? '+' : ''}${result.pnl.toStringAsFixed(2)}%",
                  "RETURN",
                  color: isProfit ? AppColors.green : Colors.redAccent,
                ),
                _buildStatItem(
                  "${result.drawdown.toStringAsFixed(1)}%",
                  "MAX DD",
                  color: Colors.orangeAccent,
                ),
              ],
            ),

            const SizedBox(height: 24),
            Divider(color: Colors.white.withOpacity(0.05), height: 1),
            const SizedBox(height: 16),

            // Action Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 4 : 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0, // Forced equal dimensions
              children: [
                _buildActionItem(
                  Icons.science_outlined,
                  "Backtest",
                  const Color(0xFFFFB800),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Loading strategy source..."),
                        ),
                      );

                      String pineCode = "";
                      try {
                        pineCode = await ref
                            .read(backtestProvider.notifier)
                            .fetchPineCode(result.strategyCode);
                      } catch (e) {
                        // FALLBACK: If dedicated pine-code endpoint fails, check strategy detail for code or JSON
                        final service = ref.read(strategyServiceProvider);
                        final detailRaw = await service.fetchBacktestDetailRaw(
                          result.strategyCode,
                        );
                        final strat = detailRaw['strategy'] ?? detailRaw;
                        pineCode =
                            strat['pine_code'] ??
                            strat['pine_script'] ??
                            strat['code'] ??
                            "";
                        if (pineCode.isEmpty && strat['backtest_json'] is Map) {
                          pineCode = _generatePineFromData(strat);
                        }
                      }

                      if (mounted) {
                        _showBacktestOptions(result, pineCode: pineCode);
                      }
                    } catch (e) {
                      if (mounted) {
                        _showBacktestOptions(result);
                      }
                    }
                  },
                ),
                _buildActionItem(
                  Icons.show_chart_outlined,
                  "Chart",
                  AppColors.cyan,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => TechnicalChartScreen(
                            strategyCode: result.strategyCode,
                            strategyName:
                                result
                                    .strategyCode, // Falling back to code if name not in BacktestModel
                            backtestId: result.id,
                          ),
                    );
                  },
                ),
                _buildActionItem(
                  Icons.edit_outlined,
                  "Edit",
                  const Color(0xFFFFB800),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Loading strategy source..."),
                        ),
                      );

                      String pineCode = "";
                      try {
                        pineCode = await ref
                            .read(backtestProvider.notifier)
                            .fetchPineCode(result.strategyCode);
                      } catch (e) {
                        // FALLBACK: If dedicated pine-code endpoint fails, check strategy detail for code or JSON
                        final service = ref.read(strategyServiceProvider);
                        final detailRaw = await service.fetchBacktestDetailRaw(
                          result.strategyCode,
                        );
                        final strat = detailRaw['strategy'] ?? detailRaw;
                        pineCode =
                            strat['pine_code'] ??
                            strat['pine_script'] ??
                            strat['code'] ??
                            "";
                        if (pineCode.isEmpty && strat['backtest_json'] is Map) {
                          pineCode = _generatePineFromData(strat);
                        }
                      }

                      if (mounted) {
                        _showEditStrategyDialog(result, pineCode: pineCode);
                      }
                    } catch (e) {
                      if (mounted) {
                        _showEditStrategyDialog(result);
                      }
                    }
                  },
                ),
                _buildActionItem(
                  Icons.code,
                  "Pine",
                  const Color(0xFF10B981),
                  onTap: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fetching Pine script..."),
                        ),
                      );

                      String code = "";
                      try {
                        code = await ref
                            .read(backtestProvider.notifier)
                            .fetchPineCode(result.strategyCode);
                      } catch (e) {
                        // FALLBACK: If dedicated pine-code endpoint fails, check strategy detail for code or JSON
                        final service = ref.read(strategyServiceProvider);
                        final detail = await service.fetchBacktestDetail(
                          result.strategyCode,
                        );
                        // BacktestDetail usually returns a BacktestModel but internally the API response for /detail/
                        // contains the full strategy object including backtest_json.
                        // Let's call the raw GET to find the source.
                        final detailRaw = await service.fetchBacktestDetailRaw(
                          result.strategyCode,
                        );
                        final strat = detailRaw['strategy'] ?? detailRaw;

                        code =
                            strat['pine_code'] ??
                            strat['pine_script'] ??
                            strat['code'] ??
                            "";

                        if (code.isEmpty && strat['backtest_json'] is Map) {
                          // Last resort: Generate from JSON
                          code = _generatePineFromData(strat);
                        }
                      }

                      if (code.isEmpty)
                        throw Exception(
                          "No Pine code available even in detail.",
                        );

                      if (mounted) {
                        await ReportGenerator.downloadTextFile(
                          code,
                          "${result.strategyCode.replaceAll(' ', '_')}.pine",
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Pine script ready to save!"),
                            backgroundColor: AppColors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to fetch Pine code: $e"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ),
                _buildActionItem(
                  Icons.insert_chart_outlined,
                  "Report",
                  const Color(0xFF8B5CF6),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => StrategyDetailedReport(
                            strategyCode: result.strategyCode,
                            backtestId: result.id,
                          ),
                    );
                  },
                ),
                _buildActionItem(
                  Icons.share_outlined,
                  "Share",
                  AppColors.cyan,
                  onTap: () {
                    _showShareWithPhoneDialog(context, result, (userMap) async {
                      try {
                        final userId = userMap['id'] ?? userMap['user_id'];
                        if (userId == null)
                          throw "User ID not found in search result";

                        await ref
                            .read(backtestProvider.notifier)
                            .shareStrategy(result.strategyCode, userId);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Strategy Shared Successfully!"),
                              backgroundColor: AppColors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to share strategy: $e"),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    });
                  },
                ),
                _buildActionItem(
                  Icons.auto_awesome_outlined,
                  "Improve",
                  const Color(0xFF8B5CF6),
                  onTap: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Starting AI Improvement..."),
                        ),
                      );
                      await ref
                          .read(backtestProvider.notifier)
                          .improveStrategy(result.strategyCode);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Improvement task submitted!"),
                            backgroundColor: AppColors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to start improvement: $e"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ),
                _buildActionItem(
                  Icons.psychology_outlined,
                  "Deep Think",
                  const Color(0xFF8B5CF6),
                  onTap: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Starting Deep Think Optimization..."),
                        ),
                      );
                      await ref
                          .read(backtestProvider.notifier)
                          .deepThinkOptimizeV2(result.strategyCode);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Deep Think task submitted!"),
                            backgroundColor: AppColors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to start Deep Think: $e"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ),
                _buildActionItem(
                  Icons.picture_as_pdf_outlined,
                  "PDF",
                  const Color(0xFFEF4444),
                  onTap: () async {
                    if (result.id != null) {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Fetching PDF report from server..."),
                          ),
                        );
                        final url = await ref
                            .read(backtestProvider.notifier)
                            .fetchBacktestReportPdfUrl(result.id!);
                        await ReportGenerator.downloadPdfFromUrl(
                          url,
                          "backtest_report_${result.strategyCode}.pdf",
                        );
                      } catch (e) {
                        // Fallback to local generation if backend fails
                        ReportGenerator.downloadBacktestReport(
                          result.strategyCode,
                          result.winRate.toDouble(),
                          result.pnl.toDouble(),
                          result.drawdown.toDouble(),
                        );
                      }
                    } else {
                      ReportGenerator.downloadBacktestReport(
                        result.strategyCode,
                        result.winRate.toDouble(),
                        result.pnl.toDouble(),
                        result.drawdown.toDouble(),
                      );
                    }
                  },
                ),
                _buildActionItem(
                  Icons.delete_outline,
                  "Delete",
                  const Color(0xFFEF4444),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: const Color(0xFF0F172A),
                            title: const Text(
                              "Delete Strategy",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              "Are you sure you want to delete this strategy from history?",
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirmed == true) {
                      try {
                        await ref
                            .read(backtestProvider.notifier)
                            .deleteStrategy(result.strategyCode);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Strategy deleted successfully!"),
                              backgroundColor: AppColors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to delete strategy: $e"),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {Color? color}) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: isMobile ? 13 : 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 7,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpotsFromData(dynamic data) {
    if (data == null || data is! List) {
      // Return a flat line as fallback if no data
      return [const FlSpot(0, 0), const FlSpot(10, 0)];
    }

    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is Map) {
        final x =
            num.tryParse(
              item['x']?.toString() ??
                  item['trade_no']?.toString() ??
                  i.toString(),
            )?.toDouble() ??
            i.toDouble();
        final y =
            num.tryParse(
              item['y']?.toString() ??
                  item['balance']?.toString() ??
                  item['value']?.toString() ??
                  '0',
            )?.toDouble() ??
            0.0;
        spots.add(FlSpot(x, y));
      } else if (item is num) {
        spots.add(FlSpot(i.toDouble(), item.toDouble()));
      }
    }
    return spots.isEmpty ? [const FlSpot(0, 0), const FlSpot(1, 0)] : spots;
  }

  void _showDeployDialog(BacktestModel result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            title: const Text(
              "Deploy Strategy",
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose trading mode:",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                _buildDialogButton(
                  "Paper Trading",
                  Icons.science_outlined,
                  AppColors.cyan,
                  () async {
                    Navigator.pop(context);
                    try {
                      await ref
                          .read(backtestProvider.notifier)
                          .setBacktestTradeMode(result.strategyCode, "Paper");
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Strategy deployed for Paper Trading!",
                            ),
                            backgroundColor: AppColors.green,
                          ),
                        );
                    } catch (e) {
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Deployment failed: $e"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildDialogButton(
                  "Live Trading",
                  Icons.bolt,
                  AppColors.green,
                  () async {
                    Navigator.pop(context);
                    try {
                      await ref
                          .read(backtestProvider.notifier)
                          .setBacktestTradeMode(result.strategyCode, "Live");
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Strategy deployed for Live Trading!",
                            ),
                            backgroundColor: AppColors.green,
                          ),
                        );
                    } catch (e) {
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Deployment failed: $e"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showBacktestOptions(BacktestModel result, {String? pineCode}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            title: const Text(
              "Backtest Options",
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogButton(
                  "Rerun with Current Config",
                  Icons.refresh,
                  const Color(0xFFFFB800),
                  () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    try {
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Rerunning backtest...")),
                      );
                      await ref
                          .read(backtestProvider.notifier)
                          .rerunBacktest(result.strategyCode);
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Backtest completed!"),
                          backgroundColor: AppColors.green,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text("Backtest failed: $e"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildDialogButton(
                  "Custom Configuration",
                  Icons.settings_suggest_outlined,
                  AppColors.purple,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BacktestConfigScreen(
                              strategyCode: result.strategyCode,
                              strategyName:
                                  result
                                      .strategyCode, // Use code as name if specific name not in BacktestModel
                              pineCode: pineCode,
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDialogButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generatePineFromData(Map<String, dynamic> data) {
    final name = data['strategy_name'] ?? 'Strategy';
    final desc = data['strategy_description'] ?? 'Generated from JSON';
    final json = data['backtest_json'] is Map ? data['backtest_json'] : {};

    // Check if it's a known pattern (like the Bollinger Band one)
    final indicators = json['indicators'] as List? ?? [];

    String logic = "";
    if (indicators.any(
      (e) =>
          e['type']?.toString().contains('bb') == true ||
          e['type']?.toString().contains('bollinger') == true,
    )) {
      logic = """
bb = ta.bb(close, 20, 2)
longCondition = close <= bb.lower
shortCondition = close >= bb.upper
""";
    } else {
      logic = """
// Strategy definitions
shortEma = ta.ema(close, 9)
longEma = ta.ema(close, 21)
longCondition = ta.crossover(shortEma, longEma)
shortCondition = ta.crossunder(shortEma, longEma)
""";
    }

    return """
//@version=5
// Name: $name
// Description: $desc
strategy("$name", overlay=true)

$logic

if (longCondition)
    strategy.entry("Long", strategy.long)

if (shortCondition)
    strategy.entry("Short", strategy.short)
""";
  }
}
