import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // Create secure storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Key name used to store token
  static const String _tokenKey = 'jwt_token';

  // Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(
      key: _tokenKey,
    );
  }

  // Delete token (logout)
  static Future<void> deleteToken() async {
    await _storage.delete(
      key: _tokenKey,
    );
  }
}
