class PaymentLedgerModel {
  final String id;
  final num amount;
  final String transactionType;
  final String description;
  final String status;
  final String createdAt;

  PaymentLedgerModel({
    required this.id,
    required this.amount,
    required this.transactionType,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory PaymentLedgerModel.fromJson(Map<String, dynamic> json) {
    return PaymentLedgerModel(
      id: json['id']?.toString() ?? json['payment_id']?.toString() ?? json['ref_id']?.toString() ?? json['invoice_id']?.toString() ?? '',
      amount: num.tryParse(json['amount']?.toString() ?? json['debit_amount']?.toString() ?? json['paid_amount']?.toString() ?? '') ?? 0,
      transactionType: json['transaction_type']?.toString() ?? 'UNKNOWN',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? json['payment_status']?.toString() ?? 'Completed',
      createdAt: json['created_at']?.toString() ?? json['debit_datetime']?.toString() ?? json['recharge_datetime']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'transaction_type': transactionType,
      'description': description,
      'status': status,
      'created_at': createdAt,
    };
  }
}
