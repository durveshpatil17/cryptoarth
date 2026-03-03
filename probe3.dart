import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    validateStatus: (s) => true,
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzcyNTM3MTYyLCJpYXQiOjE3NzI0NTA3NjIsImp0aSI6IjBjNjBiZmY1ZmEzNTQ2NTRiMzExNmJkOGM3OTNlNjM3IiwidXNlcl9pZCI6IjE5In0.YcMA2P0OQDTwxVo7soup8nOfg8tajtI9XhkVNwjmWXI',
      'Content-Type': 'application/json',
    }
  ));
  
  final candidates = [
    '/auth/check-user-phone/',
    '/auth/strategy/check-user/',
    '/auth/strategy/backtest/share/check-user/', // POSTMAN SAYS backtest share
    '/auth/strategy/share/check-user/',          // OR THIS
    '/auth/search-user/',
    '/auth/user/search/',
  ];
  
  for (var c in candidates) {
    try {
      final res = await dio.post('https://trade-api.cryptoarth.in$c', data: {'phone': '9158912169'});
      print("$c -> ${res.statusCode}");
      if(res.statusCode == 200) print(res.data);
    } catch(e) {}
  }
}
