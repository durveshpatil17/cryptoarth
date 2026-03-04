import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/strategies/services/strategy_service.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';

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
      final user = ref.read(authProvider).user;
      final service = ref.read(strategyServiceProvider);
      await service.deployStrategy(strategyId, brokerId, userId: user?.id);
      ref.invalidateSelf(); // refresh list
    } catch (e) {
      throw Exception('Deploy failed: $e');
    }
  }

  Future<void> undeployStrategy(dynamic strategyId) async {
    try {
      final user = ref.read(authProvider).user;
      final service = ref.read(strategyServiceProvider);
      await service.undeployStrategy(strategyId, userId: user?.id);
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
    return await service.fetchDashboardStrategies(cards: true, lite: false);
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
