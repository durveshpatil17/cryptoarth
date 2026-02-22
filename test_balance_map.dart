import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'lib/features/credits/models/payment_balance_model.dart';
import 'lib/core/network/api_client.dart';
import 'lib/features/credits/services/payment_service.dart';

void main() async {
  // Let's manually get the token and bypass secure storage for this raw test
  var file = File('.dart_tool/chrome-device/Default/Tokens/token.json');
  if (!file.existsSync()) {
    print("Token not found");
  } else {
    var tokenStr = file.readAsStringSync().trim().replaceAll('"', '');
    print('Token: \$tokenStr');
  }

  // To simulate correctly, we bypass Flutter bindings by mocking the API call
  // We'll write a simple dio call
  var dio = Dio();
  try {
    var tokenStr = file.existsSync() ? file.readAsStringSync().trim().replaceAll('"', '') : '';
    var response = await dio.get(
      'https://trade-api.cryptoarth.in/auth/payment/balance/',
      options: Options(headers: {'Authorization': 'Bearer $tokenStr'}),
    );
    print('RAW DATA TYPE: ${response.data.runtimeType}');
    print('RAW DATA: ${response.data}');

    Map<String, dynamic> data = ApiClient.extractMap(response.data);
    print('EXTRACTED DATA: $data');

    PaymentBalanceModel model = PaymentBalanceModel.fromJson(data);
    print('MODEL BALANCE: ${model.balance}');

  } catch (e) {
      if (e is DioException) {
          print('ERROR: ${e.response?.data}');
      } else {
          print('ERROR: $e');
      }
  }
}
