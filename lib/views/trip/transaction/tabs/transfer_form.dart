import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';
import 'package:splitrip/controller/trip/transaction_controller.dart';
import 'package:splitrip/data/trip_constant.dart';
import 'common_widgets_forms.dart';

class TransferForm extends StatelessWidget {
  TransferForm({super.key});

  final tripDetailController = Get.find<TripDetailController>();
  final transactionController = Get.find<TransactionScreenController>();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 10,top: 5),
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            CommonFormWidgets.buildSection(
              theme: theme,
              icon: Icons.call_made,
              title: "From",
              child: CommonFormWidgets.payerDropdown(
                context: context,
                theme: theme,
                tripDetailController: tripDetailController,
                controller: transactionController,
                isSingleSelection: true,
              ),
            ),
            const SizedBox(height: 16),
            CommonFormWidgets.buildSection(
              theme: theme,
              icon: Icons.call_received,
              title: "To",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _recipientDropdown(
                    context,
                    theme,
                    tripDetailController,
                    transactionController,
                  ),
                  AppSpacers.medium,
                  _recipientAmountInputs(theme, transactionController),
                  AppSpacers.small,
                  Align(
                    alignment: Alignment.centerRight,
                    child: CommonFormWidgets.amountValidation(
                      theme: theme,
                      controller: transactionController,
                      isTransfer: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            CommonFormWidgets.submitButton(
              label: 'Transfer',
              theme: theme,
              formKey: formKey,
              controller: transactionController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _recipientDropdown(
    BuildContext context,
    ThemeData theme,
    TripDetailController tripDetailController,
    TransactionScreenController controller,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showDialog(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: theme.colorScheme.surfaceContainer,
                title: Text(
                  'Select Recipients',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                content: Container(
                  width: double.maxFinite,
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Obx(
                    () => ListView(
                      children:
                          tripDetailController.participants.map((name) {
                            return CheckboxListTile(
                              value: controller.transactionRecipients.contains(
                                name,
                              ),
                              onChanged:
                                  (value) => controller.toggleRecipient(name),
                              title: Text(
                                name == "Viren" ? "$name (me)" : name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              activeColor: theme.colorScheme.primary,
                              checkColor: theme.colorScheme.onPrimary,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'Done',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
              errorText: controller.recipientsError.toString(),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.6,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1.5,
                ),
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.primary,
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
        () => transactionController.transactionRecipients.isEmpty ? SizedBox.shrink() : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.transactionRecipients.length,
          itemBuilder: (context, index) {
            final name = controller.transactionRecipients[index];
            final textController = controller.getRecipientTextController(name);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () => controller.toggleRecipient(name),
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
                        controller.updateRecipientAmount(name, amount);
                      },
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
                        prefixText:
                        tripDetailController.trip['currency'] == 'INR'
                            ? '₹ '
                            : '\$ ',
                        prefixStyle: theme.textTheme.bodyMedium?.copyWith(
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
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        hintText: "0.00",
                      ),
                      validator: (value) {
                        if (value == null ||
                            double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
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
}
