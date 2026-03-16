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
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:cryptoarth/features/broker/providers/broker_provider.dart';
import 'package:cryptoarth/shared/widgets/luxury_background.dart';

class ExecutionHistoryScreen extends ConsumerStatefulWidget {
  const ExecutionHistoryScreen({super.key});

  @override
  ConsumerState<ExecutionHistoryScreen> createState() =>
      _ExecutionHistoryScreenState();
}

class _ExecutionHistoryScreenState extends ConsumerState<ExecutionHistoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    
    return Scaffold(
      backgroundColor: AppColors.richBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "STRATEGY VAULT",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            Text(
              "EXECUTIVE EXECUTION HISTORY",
              style: TextStyle(
                color: AppColors.cyan.withOpacity(0.5),
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.cyan, size: 20),
            onPressed: () async {
              // ... sync logic ...
              try {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Syncing AI strategies...")),);
                await ref.read(backtestProvider.notifier).syncDeepThink();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sync completed!"), backgroundColor: AppColors.green,),);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sync failed: $e"), backgroundColor: Colors.redAccent,),);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
            onPressed: () => ref.read(backtestProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LuxuryBackground(
        child: ref.watch(backtestProvider).when(
            data: (allResults) {
              final results = allResults.where((r) {
                if (r.isOwner) return true;
                if (currentUser == null) return false;
                bool isIdMatch = r.ownerId != null && r.ownerId == currentUser.id.toString();
                if (isIdMatch) return true;
                if (r.userName != null) {
                  final ownerLower = r.userName!.toLowerCase();
                  final bool nameMatch = currentUser.name != null && ownerLower == currentUser.name!.toLowerCase();
                  final bool phoneMatch = currentUser.phone != null && ownerLower == currentUser.phone!;
                  if (nameMatch || phoneMatch) return true;
                }
                return false;
              }).toList();

              if (results.isEmpty) {
                 return Center(
                   child: GlassContainer(
                     borderRadius: 20,
                     padding: const EdgeInsets.all(40),
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Icon(Icons.history, color: Colors.white10, size: 64),
                         const SizedBox(height: 16),
                         Text("NO TRANSACTIONS FOUND", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                       ],
                     ),
                   ),
                 );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 120, 16, 100),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  return _buildExecutionCard(results[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cyan)),
            error: (e, s) => Center(child: Text("Vault Error: $e", style: const TextStyle(color: Colors.redAccent))),
          ),
      ),
    );
  }

  List<BacktestModel> _getMockData() {
    return [
      BacktestModel(
        strategyCode: "STRG-F2FDFB",
        strategyName: "Mock Strategy 1",
        status: "Success",
        pnl: -63.53,
        winRate: 28.1,
        drawdown: 69.6,
      ),
      BacktestModel(
        strategyCode: "STRG-E5DF75",
        strategyName: "Mock Strategy 2",
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1221),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            result.strategyCode.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.edit_outlined, color: Colors.white.withOpacity(0.3), size: 14),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            "QUANT_AI  •  BTCUSD  •  15MIN",
                            style: TextStyle(
                              color: AppColors.purple,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Activate Button
                InkWell(
                  onTap: () => _showDeployDialog(result),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill, color: AppColors.green, size: 12),
                        const SizedBox(width: 8),
                        const Text(
                          "Activate",
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Stats Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEliteStat("77", "TRADES"),
                _buildEliteStat("${(result.winRate ?? 0.0).toStringAsFixed(1)}%", "WIN RATE", color: AppColors.green),
                _buildEliteStat("${(result.pnl ?? 0.0).toStringAsFixed(2)}%", "RETURN", color: (result.pnl ?? 0) >= 0 ? AppColors.green : Colors.redAccent),
                _buildEliteStat("${(result.drawdown ?? 0.0).toStringAsFixed(1)}%", "MAX DD", color: Colors.redAccent),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Actions Grid (2 rows of 5)
          Column(
            children: [
              // Row 1
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      _buildGridAction(Icons.analytics, "Backtest", Colors.amber, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BacktestConfigScreen(strategyCode: result.strategyCode, strategyName: result.strategyName)));
                      }),
                      _buildGridDivider(),
                      _buildGridAction(Icons.show_chart, "Chart", AppColors.cyan, () {
                        showDialog(context: context, builder: (context) => TechnicalChartScreen(strategyCode: result.strategyCode, strategyName: result.strategyName, backtestId: result.id));
                      }),
                      _buildGridDivider(),
                      _buildGridAction(Icons.edit, "Edit", Colors.amber, () async {
                        final code = await _fetchCode(result.strategyCode);
                        if (mounted) _showEditStrategyDialog(result, pineCode: code);
                      }),
                      _buildGridDivider(),
                      _buildGridAction(Icons.code, "Pine", AppColors.green, () async {
                        final code = await _fetchCode(result.strategyCode);
                        if (mounted) _showPineCodeDialog(context, code);
                      }),
                      _buildGridDivider(),
                      _buildGridAction(Icons.bar_chart, "Report", AppColors.purple, () {
                        showDialog(context: context, builder: (context) => StrategyDetailedReport(strategyCode: result.strategyCode, backtestId: result.id));
                      }),
                    ],
                  ),
                ),
              ),
              // Row 2
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      _buildGridAction(Icons.share, "Share", AppColors.cyan, () {
                        _showShareWithPhoneDialog(context, result, (userMap) async {
                          try {
                            final userId = userMap['user_id'] ?? userMap['id'];
                            await ref.read(backtestProvider.notifier).shareStrategy(result.strategyCode, userId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Access shared successfully!"), backgroundColor: AppColors.green)
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Failed to share access: $e"), backgroundColor: Colors.redAccent)
                              );
                            }
                          }
                        });
                      }),
                      _buildGridDivider(),
                      _buildGridAction(Icons.settings_suggest, "Improve", AppColors.purple, () async {
                        try { await ref.read(backtestProvider.notifier).syncDeepThink(); } catch(e) {}
                      }),
                      _buildGridDivider(),
                      _buildGridAction(Icons.psychology, "Deep Think", AppColors.purple, () async {
                        try { await ref.read(backtestProvider.notifier).syncDeepThink(); } catch(e) {}
                      }),
                      _buildGridDivider(),
                      _buildGridAction(Icons.picture_as_pdf, "PDF", AppColors.cyan, () {
                        ReportGenerator.generateBacktestPdf(result);
                      }),
                      _buildGridDivider(),
                      _buildGridAction(Icons.delete_outline, "Delete", Colors.redAccent, () async {
                        final confirmed = await _showDeleteConfirmation();
                        if (confirmed == true) {
                          ref.read(backtestProvider.notifier).deleteBacktest(result.id);
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("Delete Backtest", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this backtest record?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildEliteStat(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFeatures: const [FontFeature.tabularFigures()])),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildGridAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: color.withOpacity(0.8), size: 14),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 8, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridDivider() {
    return VerticalDivider(color: Colors.white.withOpacity(0.05), width: 1, thickness: 1);
  }

  void _showPineCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("PINE SCRIPT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.copy, color: AppColors.cyan, size: 18), onPressed: () => Clipboard.setData(ClipboardData(text: code))),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(child: SingleChildScrollView(child: Text(code, style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace')))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefinedStat(String label, String value, {Color? color, bool isStatus = false, Color? statusColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          if (isStatus)
            Row(
              children: [
                FadeTransition(
                  opacity: _breatheAnimation,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor!.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: TextStyle(
                color: color ?? Colors.white.withOpacity(0.9),
                fontSize: 15,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRefinedDivider() {
    return Container(
      height: 25,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withOpacity(0.04),
    );
  }

  Widget _buildMiniAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: GlassContainer(
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: Colors.white,
        opacity: 0.03,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white54),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrokerLogo(String name) {
    Color color = Colors.grey;
    String letter = "B";
    
    final n = name.toLowerCase();
    if (n.contains("delta")) {
      color = const Color(0xFF3B82F6);
      letter = "D";
    } else if (n.contains("coindcx")) {
      color = const Color(0xFFEF4444);
      letter = "C";
    } else if (n.contains("mudrex")) {
      color = const Color(0xFFF59E0B);
      letter = "M";
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF111827), width: 2),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildMetaStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.cyan, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatMetric(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildStatVerticalDivider() {
    return VerticalDivider(
      color: Colors.white.withOpacity(0.05),
      width: 1,
      thickness: 1,
    );
  }

  Widget _buildActionGridItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color ?? AppColors.cyan, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color ?? AppColors.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _fetchCode(String strategyCode) async {
    try {
      return await ref.read(backtestProvider.notifier).fetchPineCode(strategyCode);
    } catch (e) {
      final service = ref.read(strategyServiceProvider);
      final detailRaw = await service.fetchBacktestDetailRaw(strategyCode);
      final strat = detailRaw['strategy'] ?? detailRaw;
      String code = strat['pine_code'] ?? strat['pine_script'] ?? strat['code'] ?? "";
      if (code.isEmpty && strat['backtest_json'] is Map) {
        code = _generatePineFromData(strat);
      }
      return code;
    }
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
                          .setBacktestTradeMode(result.strategyCode, 0);
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
                          .setBacktestTradeMode(result.strategyCode, 1);
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
