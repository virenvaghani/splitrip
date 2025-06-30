import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/constants.dart';
import '../../data/token.dart';
import '../../model/friend/friend_model.dart';

class FriendController extends GetxController {
  // Observable list to store FriendModel objects
  var friendsList = <FriendModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs; // Added for error display in FriendsPage

  // Method to fetch friends from the database via API
  Future<void> fetchFriends() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Reset error message

      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Authentication token is missing';
        Get.snackbar('Error', 'Please log in to fetch friends');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/participants/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        // Assuming the API returns a list of friend objects
        final List<dynamic> data = jsonDecode(response.body);
        friendsList.assignAll(data.map((json) => FriendModel.fromJson(json)).toList());
      } else {
        errorMessage.value = 'Failed to fetch friends: ${response.statusCode}';
        Get.snackbar('Error', 'Failed to fetch friends: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Optional: Method to remove a friend (for future implementation)
  void removeFriend(String? id) {
    if (id != null) {
      friendsList.removeWhere((friend) => friend.participant?.id == id);
    }
  }
}