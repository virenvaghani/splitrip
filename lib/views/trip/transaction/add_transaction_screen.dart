import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/views/trip/transaction/tabs/expense_form.dart';
import 'package:splitrip/views/trip/transaction/tabs/income_form.dart';
import 'package:splitrip/views/trip/transaction/tabs/transfer_form.dart';

import '../../../controller/trip/transaction_screen_controller.dart';
import '../../../controller/trip/trip_detail_controller.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TripDetailController _tripController = Get.find<TripDetailController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Get.put(TransactionScreenController());
    _tabController.addListener(() {
      _tripController.transactionType.value = ['expense', 'income', 'transfer'][_tabController.index];
      _tripController.discardTransaction(); // Reset form when switching tabs
      Get.find<TransactionScreenController>().hasChanges.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final transactionController = Get.find<TransactionScreenController>();
        final hasChanges = transactionController.hasChanges.value;
        final isSubmitted = _tripController.isTransactionSubmitted.value;

        if (hasChanges && !isSubmitted) {
          final shouldDiscard = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard changes?'),
              content: const Text('You have unsaved changes. Do you want to discard them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          ) ??
              false;
          if (shouldDiscard) {
            _tripController.discardTransaction();
            transactionController.hasChanges.value = false;
            return true;
          }
          return false;
        }
        _tripController.discardTransaction();
        transactionController.hasChanges.value = false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Transaction"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
              Tab(text: 'Transfer'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ExpenseForm(),
            IncomeForm(),
            TransferForm(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    Get.delete<TransactionScreenController>();
    super.dispose();
  }
}