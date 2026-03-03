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
  
  var res = await dio.get('https://trade-api.cryptoarth.in/auth/strategy/copilot/history/');
  if (res.statusCode == 200 && res.data is List && res.data.isNotEmpty) {
    var session = res.data[0];
    String sessionId = session['id'];
    print("Full History for " + sessionId);
    var res2 = await dio.get('https://trade-api.cryptoarth.in/auth/strategy/copilot/chat/?session_id=' + sessionId);
    print(res2.data);
  }
}
