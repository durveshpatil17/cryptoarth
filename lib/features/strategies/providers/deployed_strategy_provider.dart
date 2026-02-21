import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/models/deployed_strategy_model.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';

class DeployedStrategyNotifier extends AsyncNotifier<List<DeployedStrategyModel>> {
  @override
  Future<List<DeployedStrategyModel>> build() async {
    return _fetchDeployedStrategies();
  }

  Future<List<DeployedStrategyModel>> _fetchDeployedStrategies() async {
    final service = ref.read(strategyServiceProvider);
    return await service.fetchDeployedStrategies();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDeployedStrategies());
  }
}

final deployedStrategyProvider = AsyncNotifierProvider<DeployedStrategyNotifier, List<DeployedStrategyModel>>(() {
  return DeployedStrategyNotifier();
});
