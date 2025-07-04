import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmedToken = token.trim(); // Remove any leading/trailing spaces
    print('Saving token: $trimmedToken'); // Debug log
    await prefs.setString(_tokenKey, trimmedToken);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('Retrieved token: $token'); // Debug log
    return token;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('Token cleared'); // Debug log
  }
}