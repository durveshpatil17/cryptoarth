import 'package:dio/dio.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/core/network/api_endpoints.dart';
import 'package:cryptoarth/core/storage/token_storage.dart';
import '../../../core/utils/phone_utils.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<void> sendOtp(String phone) async {
    final normalizedPhone = PhoneUtils.normalize(phone);

    print("FINAL PHONE FORMAT → $normalizedPhone");
    print("SEND OTP REQUEST → $normalizedPhone");

    final Response response = await _apiClient.post(
      ApiEndpoints.sendOtp,
      { "phone": normalizedPhone },
    );

    print("SEND OTP RESPONSE → ${response.data}");
  }

  Future<bool> login(String phone, String otp) async {
    final normalizedPhone = PhoneUtils.normalize(phone);

    print("FINAL PHONE FORMAT → $normalizedPhone");
    print("LOGIN REQUEST → $normalizedPhone");

    try {
      final Response response = await _apiClient.post(
        ApiEndpoints.login,
        {
          "phone": normalizedPhone,
          "otp": otp,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data != null && data["access"] != null) {
          await TokenStorage.saveToken(data["access"]);
          print("TOKEN SAVED SUCCESSFULLY");
          return true;
        }
      }
    } catch (_) {}

    return false;
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final Response response =
          await _apiClient.get(ApiEndpoints.profile);

      return ApiClient.extractMap(response.data);
    } catch (e) {
      print("PROFILE ERROR → $e");
      throw Exception("Failed to fetch profile");
    }
  }
}
