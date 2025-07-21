import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';
import '../../../../controller/trip/transaction_controller.dart';

class CommonFormWidgets {
  static Widget buildSection({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainer.withValues(alpha: 0.9),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 1,
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
                size: 24,
                color: theme.colorScheme.primary.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.8,
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

  static Widget titleField({
    required ThemeData theme,
    required TransactionScreenController controller,
  }) {
    return Obx(() {
      final hasError = controller.titleError.value.isNotEmpty;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 60,
        transform:
            hasError
                ? Matrix4.translationValues(
                  5 *
                      (DateTime.now().millisecondsSinceEpoch % 100 < 50
                          ? 1
                          : -1),
                  0,
                  0,
                )
                : Matrix4.identity(),
        child: TextFormField(
          onChanged: controller.updateTitle,
          keyboardType: TextInputType.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Enter title',
            filled: true,
            fillColor: theme.colorScheme.surfaceContainer.withValues(
              alpha: 0.7,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color:
                    hasError
                        ? theme.colorScheme.error.withValues(alpha: 0.6)
                        : theme.colorScheme.outline.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    });
  }

  static Widget categoryDropdown({
    required ThemeData theme,
    required TransactionScreenController controller,
  }) {
    return Obx(
      () => DropdownMenu<String>(
        initialSelection:
            controller.selectedCategory.value.isEmpty
                ? null
                : controller.selectedCategory.value,
        onSelected: controller.updateCategory,
        width: 200,
        hintText: 'Select category',
        menuStyle: MenuStyle(
          surfaceTintColor: WidgetStatePropertyAll(theme.colorScheme.surface),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          elevation: const WidgetStatePropertyAll(8),
          backgroundColor: WidgetStatePropertyAll(
            theme.colorScheme.surfaceContainer.withValues(alpha: 0.95),
          ),
        ),
        textStyle: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        dropdownMenuEntries:
            TransactionScreenController.categories
                .map(
                  (e) => DropdownMenuEntry(
                    value: e,
                    label: e,
                    style: MenuItemButton.styleFrom(
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      backgroundColor: theme.colorScheme.surfaceContainer,
                    ),
                  ),
                )
                .toList(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: theme.colorScheme.surfaceContainer.withValues(alpha: 0.75),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2.0,
            ),
          ),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static Widget currencyBox({
    required ThemeData theme,
    required TripDetailController tripDetailController,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainer.withValues(alpha: 0.7),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        tripDetailController.trip['currency'] == 'INR' ? '₹' : '\$',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
        semanticsLabel:
            tripDetailController.trip['currency'] == 'INR'
                ? 'Indian Rupee'
                : 'Dollar',
      ),
    );
  }

  static Widget amountField({
    required ThemeData theme,
    required TransactionScreenController controller,
  }) {
    return Obx(() {
      final hasError = controller.amountError.value.isNotEmpty;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform:
            hasError
                ? Matrix4.translationValues(
                  5 *
                      (DateTime.now().millisecondsSinceEpoch % 100 < 50
                          ? 1
                          : -1),
                  0,
                  0,
                )
                : Matrix4.identity(),
        child: TextFormField(
          onChanged: controller.updateAmount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            filled: true,
            fillColor: theme.colorScheme.surfaceContainer.withValues(
              alpha: 0.7,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color:
                    hasError
                        ? theme.colorScheme.error.withValues(alpha: 0.6)
                        : theme.colorScheme.outline.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    });
  }

  static Widget payerDropdown({
    required BuildContext context,
    required ThemeData theme,
    required TripDetailController tripDetailController,
    required TransactionScreenController controller,
    bool isSingleSelection = false,
  }) {
    return Obx(() {
      final hasError = controller.payersError.value.isNotEmpty;
      final selectedNames = controller.transactionPayers;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform:
            hasError
                ? Matrix4.translationValues(
                  5 *
                      (DateTime.now().millisecondsSinceEpoch % 100 < 50
                          ? 1
                          : -1),
                  0,
                  0,
                )
                : Matrix4.identity(),
        child: GestureDetector(
          onTap:
              () => showDialog(
                context: context,
                builder:
                    (dialogContext) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      backgroundColor: theme.colorScheme.surfaceContainer
                          .withValues(alpha: 0.95),
                      title: Text(
                        isSingleSelection ? 'Select Payer' : 'Select Payers',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      content: Container(
                        width: double.maxFinite,
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: Obx(
                          () => ListView(
                            children:
                                tripDetailController.participants.map((name) {
                                  final isSelected = selectedNames.contains(
                                    name,
                                  );
                                  return CheckboxListTile(
                                    value: isSelected,
                                    onChanged:
                                        isSingleSelection && isSelected
                                            ? null
                                            : (checked) {
                                              controller.togglePayer(name);
                                              if (isSingleSelection)
                                                Navigator.pop(dialogContext);
                                            },
                                    title: Text(
                                      name == "Viren" ? "$name (me)" : name,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    activeColor: theme.colorScheme.primary,
                                    checkColor: theme.colorScheme.onPrimary,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                      actions: [
                        if (!isSingleSelection)
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
              ),
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText:
                    selectedNames.isEmpty
                        ? 'Select payer${isSingleSelection ? '' : 's'}'
                        : 'Paid by ${selectedNames.length} ${isSingleSelection ? 'person' : 'people'}',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainer.withValues(
                  alpha: 0.7,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color:
                        hasError
                            ? theme.colorScheme.error.withValues(alpha: 0.6)
                            : theme.colorScheme.outline.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  static Widget recipientDropdown({
    required BuildContext context,
    required ThemeData theme,
    required TripDetailController tripDetailController,
    required TransactionScreenController controller,
  }) {
    return Obx(() {
      final hasError = controller.recipientsError.value.isNotEmpty;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform:
            hasError
                ? Matrix4.translationValues(
                  5 *
                      (DateTime.now().millisecondsSinceEpoch % 100 < 50
                          ? 1
                          : -1),
                  0,
                  0,
                )
                : Matrix4.identity(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    backgroundColor: theme.colorScheme.surfaceContainer
                        .withValues(alpha: 0.95),
                    title: Text(
                      'Select Recipients',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    content: Container(
                      width: double.maxFinite,
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: Obx(
                        () => ListView(
                          children:
                              tripDetailController.participants.map((name) {
                                return CheckboxListTile(
                                  value: controller.transactionRecipients
                                      .contains(name),
                                  onChanged: (value) {
                                    controller.toggleRecipient(name);
                                  },
                                  title: Text(
                                    name == "Viren" ? "$name (me)" : name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  activeColor: theme.colorScheme.primary,
                                  checkColor: theme.colorScheme.onPrimary,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText:
                    controller.transactionRecipients.isEmpty
                        ? 'Select recipients'
                        : 'Received by ${controller.transactionRecipients.length} people',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainer.withValues(
                  alpha: 0.7,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color:
                        hasError
                            ? theme.colorScheme.error.withValues(alpha: 0.6)
                            : theme.colorScheme.outline.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  static Widget amountValidation({
    required ThemeData theme,
    required TransactionScreenController controller,
    bool isTransfer = false,
    bool forPayers = false,
  }) {
    return Obx(() {
      final amount = double.tryParse(controller.transactionAmount.value) ?? 0.0;
      final remainingRaw = controller.remainingShareString(
        forPayers: forPayers,
      );
      final remaining =
          double.tryParse(remainingRaw.replaceAll(RegExp(r'[^\d.-]'), '')) ??
          0.0;

      final showWarning = remaining != 0 && amount > 0;

      String roleText;
      if (isTransfer) {
        roleText = 'Received By';
      } else {
        roleText = forPayers ? 'Paid By' : 'Split';
      }

      final message = 'Unassigned Amount: $remainingRaw';

      return controller.transactionAmount.value == '0.0'
          ? const SizedBox.shrink()
          : Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  showWarning
                      ? theme.colorScheme.error.withValues(alpha: 0.15)
                      : theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    showWarning
                        ? theme.colorScheme.error.withValues(alpha: 0.3)
                        : theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              message,
              style: theme.textTheme.labelMedium?.copyWith(
                color:
                    showWarning
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
    });
  }

  static Widget extras({
    required BuildContext context,
    required ThemeData theme,
    required TransactionScreenController controller,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: controller.pickImage,
          icon: Icon(
            Icons.image_outlined,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          label: Text(
            "Bill Image",
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainer.withValues(
              alpha: 0.7,
            ),
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 2,
            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
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
            if (picked != null) controller.updateDate(picked);
          },
          icon: Icon(
            Icons.calendar_today_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          label: Obx(
            () => Text(
              Get.find<TripDetailController>().formatDate(
                controller.transactionDate.value,
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              semanticsLabel: Get.find<TripDetailController>().formatDate(
                controller.transactionDate.value,
              ),
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: theme.colorScheme.surfaceContainer.withValues(
              alpha: 0.7,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  static Widget submitButton({
    required String label,
    required ThemeData theme,
    required GlobalKey<FormState> formKey,
    required TransactionScreenController controller,
  }) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                controller.isLoading.value
                    ? null
                    : () {
                      controller.submitTransaction();
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 3,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            child:
                controller.isLoading.value
                    ? SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                        strokeWidth: 3,
                      ),
                    )
                    : Text(
                      label,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                      semanticsLabel: label,
                    ),
          ),
        ),
      ),
    );
  }
}
