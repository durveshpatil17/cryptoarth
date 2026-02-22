import 'dart:convert';
import 'lib/features/strategies/models/strategy_model.dart';
void main() {
  try {
    var raw = '{"id":"9b93ab84","strategy_name":"RSI Oversold Buy","is_active":null,"is_deployed":null,"broker_id":null,"win_rate":26.47,"total_pnl":-10857.35,"max_drawdown":null}';
    var m = StrategyModel.fromJson(jsonDecode(raw));
    print("Parsed: ${m.strategyName}, active: ${m.isActive}");
  } catch(e, s) {
    print("Error parsing: $e\n$s");
  }
}
