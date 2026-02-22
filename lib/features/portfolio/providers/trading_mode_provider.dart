import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TradingMode { live, paper }

final tradingModeProvider = StateProvider<TradingMode>((ref) {
  return TradingMode.live;
});
