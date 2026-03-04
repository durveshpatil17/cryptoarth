class PositionModel {
  final String symbol;
  final num quantity;
  final num entryPrice;
  final num currentPrice;
  final num pnl;
  final num pnlPercentage;

  PositionModel({
    required this.symbol,
    required this.quantity,
    required this.entryPrice,
    required this.currentPrice,
    required this.pnl,
    required this.pnlPercentage,
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
