class BrokerBalanceModel {
  final num balance;
  final num equity;
  final num availableMargin;
  final num usedMargin;

  BrokerBalanceModel({
    required this.balance,
    required this.equity,
    required this.availableMargin,
    required this.usedMargin,
  });

  factory BrokerBalanceModel.fromJson(Map<String, dynamic> json) {
    return BrokerBalanceModel(
      balance: json['balance'] ?? 0,
      equity: json['equity'] ?? 0,
      availableMargin: json['available_margin'] ?? 0,
      usedMargin: json['used_margin'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'equity': equity,
      'available_margin': availableMargin,
      'used_margin': usedMargin,
    };
  }
}
