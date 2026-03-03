import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzcyNTM3MTYyLCJpYXQiOjE3NzI0NTA3NjIsImp0aSI6IjBjNjBiZmY1ZmEzNTQ2NTRiMzExNmJkOGM3OTNlNjM3IiwidXNlcl9pZCI6IjE5In0.YcMA2P0OQDTwxVo7soup8nOfg8tajtI9XhkVNwjmWXI";

    print("Calling /auth/check-phone/");
    final res = await dio.post(
      'https://trade-api.cryptoarth.in/auth/check-phone/',
      data: {'phone': '919158912169'},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    print(res.data);
  } catch (e) {
    if (e is DioException) {
      print("ERROR: \${e.response?.statusCode}");
      print(e.response?.data);
    } else {
      print(e);
    }
  }
}
