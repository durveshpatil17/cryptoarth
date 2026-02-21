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
    return PositionModel(
      symbol: json['symbol']?.toString() ?? 'Unknown',
      quantity: num.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      entryPrice: num.tryParse(json['entry_price']?.toString() ?? '') ?? 0,
      currentPrice: num.tryParse(json['current_price']?.toString() ?? '') ?? 0,
      pnl: num.tryParse(json['pnl']?.toString() ?? '') ?? 0,
      pnlPercentage: num.tryParse(json['pnl_percentage']?.toString() ?? '') ?? 0,
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
