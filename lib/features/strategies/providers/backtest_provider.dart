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
    // Refresh to update UI if necessary
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

