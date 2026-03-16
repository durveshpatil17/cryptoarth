import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/broker/models/broker_model.dart';
import 'package:cryptoarth/features/broker/services/broker_service.dart';

final brokerServiceProvider = Provider<BrokerService>((ref) {
  return BrokerService();
});

class BrokerNotifier extends AsyncNotifier<List<BrokerModel>> {
  @override
  Future<List<BrokerModel>> build() async {
    // Return empty list initially
    return []; 
  }

  Future<bool> testConnection(String apiKey, String apiSecret, String broker) async {
    final service = ref.read(brokerServiceProvider);
    return await service.testBrokerConnection(apiKey, apiSecret, broker);
  }

  Future<void> connect(String name, String apiKey, String apiSecret, String broker) async {
    final service = ref.read(brokerServiceProvider);
    await service.connectBroker(
      apiKey: apiKey, 
      apiSecret: apiSecret, 
      broker: broker, // e.g. "DeltaExchange", "Coindcx"
      name: name,
    );
    
    final newBroker = BrokerModel(
      brokerName: name, 
      isConnected: true, 
      apiKey: apiKey, 
      createdAt: DateTime.now().toIso8601String()
    );
    
    final currentList = state.value ?? [];
    if (!currentList.any((b) => b.brokerName == newBroker.brokerName)) {
      state = AsyncValue.data([...currentList, newBroker]);
    }
  }

  Future<void> connectDelta(String name, String apiKey, String apiSecret) async {
    await connect(name, apiKey, apiSecret, "DeltaExchange");
  }

  Future<void> connectCoinDCX(String name, String apiKey, String apiSecret) async {
    await connect(name, apiKey, apiSecret, "Coindcx");
  }

  Future<void> connectMudrex(String name, String apiKey, String apiSecret) async {
    await connect(name, apiKey, apiSecret, "Mudrex");
  }

  void disconnect(String brokerName) {
    final currentList = state.value ?? [];
    state = AsyncValue.data(currentList.where((b) => b.brokerName != brokerName).toList());
  }
}

final brokerProvider = AsyncNotifierProvider<BrokerNotifier, List<BrokerModel>>(() {
  return BrokerNotifier();
});
