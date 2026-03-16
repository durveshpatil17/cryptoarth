class UserOrderDetailsModel {
  final String symbol;
  final String orderId;
  final num buyPrice;
  final num sellPrice;
  final num quantity;
  final String side;
  final String datetime;
  final num profit;
  final String strategyName;

  UserOrderDetailsModel({
    required this.symbol,
    required this.orderId,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    required this.side,
    required this.datetime,
    required this.profit,
    required this.strategyName,
  });

  factory UserOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserOrderDetailsModel(
      symbol: json['symbol']?.toString() ?? '',
      orderId: (json['order_id'] ?? json['orderId'] ?? json['id'] ?? '').toString(),
      buyPrice: num.tryParse(json['buy_price']?.toString() ?? json['buyPrice']?.toString() ?? '') ?? 0.0,
      sellPrice: num.tryParse(json['sell_price']?.toString() ?? json['sellPrice']?.toString() ?? '') ?? 0.0,
      quantity: num.tryParse(json['quantity']?.toString() ?? json['qty'] ?? '') ?? 0.0,
      side: json['side']?.toString() ?? '',
      datetime: json['datetime']?.toString() ?? json['created_at']?.toString() ?? json['date']?.toString() ?? '',
      profit: num.tryParse(json['profit']?.toString() ?? json['pnl']?.toString() ?? '') ?? 0.0,
      strategyName: json['strategy_name']?.toString() ?? json['strategy']?.toString() ?? '',
    );
  }
}
