import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';
import 'package:splitrip/views/trip/trip_detail/transaction/tabs/expense_form.dart';
import 'package:splitrip/views/trip/trip_detail/transaction/tabs/income_form.dart';
import 'package:splitrip/views/trip/trip_detail/transaction/tabs/transfer_form.dart';
import '../../../../controller/transaction_controller/transaction_controller.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final TripDetailController tripDetailController = Get.find<TripDetailController>();
    final TransactionScreenController transactionController = Get.put(TransactionScreenController(tripDetailController));
    final theme = Theme.of(context);

    final tabController = TabController(length: 3, vsync: this);
    transactionController.setTabController(tabController);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final hasChanges = transactionController.hasChanges.value;
        final isSubmitted = transactionController.isTransactionSubmitted.value;

        if (hasChanges && !isSubmitted) {
          final shouldDiscard = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: theme.colorScheme.surfaceContainer,
              title: Text(
                'Discard changes?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              content: Text(
                'You have unsaved changes. Do you want to discard them?',
                style: theme.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Discard',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ) ?? false;

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
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
          statusBarColor: theme.scaffoldBackgroundColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: true,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: true,
        ),
        child: SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                // Compact Trip Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.close,
                          size: 25,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () async {
                          if (transactionController.hasChanges.value &&
                              !transactionController.isTransactionSubmitted.value) {
                            final shouldDiscard = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: theme.colorScheme.surfaceContainer,
                                title: Text(
                                  'Discard changes?',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                content: Text(
                                  'You have unsaved changes. Do you want to discard them?',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(
                                      'Cancel',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(
                                      'Discard',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ) ?? false;

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
                      ),
                    ],
                  ),
                ),
                // Compact Tab Bar
                ListenableBuilder(
                  listenable: tabController,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(
                            context: context,
                            label: 'Expense',
                            index: 0,
                            tabController: tabController,
                            isSelected: tabController.index == 0,
                          ),
                          _buildTabButton(
                            context: context,
                            label: 'Income',
                            index: 1,
                            tabController: tabController,
                            isSelected: tabController.index == 1,
                          ),
                          _buildTabButton(
                            context: context,
                            label: 'Transfer',
                            index: 2,
                            tabController: tabController,
                            isSelected: tabController.index == 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swipe gestures
                    children: [
                      ExpenseForm(),
                      IncomeForm(),
                      TransferForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required int index,
    required TabController tabController,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          tabController.animateTo(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}