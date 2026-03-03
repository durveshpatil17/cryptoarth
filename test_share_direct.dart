import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    validateStatus: (s) => true,
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzcyNTM3MTYyLCJpYXQiOjE3NzI0NTA3NjIsImp0aSI6IjBjNjBiZmY1ZmEzNTQ2NTRiMzExNmJkOGM3OTNlNjM3IiwidXNlcl9pZCI6IjE5In0.YcMA2P0OQDTwxVo7soup8nOfg8tajtI9XhkVNwjmWXI',
      'Content-Type': 'application/json',
    }
  ));
  
  var res = await dio.post('https://trade-api.cryptoarth.in/auth/strategy/backtest/share/', data: {
    'strategy_code': 'STRG-0137DB',
    'phone': '9158912169'
  });
  print("Phone 91589: ${res.data}");

  var res2 = await dio.post('https://trade-api.cryptoarth.in/auth/strategy/backtest/share/', data: {
    'strategy_code': 'STRG-0137DB',
    'phone': '919158912169'
  });
  print("Phone 9191589: ${res2.data}");
}
