import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:splitrip/data/constants.dart';
import 'package:splitrip/data/token.dart';

class TripDetailController extends GetxController {
  RxBool isLoading = false.obs;
  var selectedTabIndex = 0.obs;

  final trip = {}.obs;
  final summary = {}.obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final participants = <Map<String, dynamic>>[].obs;
  final participantShares = <String, double>{}.obs;

  List<Map<String, dynamic>> get todayTransactions {
    final now = DateTime.now();
    return transactions.where((t) {
      final tDate = DateTime.tryParse(t['created_at'] ?? '') ?? now;
      return isSameDate(tDate, now);
    }).toList();
  }

  List<Map<String, dynamic>> get yesterdayTransactions {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return transactions.where((t) {
      final tDate = DateTime.tryParse(t['created_at'] ?? '') ?? now;
      return isSameDate(tDate, yesterday);
    }).toList();
  }

  List<Map<String, dynamic>> get olderTransactions {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return transactions.where((t) {
      final tDate = DateTime.tryParse(t['created_at'] ?? '') ?? now;
      return tDate.isBefore(
        DateTime(yesterday.year, yesterday.month, yesterday.day),
      );
    }).toList();
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '', // No symbol
      decimalDigits: 2,
    );
    return format.format(amount).trim();
  }

  String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> fetchTripDetailById({
    required BuildContext context,
    required int tripId,
  }) async {
    isLoading.value = true;
    final token = await TokenStorage.getToken();

    if (token == null) {
      Get.snackbar("Please log in again", "");
      isLoading.value = false;
      return;
    }

    final Uri url = Uri.parse('${ApiConstants.baseUrl}/trips/$tripId');

    try {
      final response = await http.get(
        url,
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save trip data
        trip.value = data['trip_data'];

        // Save participants
        participants.assignAll(
          List<Map<String, dynamic>>.from(data['trip_data']['selected_participants']),
        );

        // Process and save transactions
        transactions.assignAll(
          List<Map<String, dynamic>>.from(data['transactions']).map((t) {
            final pyers = List<Map<String, dynamic>>.from(t['pyers'] ?? []);
            final splits = List<Map<String, dynamic>>.from(t['splits'] ?? []);

            // Find payer name (first payer for display)
            final paidBy = pyers.isNotEmpty
                ? participants.firstWhere(
                  (p) => p['id'] == pyers[0]['participant'],
              orElse: () => {'name': 'Unknown'},
            )['name']
                : 'Unknown';

            // Find only participants that exist in both pyers & splits
            final matchedShares = pyers.where((payer) {
              return splits.any((split) => split['participant'] == payer['participant']);
            }).map((payer) {
              final split = splits.firstWhere(
                    (s) => s['participant'] == payer['participant'],
                orElse: () => {'amount': '0'},
              );

              return {
                'participant': payer['participant'],
                'paid': double.tryParse(payer['amount'].toString()) ?? 0.0,
                'share': double.tryParse(split['amount'].toString()) ?? 0.0,
              };
            }).toList();

            return {
              'category': getCategoryName(t['category'] ?? 0),
              'paid_by': paidBy,
              'amount': t['amount'] ?? 0.0,
              'user_share': matchedShares, // only payer who also has split
              'created_at': t['created_at'] ?? DateTime.now().toIso8601String(),
              'type': t['type'] ?? 'expense',
              'tr_name': t['tr_name'] ?? '',
            };
          }).toList(),
        );



        calculateSummary();
        isLoading.value = false;
      } else {
        Get.snackbar('Error', 'Failed to fetch trip details: ${response.body}');
        isLoading.value = false;
      }
    } catch (e) {
      print('Error fetching trip details: $e');
      Get.snackbar('Error', 'An error occurred while fetching trip details');
      isLoading.value = false;
    }
  }

  Object getCategoryName(int categoryId) {
    // Map category ID to name (replace with actual category fetching logic)
    final categoryMap = Kconstant.categoryModelList;
    return categoryMap[categoryId] ?? 'Unknown';
  }

  void calculateSummary() {
    double totalExpenses = 0;
    double myExpenses = 0;
    double amountOwed = 0;

    for (var t in transactions) {
      final paidBy = t['paid_by'];
      final amount = (t['amount'] ?? 0.0) as double;
      final userShare = (t['user_share'] ?? 0.0) as double;

      if (t['type'] == 'expense') {
        totalExpenses += amount;
        if (paidBy == 'Viren') { // Replace 'Viren' with current user logic
          myExpenses += amount;
        }
        amountOwed += userShare;
      }
    }

    summary.value = {
      'total_expenses': totalExpenses,
      'my_expenses': myExpenses,
      'amount_owed': amountOwed,
    };
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    transactions.add(transaction);
    calculateSummary();
  }

  Color getTypeColor(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'expense':
        return theme.colorScheme.error;
      case 'income':
        return Colors.green;
      case 'transfer':
        return Colors.orange;
      default:
        return theme.colorScheme.primary;
    }
  }
}