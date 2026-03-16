import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/portfolio/models/user_order_details_model.dart';
import 'package:cryptoarth/features/portfolio/services/portfolio_service.dart';
import 'package:cryptoarth/features/portfolio/providers/portfolio_provider.dart';

class UserOrderDetailsFilter {
  final String startDate;
  final String endDate;
  final String strategy;
  final String tradeMode;

  UserOrderDetailsFilter({
    required this.startDate,
    required this.endDate,
    required this.strategy,
    required this.tradeMode,
  });

  UserOrderDetailsFilter copyWith({
    String? startDate,
    String? endDate,
    String? strategy,
    String? tradeMode,
  }) {
    return UserOrderDetailsFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      strategy: strategy ?? this.strategy,
      tradeMode: tradeMode ?? this.tradeMode,
    );
  }
}

final userOrderDetailsFilterProvider = StateProvider<UserOrderDetailsFilter>((ref) {
  final now = DateTime.now();
  final lastMonth = now.subtract(const Duration(days: 30));
  return UserOrderDetailsFilter(
    startDate: "${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}-${lastMonth.day.toString().padLeft(2, '0')}",
    endDate: "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
    strategy: "",
    tradeMode: "1",
  );
});

final userOrderDetailsProvider = FutureProvider<List<UserOrderDetailsModel>>((ref) async {
  final filter = ref.watch(userOrderDetailsFilterProvider);
  final service = ref.read(portfolioServiceProvider);
  return await service.fetchUserOrderDetails(
    startDate: filter.startDate,
    endDate: filter.endDate,
    strategy: filter.strategy,
    tradeMode: filter.tradeMode,
  );
});
