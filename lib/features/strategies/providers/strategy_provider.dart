import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/strategies/services/strategy_service.dart';

final strategyServiceProvider = Provider<StrategyService>((ref) {
  return StrategyService();
});

class StrategyNotifier extends AsyncNotifier<List<StrategyModel>> {
  @override
  Future<List<StrategyModel>> build() async {
    return _fetchStrategies();
  }

  Future<List<StrategyModel>> _fetchStrategies() async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchUserStrategies();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStrategies());
  }

  Future<void> deployStrategy(String strategyId, int brokerId) async {
    try {
      final service = ref.read(strategyServiceProvider);
      await service.deployStrategy(strategyId, brokerId);
      ref.invalidateSelf(); // refresh list
    } catch (e) {
      throw Exception('Deploy failed: $e');
    }
  }

  Future<void> undeployStrategy(String strategyId) async {
    try {
      final service = ref.read(strategyServiceProvider);
      await service.undeployStrategy(strategyId);
      ref.invalidateSelf(); // refresh list
    } catch (e) {
      throw Exception('Undeploy failed: $e');
    }
  }
}

final strategyProvider = AsyncNotifierProvider<StrategyNotifier, List<StrategyModel>>(() {
  return StrategyNotifier();
});

// For dashboard specific strategies
class DashboardStrategyNotifier extends AsyncNotifier<List<StrategyModel>> {
  @override
  Future<List<StrategyModel>> build() async {
    return _fetchDashboardStrategies();
  }

  Future<List<StrategyModel>> _fetchDashboardStrategies() async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchDashboardStrategies();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDashboardStrategies());
  }
}

final dashboardStrategyProvider = AsyncNotifierProvider<DashboardStrategyNotifier, List<StrategyModel>>(() {
  return DashboardStrategyNotifier();
});
