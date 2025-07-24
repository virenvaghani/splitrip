import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';
import 'package:splitrip/data/trip_constant.dart';
import '../../../../controller/transaction_controller/transaction_controller.dart';
import 'common_widgets_forms.dart';

class ExpenseForm extends StatelessWidget {
  ExpenseForm({super.key});

  final TripDetailController tripDetailController =
      Get.find<TripDetailController>();
  final TransactionScreenController transactionController =
      Get.find<TransactionScreenController>();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetX<TransactionScreenController>(
      initState: (state) {},
      builder: (_) {
        return Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 5, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonFormWidgets.buildSection(
                  theme: theme,
                  icon: Icons.edit_note_rounded,
                  title: "Transaction Details",
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CommonFormWidgets.titleField(
                              theme: theme,
                              controller: transactionController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CommonFormWidgets.categoryDropdown(
                              theme: theme,
                              controller: transactionController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CommonFormWidgets.currencyBox(
                            theme: theme,
                            tripDetailController: tripDetailController,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CommonFormWidgets.amountField(
                              theme: theme,
                              controller: transactionController,
                            ),
                          ),
                        ],
                      ),
                      AppSpacers.medium,
                      CommonFormWidgets.extras(
                        context: context,
                        theme: theme,
                        controller: transactionController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.buildSection(
                  theme: theme,
                  icon: Icons.payments_outlined,
                  title: "Paid By",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonFormWidgets.payerDropdown(
                        context: context,
                        theme: theme,
                        tripDetailController: tripDetailController,
                        controller: transactionController,
                      ),
                      AppSpacers.medium,
                      _payerAmountInputs(theme, transactionController),
                      AppSpacers.small,
                      Align(
                        alignment: Alignment.centerRight,
                        child: CommonFormWidgets.amountValidation(
                          theme: theme,
                          controller: transactionController,
                          forPayers: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.buildSection(
                  theme: theme,
                  icon: Icons.groups_2_outlined,
                  title: "Split Between",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _splitOptions(theme, transactionController),
                      _shareInputs(
                        theme,
                        tripDetailController,
                        transactionController,
                      ),
                      Obx(
                        () =>
                            transactionController.transactionSplitType.value !=
                                    'Equally'
                                ? Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: CommonFormWidgets.amountValidation(
                                      theme: theme,
                                      controller: transactionController,
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                CommonFormWidgets.submitButton(
                  label: 'Add Expense',
                  theme: theme,
                  formKey: formKey,
                  controller: transactionController,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _payerAmountInputs(
    ThemeData theme,
    TransactionScreenController controller,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Obx(
        () =>
            transactionController.transactionPayers.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.transactionPayers.length,
                  itemBuilder: (context, index) {
                    final name = controller.transactionPayers[index];
                    final textController = controller.getPayerTextController(
                      name,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: theme.colorScheme.error,
                            ),
                            onPressed: () => controller.removePayer(name),
                          ),
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              semanticsLabel: name,
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              controller: textController,
                              onChanged: (val) {
                                final amount =
                                    double.tryParse(
                                      val.replaceAll(RegExp(r'[^\d.]'), ''),
                                    ) ??
                                    0.0;
                                controller.updatePayerAmount(name, amount);
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                prefixText:
                                    tripDetailController.trip['currency'] ==
                                            'INR'
                                        ? '₹ '
                                        : '\$ ',
                                prefixStyle: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                hintText: "0.00",
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _splitOptions(
    ThemeData theme,
    TransactionScreenController controller,
  ) {
    return Obx(
      () => Row(
        children:
            TransactionScreenController.splitTypes.map((type) {
              final isSelected = controller.transactionSplitType.value == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () => controller.updateSplitType(type),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected
                                ? theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                )
                                : theme.colorScheme.surfaceContainer,
                        foregroundColor:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        type,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _shareInputs(
    ThemeData theme,
    TripDetailController tripDetailController,
    TransactionScreenController controller,
  ) {
    // Map to store TextEditingControllers for each participant
    final Map<String, TextEditingController> shareControllers = {};

    // Initialize controllers for each participant
    for (var name in tripDetailController.participants) {
      shareControllers[name] = TextEditingController(
        text: controller.transactionShares[name]?.toStringAsFixed(2) ?? '0.00',
      );
    }

    // Listen to transactionShares changes to update TextEditingControllers
    ever(controller.transactionShares, (Map<String, double> shares) {
      for (var name in tripDetailController.participants) {
        shareControllers[name]?.text =
            shares[name]?.toStringAsFixed(2) ?? '0.00';
      }
    });
    final isEqual = controller.transactionSplitType.value == 'Equally';
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tripDetailController.participants.length,
      itemBuilder: (context, index) {
        final name = tripDetailController.participants[index];
        final amount = controller.transactionShares[name] ?? 0.0;
        bool isSelected = true;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  // Update the state variable (assuming isSelected is managed in a stateful widget or controller)
                  controller.updateSelection(
                    value ?? false,
                  ); // Example: Update via controller
                  // If using setState in a StatefulWidget, use: setState(() => isSelected = value ?? false);
                },
                activeColor:
                    theme.colorScheme.primary, // Matches theme's primary color
                checkColor:
                    theme
                        .colorScheme
                        .onPrimary, // Matches text/icon color on primary
                side: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(
                    0.6,
                  ), // Matches unselected tab color
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    4,
                  ), // Subtle rounded corners for consistency
                ),
              ),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller:
                      shareControllers[name], // Use TextEditingController
                  enabled: !isEqual,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText:
                        isEqual
                            ? tripDetailController.formatCurrency(amount)
                            : 'Enter',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged:
                      (val) => controller.updateCustomShare(
                        name,
                        double.tryParse(val) ?? 0.0,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
