import 'package:dio/dio.dart';

void main() async {
  final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzcyNTM3MTYyLCJpYXQiOjE3NzI0NTA3NjIsImp0aSI6IjBjNjBiZmY1ZmEzNTQ2NTRiMzExNmJkOGM3OTNlNjM3IiwidXNlcl9pZCI6IjE5In0.YcMA2P0OQDTwxVo7soup8nOfg8tajtI9XhkVNwjmWXI";
  final dio = Dio(BaseOptions(
    validateStatus: (s) => true,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }
  ));
  
  // Test check-phone with auth
  print("1. Testing POST /auth/check-phone/");
  var res = await dio.post('https://trade-api.cryptoarth.in/auth/check-phone/', data: {'phone': '9158912169'});
  print("${res.statusCode} -> ${res.data}");
  
  // Test check_user if exist
  print("2. Testing POST /auth/check_user/");
  res = await dio.post('https://trade-api.cryptoarth.in/auth/check_user/', data: {'phone': '9158912169'});
  print("${res.statusCode} -> ${res.data}");

}
