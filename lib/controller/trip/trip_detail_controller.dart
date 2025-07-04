import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class TripDetailController extends GetxController {
  var isLoading = true.obs;
  var selectedTabIndex = 0.obs;

  final trip = {}.obs;
  final summary = {}.obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final tabs = {}.obs;
  final participants = ["Viren", "Sandip", "Akash", "Prayag"].obs;
  final participantShares = <String, double>{}.obs;

  // For AddTransactionScreen
  final transactionType = 'expense'.obs;
  final transactionTitle = ''.obs;
  final transactionAmount = '0.0'.obs;
  final transactionPayers = <String>[].obs;
  final payerAmounts = <String, double>{}.obs;
  final transactionDate = DateTime.now().obs;
  final transactionSplitType = 'Equally'.obs;
  final transactionShares = <String, double>{}.obs;
  final customShares = <String, double>{}.obs;
  final isTransactionSubmitted = false.obs;
  final selectedCategory = 'Misc'.obs;
  final transactionRecipients = <String>[].obs; // Added for multiple recipients
  final recipientAmounts =
      <String, double>{}.obs; // Added for recipient amounts
  final transactionTypes = ['expense', 'income', 'transfer'].obs;
  final categories = ['Food', 'Travel', 'Stay', 'Misc'].obs;
  final splitTypes = ['Equally', 'As parts', 'As Amount'].obs;

  // Maps to store TextEditingControllers for payer and recipient amount inputs
  final Map<String, TextEditingController> _payerTextControllers = {};
  final Map<String, TextEditingController> _recipientTextControllers = {};

  @override
  void onInit() {
    super.onInit();
    fetchTripData();
    initializeShares();
  }

  // Get or create TextEditingController for a payer
  TextEditingController getPayerTextController(String name) {
    if (!_payerTextControllers.containsKey(name)) {
      _payerTextControllers[name] = TextEditingController(text: '');
    }
    return _payerTextControllers[name]!;
  }

  // Get or create TextEditingController for a recipient
  TextEditingController getRecipientTextController(String name) {
    if (!_recipientTextControllers.containsKey(name)) {
      _recipientTextControllers[name] = TextEditingController(text: '');
    }
    return _recipientTextControllers[name]!;
  }

  // Clean up controllers for payers and recipients no longer in their respective lists
  void cleanupPayerControllers() {
    final currentPayers = transactionPayers.toSet();
    _payerTextControllers.removeWhere((name, controller) {
      if (!currentPayers.contains(name)) {
        controller.dispose();
        return true;
      }
      return false;
    });
  }

  void cleanupRecipientControllers() {
    final currentRecipients = transactionRecipients.toSet();
    _recipientTextControllers.removeWhere((name, controller) {
      if (!currentRecipients.contains(name)) {
        controller.dispose();
        return true;
      }
      return false;
    });
  }

  @override
  void onClose() {
    _payerTextControllers.forEach((_, controller) => controller.dispose());
    _recipientTextControllers.forEach((_, controller) => controller.dispose());
    _payerTextControllers.clear();
    _recipientTextControllers.clear();
    super.onClose();
  }

  // Discard all transaction-related data
  void discardTransaction() {
    transactionType.value = 'expense';
    transactionTitle.value = '';
    transactionAmount.value = '0.0';
    transactionPayers.clear();
    payerAmounts.clear();
    transactionRecipients.clear(); // Reset recipients
    recipientAmounts.clear(); // Reset recipient amounts
    transactionDate.value = DateTime.now();
    transactionSplitType.value = 'Equally';
    transactionShares.clear();
    customShares.clear();
    isTransactionSubmitted.value = false;
    selectedCategory.value = 'Misc';
    _payerTextControllers.forEach((_, controller) {
      controller.text = '';
      controller.dispose();
    });
    _recipientTextControllers.forEach((_, controller) {
      controller.text = '';
      controller.dispose();
    });
    _payerTextControllers.clear();
    _recipientTextControllers.clear();
  }

  void initializeShares() {
    for (var person in participants) {
      participantShares[person] = 0.0;
      transactionShares[person] = 0.0;
      payerAmounts[person] = 0.0;
      recipientAmounts[person] = 0.0;
    }
  }

  List<Map<String, dynamic>> get todayTransactions {
    final today = DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(today);
    return transactions.where((t) => t['date'] == todayString).toList();
  }

  Future<void> fetchTripData() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      const mockResponse = '''
      {
        "trip": {
          "name": "Goa Trip",
          "emoji": "✌️",
          "currency": "INR"
        },
        "summary": {
          "total_expenses": 7500.00,
          "my_expenses": 3500.00,
          "total_income": 0.00,
          "my_income": 0.00,
          "amount_owed": 4000.00
        },
        "transactions": [
          {
            "id": "1",
            "type": "expense",
            "title": "Beach Party Drinks",
            "category": "Drinks",
            "icon": "local_drink",
            "amount": 5000.00,
            "payers": {"Viren": 5000.00},
            "user_share": 1250.00,
            "date": "2025-06-25",
            "split_type": "Equally",
            "shares": {
              "Viren": 1250.00,
              "Sandip": 1250.00,
              "Akash": 1250.00,
              "Prayag": 1250.00
            }
          },
          {
            "id": "2",
            "type": "expense",
            "title": "Dinner at Baga",
            "category": "Food",
            "icon": "restaurant",
            "amount": 2500.00,
            "payers": {"Sandip": 2500.00},
            "user_share": 625.00,
            "date": "2025-06-25",
            "split_type": "Equally",
            "shares": {
              "Viren": 625.00,
              "Sandip": 625.00,
              "Akash": 625.00,
              "Prayag": 625.00
            }
          }
        ],
        "tabs": {
          "balances_notification": 1,
          "photos_notification": 2
        }
      }
      ''';

      final data = jsonDecode(mockResponse);
      trip.value = data['trip'];
      summary.value = data['summary'];
      transactions.assignAll(
        List<Map<String, dynamic>>.from(data['transactions']),
      );
      tabs.value = data['tabs'];
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch trip data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  String formatCurrency(double amount) {
    final currency = trip['currency'] ?? 'INR';
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: currency == 'INR' ? '₹' : '\$',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  void updateTitle(String value) => transactionTitle.value = value;

  void updateAmount(String value) {
    transactionAmount.value = value;
    if (transactionType.value != 'transfer') {
      updateCalculatedShares();
    }
  }

  void togglePayer(String name) {
    if (transactionType.value == 'transfer' && transactionPayers.isNotEmpty) {
      // For transfers, allow only one payer
      final currentPayer = transactionPayers.first;
      transactionPayers.remove(currentPayer);
      payerAmounts.remove(currentPayer);
      if (_payerTextControllers.containsKey(currentPayer)) {
        _payerTextControllers[currentPayer]!.text = '';
      }
    }
    if (!transactionPayers.contains(name)) {
      transactionPayers.add(name);
      payerAmounts[name] = 0.0;
      getPayerTextController(name).text = '';
    } else {
      transactionPayers.remove(name);
      payerAmounts.remove(name);
      if (_payerTextControllers.containsKey(name)) {
        _payerTextControllers[name]!.text = '';
      }
    }
    cleanupPayerControllers();
    if (transactionType.value != 'transfer') {
      updateCalculatedShares();
    }
  }

  void updatePayerAmount(String name, double amount) {
    payerAmounts[name] = amount;
    if (transactionType.value != 'transfer') {
      updateCalculatedShares();
    }
  }

  void toggleRecipient(String name) {
    if (transactionRecipients.contains(name)) {
      transactionRecipients.remove(name);
      recipientAmounts.remove(name);
      if (_recipientTextControllers.containsKey(name)) {
        _recipientTextControllers[name]!.text = '';
      }
    } else {
      transactionRecipients.add(name);
      recipientAmounts[name] = 0.0;
      getRecipientTextController(name).text = '';
    }
    cleanupRecipientControllers();
  }

  void updateRecipientAmount(String name, double amount) {
    recipientAmounts[name] = amount;
  }

  void updateRecipient(String? value) {
    // Deprecated: Use toggleRecipient for multiple recipients
  }

  void updateDate(DateTime date) {
    transactionDate.value = date;
  }

  void updateSplitType(String value) {
    transactionSplitType.value = value;
    updateCalculatedShares();
  }

  void updateCustomShare(String person, double value) {
    customShares[person] = value;
    updateCalculatedShares();
  }

  void updateCategory(String? value) {
    if (value != null) selectedCategory.value = value;
  }

  void pickImage() {
    Get.snackbar('Image', 'Image picker to be implemented');
  }

  void updateCalculatedShares() {
    if (transactionType.value == 'transfer') return;

    final amount = double.tryParse(transactionAmount.value) ?? 0.0;
    final splitType = transactionSplitType.value;

    transactionShares.clear();
    transactionShares.addAll(calculateSplit(amount, splitType, customShares));
  }

  String remainingShareString() {
    if (transactionType.value == 'transfer') {
      final total = double.tryParse(transactionAmount.value) ?? 0.0;
      final assigned = recipientAmounts.values.fold(0.0, (sum, v) => sum + v);
      final remaining = total - assigned;
      return formatCurrency(remaining);
    }

    final total = double.tryParse(transactionAmount.value) ?? 0.0;
    final assigned = transactionShares.values.fold(0.0, (sum, v) => sum + v);
    final remaining = total - assigned;
    return formatCurrency(remaining);
  }

  void submitTransaction() {
    isTransactionSubmitted.value = true;

    if (transactionTitle.value.isEmpty) {
      Get.snackbar('Error', 'Please provide a valid title');
      return;
    }

    final totalAmount = double.tryParse(transactionAmount.value) ?? 0.0;
    if (totalAmount <= 0) {
      Get.snackbar('Error', 'Please provide a valid amount');
      return;
    }

    if (transactionPayers.isEmpty) {
      Get.snackbar('Error', 'Please select at least one payer');
      return;
    }

    if (transactionType.value == 'transfer') {
      if (transactionRecipients.isEmpty) {
        Get.snackbar('Error', 'Please select at least one recipient');
        return;
      }
      if (transactionPayers.length > 1) {
        Get.snackbar('Error', 'Transfer can only have one payer');
        return;
      }
      final totalReceived = recipientAmounts.values.fold(
        0.0,
        (sum, amount) => sum + amount,
      );
      if ((totalReceived - totalAmount).abs() > 0.01) {
        Get.snackbar(
          'Error',
          'Total received amounts must equal the transaction amount',
        );
        return;
      }
    } else {
      final totalPaid = payerAmounts.values.fold(
        0.0,
        (sum, amount) => sum + amount,
      );
      if ((totalPaid - totalAmount).abs() > 0.01) {
        Get.snackbar(
          'Error',
          'Total paid amounts must equal the transaction amount',
        );
        return;
      }
    }

    final transaction = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': transactionType.value,
      'title': transactionTitle.value,
      'category': selectedCategory.value,
      'icon': 'category',
      'amount': totalAmount,
      'payers': Map<String, double>.from(payerAmounts),
      'user_share':
          transactionType.value == 'transfer'
              ? 0.0
              : transactionShares['Viren'] ?? 0.0,
      'date': DateFormat('yyyy-MM-dd').format(transactionDate.value),
      'split_type':
          transactionType.value == 'transfer'
              ? 'None'
              : transactionSplitType.value,
      'shares':
          transactionType.value == 'transfer'
              ? {}
              : Map<String, double>.from(transactionShares),
      if (transactionType.value == 'transfer')
        'recipients': Map<String, double>.from(recipientAmounts),
    };

    addTransaction(transaction);
    Get.back();
  }

  void addTransaction(Map<String, dynamic> transaction) {
    transactions.add(transaction);

    final type = transaction['type'];
    final amount = transaction['amount'] ?? 0.0;
    final payers = Map<String, double>.from(transaction['payers'] ?? {});
    final shares = Map<String, double>.from(transaction['shares'] ?? {});
    final recipients =
        transaction['recipients'] != null
            ? Map<String, double>.from(transaction['recipients'])
            : <String, double>{};

    if (type == 'expense') {
      summary['total_expenses'] = (summary['total_expenses'] ?? 0.0) + amount;
      if (payers.containsKey('Viren')) {
        summary['my_expenses'] =
            (summary['my_expenses'] ?? 0.0) + (payers['Viren'] ?? 0.0);
      }
    } else if (type == 'income') {
      summary['total_income'] = (summary['total_income'] ?? 0.0) + amount;
      if (payers.containsKey('Viren')) {
        summary['my_income'] =
            (summary['my_income'] ?? 0.0) + (payers['Viren'] ?? 0.0);
      }
    } else if (type == 'transfer') {
      payers.forEach((payer, paidAmount) {
        participantShares[payer] =
            (participantShares[payer] ?? 0.0) - paidAmount;
      });
      recipients.forEach((recipient, receivedAmount) {
        participantShares[recipient] =
            (participantShares[recipient] ?? 0.0) + receivedAmount;
      });
    }

    summary['amount_owed'] =
        (summary['total_expenses'] ?? 0.0) -
        (summary['my_expenses'] ?? 0.0) +
        (summary['my_income'] ?? 0.0);

    if (type != 'transfer') {
      shares.forEach((person, share) {
        participantShares[person] = (participantShares[person] ?? 0.0) + share;
      });
    }
  }

  Map<String, double> calculateSplit(
    double amount,
    String splitType,
    Map<String, double> customShares,
  ) {
    final shares = <String, double>{};
    final participantCount = participants.length;

    if (amount <= 0) {
      Get.snackbar('Error', 'Amount must be greater than zero');
      return shares;
    }

    if (splitType == 'Equally') {
      final share = double.parse(
        (amount / participantCount).toStringAsFixed(2),
      );
      for (var person in participants) {
        shares[person] = share;
      }
    } else if (splitType == 'As parts') {
      final totalParts = customShares.values.fold(0.0, (sum, val) => sum + val);
      if (totalParts <= 0) {
        Get.snackbar('Error', 'Total parts must be greater than zero');
        return shares;
      }
      for (var person in participants) {
        final parts = customShares[person] ?? 0.0;
        final share = double.parse(
          ((parts / totalParts) * amount).toStringAsFixed(2),
        );
        shares[person] = share;
      }
    } else if (splitType == 'As Amount') {
      final totalAssigned = customShares.values.fold(
        0.0,
        (sum, val) => sum + val,
      );
      if ((totalAssigned - amount).abs() > 0.01) {
        Get.snackbar('Error', 'Assigned amounts must equal total amount');
        return shares;
      }
      for (var person in participants) {
        final share = double.parse(
          (customShares[person] ?? 0.0).toStringAsFixed(2),
        );
        shares[person] = share;
      }
    }

    return shares;
  }

  void removePayer(String name) {
    transactionPayers.remove(name);
    payerAmounts.remove(name);
    update(); // Optional if using GetBuilder
  }
}
