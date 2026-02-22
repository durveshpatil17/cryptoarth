import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/orders/models/order_model.dart';
import 'package:cryptoarth/features/orders/providers/order_provider.dart';
import 'package:cryptoarth/features/portfolio/providers/trading_mode_provider.dart';

class TradeHistoryNotifier extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    ref.watch(tradingModeProvider);
    return _fetchTrades();
  }

  Future<List<OrderModel>> _fetchTrades() async {
    final mode = ref.read(tradingModeProvider);
    final service = ref.read(orderServiceProvider);
    
    if (mode == TradingMode.paper) {
      return await service.fetchPaperTrades();
    } else {
      return await service.fetchTrades();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTrades());
  }
}

final tradeHistoryProvider = AsyncNotifierProvider<TradeHistoryNotifier, List<OrderModel>>(() {
  return TradeHistoryNotifier();
});
