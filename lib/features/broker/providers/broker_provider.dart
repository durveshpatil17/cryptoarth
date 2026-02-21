import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/broker/models/broker_model.dart';
import 'package:cryptoarth/features/broker/services/broker_service.dart';

final brokerServiceProvider = Provider<BrokerService>((ref) {
  return BrokerService();
});

class BrokerNotifier extends AsyncNotifier<BrokerModel?> {
  @override
  Future<BrokerModel?> build() async {
    // There is no explicit GET /auth/broker/ info endpoint provided in instructions,
    // assuming it returns null initially until connected or parsed from other data.
    // However, we must provide connect and test methods here.
    return null; 
  }

  Future<bool> testConnection(String apiKey, String apiSecret, String broker) async {
    final service = ref.read(brokerServiceProvider);
    return await service.testBrokerConnection(apiKey, apiSecret, broker);
  }

  Future<void> connectDelta(String apiKey, String apiSecret) async {
    final service = ref.read(brokerServiceProvider);
    await service.connectDeltaBroker(apiKey, apiSecret);
    state = AsyncValue.data(BrokerModel(brokerName: "Delta Exchange", isConnected: true, apiKey: apiKey, createdAt: DateTime.now().toIso8601String()));
  }

  Future<void> connectCoinDCX(String apiKey, String apiSecret) async {
    final service = ref.read(brokerServiceProvider);
    await service.connectCoinDCX(apiKey, apiSecret);
    state = AsyncValue.data(BrokerModel(brokerName: "CoinDCX", isConnected: true, apiKey: apiKey, createdAt: DateTime.now().toIso8601String()));
  }

  void disconnect() {
    state = const AsyncValue.data(null);
  }
}

final brokerProvider = AsyncNotifierProvider<BrokerNotifier, BrokerModel?>(() {
  return BrokerNotifier();
});
