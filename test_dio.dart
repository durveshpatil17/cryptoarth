import 'package:dio/dio.dart';
import 'dart:io';

void main() async {
  var file = File('.dart_tool/chrome-device/Default/Tokens/token.json');
  if (!file.existsSync()) {
    print("Token not found. Run flutter app and login first.");
    return;
  }
  var tokenRaw = file.readAsStringSync().trim();
  var tokenStr = tokenRaw.replaceAll('"', '');

  print("Token: $tokenStr");
  
  var dio = Dio();
  try {
    var response = await dio.get(
      'https://trade-api.cryptoarth.in/auth/profile/',
      options: Options(headers: {'Authorization': 'Bearer $tokenStr', 'Content-Type': 'application/json'}),
    );
    print('SUCCESS! Response Data = ${response.data}');
  } on DioException catch (e) {
    print('ERROR! Status = ${e.response?.statusCode}');
    print('ERROR Data = ${e.response?.data}');
  } catch (e) {
    print('Unknown Error: $e');
  }
}
