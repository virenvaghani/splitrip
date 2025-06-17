import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String? token;
  ApiService({this.token});
  static String get baseUrl => 'https://expense.jayamsoft.net/api';

  Future<void> saveUserToBackend({
    required String email,
    required String displayName,
    required String photoUrl,
    required String provider,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/social_login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': displayName,
          'image': photoUrl,
          'provider': provider,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          print('✅ User data saved and token stored: $token');
        } else {
          print('⚠️ Token not found in response');
          Get.snackbar('Error', 'Token not found in backend response');
        }
      } else {
        print(
          '❌ Failed to save user data: ${response.statusCode} ${response.body}',
        );
        Get.snackbar('Error', 'Failed to save user data to backend');
      }
    } catch (e) {
      print('🔥 Error saving user to backend: $e');
      Get.snackbar('Error', 'Error saving user data: $e');
    }
  }

  static Future<Map<String, dynamic>?> fetchTripInitData({int? tripId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("No token found");
      return null;
    }

    final url =
        tripId != null
            ? Uri.parse('$baseUrl/trips/$tripId/init/')
            : Uri.parse('$baseUrl/trips/init/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        print("Trip init data fetched successfully");
        return jsonDecode(response.body);
      } else {
        print("Failed to fetch trip init data: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching trip init data: $e");
      return null;
    }
  }
}
