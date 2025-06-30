import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/data/trip_constant.dart';

import '../../../../controller/trip/transaction_screen_controller.dart';
import '../../../../controller/trip/trip_detail_controller.dart';

class ExpenseForm extends StatelessWidget {
  const ExpenseForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripDetailController>();
    final transactionController = Get.find<TransactionScreenController>();
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                      Expanded(child: _titleField(theme, controller, transactionController)),
                      const SizedBox(width: 12),
                      Expanded(child: _categoryDropdown(theme, controller, transactionController)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _currencyBox(theme, controller),
                      const SizedBox(width: 12),
                      Expanded(child: _amountField(theme, controller, transactionController)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              theme,
              icon: Icons.payments_outlined,
              title: "Paid By",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _payerDropdown(context, theme, controller, transactionController),
                  AppSpacers.medium,
                  _payerAmountInputs(theme, controller, transactionController),
                  AppSpacers.small,
                  Align(
                    alignment: Alignment.centerRight,
                    child: _amountValidation(theme, controller),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              theme,
              icon: Icons.groups_2_outlined,
              title: "Split Between",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _splitOptions(theme, controller, transactionController),
                  _shareInputs(theme, controller, transactionController),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              theme,
              icon: Icons.more_horiz_outlined,
              title: "Extras",
              child: _extras(context, theme, controller, transactionController),
            ),
            const SizedBox(height: 24),
            _submitButton('Add Expense', theme, controller, formKey, transactionController),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, {required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainer,
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary.withOpacity(0.9),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.5,
                ),
                semanticsLabel: title,
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _titleField(ThemeData theme, TripDetailController controller, TransactionScreenController transactionController) {
    return TextFormField(
      onChanged: (value) {
        controller.updateTitle(value);
        transactionController.hasChanges.value = true;
      },
      keyboardType: TextInputType.text,
      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Enter title',
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
    );
  }

  Widget _categoryDropdown(ThemeData theme, TripDetailController controller, TransactionScreenController transactionController) {
    return DropdownMenu<String>(
      initialSelection: controller.selectedCategory.value.isEmpty ? null : controller.selectedCategory.value,
      onSelected: (value) {
        controller.updateCategory(value);
        transactionController.hasChanges.value = true;
      },
      width: double.infinity,
      dropdownMenuEntries: controller.categories.map((e) => DropdownMenuEntry(
        value: e,
        label: e,
        style: MenuItemButton.styleFrom(
          textStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
        ),
      )).toList(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _currencyBox(ThemeData theme, TripDetailController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Text(
        controller.trip['currency'] == 'INR' ? '₹' : '\$',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
        semanticsLabel: controller.trip['currency'] == 'INR' ? 'Indian Rupee' : 'Dollar',
      ),
    );
  }

  Widget _amountField(ThemeData theme, TripDetailController controller, TransactionScreenController transactionController) {
    return TextFormField(
      onChanged: (value) {
        controller.updateAmount(value);
        transactionController.hasChanges.value = true;
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
      decoration: InputDecoration(
        hintText: '0.00',
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _payerDropdown(BuildContext context, ThemeData theme, TripDetailController controller, TransactionScreenController transactionController) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: theme.colorScheme.surfaceContainer,
            title: Text(
              'Select Payers',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxHeight: 300),
              child: Obx(() => ListView(
                children: controller.participants.map((name) {
                  return CheckboxListTile(
                    value: controller.transactionPayers.contains(name),
                    onChanged: (value) {
                      controller.togglePayer(name);
                      transactionController.hasChanges.value = true;
                    },
                    title: Text(
                      name == "Viren" ? "$name (me)" : name,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                    activeColor: theme.colorScheme.primary,
                    checkColor: theme.colorScheme.onPrimary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  );
                }).toList(),
              )),
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
        child: Obx(() => TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: controller.transactionPayers.isEmpty
                ? 'Select payers'
                : 'Paid by ${controller.transactionPayers.length} people',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.primary,
            ),
          ),
          validator: (value) => controller.transactionPayers.isEmpty ? 'Please select at least one payer' : null,
        )),
      ),
    );
  }

  Widget _payerAmountInputs(ThemeData theme, TripDetailController controller, TransactionScreenController transactionController) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Obx(() => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.transactionPayers.length,
        itemBuilder: (context, index) {
          final name = controller.transactionPayers[index];
          final textController = controller.getPayerTextController(name);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
                  onPressed: () {
                    controller.removePayer(name);
                    transactionController.hasChanges.value = true;
                  },
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
                  child: TextField(
                    controller: textController,
                    onChanged: (val) {
                      final amount = double.tryParse(val.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
                      controller.updatePayerAmount(name, amount);
                      transactionController.hasChanges.value = true;
                    },
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    decoration: InputDecoration(
                      prefixText: controller.trip['currency'] == 'INR' ? '₹ ' : '\$ ',
                      prefixStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLow,
                      hintText: "0.00",
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      )),
    );
  }

  Widget _splitOptions(
      ThemeData theme,
      TripDetailController controller,
      TransactionScreenController transactionController,
      ) {
    return Obx(
          () => Row(
        children: controller.splitTypes.map((type) {
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
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    controller.updateSplitType(type);
                    transactionController.hasChanges.value = true;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.15)
                        : theme.colorScheme.surfaceContainer,
                    foregroundColor: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.8),
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

  Widget _shareInputs(ThemeData theme, TripDetailController controller, TransactionScreenController transactionController) {
    return Obx(() {
      final isEqual = controller.transactionSplitType.value == 'Equally';
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.participants.length,
        itemBuilder: (context, index) {
          final name = controller.participants[index];
          final amount = controller.transactionShares[name] ?? 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
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
                    enabled: !isEqual,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: isEqual ? controller.formatCurrency(amount) : 'Enter',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      controller.updateCustomShare(name, double.tryParse(val.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0);
                      transactionController.hasChanges.value = true;
                    },
                    validator: (value) {
                      if (!isEqual && (value == null || double.tryParse(value) == null || double.parse(value) <= 0)) {
                        return 'Enter a valid share';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _amountValidation(ThemeData theme, TripDetailController controller) {
    return Obx(() {
      final totalAmount = double.tryParse(controller.transactionAmount.value) ?? 0.0;
      final total = controller.payerAmounts.values.fold(0.0, (sum, amt) => sum + amt);
      final diff = totalAmount - total;
      final hasError = diff != 0 || total == 0;
      final message = hasError
          ? (diff > 0 ? 'Remaining: ${controller.formatCurrency(diff)}' : 'Over by: ${controller.formatCurrency(-diff)}')
          : 'Total matches: ${controller.formatCurrency(total)}';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasError ? theme.colorScheme.error.withOpacity(0.1) : theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: hasError ? theme.colorScheme.error : theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          semanticsLabel: message,
        ),
      );
    });
  }

  Widget _extras(BuildContext context, ThemeData theme, TripDetailController controller, TransactionScreenController transactionController) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            controller.pickImage();
            transactionController.hasChanges.value = true;
          },
          icon: Icon(Icons.image_outlined, size: 20, color: theme.colorScheme.primary),
          label: Text(
            "Bill Image",
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () async {
            final picked = await showDialog<DateTime>(
              context: context,
              builder: (dialogContext) => DatePickerDialog(
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
          icon: Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          label: Obx(() => Text(
            controller.formatDate(controller.transactionDate.value),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            semanticsLabel: controller.formatDate(controller.transactionDate.value),
          )),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _submitButton(String label, ThemeData theme, TripDetailController controller, GlobalKey<FormState> formKey, TransactionScreenController transactionController) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (controller.transactionPayers.isEmpty) {
            Get.snackbar(
              'Error',
              'Please select at least one payer',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: theme.colorScheme.error.withOpacity(0.9),
              colorText: theme.colorScheme.onError,
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
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
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: theme.colorScheme.primary.withOpacity(0.3),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          semanticsLabel: label,
        ),
      ),
    );
  }
}