import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    validateStatus: (s) => true,
    headers: {
      'Content-Type': 'application/json',
    }
  ));
  
  var res = await dio.post('https://trade-api.cryptoarth.in/auth/check-phone/', data: {'phone': '+919158912169'});
  print("1: ${res.data}");
  var res2 = await dio.post('https://trade-api.cryptoarth.in/auth/check-phone/', data: {'phone': '91 9158912169'});
  print("2: ${res2.data}");
  var res3 = await dio.post('https://trade-api.cryptoarth.in/auth/check-phone/', data: {'phone': '09158912169'});
  print("3: ${res3.data}");
  var res4 = await dio.post('https://trade-api.cryptoarth.in/auth/check-phone/', data: {'phone': '91589 12169'});
  print("4: ${res4.data}");
  var res5 = await dio.post('https://trade-api.cryptoarth.in/auth/check-phone/', data: {'phone': '919158912169'});
  print("5: ${res5.data}");
}
