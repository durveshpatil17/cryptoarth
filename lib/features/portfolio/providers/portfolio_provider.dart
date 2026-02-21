import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/portfolio/models/position_model.dart';
import 'package:cryptoarth/features/portfolio/services/portfolio_service.dart';

final portfolioServiceProvider = Provider<PortfolioService>((ref) {
  return PortfolioService();
});

class PortfolioNotifier extends AsyncNotifier<List<PositionModel>> {
  @override
  Future<List<PositionModel>> build() async {
    return _fetchPositions();
  }

  Future<List<PositionModel>> _fetchPositions() async {
    final service = ref.read(portfolioServiceProvider);
    return await service.fetchUserPositions();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPositions());
  }
}

final portfolioProvider = AsyncNotifierProvider<PortfolioNotifier, List<PositionModel>>(() {
  return PortfolioNotifier();
});
