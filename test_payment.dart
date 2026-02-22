import 'package:dio/dio.dart';
import 'dart:io';

void main() async {
  var file = File('.dart_tool/chrome-device/Default/Tokens/token.json');
  if (!file.existsSync()) {
    print("Token not found");
    return;
  }
  var tokenStr = file.readAsStringSync().trim().replaceAll('"', '');

  var dio = Dio();
  // 1. Check Balance Payload
  try {
    var response = await dio.get(
      'https://trade-api.cryptoarth.in/auth/payment/balance/',
      options: Options(headers: {'Authorization': 'Bearer $tokenStr'}),
    );
    print('ACTUAL BALANCE PAYLOAD: ${response.data}');
  } catch (e) {
    if (e is DioException) {
      print('BALANCE ERROR: ${e.response?.data}');
    } else {
      print('BALANCE ERROR: $e');
    }
  }

  // 2. Check Create Order Validation
  try {
    var response = await dio.post(
      'https://trade-api.cryptoarth.in/auth/payment/create-order/',
       data: {'amount': 500},
      options: Options(headers: {'Authorization': 'Bearer $tokenStr', 'Content-Type': 'application/json'}),
    );
    print('ACTUAL CREATE ORDER RESPONSE: ${response.data}');
  } catch (e) {
    if (e is DioException) {
      print('CREATE ORDER ERROR: ${e.response?.data}');
    } else {
      print('CREATE ORDER ERROR: $e');
    }
  }
}
