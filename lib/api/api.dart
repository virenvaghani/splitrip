import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:splitrip/data/token.dart';

class ApiService {
  final String? token;
  ApiService({this.token});
  static String get baseUrl => 'https://expense.jayamsoft.net';

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
        final token = responseData['token']?.trim(); // Trim to avoid spaces

        if (token != null && token.isNotEmpty) {
          await TokenStorage.saveToken(token); // Save the actual token
          print('User data saved and token stored: $token');
        } else {
          print('Token not found or invalid in response');
          Get.snackbar('Error', 'Token not found in backend response');
        }
      } else {
        print('Failed to save user data: ${response.statusCode} ${response.body}');
        Get.snackbar('Error', 'Failed to save user data to backend');
      }
    } catch (e) {
      print('Error saving user to backend: $e');
      Get.snackbar('Error', 'Error saving user data: $e');
    }
  }
}