import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    validateStatus: (s) => true,
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzcyNTM3MTYyLCJpYXQiOjE3NzI0NTA3NjIsImp0aSI6IjBjNjBiZmY1ZmEzNTQ2NTRiMzExNmJkOGM3OTNlNjM3IiwidXNlcl9pZCI6IjE5In0.YcMA2P0OQDTwxVo7soup8nOfg8tajtI9XhkVNwjmWXI',
    }
  ));
  
  final candidates = [
    '/auth/check-phone/',
    '/auth/check_phone/',
    '/auth/get_user/',
    '/auth/search_user/',
    '/auth/search-user/',
    '/auth/find_user/',
    '/auth/strategy/search-user/',
    '/auth/user/',
  ];
  
  for (var c in candidates) {
    try {
      final res = await dio.get('https://trade-api.cryptoarth.in$c?phone=9158912169');
      if (res.statusCode == 200 || res.statusCode == 201) {
         print("SUCCESS: GET $c -> ${res.data}");
      }
      final res2 = await dio.get('https://trade-api.cryptoarth.in$c?phone=919158912169');
      if (res2.statusCode == 200 || res2.statusCode == 201) {
         print("SUCCESS: GET $c -> ${res2.data}");
      }
    } catch(e) {}
  }
}
