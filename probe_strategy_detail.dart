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
  
  print("Testing /auth/strategy/backtest/pine-code/?strategy_code=STRG-809F18");
  var res = await dio.get('https://trade-api.cryptoarth.in/auth/strategy/backtest/pine-code/?strategy_code=STRG-809F18');
  print("${res.statusCode} -> ${res.data}");
}
