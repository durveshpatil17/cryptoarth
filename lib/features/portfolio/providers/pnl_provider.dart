import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/portfolio/models/pnl_model.dart';
import 'package:cryptoarth/features/portfolio/services/portfolio_service.dart';
import 'package:cryptoarth/features/portfolio/providers/portfolio_provider.dart';

class PnlNotifier extends AsyncNotifier<PnLModel> {
  @override
  Future<PnLModel> build() async {
    return _fetchPnL();
  }

  Future<PnLModel> _fetchPnL() async {
    final service = ref.read(portfolioServiceProvider);
    return await service.fetchUserPnL();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPnL());
  }
}

final pnlProvider = AsyncNotifierProvider<PnlNotifier, PnLModel>(() {
  return PnlNotifier();
});
