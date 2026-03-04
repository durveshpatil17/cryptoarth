class SignalModel {
  final String id;
  final String symbol;
  final String side;
  final num entryPrice;
  final num targetPrice;
  final num stopLoss;
  final num leverage;
  final num capital;
  final String orderType;
  final String status;
  final String timestamp;
  final String strategyName;

  SignalModel({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.targetPrice,
    required this.stopLoss,
    required this.leverage,
    required this.capital,
    required this.orderType,
    required this.status,
    required this.timestamp,
    required this.strategyName,
  });

  factory SignalModel.fromJson(Map<String, dynamic> json) {
    return SignalModel(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? 'N/A',
      side: json['side']?.toString() ?? 'N/A',
      entryPrice: num.tryParse(json['entry_price']?.toString() ?? '') ?? 0.0,
      targetPrice: num.tryParse(json['target_price']?.toString() ?? '') ?? 0.0,
      stopLoss: num.tryParse(json['stop_loss']?.toString() ?? '') ?? 0.0,
      leverage: num.tryParse(json['leverage']?.toString() ?? '') ?? 1.0,
      capital: num.tryParse(json['capital']?.toString() ?? '') ?? 0.0,
      orderType: json['order_type']?.toString() ?? 'Market',
      status: json['status']?.toString() ?? 'Pending',
      timestamp: json['timestamp']?.toString() ?? json['created_at']?.toString() ?? '',
      strategyName: json['strategy_name']?.toString() ?? 'AI Strategy',
    );
  }
}
