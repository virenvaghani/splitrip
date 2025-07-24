import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';
import 'package:splitrip/data/trip_constant.dart';
import '../../../../../controller/transaction_controller/transaction_controller.dart';
import '../../../../../data/constants.dart';
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
                            context: context,
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
                  icon: transactionController.transactionPayers.isEmpty ? Icons
                      .payments_outlined : null,
                  title: transactionController.transactionPayers.isEmpty
                      ? "Paid By"
                      : null,
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
                  title: "Split",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _splitOptionsDropdown(theme, transactionController),
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

  Widget _payerAmountInputs(ThemeData theme,
      TransactionScreenController controller,) {
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
      child: Obx(() {
        final selectedCurrency = Kconstant.currencyModelList.firstWhere(
              (currency) =>
          currency.id == tripDetailController.trip['currency'],
          orElse: () => Kconstant.currencyModelList.first,
        );

        return controller.transactionPayers.isEmpty
            ? const SizedBox.shrink()
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.transactionPayers.length,
          itemBuilder: (context, index) {
            final name = controller.transactionPayers[index];
            final textController =
            controller.getPayerTextController(name);

            return Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                    flex: 3,
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      semanticsLabel: name,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    selectedCurrency.symbol,
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: textController,
                      onChanged: (val) {
                        final amount = double.tryParse(
                          val.replaceAll(RegExp(r'[^\d.]'), ''),
                        ) ??
                            0.0;
                        controller.updatePayerAmount(name, amount);
                      },
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      textDirection: TextDirection.ltr,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
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
                        fillColor: theme.highlightColor.withValues(alpha: 0.2),
                        hintText: "0.00",
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }


  Widget _splitOptionsDropdown(ThemeData theme,
      TransactionScreenController controller,) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.2,
          ),
          color: theme.colorScheme.surfaceContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.transactionSplitType.value,
            icon: const Icon(Icons.arrow_drop_down),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            dropdownColor: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            isExpanded: true,
            items: TransactionScreenController.splitTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) controller.updateSplitType(value);
            },
          ),
        ),
      );
    });
  }

  Widget _shareInputs(ThemeData theme,
      TripDetailController tripDetailController,
      TransactionScreenController controller,) {
    return Obx(() {
      final splitType = controller.transactionSplitType.value;
      if (splitType == 'As parts') {
        return _shareInputsAsParts(theme, tripDetailController, controller);
      } else {
        return _shareInputsEqualAndAmount(
            theme, tripDetailController, controller);
      }
    });
  }
}

Widget _shareInputsAsParts(
    ThemeData theme,
    TripDetailController tripDetailController,
    TransactionScreenController controller,
    ) {
  controller.initializeShareFields(tripDetailController.participants);

  return Obx(() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tripDetailController.participants.length,
      itemBuilder: (context, index) {
        final name = tripDetailController.participants[index];
        final isSelected = controller.selectedParticipants.contains(name);
        final amount = controller.transactionShares[name] ?? 0.0;
        final parts = controller.customShares[name] ?? 1.0;

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      if (value == true) {
                        controller.selectedParticipants.add(name);
                        controller.customShares[name] = 1.0;
                      } else {
                        controller.selectedParticipants.remove(name);
                        controller.customShares[name] = 0.0;
                        controller.transactionShares[name] = 0.0;
                      }
                      controller.updateCalculatedShares();
                    },
                    activeColor: theme.colorScheme.primary,
                    checkColor: theme.colorScheme.onPrimary,
                    side: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      width: 1.8,
                    ),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Name
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Parts & Amount Column
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            parts.toStringAsFixed(0),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'x',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tripDetailController.formatCurrency(amount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // Stepper buttons
                  _stepperButton(
                    theme: theme,
                    icon: Icons.remove,
                    onPressed: isSelected ? () => controller.decrementParts(name) : null,
                    isEnabled: isSelected,
                  ),
                  const SizedBox(width: 4),
                  _stepperButton(
                    theme: theme,
                    icon: Icons.add,
                    onPressed: isSelected ? () => controller.incrementParts(name) : null,
                    isEnabled: isSelected,
                  ),
                ],
              ),
            ),
            tripDetailController.participants.length - 1 == index ? SizedBox.shrink() :Divider(height: 1,color: theme.dividerColor.withValues(alpha: 0.2), thickness: 1,),
          ],
        );
      },
    );
  });
}

Widget _stepperButton({
  required ThemeData theme,
  required IconData icon,
  required VoidCallback? onPressed,
  required bool isEnabled,
}) {
  return GestureDetector(
    onTap:onPressed ,
    child: Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: isEnabled
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child:Icon(
        icon,
        size: 16,
        color: isEnabled
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    ),
  );
}


Widget _shareInputsEqualAndAmount(
    ThemeData theme,
    TripDetailController tripDetailController,
    TransactionScreenController controller,
    ) {
  final isEqual = controller.transactionSplitType.value == 'Equally';

  controller.initializeShareFields(tripDetailController.participants);

  return Obx(() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tripDetailController.participants.length,
      itemBuilder: (context, index) {
        final name = tripDetailController.participants[index];
        final isSelected = controller.selectedParticipants.contains(name);
        final amount = controller.transactionShares[name] ?? 0.0;
        final textController = controller.shareControllers[name]!;
        final focusNode = controller.shareFocusNodes[name]!;

        final selectedCurrency = Kconstant.currencyModelList.firstWhere(
              (currency) => currency.id == tripDetailController.trip['currency'],
          orElse: () => Kconstant.currencyModelList.first,
        );


        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      if (value == true) {
                        controller.selectedParticipants.add(name);
                        if (!isEqual) {
                          controller.customShares[name] = 0.0;
                          textController.text = '0.00';
                        }
                      } else {
                        controller.selectedParticipants.remove(name);
                        controller.customShares[name] = 0.0;
                        controller.transactionShares[name] = 0.0;
                        textController.text = tripDetailController.formatCurrency(0.0);
                      }
                      controller.updateCalculatedShares();
                    },
                    activeColor: theme.colorScheme.primary,
                    checkColor: theme.colorScheme.onPrimary,
                    side: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Name
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Currency symbol
                  Text(
                    selectedCurrency.symbol,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Amount input
                  SizedBox(
                    width: 90,
                    child: TextFormField(
                      key: ValueKey('$name-amount'),
                      controller: textController,
                      focusNode: focusNode,
                      enabled: !isEqual && isSelected,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: isEqual
                            ? tripDetailController.formatCurrency(amount)
                            : '0.00',
                        filled: true,
                        fillColor: theme.highlightColor.withValues(alpha: 0.2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        controller.updateCustomShare(name, parsed);
                      },
                      onFieldSubmitted: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        controller.updateCustomShare(name, parsed);
                      },
                    ),
                  ),
                ],
              ),
            ),
            tripDetailController.participants.length - 1 == index ? SizedBox.shrink() :Divider(height: 1,color: theme.dividerColor.withValues(alpha: 0.2), thickness: 1,),
          ],
        );
      },
    );
  });
}
