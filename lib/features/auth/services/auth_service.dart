import 'package:dio/dio.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/core/network/api_endpoints.dart';
import 'package:cryptoarth/core/storage/token_storage.dart';
import '../../../core/utils/phone_utils.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<void> sendOtp(String phone) async {
    final normalizedPhone = PhoneUtils.normalize(phone);
    await _apiClient.post(
      ApiEndpoints.sendOtp,
      { "phone": normalizedPhone },
    );
  }

  Future<bool> checkPhone(String phone) async {
    final normalizedPhone = PhoneUtils.normalize(phone);
    try {
      final Response response = await _apiClient.post(
        ApiEndpoints.checkPhone,
        { "phone": normalizedPhone },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      return false; // Silent for existence check
    } catch (_) {
      return false;
    }
  }

  Future<bool> login(String phone, String otp) async {
    final normalizedPhone = PhoneUtils.normalize(phone);

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
        _consumeOtp();
        return true;
      }
    }
    return false;
  }

  Future<void> _consumeOtp() async {
    try {
      await _apiClient.post(ApiEndpoints.consumeOtp, {});
    } catch (_) {}
  }

  Future<bool> signup(String phone, String otp, String email, String firstName, String lastName, {String refercode = ""}) async {
    final normalizedPhone = PhoneUtils.normalize(phone);
    final Response response = await _apiClient.post(
      ApiEndpoints.signup,
      {
        "phone": normalizedPhone,
        "otp": otp,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "refercode": refercode,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data != null && data["access"] != null) {
        await TokenStorage.saveToken(data["access"]);
        _consumeOtp();
        return true;
      }
    }
    return false;
  }

  Future<Map<String, dynamic>?> checkSession() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.session);
      return ApiClient.extractMap(response.data);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final Response response = await _apiClient.get(ApiEndpoints.profile);
    return ApiClient.extractMap(response.data);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    final Response response = await _apiClient.patch(ApiEndpoints.profile, data: updates);
    return ApiClient.extractMap(response.data);
  }

  Future<List<dynamic>> fetchNotifications() async {
    final Response response = await _apiClient.get(ApiEndpoints.notifications);
    return ApiClient.extractList(response.data);
  }

  Future<String> fetchReferralLink() async {
    final Response response = await _apiClient.get(ApiEndpoints.referralLink);
    final data = ApiClient.extractMap(response.data);
    return data['referal_link'] ?? data['link'] ?? data['url'] ?? '';
  }
}
