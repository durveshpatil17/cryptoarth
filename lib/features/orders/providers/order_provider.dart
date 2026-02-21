import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/orders/models/order_model.dart';
import 'package:cryptoarth/features/orders/services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

class OrderNotifier extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    return _fetchOrders();
  }

  Future<List<OrderModel>> _fetchOrders() async {
    final service = ref.read(orderServiceProvider);
    return await service.fetchOrders();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOrders());
  }
}

final orderProvider = AsyncNotifierProvider<OrderNotifier, List<OrderModel>>(() {
  return OrderNotifier();
});
