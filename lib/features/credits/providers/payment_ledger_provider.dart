import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/credits/models/payment_ledger_model.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';

class PaymentLedgerNotifier extends AsyncNotifier<List<PaymentLedgerModel>> {
  @override
  Future<List<PaymentLedgerModel>> build() async {
    return _fetchLedger();
  }

  Future<List<PaymentLedgerModel>> _fetchLedger() async {
    final service = ref.read(paymentServiceProvider);
    return await service.fetchPaymentLedger();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLedger());
  }
}

final paymentLedgerProvider = AsyncNotifierProvider<PaymentLedgerNotifier, List<PaymentLedgerModel>>(() {
  return PaymentLedgerNotifier();
});
