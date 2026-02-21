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
    return OrderModel(
      orderId: int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      symbol: json['symbol']?.toString() ?? 'Unknown',
      quantity: num.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      price: num.tryParse(json['price']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'UNKNOWN',
      timestamp: json['timestamp']?.toString() ?? '',
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
