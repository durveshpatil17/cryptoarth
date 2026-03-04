class OrderModel {
  final int orderId;
  final String symbol;
  final num quantity;
  final num price;
  final String status;
  final String timestamp;

  OrderModel({
    required this.orderId,
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.status,
    required this.timestamp,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final String rawOrderId = (json['order_id'] ?? json['id'] ?? json['trade_id'] ?? '').toString();
    final String rawQty = (json['quantity'] ?? json['qty'] ?? json['size'] ?? '').toString();
    final String rawPrice = (json['price'] ?? json['avg_price'] ?? json['entry_price'] ?? '').toString();

    return OrderModel(
      orderId: int.tryParse(rawOrderId) ?? 0,
      symbol: json['symbol']?.toString() ?? 'Unknown',
      quantity: num.tryParse(rawQty) ?? 0,
      price: num.tryParse(rawPrice) ?? 0,
      status: json['status']?.toString() ?? 'UNKNOWN',
      timestamp: json['timestamp']?.toString() ?? json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'symbol': symbol,
      'quantity': quantity,
      'price': price,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
