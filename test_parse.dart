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
      'https://trade-api.cryptoarth.in/auth/payment/balance/',
      options: Options(headers: {'Authorization': 'Bearer $tokenStr'}),
    );
    print('RAW DATA TYPE: ${response.data.runtimeType}');
    print('RAW DATA: ${response.data}');
  } catch (e) {
      print('ERROR: $e');
  }
}
