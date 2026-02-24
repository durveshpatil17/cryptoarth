class PaymentBalanceModel {
  final num balance;

  PaymentBalanceModel({
    required this.balance,
  });

  factory PaymentBalanceModel.fromJson(Map<String, dynamic> json) {
    num mappedBalance = 0;
    bool found = false;

    // Helper to extract from any dynamic value
    num? extract(dynamic val) {
      if (val == null) return null;
      if (val is num) return val;
      return num.tryParse(val.toString());
    }

    // 1. Check for nested 'balance' object which often contains the real fields
    if (json['balance'] is Map) {
      final inner = json['balance'] as Map<String, dynamic>;
      final possibleInnerKeys = ['available_balance', 'available_credits', 'balance', 'total_balance', 'amount'];
      for (var key in possibleInnerKeys) {
        final val = extract(inner[key]);
        if (val != null) {
          mappedBalance = val;
          found = true;
          break;
        }
      }
      
      // If we have total and used, but no available, calculate it
      if (!found) {
        final total = extract(inner['total_balance'] ?? inner['total_credits']);
        final used = extract(inner['used_credit'] ?? inner['used_credits'] ?? inner['debit_amount']);
        if (total != null && used != null) {
          mappedBalance = total - used;
          found = true;
        }
      }
    }

    // 2. Check top-level keys if not found yet
    if (!found) {
      final possibleTopKeys = [
        'available_balance', 'available_credits', 'wallet_balance', 
        'balance', 'credits', 'amount', 'total_credits', 'total_balance'
      ];
      for (var key in possibleTopKeys) {
        final val = extract(json[key]);
        if (val != null) {
          mappedBalance = val;
          found = true;
          break;
        }
      }
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
