import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/signals/models/signal_model.dart';
import 'package:cryptoarth/features/signals/services/signal_service.dart';

class SignalNotifier extends StateNotifier<AsyncValue<List<SignalModel>>> {
  final SignalService _service;

  SignalNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchSignals();
  }

  Future<void> fetchSignals() async {
    state = const AsyncValue.loading();
    try {
      final rawList = await _service.fetchSignals();
      final signals = rawList.map((j) => SignalModel.fromJson(j)).toList();
      state = AsyncValue.data(signals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => fetchSignals();
}

final signalProvider = StateNotifierProvider<SignalNotifier, AsyncValue<List<SignalModel>>>((ref) {
  return SignalNotifier(ref.watch(signalServiceProvider));
});
