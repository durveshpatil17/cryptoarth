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

  Future<void> connectDelta(String apiKey, String apiSecret) async {
    final service = ref.read(brokerServiceProvider);
    await service.connectDeltaBroker(apiKey, apiSecret);
    
    final newBroker = BrokerModel(
      brokerName: "Delta Exchange", 
      isConnected: true, 
      apiKey: apiKey, 
      createdAt: DateTime.now().toIso8601String()
    );
    
    final currentList = state.value ?? [];
    // Avoid duplicates
    if (!currentList.any((b) => b.brokerName == newBroker.brokerName)) {
      state = AsyncValue.data([...currentList, newBroker]);
    }
  }

  Future<void> connectCoinDCX(String apiKey, String apiSecret) async {
    final service = ref.read(brokerServiceProvider);
    await service.connectCoinDCX(apiKey, apiSecret);
    
    final newBroker = BrokerModel(
      brokerName: "CoinDCX", 
      isConnected: true, 
      apiKey: apiKey, 
      createdAt: DateTime.now().toIso8601String()
    );
    
    final currentList = state.value ?? [];
     // Avoid duplicates
    if (!currentList.any((b) => b.brokerName == newBroker.brokerName)) {
      state = AsyncValue.data([...currentList, newBroker]);
    }
  }

  // Support for Mudrex (Mock or actual if endpoint added)
  Future<void> connectMudrex(String apiKey, String apiSecret) async {
    // Assuming backend handles it or we mock for now
    await Future.delayed(const Duration(seconds: 1)); 
    
    final newBroker = BrokerModel(
      brokerName: "Mudrex", 
      isConnected: true, 
      apiKey: apiKey, 
      createdAt: DateTime.now().toIso8601String()
    );
    
    final currentList = state.value ?? [];
    if (!currentList.any((b) => b.brokerName == newBroker.brokerName)) {
      state = AsyncValue.data([...currentList, newBroker]);
    }
  }

  void disconnect(String brokerName) {
    final currentList = state.value ?? [];
    state = AsyncValue.data(currentList.where((b) => b.brokerName != brokerName).toList());
  }
}

final brokerProvider = AsyncNotifierProvider<BrokerNotifier, List<BrokerModel>>(() {
  return BrokerNotifier();
});
