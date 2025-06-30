import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'base_transaction_controller.dart';
import 'trip_detail_controller.dart';

class TransferController extends BaseTransactionController {
  @override
  final RxString transactionTitle = ''.obs;
  @override
  final RxString transactionAmount = '0.0'.obs;
  @override
  final RxList<String> transactionPayers = <String>[].obs;
  @override
  final RxMap<String, double> payerAmounts = <String, double>{}.obs;
  @override
  final Rx<DateTime> transactionDate = DateTime.now().obs;
  @override
  final RxString transactionSplitType = 'None'.obs;
  @override
  final RxMap<String, double> transactionShares = <String, double>{}.obs;
  @override
  final RxMap<String, double> customShares = <String, double>{}.obs;
  @override
  final RxBool isTransactionSubmitted = false.obs;
  @override
  final RxString selectedCategory = 'Misc'.obs;
  @override
  final RxList<String> transactionRecipients = <String>[].obs;
  @override
  final RxMap<String, double> recipientAmounts = <String, double>{}.obs;

  final Map<String, TextEditingController> _payerTextControllers = {};
  final Map<String, TextEditingController> _recipientTextControllers = {};

  @override
  void onInit() {
    super.onInit();
    initializeShares();
  }

  void initializeShares() {
    for (var person in participants) {
      payerAmounts[person] = 0.0;
      recipientAmounts[person] = 0.0;
    }
  }

  @override
  TextEditingController getPayerTextController(String name) {
    if (!_payerTextControllers.containsKey(name)) {
      _payerTextControllers[name] = TextEditingController(text: '');
    }
    return _payerTextControllers[name]!;
  }

  @override
  TextEditingController getRecipientTextController(String name) {
    if (!_recipientTextControllers.containsKey(name)) {
      _recipientTextControllers[name] = TextEditingController(text: '');
    }
    return _recipientTextControllers[name]!;
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
    super.onClose();
  }

  @override
  void discardTransaction() {
    transactionTitle.value = '';
    transactionAmount.value = '0.0';
    transactionPayers.clear();
    payerAmounts.clear();
    transactionRecipients.clear();
    recipientAmounts.clear();
    transactionDate.value = DateTime.now();
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

  @override
  void updateTitle(String value) => transactionTitle.value = value;

  @override
  void updateAmount(String value) {
    transactionAmount.value = value;
  }

  @override
  void togglePayer(String name) {
    if (transactionPayers.isNotEmpty) {
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
  }

  @override
  void updatePayerAmount(String name, double amount) {
    payerAmounts[name] = amount;
  }

  @override
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

  @override
  void updateRecipientAmount(String name, double amount) {
    recipientAmounts[name] = amount;
  }

  @override
  void updateDate(DateTime date) {
    transactionDate.value = date;
  }

  @override
  void updateSplitType(String value) {
    // Not used for transfers
  }

  @override
  void updateCustomShare(String person, double value) {
    // Not used for transfers
  }

  @override
  void updateCategory(String? value) {
    if (value != null) selectedCategory.value = value;
  }

  @override
  void updateCalculatedShares() {
    // Not used for transfers
  }

  @override
  String remainingShareString() {
    final total = double.tryParse(transactionAmount.value) ?? 0.0;
    final assigned = recipientAmounts.values.fold(0.0, (sum, v) => sum + v);
    final remaining = total - assigned;
    return formatCurrency(remaining);
  }

  @override
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

    if (transactionRecipients.isEmpty) {
      Get.snackbar('Error', 'Please select at least one recipient');
      return;
    }

    if (transactionPayers.length > 1) {
      Get.snackbar('Error', 'Transfer can only have one payer');
      return;
    }

    final totalReceived = recipientAmounts.values.fold(0.0, (sum, amount) => sum + amount);
    if ((totalReceived - totalAmount).abs() > 0.01) {
      Get.snackbar('Error', 'Total received amounts must equal the transaction amount');
      return;
    }

    final transaction = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'transfer',
      'title': transactionTitle.value,
      'category': selectedCategory.value,
      'icon': 'category',
      'amount': totalAmount,
      'payers': Map<String, double>.from(payerAmounts),
      'user_share': 0.0,
      'date': DateFormat('yyyy-MM-dd').format(transactionDate.value),
      'split_type': 'None',
      'shares': <String, double>{},
      'recipients': Map<String, double>.from(recipientAmounts),
    };

    Get.find<TripDetailController>().addTransaction(transaction);
    discardTransaction();
    Get.back();
  }
}