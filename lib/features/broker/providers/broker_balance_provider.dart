import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/broker/models/broker_balance_model.dart';
import 'package:cryptoarth/features/broker/services/broker_service.dart';
import 'package:cryptoarth/features/broker/providers/broker_provider.dart';

class BrokerBalanceNotifier extends AsyncNotifier<BrokerBalanceModel?> {
  @override
  Future<BrokerBalanceModel?> build() async {
    return _fetchBalance();
  }

  Future<BrokerBalanceModel?> _fetchBalance() async {
    final service = ref.read(brokerServiceProvider);
    return await service.fetchBrokerBalance();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBalance());
  }
}

final brokerBalanceProvider = AsyncNotifierProvider<BrokerBalanceNotifier, BrokerBalanceModel?>(() {
  return BrokerBalanceNotifier();
});
