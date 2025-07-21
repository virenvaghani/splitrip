  import 'package:shared_preferences/shared_preferences.dart';

  class AuthStatusStorage {
    static const _userIdKey = 'userId';
    static const _userNameKey = 'userName';
    static const _userEmailKey = 'userEmail';
    static const _userImageKey = 'userImage';
    static const _userTokenKey = 'userToken';
    static const _userProvider = 'provider';

    // Save individual values
    static Future<void> saveUserId(String userId) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId.trim());
    }

    static Future<void> saveUserName(String userName) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, userName.trim());
    }

    static Future<void> saveUserEmail(String userEmail) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, userEmail.trim());
    }

    static Future<void> saveUserImage(String userImage) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userImageKey, userImage.trim());
    }

    static Future<void> saveUserToken(String userToken) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userTokenKey, userToken.trim());
    }


    static Future<void> saveUserProvider(String userProvider) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userProvider, userProvider.trim());
    }

    // Get individual values
    static Future<String?> getUserId() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    }

    static Future<String?> getUserName() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    }

    static Future<String?> getUserEmail() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    }

    static Future<String?> getUserImage() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userImageKey);
    }

    static Future<String?> getUserToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTokenKey);
    }

    static Future<String?> getUserProvider() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userProvider);
    }



    // Clear all
    static Future<void> clearAllUserData() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userImageKey);
      await prefs.remove(_userTokenKey);
      await prefs.remove(_userProvider);
    }
  }