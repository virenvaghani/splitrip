import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';
import 'package:splitrip/views/trip/transaction/tabs/expense_form.dart';
import 'package:splitrip/views/trip/transaction/tabs/income_form.dart';
import 'package:splitrip/views/trip/transaction/tabs/transfer_form.dart';
import '../../../controller/trip/transaction_controller.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionScreenController transactionController = Get.find<TransactionScreenController>();
    final TripDetailController tripDetailController = Get.find<TripDetailController>();
    final tickerProvider = _TickerProvider();
    final tabController = TabController(length: 3, vsync: tickerProvider);
    transactionController.setTabController(tabController);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final hasChanges = transactionController.hasChanges.value;
        final isSubmitted = transactionController.isTransactionSubmitted.value;

        if (hasChanges && !isSubmitted) {
          final shouldDiscard =
              await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                      title: Text(
                        'Discard changes?',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      content: Text(
                        'You have unsaved changes. Do you want to discard them?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Discard',
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
              ) ??
              false;

          if (shouldDiscard) {
            transactionController.discardTransaction();
            transactionController.hasChanges.value = false;
            Get.back();
          }
        } else {
          transactionController.discardTransaction();
          transactionController.hasChanges.value = false;
          Get.back();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor:
              Theme.of(context).scaffoldBackgroundColor, // navigation bar color
          statusBarColor: Theme.of(context).scaffoldBackgroundColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: true,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: true,
        ),
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "${tripDetailController.trip['trip_emoji']} ${tripDetailController.trip['trip_name']}",
                style: Theme.of(
                  context,
                ).textTheme.displayMedium,
              ),
              bottom: TabBar(
                controller: tabController,
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                tabs: const [
                  Tab(text: 'Expense'),
                  Tab(text: 'Income'),
                  Tab(text: 'Transfer'),
                ],
              ),
            ),
            body: TabBarView(
              controller: tabController,
              children: [ExpenseForm(), IncomeForm(), TransferForm()],
            ),
          ),
        ),
      ),
    );
  }
}

class _TickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
