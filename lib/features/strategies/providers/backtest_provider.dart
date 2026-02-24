import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/models/backtest_model.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';

class BacktestNotifier extends AsyncNotifier<List<BacktestModel>> {
  @override
  Future<List<BacktestModel>> build() async {
    return _fetchBacktestList();
  }

  Future<List<BacktestModel>> _fetchBacktestList() async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchBacktestList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBacktestList());
  }

  Future<BacktestModel> fetchBacktestDetail(String strategyCode) async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchBacktestDetail(strategyCode);
  }

  Future<Map<String, dynamic>> fetchBacktestResult(String backtestId) async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchBacktestResult(backtestId);
  }

  Future<Map<String, dynamic>> fetchBacktestChart(String backtestId) async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchBacktestChart(backtestId);
  }

  Future<Map<String, dynamic>> fetchBacktestReport(String backtestId) async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchBacktestReport(backtestId);
  }

  Future<Map<String, dynamic>?> checkUserPhone(String phone) async {
    final service = ref.read(strategyServiceProvider);
    return await service.checkUserPhone(phone);
  }

  Future<void> updateStrategyAccess(String strategyCode, String accessType, List<String> sharedWith) async {
    final service = ref.read(strategyServiceProvider);
    await service.updateStrategyAccess(strategyCode, accessType, sharedWith);
    refresh();
  }

  Future<void> editStrategy(String strategyCode, Map<String, dynamic> updates) async {
    final service = ref.read(strategyServiceProvider);
    await service.editStrategy(strategyCode, updates);
    refresh();
  }

  Future<void> deleteStrategy(String strategyCode) async {
    final service = ref.read(strategyServiceProvider);
    await service.deleteStrategy(strategyCode);
    refresh();
  }

  Future<void> shareStrategy(String strategyCode, int userId) async {
    final service = ref.read(strategyServiceProvider);
    await service.shareStrategy(strategyCode, userId);
  }

  Future<void> removeShareAccess(String strategyCode, int userId) async {
    final service = ref.read(strategyServiceProvider);
    await service.removeShareAccess(strategyCode, userId);
  }

  Future<List<dynamic>> fetchShareList(String strategyCode) async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchShareList(strategyCode);
  }

  Future<void> improveStrategy(String strategyCode) async {
    final service = ref.read(strategyServiceProvider);
    await service.improveStrategy(strategyCode);
  }

  Future<Map<String, dynamic>> deepThinkOptimizeV2(String strategyCode) async {
    final service = ref.read(strategyServiceProvider);
    return await service.deepThinkOptimizeV2(strategyCode);
  }

  Future<String> fetchPineCode(String strategyCode) async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchPineCode(strategyCode);
  }

  Future<Map<String, dynamic>> rerunBacktest(String strategyCode) async {
    final service = ref.read(strategyServiceProvider);
    final result = await service.rerunBacktest(strategyCode);
    refresh();
    return result;
  }

  Future<String> fetchBacktestReportPdfUrl(String backtestId) async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchBacktestReportPdf(backtestId);
  }

  Future<void> updateBacktestIndicators(String strategyCode, List<Map<String, dynamic>> indicators) async {
    final service = ref.read(strategyServiceProvider);
    await service.updateBacktestIndicators(strategyCode, indicators);
  }

  Future<Map<String, dynamic>> validateBacktest(String strategyCode) async {
    final service = ref.read(strategyServiceProvider);
    return await service.validateBacktest(strategyCode);
  }

  Future<void> setBacktestTradeMode(String strategyCode, String tradeMode) async {
    final service = ref.read(strategyServiceProvider);
    await service.setBacktestTradeMode(strategyCode, tradeMode);
    refresh();
  }

  Future<Map<String, dynamic>> fetchDeepThinkStatus() async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchDeepThinkStatus();
  }

  Future<void> syncDeepThink() async {
    final service = ref.read(strategyServiceProvider);
    await service.syncDeepThink();
    refresh();
  }
}

final backtestProvider = AsyncNotifierProvider<BacktestNotifier, List<BacktestModel>>(() {
  return BacktestNotifier();
});

final backtestSymbolsProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(strategyServiceProvider);
  return await service.fetchBacktestSymbols();
});

