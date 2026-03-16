class PositionModel {
  final String symbol;
  final num quantity;
  final num entryPrice;
  final num currentPrice;
  final num pnl;
  final num pnlPercentage;
  final String? strategyName;
  final String? strategyCode;
  final String? brokerName;
  final String? orderId;
  final String? side;
  final String? dateTime;

  PositionModel({
    required this.symbol,
    required this.quantity,
    required this.entryPrice,
    required this.currentPrice,
    required this.pnl,
    required this.pnlPercentage,
    this.strategyName,
    this.strategyCode,
    this.brokerName,
    this.orderId,
    this.side,
    this.dateTime,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    final String rawQty = (json['quantity'] ?? json['qty'] ?? json['size'] ?? '').toString();
    final String rawEntry = (json['entry_price'] ?? json['avg_price'] ?? '').toString();
    final String rawCurrent = (json['current_price'] ?? json['last_price'] ?? json['mark_price'] ?? '').toString();
    final String rawPnl = (json['pnl'] ?? json['unrealized_pnl'] ?? json['total_pnl'] ?? '').toString();
    final String rawPct = (json['pnl_percentage'] ?? json['roe'] ?? json['pnl_pct'] ?? '').toString();

    return PositionModel(
      symbol: json['symbol']?.toString() ?? 'Unknown',
      quantity: num.tryParse(rawQty) ?? 0,
      entryPrice: num.tryParse(rawEntry) ?? 0,
      currentPrice: num.tryParse(rawCurrent) ?? 0,
      pnl: num.tryParse(rawPnl) ?? 0,
      pnlPercentage: num.tryParse(rawPct) ?? 0,
      strategyName: json['strategy_name']?.toString(),
      strategyCode: json['strategy_code']?.toString(),
      brokerName: json['broker_name']?.toString(),
      orderId: (json['order_id'] ?? json['id'])?.toString(),
      side: json['side']?.toString() ?? (num.tryParse(rawQty) != null && (num.tryParse(rawQty)! >= 0) ? "BUY" : "SELL"),
      dateTime: json['date_time'] ?? json['timestamp'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'quantity': quantity,
      'entry_price': entryPrice,
      'current_price': currentPrice,
      'pnl': pnl,
      'pnl_percentage': pnlPercentage,
    };
  }
}
