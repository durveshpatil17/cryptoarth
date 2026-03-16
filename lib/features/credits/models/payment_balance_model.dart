class PaymentBalanceModel {
  final num balance;
  final num totalBalance;
  final num usedCredit;

  PaymentBalanceModel({
    required this.balance,
    this.totalBalance = 0,
    this.usedCredit = 0,
  });

  factory PaymentBalanceModel.fromJson(Map<String, dynamic> json) {
    num mappedBalance = 0;
    bool found = false;
    num mappedTotal = 0;
    num mappedUsed = 0;

    // Helper to extract from any dynamic value
    num? extract(dynamic val) {
      if (val == null) return null;
      if (val is num) return val;
      return num.tryParse(val.toString());
    }

    // 1. Check for nested 'balance' object which often contains the real fields
    if (json['balance'] is Map) {
      final inner = json['balance'] as Map<String, dynamic>;
      
      mappedTotal = extract(inner['total_balance'] ?? inner['total_credits']) ?? 0;
      mappedUsed = extract(inner['used_credit'] ?? inner['used_credits'] ?? inner['debit_amount']) ?? 0;
      
      final possibleInnerKeys = ['available_balance', 'available_credits', 'balance', 'total_balance', 'amount'];
      for (var key in possibleInnerKeys) {
        final val = extract(inner[key]);
        if (val != null) {
          mappedBalance = val;
          found = true;
          break;
        }
      }
      
      // Calculate avail if mapping says foundational for total-used
      if (!found && mappedTotal > 0) {
        mappedBalance = mappedTotal - mappedUsed;
        found = true;
      }
    }

    // 2. Check top-level keys if not found yet
    if (!found) {
      mappedTotal = extract(json['total_balance'] ?? json['total_credits']) ?? 0;
      mappedUsed = extract(json['used_credit'] ?? json['used_credits'] ?? json['debit_amount']) ?? 0;

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

      if (!found && mappedTotal > 0) {
        mappedBalance = mappedTotal - mappedUsed;
        found = true;
      }
    }

    return PaymentBalanceModel(
      balance: mappedBalance,
      totalBalance: mappedTotal,
      usedCredit: mappedUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'total_balance': totalBalance,
      'used_credit': usedCredit,
    };
  }
}
