import 'package:flutter/Material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:splitrip/data/constants.dart';
import 'package:splitrip/data/token.dart';
import 'package:http/http.dart' as http;

class TripDetailController extends GetxController {
  RxBool ismokLoading = false.obs;
  RxBool isLoading = false.obs;
  var selectedTabIndex = 0.obs;

  final trip = {}.obs;
  final summary = {}.obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final participantShares = <String, double>{}.obs;

  void shareTripLink(int tripId) {
    final url = 'https://expense.jayamsoft.net/trip?id=$tripId';
    SharePlus.instance.share(ShareParams(text: 'Join my trip: $url'));
  }

  List<Map<String, dynamic>> get todayTransactions {
    final now = DateTime.now();
    return transactions.where((t) {
      final tDate = DateTime.tryParse(t['date'] ?? '') ?? now;
      return isSameDate(tDate, now);
    }).toList();
  }

  List<Map<String, dynamic>> get yesterdayTransactions {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return transactions.where((t) {
      final tDate = DateTime.tryParse(t['date'] ?? '') ?? now;
      return isSameDate(tDate, yesterday);
    }).toList();
  }

  List<Map<String, dynamic>> get olderTransactions {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return transactions.where((t) {
      final tDate = DateTime.tryParse(t['date'] ?? '') ?? now;
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

        // Save the trip data (basic info and emoji)
        trip.value = data['trip_data'];

        // Extract selected participants from trip_data
        final participants = <Map<String, dynamic>>[].obs;
        participants.value = List<Map<String, dynamic>>.from(
          data['trip_data']['selected_participants'],
        );


        Kconstant.setParticipantsRx(participants);

        // Save transactions (optional: if you store them elsewhere)
        final transactions = List<Map<String, dynamic>>.from(
          data['transactions'],
        );
        Kconstant.setTransactions(
          transactions,
        ); // You can define this method similarly to setParticipantsRx()

        isLoading.value = false;
      }
    } catch (e) {
      print(e);
    }
  }

  void loadMockData() {
    final now = DateTime.now();

    transactions.value = [
      {
        'category': 'Salary',
        'paid_by': 'Viren',
        'amount': 15000.0,
        'user_share': 0.0,
        'date': DateFormat('yyyy-MM-dd').format(now),
        'type': 'income',
      },
      {
        'category': 'Food',
        'paid_by': 'Viren',
        'amount': 1200.0,
        'user_share': 400.0,
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 1))),
        'type': 'expense',
      },
      {
        'category': 'Bank Transfer',
        'paid_by': 'Prayag',
        'amount': 2000.0,
        'user_share': 500.0,
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 2))),
        'type': 'transfer',
      },
      {
        'category': 'Transport',
        'paid_by': 'Sandip',
        'amount': 800.0,
        'user_share': 200.0,
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 3))),
        'type': 'expense',
      },
      {
        'category': 'Freelance Payment',
        'paid_by': 'Akash',
        'amount': 8000.0,
        'user_share': 0.0,
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 4))),
        'type': 'income',
      },
      {
        'category': 'Shopping',
        'paid_by': 'Akash',
        'amount': 3000.0,
        'user_share': 750.0,
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 5))),
        'type': 'expense',
      },
      {
        'category': 'Payback',
        'paid_by': 'Sandip',
        'amount': 3000.0,
        'user_share': 750.0,
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 6))),
        'type': 'transfer',
      },
      {
        'category': 'Misc',
        'paid_by': 'Viren',
        'amount': 1500.0,
        'user_share': 375.0,
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 7))),
        'type': 'expense',
      },
      {
        'category': 'Bonus',
        'paid_by': 'Viren',
        'amount': 5000.0,
        'user_share': 0.0,
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 8))),
        'type': 'income',
      },
      {
        'category': 'Hotel',
        'paid_by': 'Prayag',
        'amount': 5000.0,
        'user_share': 1250.0,
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 9))),
        'type': 'expense',
      },
      {
        'category': 'Snacks',
        'paid_by': 'Sandip',
        'amount': 600.0,
        'user_share': 150.0,
        'date': DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 10))),
        'type': 'expense',
      },
    ];

    calculateSummary();
  }

  void calculateSummary() {
    double totalExpenses = 0;
    double myExpenses = 0;
    double amountOwed = 0;

    for (var t in transactions) {
      final paidBy = t['paid_by'];
      final amount = (t['amount'] ?? 0.0) as double;
      final userShare = (t['user_share'] ?? 0.0) as double;

      totalExpenses += amount;
      if (paidBy == 'Viren') {
        myExpenses += amount;
      }
      amountOwed += userShare;
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
