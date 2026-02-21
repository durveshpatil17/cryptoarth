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
}

final backtestProvider = AsyncNotifierProvider<BacktestNotifier, List<BacktestModel>>(() {
  return BacktestNotifier();
});
