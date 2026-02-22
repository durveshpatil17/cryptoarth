import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/portfolio/models/position_model.dart';
import 'package:cryptoarth/features/portfolio/services/portfolio_service.dart';

import 'package:cryptoarth/features/portfolio/providers/trading_mode_provider.dart';

final portfolioServiceProvider = Provider<PortfolioService>((ref) {
  return PortfolioService();
});

class PortfolioNotifier extends AsyncNotifier<List<PositionModel>> {
  @override
  Future<List<PositionModel>> build() async {
    // Watch trading mode to re-fetch when it changes
    ref.watch(tradingModeProvider);
    return _fetchPositions();
  }

  Future<List<PositionModel>> _fetchPositions() async {
    final mode = ref.read(tradingModeProvider);
    final service = ref.read(portfolioServiceProvider);
    
    if (mode == TradingMode.paper) {
      return await service.fetchUserPaperPositions();
    } else {
      return await service.fetchUserPositions();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPositions());
  }
}

final portfolioProvider = AsyncNotifierProvider<PortfolioNotifier, List<PositionModel>>(() {
  return PortfolioNotifier();
});
