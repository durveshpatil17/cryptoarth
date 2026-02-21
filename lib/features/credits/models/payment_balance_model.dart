class PaymentBalanceModel {
  final num balance;

  PaymentBalanceModel({
    required this.balance,
  });

  factory PaymentBalanceModel.fromJson(Map<String, dynamic> json) {
    num mappedBalance = 0;
    
    if (json['balance'] is Map) {
      mappedBalance = num.tryParse(json['balance']['available_balance']?.toString() ?? json['balance']['total_balance']?.toString() ?? '0') ?? 0;
    } else {
      mappedBalance = num.tryParse(json['balance']?.toString() ?? json['credits']?.toString() ?? json['amount']?.toString() ?? json['total_credits']?.toString() ?? json['credit']?.toString() ?? json['available_balance']?.toString() ?? '') ?? 0;
    }

    return PaymentBalanceModel(
      balance: mappedBalance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
    };
  }
}
