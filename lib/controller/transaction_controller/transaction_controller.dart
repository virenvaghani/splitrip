import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';
import 'package:splitrip/data/constants.dart';
import 'package:splitrip/data/token.dart';
import '../../model/Category/category_model.dart';
import '../../model/transaction_model/transaction_model.dart';

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
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final transactionRecipients = <String>[].obs;
  final recipientAmounts = <String, double>{}.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final titleError = ''.obs;
  final amountError = ''.obs;
  final payersError = ''.obs;
  final recipientsError = ''.obs;
  final fixedAmounts = <String, bool>{}.obs;
  final selectedPayer = ''.obs;

  // Constants
  static const List<String> transactionTypes = ['expense', 'income', 'transfer'];
  List<CategoryModel> get categories => Kconstant.categoryModelList;
  static const List<String> splitTypes = ['Equally', 'As parts', 'As Amount'];

  // Controllers and dependencies
  final Map<String, TextEditingController> _payerTextControllers = {};
  final Map<String, TextEditingController> _recipientTextControllers = {};
  final TripDetailController tripDetailController;
  late TabController tabController;
  final Map<String, TextEditingController> shareControllers = {};
  final Map<String, FocusNode> shareFocusNodes = {};
  final RxList<String> selectedParticipants = RxList<String>();
  final Map<String, bool> clearedOnFocus = {};
  Timer? _debounceTimer;

  TransactionScreenController(this.tripDetailController);

  @override
  void onInit() {
    super.onInit();
    final List<String> participantNames = [];
    final List<num> participantMembers = [];

    for (var participant in Kconstant.participantsRx) {
      final name = participant['name']?.toString() ?? 'Unknown';
      final memberValue = participant['custom_member_count'];
      final memberCount = num.tryParse(memberValue.toString()) ?? 1;
      participantNames.add(name);
      participantMembers.add(memberCount);
    }

    selectedParticipants.addAll(participantNames);
    _initializeShares();
    _setupValidation();
    initializeShareFields(participantNames, participantMembers);
  }

  void initializeShareFields(List<String> participantNames, List<num> participantMembers) {
    for (int i = 0; i < participantNames.length; i++) {
      final name = participantNames[i];
      final members = participantMembers[i];
      final isAsParts = transactionSplitType.value == 'As parts';
      final defaultValue = isAsParts ? members.toStringAsFixed(0) : members.toStringAsFixed(2);

      shareControllers.putIfAbsent(name, () => TextEditingController(text: defaultValue));
      customShares.putIfAbsent(name, () => members.toDouble());
      shareFocusNodes.putIfAbsent(name, () {
        final focusNode = FocusNode();
        focusNode.addListener(() {
          final controller = shareControllers[name]!;
          if (focusNode.hasFocus && !clearedOnFocus[name]!) {
            controller.text = '';
            clearedOnFocus[name] = true;
          } else if (!focusNode.hasFocus) {
            final text = controller.text.trim();
            final fallback = isAsParts ? members.toDouble() : 0.0;
            if (text.isEmpty) {
              controller.text = defaultValue;
              customShares[name] = fallback;
              fixedAmounts[name] = false;
            } else {
              final value = double.tryParse(text);
              if (value != null && value >= 0) {
                customShares[name] = value;
                controller.text = isAsParts ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
                if (!isAsParts) fixedAmounts[name] = true;
              } else {
                controller.text = defaultValue;
                customShares[name] = fallback;
                fixedAmounts[name] = false;
              }
            }
            updateCalculatedShares();
          }
        });
        return focusNode;
      });
      clearedOnFocus.putIfAbsent(name, () => false);
      fixedAmounts.putIfAbsent(name, () => false);
    }
    syncShareTextFields();
  }

  void syncShareTextFields() {
    transactionShares.forEach((name, value) {
      if (shareControllers.containsKey(name)) {
        final controller = shareControllers[name]!;
        final focusNode = shareFocusNodes[name]!;
        if (!focusNode.hasFocus) {
          if (transactionSplitType.value == 'Equally') {
            controller.text = value.toStringAsFixed(2);
          } else if (transactionSplitType.value == 'As parts') {
            controller.text = (customShares[name] ?? 1.0).toStringAsFixed(0);
          } else {
            controller.text = (customShares[name] ?? 0.0).toStringAsFixed(2);
          }
        }
      }
    });
  }

  void incrementParts(String name) {
    final currentParts = customShares[name] ?? 1.0;
    updateCustomShare(name, currentParts + 0.25);
  }

  void decrementParts(String name) {
    final currentParts = customShares[name] ?? 1.0;
    if (currentParts > 0.25) {
      updateCustomShare(name, currentParts - 0.25);
    }
  }

  void updateCustomShare(String person, double value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (transactionSplitType.value == 'As parts') {
        double adjustedValue = value < 0.25 ? 0.25 : value;
        adjustedValue = (adjustedValue / 0.25).round() * 0.25;
        customShares[person] = adjustedValue;
      } else {
        customShares[person] = value;
        fixedAmounts[person] = true;
      }
      updateCalculatedShares();
      syncShareTextFields();
      hasChanges.value = true;
    });
  }

  void updateSplitType(String value) {
    if (splitTypes.contains(value)) {
      transactionSplitType.value = value;
      customShares.clear();
      fixedAmounts.clear();
      final participantNames = Kconstant.participantsRx.map((participant) => participant['name'] as String).toList();
      final participantMembers = Kconstant.participantsRx.map((participant) => num.tryParse(participant['custom_member_count'].toString()) ?? 1).toList();

      for (var person in participantNames) {
        if (value == 'As Amount' && selectedParticipants.contains(person)) {
          customShares[person] = transactionShares[person] ?? 0.0;
        } else if (value == 'As parts' && selectedParticipants.contains(person)) {
          customShares[person] = participantMembers[participantNames.indexOf(person)].toDouble();
        } else {
          customShares[person] = 0.0;
        }
        fixedAmounts[person] = false;
        clearedOnFocus[person] = false;
      }
      initializeShareFields(participantNames, participantMembers);
      updateCalculatedShares();
      syncShareTextFields();
      hasChanges.value = true;
    }
  }

  void updateCalculatedShares() {
    if (transactionType.value == 'transfer') return;

    final amount = double.tryParse(transactionAmount.value) ?? 0.0;
    final splitType = transactionSplitType.value;

    transactionShares.clear();
    try {
      if (splitType == 'As Amount') {
        final selected = selectedParticipants.toList();
        if (selected.isEmpty) throw TransactionException('At least one participant must be selected');

        double totalFixed = 0.0;
        for (var person in selected) {
          if (fixedAmounts[person] == true) {
            totalFixed += customShares[person] ?? 0.0;
            transactionShares[person] = customShares[person] ?? 0.0;
          }
        }

        final remainingAmount = amount - totalFixed;
        final nonFixedParticipants = selected.where((p) => fixedAmounts[p] != true).toList();
        final remainingParticipantsCount = nonFixedParticipants.length;

        if (remainingParticipantsCount > 0 && remainingAmount >= 0) {
          final share = double.parse((remainingAmount / remainingParticipantsCount).toStringAsFixed(2));
          for (var person in nonFixedParticipants) {
            transactionShares[person] = share;
            customShares[person] = share;
          }
        } else {
          for (var person in selected) {
            if (!transactionShares.containsKey(person)) {
              transactionShares[person] = customShares[person] ?? 0.0;
            }
          }
        }
      } else {
        transactionShares.addAll(calculateSplit(amount, splitType, customShares));
      }
      syncShareTextFields();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Map<String, double> calculateSplit(double amount, String splitType, Map<String, double> customShares) {
    final shares = <String, double>{};
    final selected = selectedParticipants.toList();

    if (selected.isEmpty) throw TransactionException('At least one participant must be selected');
    if (amount <= 0) {
      for (var person in selected) {
        shares[person] = 0.0;
      }
      return shares;
    }

    if (splitType == 'Equally') {
      final share = double.parse((amount / selected.length).toStringAsFixed(2));
      for (var person in selected) {
        shares[person] = share;
      }
    } else if (splitType == 'As parts') {
      final totalParts = selected.fold<double>(0.0, (sum, person) => sum + (customShares[person] ?? 1.0));
      if (totalParts <= 0) {
        final share = double.parse((amount / selected.length).toStringAsFixed(2));
        for (var person in selected) {
          shares[person] = share;
          customShares[person] = 1.0;
        }
      } else {
        for (var person in selected) {
          final parts = customShares[person] ?? 1.0;
          final share = double.parse(((parts / totalParts) * amount).toStringAsFixed(2));
          shares[person] = share;
        }
        final totalShares = shares.values.fold<double>(0.0, (sum, value) => sum + value);
        final remaining = double.parse((amount - totalShares).toStringAsFixed(2));
        if (remaining != 0) {
          final changedParticipants = selected.where((person) => (customShares[person] ?? 1.0) != 1.0).toList();
          if (changedParticipants.isNotEmpty) {
            final totalChangedParts = changedParticipants.fold<double>(0.0, (sum, person) => sum + (customShares[person] ?? 1.0));
            for (var person in changedParticipants) {
              final parts = customShares[person] ?? 1.0;
              final adjustment = double.parse(((parts / totalChangedParts) * remaining).toStringAsFixed(2));
              shares[person] = (shares[person] ?? 0.0) + adjustment;
            }
          } else {
            final minParts = selected.map((p) => customShares[p] ?? 1.0).reduce((a, b) => a < b ? a : b);
            final lowestPartPeople = selected.where((p) => (customShares[p] ?? 1.0) == minParts).toList();
            if (lowestPartPeople.isNotEmpty) {
              final person = lowestPartPeople.first;
              shares[person] = (shares[person] ?? 0.0) + remaining;
            }
          }
        }
      }
    }
    return shares;
  }

  void _initializeShares() {
    final participantNames = Kconstant.participantsRx.map((participant) => participant['name'] as String).toList();
    for (var person in participantNames) {
      transactionShares[person] = 0.0;
      payerAmounts[person] = 0.0;
      recipientAmounts[person] = 0.0;
      customShares[person] = transactionSplitType.value == 'As parts' && selectedParticipants.contains(person) ? 1.0 : 0.0;
      clearedOnFocus[person] = false;
      fixedAmounts[person] = false;
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
    _debounceTimer?.cancel();
    _payerTextControllers.forEach((_, controller) => controller.dispose());
    _recipientTextControllers.forEach((_, controller) => controller.dispose());
    shareControllers.forEach((_, controller) => controller.dispose());
    shareFocusNodes.forEach((_, focusNode) => focusNode.dispose());
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
    selectedParticipants.clear();
    final participantNames = Kconstant.participantsRx.map((participant) => participant['name'] as String).toList();
    selectedParticipants.addAll(participantNames);
    isTransactionSubmitted.value = false;
    selectedCategory.value = categories.isNotEmpty ? categories[0] : null;
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
    shareControllers.forEach((_, controller) {
      controller.text = '';
      controller.dispose();
    });
    shareFocusNodes.forEach((_, focusNode) => focusNode.dispose());
    _payerTextControllers.clear();
    _recipientTextControllers.clear();
    shareControllers.clear();
    shareFocusNodes.clear();
    clearedOnFocus.clear();
    fixedAmounts.clear();
    _initializeShares();
  }

  void updateTitle(String value) {
    transactionTitle.value = value.trim();
    hasChanges.value = true;
    if (isTransactionSubmitted.value) {
      titleError.value = value.isEmpty ? 'Title is required' : '';
    }
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
      transactionRecipients.remove(currentPayer);
    }
    if (!transactionPayers.contains(name)) {
      transactionPayers.add(name);
      payerAmounts[name] = 0.0;
      getPayerTextController(name).text = '';
      if (transactionType.value == 'transfer') {
        transactionRecipients.remove(name);
      }
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

  void updateCategory(CategoryModel? value) {
    selectedCategory.value = value;
  }

  void pickImage() {
    Get.snackbar('Image', 'Image picker to be implemented');
  }

  String remainingShareString({bool forPayers = false}) {
    final total = double.tryParse(transactionAmount.value) ?? 0.0;
    if (forPayers) {
      final assigned = payerAmounts.values.fold(0.0, (sum, v) => sum + v);
      return tripDetailController.formatCurrency(total - assigned);
    }
    if (transactionType.value == 'transfer') {
      final assigned = recipientAmounts.values.fold(0.0, (sum, v) => sum + v);
      return tripDetailController.formatCurrency(total - assigned);
    }
    if (transactionSplitType.value == 'Equally') {
      return tripDetailController.formatCurrency(0.0);
    }
    final assigned = transactionShares.values.fold(0.0, (sum, v) => sum + v);
    return tripDetailController.formatCurrency(total - assigned);
  }

  Future<void> submitTransaction() async {
    isTransactionSubmitted.value = true;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      _validateTransaction();
      if (transactionType.value == 'transfer') {
        await _saveTransferToBackend();
        Get.snackbar('Success', 'Transfer added successfully');
        Get.back();
      } else {
        final transaction = _buildTransaction();
        await tripDetailController.addTransaction(transaction);
        Get.snackbar('Success', 'Transaction added successfully');
        Get.back();
      }
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

    if (titleError.value.isNotEmpty || amountError.value.isNotEmpty || payersError.value.isNotEmpty || recipientsError.value.isNotEmpty) {
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
      if (transactionSplitType.value == 'As Amount') {
        final totalShares = transactionShares.values.fold(0.0, (sum, v) => sum + v);
        if ((totalShares - totalAmount).abs() > 0.01) {
          throw TransactionException('Total shares must equal the transaction amount');
        }
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

  Future<void> _saveTransferToBackend() async {
    final token = await TokenStorage.getToken();
    try {
      final amount = double.tryParse(transactionAmount.value) ?? 0.0;
      final tripId = tripDetailController.trip['id'] as int;
      final currencyId = tripDetailController.trip['default_currency'] as int;

      // Map payers
      final payees = transactionPayers.map((payerName) {
        final participant = Kconstant.participantsRx.firstWhere(
              (p) => p['name'] == payerName,
          orElse: () => throw TransactionException('Payer not found: $payerName'),
        );
        final participantId = participant['id'] as int;
        final payerAmount = payerAmounts[payerName] ?? amount; // Use total amount if not specified
        return Payee(participant: participantId, amount: payerAmount);
      }).toList();

      // Map recipients
      final receivers = transactionRecipients.map((recipientName) {
        final participant = Kconstant.participantsRx.firstWhere(
              (p) => p['name'] == recipientName,
          orElse: () => throw TransactionException('Recipient not found: $recipientName'),
        );
        final participantId = participant['id'] as int;
        final recipientAmount = recipientAmounts[recipientName] ?? (amount / transactionRecipients.length);
        return Receiver(participant: participantId, amount: recipientAmount);
      }).toList();

      // Get fromParticipant
      final fromParticipantName = transactionPayers.first;
      final fromParticipant = Kconstant.participantsRx.firstWhere(
            (p) => p['name'] == fromParticipantName,
        orElse: () => throw TransactionException('From participant not found: $fromParticipantName'),
      );
      final fromParticipantId = fromParticipant['id'] as int;

      // Create Transfer object
      final transfer = Transfer(
        type: 'transfer',
        trip: tripId,
        currency: currencyId,
        amount: amount,
        exchangeRate: 1.0, // As per your example JSON
        fromParticipant: fromParticipantId,
        payees: payees,
        receivers: receivers,
      );

      // Send to backend
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/transaction/maintain/$tripId/'), // Replace with your actual API endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(transfer.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw TransactionException('Failed to save transfer: ${response.body}');
      }
    } catch (e) {
      throw TransactionException('Error saving transfer: $e');
    }
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