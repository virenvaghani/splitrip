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
        friendsList.value = data.map((participantData) {
          final participant = ParticipantModel.fromJson(participantData);
          return FriendModel(participant: participant);
        }).toList();
      } else {
        errorMessage.value = 'Failed to fetch linked participants: ${response.statusCode}';
        friendsList.clear();
      }
    } catch (data) {
      errorMessage.value = 'Error fetching linked participants: ${data}';
      print('$data');
      friendsList.clear();
    }

    isLoading.value = false;
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