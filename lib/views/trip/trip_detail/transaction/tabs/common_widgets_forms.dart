import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';
import '../../../../../controller/transaction_controller/transaction_controller.dart';
import '../../../../../data/constants.dart';
import '../../../../../model/Category/category_model.dart';

TripDetailController tripDetailController = Get.find<TripDetailController>();
TransactionScreenController transactionScreenController = Get.find<TransactionScreenController>();

class CommonFormWidgets {
  static Widget
  buildSection({
    ThemeData? theme,
    IconData? icon,
    String? title,
    required Widget child,
  }) {
    final t = theme ?? ThemeData.light(); // fallback theme

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            t.colorScheme.surfaceContainer.withValues(alpha: 0.9),
            t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: t.shadowColor.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null || title != null)
            Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 24,
                    color: t.colorScheme.primary.withValues(alpha: 0.95),
                  ),
                if (icon != null && title != null) const SizedBox(width: 12),
                if (title != null)
                  Text(
                    title,
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: t.colorScheme.primary,
                      letterSpacing: 0.8,
                    ),
                    semanticsLabel: title,
                  ),
              ],
            ),
          if (icon != null || title != null) const SizedBox(height: 8),
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
        transform: hasError
            ? Matrix4.translationValues(
          5 * (DateTime
              .now()
              .millisecondsSinceEpoch % 100 < 50 ? 1 : -1),
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
                color: hasError
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
    final selected = controller.selectedCategory.value;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainer.withAlpha(80),
        border: Border.all(
          color: selected != null
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withAlpha(100),
          width: selected != null ? 1.8 : 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: DropdownMenu<CategoryModel>(
        initialSelection: selected,
        onSelected: controller.updateCategory,
        trailingIcon: Icon(Icons.arrow_drop_down),
        hintText: 'Select category',
        width: 260,
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            theme.colorScheme.surfaceContainerHighest,
          ),
          elevation: const WidgetStatePropertyAll(12),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          shadowColor: WidgetStatePropertyAll(
            theme.shadowColor.withAlpha(50),
          ),
          maximumSize: WidgetStatePropertyAll(const Size(165, 300)),
        ),
        dropdownMenuEntries: controller.categories.map(
              (cat) =>
              DropdownMenuEntry<CategoryModel>(
                value: cat,
                label: '${cat.emoji} ${cat.name}',
                style: MenuItemButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 14),
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
        ).toList(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.transparent,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 8,
          ),
          border: InputBorder.none,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline.withAlpha(150),
          ),
        ),
      ),
    );
  }

  static Widget currencyBox({
    required BuildContext context,
    required ThemeData theme,
    required TripDetailController tripDetailController,
  }) {
    final currencyList = Kconstant.currencyModelList;

    final selectedCurrency = currencyList.firstWhere(
          (currency) =>
      currency.id == tripDetailController.trip['default_currency'],
      orElse: () => currencyList.firstWhere((currency) => currency.id == 15),
    );
    return GestureDetector(
      onTap: () async {
        await Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Text('Select Currency', style: theme.textTheme.titleMedium),
            content: SizedBox(
              height: 300,
              width: 300,
              child: Scrollbar(
                thickness: 4,
                radius: const Radius.circular(8),
                child: ListView.builder(
                  itemCount: currencyList.length,
                  itemBuilder: (context, index) {
                    final currency = currencyList[index];
                    return ListTile(
                      title: Text(currency.name),
                      trailing: Text('(${currency.code})'),
                      onTap: () {
                        tripDetailController.trip['default_currency'] = currency
                            .id;
                        tripDetailController.update();
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCurrency.symbol,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
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
        transform: hasError
            ? Matrix4.translationValues(
          5 * (DateTime
              .now()
              .millisecondsSinceEpoch % 100 < 50 ? 1 : -1),
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
            fontSize: 14,
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
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: hasError
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
        transform: hasError
            ? Matrix4.translationValues(
          5 * (DateTime
              .now()
              .millisecondsSinceEpoch % 100 < 50 ? 1 : -1),
          0,
          0,
        )
            : Matrix4.identity(),
        child: GestureDetector(
          onTap: () =>
              showDialog(
                context: context,
                builder: (dialogContext) =>
                    Obx(() {
                      final participantNames = Kconstant.participantsRx
                          .map((participant) => participant['name'] as String)
                          .toList();
                      final isAllSelected = selectedNames.length ==
                          participantNames.length;
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: theme.colorScheme.surfaceContainer
                            .withValues(alpha: 0.95),
                        title: isSingleSelection
                            ? Text(
                          'Select Payer',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        )
                            : CheckboxListTile(
                          value: isAllSelected,
                          onChanged: (checked) {
                            if (checked == true) {
                              controller.transactionPayers.clear();
                              controller.transactionPayers.addAll(
                                  participantNames);
                            } else {
                              controller.transactionPayers.clear();
                            }
                            controller.transactionPayers.refresh();
                          },
                          title: Text(
                            'Select All',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          activeColor: theme.colorScheme.primary,
                          checkColor: theme.colorScheme.onPrimary,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        content: Container(
                          width: double.maxFinite,
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: ListView(
                            children: participantNames.map((name) {
                              final isSelected = selectedNames.contains(name);
                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: isSingleSelection && isSelected
                                    ? null
                                    : (checked) {
                                  controller.togglePayer(name);
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
                      );
                    }),
              ),
          child: AbsorbPointer(
            child: TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: selectedNames.isEmpty
                    ? 'Select payer${isSingleSelection ? '' : 's'}'
                    : 'Paid by ${selectedNames.length} ${isSingleSelection
                    ? 'person'
                    : 'people'}',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainer.withValues(
                    alpha: 0.7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: hasError
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
        transform: hasError
            ? Matrix4.translationValues(
          5 * (DateTime
              .now()
              .millisecondsSinceEpoch % 100 < 50 ? 1 : -1),
          0,
          0,
        )
            : Matrix4.identity(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) =>
                  AlertDialog(
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
                            () {
                          final participantNames = Kconstant.participantsRx
                              .map((
                              participant) => participant['name'] as String)
                              .toList();
                          return ListView(
                            children: participantNames.map((name) {
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
                          );
                        },
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
                hintText: controller.transactionRecipients.isEmpty
                    ? 'Select recipients'
                    : 'Received by ${controller.transactionRecipients
                    .length} people',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainer.withValues(
                  alpha: 0.7,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: hasError
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
    final amount = double.tryParse(controller.transactionAmount.value) ?? 0.0;
    final remainingRaw = controller.remainingShareString(forPayers: forPayers);
    final remaining =
        double.tryParse(remainingRaw.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0.0;

    final showWarning = remaining != 0 && amount > 0;

    String roleText;
    if (isTransfer) {
      roleText = 'Received By';
    } else {
      roleText = forPayers ? 'Paid By' : 'Split';
    }
    print(roleText);

    final selectedCurrency = Kconstant.currencyModelList.firstWhere(
          (c) => c.id == tripDetailController.trip['default_currency'],
      orElse: () => Kconstant.currencyModelList.first,
    );

    final message = 'Unassigned Amount: ${selectedCurrency.symbol} $remaining';

    return remaining.isEqual(0)
        ? const SizedBox.shrink()
        : Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: showWarning
            ? theme.colorScheme.error.withValues(alpha: 0.15)
            : theme.colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showWarning
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        message,
        style: theme.textTheme.labelMedium?.copyWith(
          color: showWarning
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  static Widget extras({
    required BuildContext context,
    required ThemeData theme,
    required TransactionScreenController controller,
  }) {
    final tripController = Get.find<TripDetailController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: ElevatedButton.icon(
            onPressed: controller.pickImage,
            icon: Icon(
              Icons.image_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              "Bill Image",
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainer.withAlpha(
                  180),
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 2,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: const Size(0, 44),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: TextButton.icon(
            onPressed: () async {
              final picked = await showDialog<DateTime>(
                context: context,
                builder: (dialogContext) =>
                    DatePickerDialog(
                      initialDate: controller.transactionDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    ),
              );
              if (picked != null) controller.updateDate(picked);
            },
            icon: Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            label: Obx(
                  () =>
                  Text(
                    tripController.formatDate(controller.transactionDate.value),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    semanticsLabel: tripController.formatDate(
                      controller.transactionDate.value,
                    ),
                  ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              backgroundColor: theme.colorScheme.surfaceContainer.withAlpha(
                  180),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: const Size(0, 44),
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
          () =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                  if (formKey.currentState?.validate() ?? false) {
                    controller.submitTransaction();
                  }
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
                child: controller.isLoading.value
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