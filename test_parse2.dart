import 'lib/features/credits/models/payment_balance_model.dart';

void main() {
  final json = {
    'success': true, 
    'balance': {
      'total_balance': 500.0, 
      'available_balance': 380.09, 
      'used_credit': 119.91
    }
  };

  print(PaymentBalanceModel.fromJson(json).balance);
}
