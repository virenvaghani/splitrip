import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';

class TransactionException implements Exception {
  final String message;
  TransactionException(this.message);
}

class TransactionScreenController extends GetxController {
  // Reactive state
  final hasChanges = false.obs;
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
  final transactionRecipients = <String>[].obs;
  final recipientAmounts = <String, double>{}.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final titleError = ''.obs;
  final amountError = ''.obs;
  final payersError = ''.obs;
  final recipientsError = ''.obs;

  // Constants
  static const List<String> transactionTypes = ['expense', 'income', 'transfer'];
  static const List<String> categories = ['Food', 'Travel', 'Stay', 'Misc'];
  static const List<String> splitTypes = ['Equally', 'As parts', 'As Amount'];

  // Controllers and dependencies
  final Map<String, TextEditingController> _payerTextControllers = {};
  final Map<String, TextEditingController> _recipientTextControllers = {};
  late final TripDetailController _tripDetailController;
  late TabController tabController;

  TransactionScreenController();

  @override
  void onInit() {
    super.onInit();
    _tripDetailController = Get.find<TripDetailController>();
    _initializeShares();
    _setupValidation();
  }

  void _initializeShares() {
    for (var person in _tripDetailController.participants) {
      transactionShares[person] = 0.0;
      payerAmounts[person] = 0.0;
      recipientAmounts[person] = 0.0;
      customShares[person] = 0.0;
    }
  }

  void _setupValidation() {
    everAll([transactionTitle, transactionAmount, transactionPayers, transactionRecipients, transactionType], (_) {
      hasChanges.value = true;
    });
  }

  void setTabController(TabController controller) {
    tabController = controller;
    _setupTabListener();
  }

  void _setupTabListener() {
    tabController.addListener(() {
      final index = tabController.index;
      if (index < transactionTypes.length) {
        transactionType.value = transactionTypes[index];
        discardTransaction();
        hasChanges.value = false;
      }
    });
  }

  TextEditingController getPayerTextController(String name) {
    return _payerTextControllers.putIfAbsent(name, () => TextEditingController(text: ''));
  }

  TextEditingController getRecipientTextController(String name) {
    return _recipientTextControllers.putIfAbsent(name, () => TextEditingController(text: ''));
  }

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
    tabController.dispose();
    super.onClose();
  }

  void discardTransaction() {
    transactionType.value = transactionTypes[0];
    transactionTitle.value = '';
    transactionAmount.value = '0.0';
    transactionPayers.clear();
    payerAmounts.clear();
    transactionRecipients.clear();
    recipientAmounts.clear();
    transactionDate.value = DateTime.now();
    transactionSplitType.value = 'Equally';
    transactionShares.clear();
    customShares.clear();
    isTransactionSubmitted.value = false;
    selectedCategory.value = categories[0];
    titleError.value = '';
    amountError.value = '';
    payersError.value = '';
    recipientsError.value = '';
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
    _initializeShares();
  }

  void updateTitle(String value) {
    transactionTitle.value = value.trim();
    hasChanges.value = true;
    if (isTransactionSubmitted.value) titleError.value = value.isEmpty ? 'Title is required' : '';
  }

  void updateAmount(String value) {
    transactionAmount.value = value.trim();
    if (transactionType.value != 'transfer') {
      updateCalculatedShares();
    }
    hasChanges.value = true;
    if (isTransactionSubmitted.value) {
      amountError.value = (double.tryParse(value) ?? 0.0) <= 0 ? 'Amount must be greater than zero' : '';
    }
  }

  void togglePayer(String name) {
    if (transactionType.value == 'transfer' && transactionPayers.isNotEmpty && !transactionPayers.contains(name)) {
      final currentPayer = transactionPayers.first;
      transactionPayers.remove(currentPayer);
      payerAmounts.remove(currentPayer);
      _payerTextControllers[currentPayer]?.text = '';
    }
    if (!transactionPayers.contains(name)) {
      transactionPayers.add(name);
      payerAmounts[name] = 0.0;
      getPayerTextController(name).text = '';
    } else {
      transactionPayers.remove(name);
      payerAmounts.remove(name);
      _payerTextControllers[name]?.text = '';
    }
    cleanupPayerControllers();
    if (transactionType.value != 'transfer') {
      updateCalculatedShares();
    }
    hasChanges.value = true;
    if (isTransactionSubmitted.value) {
      payersError.value = transactionPayers.isEmpty ? 'At least one payer is required' : '';
    }
  }

  void updatePayerAmount(String name, double amount) {
    payerAmounts[name] = amount;
    if (transactionType.value != 'transfer') {
      updateCalculatedShares();
    }
    hasChanges.value = true;
  }

  void toggleRecipient(String name) {
    if (transactionRecipients.contains(name)) {
      transactionRecipients.remove(name);
      recipientAmounts.remove(name);
      _recipientTextControllers[name]?.text = '';
    } else {
      transactionRecipients.add(name);
      recipientAmounts[name] = 0.0;
      getRecipientTextController(name).text = '';
    }
    cleanupRecipientControllers();
    hasChanges.value = true;
    if (isTransactionSubmitted.value) {
      recipientsError.value = transactionType.value == 'transfer' && transactionRecipients.isEmpty ? 'At least one recipient is required' : '';
    }
  }

  void updateRecipientAmount(String name, double amount) {
    recipientAmounts[name] = amount;
    hasChanges.value = true;
  }

  void updateDate(DateTime date) {
    transactionDate.value = date;
    hasChanges.value = true;
  }

  void updateSplitType(String value) {
    if (splitTypes.contains(value)) {
      transactionSplitType.value = value;
      updateCalculatedShares();
      hasChanges.value = true;
    }
  }

  void updateCustomShare(String person, double value) {
    customShares[person] = value;
    updateCalculatedShares();
    hasChanges.value = true;
  }

  void updateCategory(String? value) {
    if (value != null && categories.contains(value)) {
      selectedCategory.value = value;
      hasChanges.value = true;
    }
  }

  void pickImage() {
    Get.snackbar('Image', 'Image picker to be implemented');
  }

  void updateCalculatedShares() {
    if (transactionType.value == 'transfer') return;

    final amount = double.tryParse(transactionAmount.value) ?? 0.0;
    final splitType = transactionSplitType.value;

    transactionShares.clear();
    try {
      transactionShares.addAll(calculateSplit(amount, splitType, customShares));
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  String remainingShareString({bool forPayers = false}) {
    final total = double.tryParse(transactionAmount.value) ?? 0.0;
    if (forPayers) {
      final assigned = payerAmounts.values.fold(0.0, (sum, v) => sum + v);
      return _tripDetailController.formatCurrency(total - assigned);
    }
    if (transactionType.value == 'transfer') {
      final assigned = recipientAmounts.values.fold(0.0, (sum, v) => sum + v);
      return _tripDetailController.formatCurrency(total - assigned);
    }
    if (transactionSplitType.value == 'Equally') {
      return _tripDetailController.formatCurrency(0.0);
    }
    final assigned = customShares.values.fold(0.0, (sum, v) => sum + v);
    return _tripDetailController.formatCurrency(total - assigned);
  }

  Future<void> submitTransaction() async {
    isTransactionSubmitted.value = true;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      _validateTransaction();
      final transaction = _buildTransaction();
      await _tripDetailController.addTransaction(transaction);
      Get.snackbar('Success', 'Transaction added successfully');
      Get.back();
    } catch (e) {
      errorMessage.value = e is TransactionException ? e.message : 'An unexpected error occurred';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void _validateTransaction() {
    titleError.value = transactionTitle.value.isEmpty ? 'Title is required' : '';
    amountError.value = (double.tryParse(transactionAmount.value) ?? 0.0) <= 0 ? 'Amount must be greater than zero' : '';
    payersError.value = transactionPayers.isEmpty ? 'At least one payer is required' : '';
    recipientsError.value = transactionType.value == 'transfer' && transactionRecipients.isEmpty ? 'At least one recipient is required' : '';

    if (titleError.value.isNotEmpty ||
        amountError.value.isNotEmpty ||
        payersError.value.isNotEmpty ||
        recipientsError.value.isNotEmpty) {
      throw TransactionException('Please correct the errors in the form');
    }

    final totalAmount = double.tryParse(transactionAmount.value) ?? 0.0;
    if (transactionType.value == 'transfer') {
      if (transactionPayers.length > 1) {
        payersError.value = 'Transfer can only have one payer';
        throw TransactionException('Transfer can only have one payer');
      }
      final totalReceived = recipientAmounts.values.fold(0.0, (sum, amount) => sum + amount);
      if ((totalReceived - totalAmount).abs() > 0.01) {
        recipientsError.value = 'Total received amounts must equal the transaction amount';
        throw TransactionException('Total received amounts must equal the transaction amount');
      }
    } else {
      final totalPaid = payerAmounts.values.fold(0.0, (sum, amount) => sum + amount);
      if ((totalPaid - totalAmount).abs() > 0.01) {
        payersError.value = 'Total paid amounts must equal the transaction amount';
        throw TransactionException('Total paid amounts must equal the transaction amount');
      }
    }
  }

  Map<String, dynamic> _buildTransaction() {
    final totalAmount = double.tryParse(transactionAmount.value) ?? 0.0;
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': transactionType.value,
      'title': transactionTitle.value,
      'category': selectedCategory.value,
      'icon': 'category',
      'amount': totalAmount,
      'payers': Map<String, double>.from(payerAmounts),
      'user_share': transactionType.value == 'transfer' ? 0.0 : transactionShares['Viren'] ?? 0.0,
      'date': DateFormat('yyyy-MM-dd').format(transactionDate.value),
      'split_type': transactionType.value == 'transfer' ? 'None' : transactionSplitType.value,
      'shares': transactionType.value == 'transfer' ? {} : Map<String, double>.from(transactionShares),
      if (transactionType.value == 'transfer') 'recipients': Map<String, double>.from(recipientAmounts),
    };
  }

  Map<String, double> calculateSplit(double amount, String splitType, Map<String, double> customShares) {
    final shares = <String, double>{};
    final participantCount = _tripDetailController.participants.length;

    if (amount <= 0) {
      throw TransactionException('Amount must be greater than zero');
    }

    if (splitType == 'Equally') {
      final share = double.parse((amount / participantCount).toStringAsFixed(2));
      for (var person in _tripDetailController.participants) {
        shares[person] = share;
      }
    } else if (splitType == 'As parts') {
      final totalParts = customShares.values.fold(0.0, (sum, val) => sum + val);
      if (totalParts <= 0) {
        throw TransactionException('Total parts must be greater than zero');
      }
      for (var person in _tripDetailController.participants) {
        final parts = customShares[person] ?? 0.0;
        final share = double.parse(((parts / totalParts) * amount).toStringAsFixed(2));
        shares[person] = share;
      }
    } else if (splitType == 'As Amount') {
      final totalAssigned = customShares.values.fold(0.0, (sum, val) => sum + val);
      if ((totalAssigned - amount).abs() > 0.01) {
        throw TransactionException('Assigned amounts must equal total amount');
      }
      for (var person in _tripDetailController.participants) {
        final share = double.parse((customShares[person] ?? 0.0).toStringAsFixed(2));
        shares[person] = share;
      }
    }

    return shares;
  }

  void removePayer(String name) {
    transactionPayers.remove(name);
    payerAmounts.remove(name);
    update();
    hasChanges.value = true;
    if (isTransactionSubmitted.value) {
      payersError.value = transactionPayers.isEmpty ? 'At least one payer is required' : '';
    }
  }
}