import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/strategies/services/strategy_service.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
import 'package:cryptoarth/features/strategies/models/deployed_strategy_model.dart';

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

  Future<void> deployStrategy(String strategyCode, {bool isLive = false}) async {
    try {
      final service = ref.read(strategyServiceProvider);
      // Set trade mode first if necessary
      await service.setBacktestTradeMode(strategyCode, isLive ? 1 : 0);
      await service.deployStrategy(strategyCode);
      ref.invalidateSelf(); // refresh list
    } catch (e) {
      throw Exception('Deploy failed: $e');
    }
  }

  Future<void> switchTradeMode(String strategyCode, bool isLive) async {
    try {
      final service = ref.read(strategyServiceProvider);
      await service.setBacktestTradeMode(strategyCode, isLive ? 1 : 0);
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Mode switch failed: $e');
    }
  }

  Future<void> undeployStrategy(String strategyCode) async {
    try {
      final service = ref.read(strategyServiceProvider);
      await service.undeployStrategy(strategyCode);
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
    return await service.fetchDashboardStrategies(cards: true, lite: true);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDashboardStrategies());
  }
}

final dashboardStrategyProvider = AsyncNotifierProvider<DashboardStrategyNotifier, List<StrategyModel>>(() {
  return DashboardStrategyNotifier();
});

// Combined provider for selection dropdowns
final selectStrategyProvider = FutureProvider<List<StrategyModel>>((ref) async {
  List<StrategyModel> userStrategies = [];
  List<StrategyModel> dashboardStrategies = [];

  try {
    userStrategies = await ref.watch(strategyProvider.future);
  } catch (e) {
    debugPrint("selectStrategyProvider: Error fetching user strategies: $e");
  }

  try {
    dashboardStrategies = await ref.watch(dashboardStrategyProvider.future);
  } catch (e) {
    debugPrint("selectStrategyProvider: Error fetching dashboard strategies: $e");
  }
  
  // Combine and deduplicate
  // We prefer strategyCode as key if available, otherwise ID
  final Map<String, StrategyModel> combinedMap = {};
  
  // 1. Marketplace strategies
  for (var s in dashboardStrategies) {
    final key = s.strategyCode.isNotEmpty ? s.strategyCode : s.id;
    if (key.isNotEmpty) combinedMap[key] = s;
  }
  
  // 2. User strategies take precedence
  for (var s in userStrategies) {
    final key = s.strategyCode.isNotEmpty ? s.strategyCode : s.id;
    if (key.isNotEmpty) combinedMap[key] = s;
  }
  
  final result = combinedMap.values.toList();
  debugPrint("Strategy Selection List: Found ${result.length} strategies total.");
  
  return result;
});

// Returns only currently deployed strategies for filtering in Portfolio/Orders
final deployedStrategyListProvider = FutureProvider<List<StrategyModel>>((ref) async {
  final all = await ref.watch(selectStrategyProvider.future);
  return all.where((s) => s.isDeployed).toList();
});

final deployedStrategiesProvider = FutureProvider<List<DeployedStrategyModel>>((ref) async {
  final service = ref.read(strategyServiceProvider);
  return await service.fetchDeployedStrategies();
});
