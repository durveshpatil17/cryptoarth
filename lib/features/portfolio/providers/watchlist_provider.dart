import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/portfolio/providers/portfolio_provider.dart';

class WatchlistNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    return _fetchWatchlist();
  }

  Future<List<dynamic>> _fetchWatchlist() async {
    final service = ref.read(portfolioServiceProvider);
    return await service.fetchUserWatchlist();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchWatchlist());
  }
}

final watchlistProvider = AsyncNotifierProvider<WatchlistNotifier, List<dynamic>>(() {
  return WatchlistNotifier();
});
