import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/trip/transaction_screen_controller.dart';
import '../../../../controller/trip/trip_detail_controller.dart';

class TransferForm extends StatelessWidget {
  const TransferForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripDetailController>();
    final transactionController = Get.find<TransactionScreenController>();
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              theme,
              icon: Icons.edit_note_rounded,
              title: "Transaction Details",
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _titleField(
                          theme,
                          controller,
                          transactionController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _categoryDropdown(
                          theme,
                          controller,
                          transactionController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _currencyBox(theme, controller),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _amountField(
                          theme,
                          controller,
                          transactionController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              theme,
              icon: Icons.call_made,
              title: "From",
              child: _payerDropdown(
                context,
                theme,
                controller,
                transactionController,
                isSingleSelection: true,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              theme,
              icon: Icons.call_received,
              title: "To",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _recipientDropdown(
                    context,
                    theme,
                    controller,
                    transactionController,
                  ),
                  _recipientAmountInputs(
                    theme,
                    controller,
                    transactionController,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _amountValidation(
                      theme,
                      controller,
                      isTransfer: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              theme,
              icon: Icons.more_horiz_outlined,
              title: "Extras",
              child: _extras(context,theme, controller, transactionController),
            ),
            const SizedBox(height: 32),
            _submitButton(
              'Transfer',
              theme,
              controller,
              formKey,
              transactionController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                semanticsLabel: title,
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _titleField(
    ThemeData theme,
    TripDetailController controller,
    TransactionScreenController transactionController,
  ) {
    return TextFormField(
      onChanged: (value) {
        controller.updateTitle(value);
        transactionController.hasChanges.value = true;
      },
      keyboardType: TextInputType.text,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Title',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please enter a title' : null,
    );
  }

  Widget _categoryDropdown(
    ThemeData theme,
    TripDetailController controller,
    TransactionScreenController transactionController,
  ) {
    return DropdownButtonFormField<String>(
      value:
          controller.selectedCategory.value.isEmpty
              ? null
              : controller.selectedCategory.value,
      onChanged: (value) {
        controller.updateCategory(value);
        transactionController.hasChanges.value = true;
      },
      items:
          controller.categories
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
      decoration: InputDecoration(
        hintText: 'Category',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _currencyBox(ThemeData theme, TripDetailController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        controller.trip['currency'] == 'INR' ? '₹' : '\$',
        style: theme.textTheme.bodyLarge,
        semanticsLabel:
            controller.trip['currency'] == 'INR' ? 'Indian Rupee' : 'Dollar',
      ),
    );
  }

  Widget _amountField(
    ThemeData theme,
    TripDetailController controller,
    TransactionScreenController transactionController,
  ) {
    return TextFormField(
      onChanged: (value) {
        controller.updateAmount(value);
        transactionController.hasChanges.value = true;
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: '0.00',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null ||
            double.tryParse(value) == null ||
            double.parse(value) <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _payerDropdown(
    BuildContext context,
    ThemeData theme,
    TripDetailController controller,
    TransactionScreenController transactionController, {
    bool isSingleSelection = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('Payer dropdown tapped'); // Debug print
        showDialog(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: Text(
                  isSingleSelection ? 'Select Payer' : 'Select Payers',
                ),
                content: Container(
                  width: double.maxFinite,
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Obx(() {
                    print(
                      'Participants: ${controller.participants}',
                    ); // Debug print
                    return ListView(
                      children:
                          controller.participants.map((name) {
                            return CheckboxListTile(
                              value: controller.transactionPayers.contains(
                                name,
                              ),
                              onChanged:
                                  isSingleSelection &&
                                          controller.transactionPayers.contains(
                                            name,
                                          )
                                      ? null
                                      : (value) {
                                        print(
                                          'Toggling payer: $name',
                                        ); // Debug print
                                        controller.togglePayer(name);
                                        transactionController.hasChanges.value =
                                            true;
                                        if (isSingleSelection)
                                          Navigator.pop(dialogContext);
                                      },
                              title: Text(
                                name == "Viren" ? "$name (me)" : name,
                                style: theme.textTheme.bodyMedium,
                                semanticsLabel:
                                    name == "Viren" ? "$name (me)" : name,
                              ),
                              activeColor: theme.colorScheme.primary,
                              checkColor: theme.colorScheme.onPrimary,
                            );
                          }).toList(),
                    );
                  }),
                ),
                actions: [
                  if (!isSingleSelection)
                    TextButton(
                      onPressed: () {
                        print('Closing payer dialog'); // Debug print
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Done'),
                    ),
                ],
              ),
        );
      },
      child: IgnorePointer(
        child: Obx(
          () => TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              hintText:
                  controller.transactionPayers.isEmpty
                      ? 'Select payer${isSingleSelection ? '' : 's'}'
                      : 'Paid by ${controller.transactionPayers.length} ${isSingleSelection ? 'person' : 'people'}',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            validator:
                (value) =>
                    controller.transactionPayers.isEmpty
                        ? 'Please select at least one payer'
                        : null,
          ),
        ),
      ),
    );
  }

  Widget _recipientDropdown(
    BuildContext context,
    ThemeData theme,
    TripDetailController controller,
    TransactionScreenController transactionController,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('Recipient dropdown tapped'); // Debug print
        showDialog(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Text('Select Recipients'),
                content: Container(
                  width: double.maxFinite,
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Obx(() {
                    print(
                      'Participants: ${controller.participants}',
                    ); // Debug print
                    return ListView(
                      children:
                          controller.participants.map((name) {
                            return CheckboxListTile(
                              value: controller.transactionRecipients.contains(
                                name,
                              ),
                              onChanged: (value) {
                                print(
                                  'Toggling recipient: $name',
                                ); // Debug print
                                controller.toggleRecipient(name);
                                transactionController.hasChanges.value = true;
                              },
                              title: Text(
                                name == "Viren" ? "$name (me)" : name,
                                style: theme.textTheme.bodyMedium,
                                semanticsLabel:
                                    name == "Viren" ? "$name (me)" : name,
                              ),
                              activeColor: theme.colorScheme.primary,
                              checkColor: theme.colorScheme.onPrimary,
                            );
                          }).toList(),
                    );
                  }),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      print('Closing recipient dialog'); // Debug print
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
        );
      },
      child: IgnorePointer(
        child: Obx(
          () => TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              hintText:
                  controller.transactionRecipients.isEmpty
                      ? 'Select recipients'
                      : 'Received by ${controller.transactionRecipients.length} people',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            validator:
                (value) =>
                    controller.transactionRecipients.isEmpty
                        ? 'Please select at least one recipient'
                        : null,
          ),
        ),
      ),
    );
  }

  Widget _recipientAmountInputs(
    ThemeData theme,
    TripDetailController controller,
    TransactionScreenController transactionController,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              controller.transactionRecipients.map((recipient) {
                final textController = controller.getRecipientTextController(
                  recipient,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipient,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: textController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter amount for $recipient',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                        ),
                        style: theme.textTheme.bodyLarge,
                        onChanged: (val) {
                          final amount = double.tryParse(val) ?? 0.0;
                          controller.updateRecipientAmount(recipient, amount);
                          transactionController.hasChanges.value = true;
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _amountValidation(ThemeData theme, TripDetailController controller, {required bool isTransfer}) {
    return Obx(() {
      final totalAmount =
          double.tryParse(controller.transactionAmount.value) ?? 0.0;
      final total = controller.payerAmounts.values.fold(
        0.0,
        (sum, amt) => sum + amt,
      );
      final diff = totalAmount - total;
      final hasError = diff != 0 || total == 0;
      final message =
          hasError
              ? (diff > 0
                  ? 'Remaining: ${controller.formatCurrency(diff)}'
                  : 'Over by: ${controller.formatCurrency(-diff)}')
              : 'Total matches: ${controller.formatCurrency(total)}';
      return Text(
        message,
        style: TextStyle(
          color: hasError ? theme.colorScheme.error : theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        semanticsLabel: message,
      );
    });
  }

  Widget _extras(
    BuildContext context,
    ThemeData theme,
    TripDetailController controller,
    TransactionScreenController transactionController,
  ) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            controller.pickImage();
            transactionController.hasChanges.value = true;
          },
          icon: const Icon(Icons.image_outlined),
          label: const Text("Bill Image"),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceVariant,
            foregroundColor: theme.colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () async {
            final picked = await showDialog<DateTime>(
              context: context,
              builder:
                  (dialogContext) => DatePickerDialog(
                    initialDate: controller.transactionDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  ),
            );
            if (picked != null) {
              controller.updateDate(picked);
              transactionController.hasChanges.value = true;
            }
          },
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Obx(
            () => Text(
              controller.formatDate(controller.transactionDate.value),
              style: theme.textTheme.bodyMedium,
              semanticsLabel: controller.formatDate(
                controller.transactionDate.value,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton(
    String label,
    ThemeData theme,
    TripDetailController controller,
    GlobalKey<FormState> formKey,
    TransactionScreenController transactionController,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (controller.transactionPayers.isEmpty) {
            Get.snackbar(
              'Error',
              'Please select at least one payer',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: theme.colorScheme.error,
              colorText: theme.colorScheme.onError,
            );
            return;
          }
          if (formKey.currentState!.validate()) {
            controller.submitTransaction();
            transactionController.hasChanges.value = false;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          semanticsLabel: label,
        ),
      ),
    );
  }
}
