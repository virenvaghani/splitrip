import 'package:flutter/Material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/constants.dart';
import '../../data/token.dart';
import '../../model/trip/trip_model.dart';

class TripScreenController extends GetxController {
  final RxList<Trip> tripModelList = RxList();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final authToken = RxnString();
  final isTokenLoading = true.obs;
  final RxList<Trip> archivedTripList = RxList();

  @override
  void onInit() {
    super.onInit();
    fetchAndSetToken();
  }

  Future<void> fetchAndSetToken() async {
    print('[TripScreenController] Fetching token...');
    isTokenLoading.value = true;

    try {
      final token = await TokenStorage.getToken();
      authToken.value = token;
      isTokenLoading.value = false;

      if (token != null && token.isNotEmpty) {
        print('[TripScreenController] Token found, fetching friends...');
        await iniStateMethodForTripScreen();
      } else {
        print('[FriendController] No token, clearing friends list...');
        clearFriendsData();
      }
    } catch (e) {
      authToken.value = null;
      isTokenLoading.value = false;
      errorMessage.value = 'Failed to fetch token: $e';
      print('[FriendController] Error fetching token: $e');
    }
  }

  Future<void> iniStateMethodForTripScreen({
    BuildContext? context,
  }) async {
    isLoading.value = true;
    final token = authToken.value;

    try {


      if (token == null || token.isEmpty) {
        print('[TripController] Skipping fetch, no valid token.');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/trips/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('[TripController] HTTP ${response.statusCode}: ${response.body}');
        final data = jsonDecode(response.body);
        final tripsData = data['trips'] as List;

        final activeTrips = <Trip>[];
        final archivedTrips = <Trip>[];

        for (final tripJson in tripsData) {
          final trip = Trip.fromJson(tripJson);

          if (trip.isDeleted == true) continue;

          if (trip.isArchived == true) {
            archivedTrips.add(trip);
          } else {
            activeTrips.add(trip);
          }
        }

        tripModelList.value = activeTrips;
        archivedTripList.value = archivedTrips;

        tripModelList.refresh();
        archivedTripList.refresh();
      } else {
        Get.snackbar("Error", "Failed to fetch trips: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onDeleteTrip(Trip trip) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/trips/${trip.id}/delete/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        tripModelList.refresh();
      } else {
        throw Exception('Failed to delete trip: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting trip: $e');
    }
  }
  Future<void> addToArchive(Trip trip) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/trips/${trip.id}/archive/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simulate backend toggling archived status
        final updatedTrip = trip.copyWith(isArchived: !trip.isArchived);

        // Remove from both lists
        tripModelList.removeWhere((t) => t.id == trip.id);
        archivedTripList.removeWhere((t) => t.id == trip.id);

        // Add to appropriate list
        if (updatedTrip.isArchived) {
          archivedTripList.add(updatedTrip);
        } else {
          tripModelList.add(updatedTrip);
        }

        // Refresh the UI
        tripModelList.refresh();
        archivedTripList.refresh();
      } else {
        throw Exception('Failed to archive trip: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error archiving trip: $e');
    }
  }



  Future<void> saveTripOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Extract trip IDs in current order
      final tripIds = archivedTripList.map((trip) => trip.id).toList();
      // Save as JSON-encoded string
      await prefs.setString('archived_trip_order', jsonEncode(tripIds));
    } catch (e) {
      // Handle errors (e.g., storage failure)
      print('Error saving trip order: $e');
      // Optionally, notify user or retry
    }
  }

  // Optional: Method to load the saved order (for completeness)
  Future<void> loadTripOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripOrderJson = prefs.getString('archived_trip_order');
      if (tripOrderJson != null) {
        final List<String> tripIds = List<String>.from(jsonDecode(tripOrderJson));
        // Reorder archivedTripList based on saved IDs
        final reorderedTrips = <Trip>[];
        for (var id in tripIds) {
          final trip = archivedTripList.firstWhere(
                (trip) => trip.id == id,
            orElse: () => Trip(id: '', tripName: '', tripCurrency: '', tripEmoji: '', participantReferenceIds: []),
          );
          if (trip.id != null) {
            reorderedTrips.add(trip);
          }
        }
        // Update the observable list
        archivedTripList.assignAll(reorderedTrips);
      }
    } catch (e) {
      print('Error loading trip order: $e');
    }
  }

  void refreshArchivedTrips() {
  }

  void unarchiveTrip(Trip trip) {}

  Future<void> deletetrip(Trip trip) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/trips/${trip.id}/delete/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simulate backend toggling archived status

        // Remove from both lists
        tripModelList.removeWhere((t) => t.id == trip.id);
        archivedTripList.removeWhere((t) => t.id == trip.id);


        // Refresh the UI
        tripModelList.refresh();
        archivedTripList.refresh();
      } else {
        throw Exception('Failed to archive trip: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error archiving trip: $e');
    }
  }


  void refreshFriends() {
    print('[FriendController] Refreshing friends...');
    fetchAndSetToken();
  }

  void clearFriendsData() {
    tripModelList.clear();
    errorMessage.value = '';
    print('[FriendController] Friends data cleared');
  }

  void clearAllData() {
    tripModelList.clear();
    authToken.value = null;
    isTokenLoading.value = false;
    errorMessage.value = '';
    print('[FriendController] All data cleared');
  }
}
