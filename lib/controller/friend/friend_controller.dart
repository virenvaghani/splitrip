import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/constants.dart';
import '../../data/token.dart';
import '../../model/friend/friend_model.dart';
import '../../model/friend/participant_model.dart';

class FriendController extends GetxController {
  final friendsList = <FriendModel>[].obs;
  final isLoading = false.obs;
  RxBool isDeleteBoxIsLoading = false.obs;
  RxBool isAddParticipantisLoading = false.obs;
  final errorMessage = ''.obs;
  final authToken = RxnString();
  final isTokenLoading = true.obs;



  @override
  void onInit() {
    super.onInit();
    fetchAndSetToken();
  }

  Future<void> fetchAndSetToken() async {
    isTokenLoading.value = true;

    try {
      final token = await TokenStorage.getToken();
      authToken.value = token;
      isTokenLoading.value = false;

      if (token != null && token.isNotEmpty) {
        await fetchLinkedParticipants();
      } else {
        clearFriendsData();
      }
    } catch (e) {
      authToken.value = null;
      isTokenLoading.value = false;
      errorMessage.value = 'Failed to fetch token: $e';
    }
  }

  Future<void> fetchLinkedParticipants() async {
    final token = authToken.value;
    if (token == null || token.isEmpty) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/participants/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print(data);
        Kconstant.friendModelList.clear();
        List<FriendModel> friendModelList = [];
        friendModelList = data
            .where((participantData) => participantData['is_deleted'] == false)
            .map((participantData) {
          final participant = ParticipantModel.fromJson(participantData);
          return FriendModel(participant: participant);
        }).toList();
        Kconstant.friendModelList.addAll(friendModelList);
      } else {
        errorMessage.value = 'Failed to fetch linked participants: ${response.statusCode}';
        friendsList.clear();
      }
    } catch (data) {
      errorMessage.value = 'Error fetching linked participants: $data';
      print('$data');
      friendsList.clear();
    }

    isLoading.value = false;
  }
  Future<void> deleteParticipant(FriendModel friend) async {
    final token = authToken.value;
    if (token == null || token.isEmpty) {
      return;
    }

    isDeleteBoxIsLoading.value = true;
    errorMessage.value = '';

    try {
      print("=============================================");
      print(friend.participant.id);

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/participants/${friend.participant.id}/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(data);

        // Remove from the local list
        Kconstant.friendModelList.removeWhere((t) => t.participant.id == friend.participant.id);
        Kconstant.friendModelList.refresh();

      } else {
        errorMessage.value = 'Failed to delete participant: ${response.statusCode}';
        friendsList.clear();
      }
    } catch (error) {
      errorMessage.value = 'Error deleting participant: $error';
      print('$error');
      friendsList.clear();
    }

    isDeleteBoxIsLoading.value = false;
  }




  void refreshFriends() {
    fetchAndSetToken();
  }

  void clearFriendsData() {
    friendsList.clear();
    errorMessage.value = '';
  }

  void clearAllData() {
    friendsList.clear();
    authToken.value = null;
    isTokenLoading.value = false;
    errorMessage.value = '';
  }
}