import 'package:shared_preferences/shared_preferences.dart';

class PersistentStorage {
  static const String _landingKey = 'has_seen_landing';

  static Future<void> markLandingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_landingKey, true);
  }

  static Future<bool> shouldShowLanding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_landingKey) ?? false);
  }
}
