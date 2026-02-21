import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/credits/models/payment_balance_model.dart';
import 'package:cryptoarth/features/credits/services/payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

class PaymentBalanceNotifier extends AsyncNotifier<PaymentBalanceModel?> {
  @override
  Future<PaymentBalanceModel?> build() async {
    return _fetchBalance();
  }

  Future<PaymentBalanceModel?> _fetchBalance() async {
    final service = ref.read(paymentServiceProvider);
    return await service.fetchPaymentBalance();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBalance());
  }
}

final paymentBalanceProvider = AsyncNotifierProvider<PaymentBalanceNotifier, PaymentBalanceModel?>(() {
  return PaymentBalanceNotifier();
});
