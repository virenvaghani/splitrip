import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:splitrip/data/token.dart';
import 'dart:convert';
import '../../data/constants.dart';
import '../../model/friend/friend_model.dart';
import '../../model/trip/participant_model.dart';

class FriendController extends GetxController {
  // Observable list to store FriendModel objects
  var friendsList = <FriendModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Method to fetch friends from the database via API
  Future<List<FriendModel>> fetchLinkedParticipants() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await TokenStorage.getToken(); // Await the async call

      if (token == null) {
        print('No authentication token found');
        Get.snackbar('Error', 'Authentication token not found');
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/participants/'),
        headers: {
          'Authorization': 'Token ${token.trim()}', // Use Bearer and trim token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Map Django response to ParticipantModel, then wrap in FriendModel
        friendsList.value = data.map((json) {
          final participant = ParticipantModel.fromJson(json);
          return FriendModel(participant: participant);
        }).toList();
        print('Friend list fetched successfully: ${friendsList.length} friends');
        return friendsList;
      } else {
        print('Failed to fetch friend list: ${response.statusCode} ${response.body}');
        Get.snackbar('Error', 'Failed to fetch friend list');
        throw Exception('Failed to fetch friend list: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching friend list: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Error fetching friend list: $e');
      throw Exception('Error fetching friend list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void removeFriend(String? referenceId) {
    if (referenceId != null) {
      friendsList.removeWhere((friend) => friend.participant.referenceId == referenceId);
      print('Removed friend with referenceId: $referenceId');
    }
  }
}