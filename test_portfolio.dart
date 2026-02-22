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
  try {
    var response = await dio.get(
      'https://trade-api.cryptoarth.in/auth/get_user_positions/',
      options: Options(headers: {'Authorization': 'Bearer $tokenStr', 'Content-Type': 'application/json'}),
    );
    print('POSITIONS: ${response.data}');
    
    var responsePnl = await dio.get(
      'https://trade-api.cryptoarth.in/auth/get_user_pnl/',
      options: Options(headers: {'Authorization': 'Bearer $tokenStr'}),
    );
    print('PNL: ${responsePnl.data}');
    
    var responseOrders = await dio.get(
      'https://trade-api.cryptoarth.in/auth/orders/',
      options: Options(headers: {'Authorization': 'Bearer $tokenStr'}),
    );
    print('ORDERS: ${responseOrders.data}');
  } catch (e) {
    if (e is DioException) {
      print('ERROR: ${e.response?.data}');
    } else {
      print('ERROR: $e');
    }
  }
}
