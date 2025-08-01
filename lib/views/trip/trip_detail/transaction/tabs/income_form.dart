import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';
import 'package:splitrip/controller/transaction_controller/transaction_controller.dart';
import 'package:splitrip/data/trip_constant.dart';
import '../../../../../data/constants.dart';
import 'common_widgets_forms.dart';

class IncomeForm extends StatelessWidget {
  IncomeForm({super.key});

  final tripDetailController = Get.find<TripDetailController>();
  final transactionController = Get.find<TransactionScreenController>();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetX<TransactionScreenController>(
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
                      CommonFormWidgets.extras(context: context, theme: theme, controller: transactionController),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.buildSection(
                  theme: theme,
                  icon: Icons.payments_outlined,
                  title: "Received By",
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
                  icon:null,
                  title: null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.groups_2_outlined,
                                  size: 24,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.95,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Split",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 0.8,
                                  ),
                                  semanticsLabel: "Split",
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _splitOptionsDropdown(
                              theme,
                              transactionController,
                            ),
                          ),
                        ],
                      ),
                      _shareInputs(
                        theme,
                        tripDetailController,
                        transactionController,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CommonFormWidgets.amountValidation(
                          theme: theme,
                          controller: transactionController,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.submitButton(
                  label: 'Add Income',
                  theme: theme,
                  formKey: formKey,
                  controller: transactionController,
                ),
              ],
            ),
          ),
        );
      }
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
            () => controller.transactionPayers.isEmpty
            ? const SizedBox.shrink()
            : ListView.builder(
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
                        final amount = double.tryParse(val.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
                        controller.updatePayerAmount(name, amount);
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
                        prefixText: tripDetailController.trip['currency'] == 'INR' ? '₹ ' : '\$ ',
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
                        if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
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
  Widget _splitOptionsDropdown(
      ThemeData theme,
      TransactionScreenController controller,
      ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        color: Colors.transparent,
      ),
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
          items:
          TransactionScreenController.splitTypes.map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            if (value != null) controller.updateSplitType(value);
          },
        ),
      ),
    );
  }

  Widget _shareInputs(
      ThemeData theme,
      TripDetailController tripDetailController,
      TransactionScreenController controller,
      ) {
    final splitType = controller.transactionSplitType.value;

    if (splitType == 'As parts') {
      return _shareInputsAsParts(theme, tripDetailController, controller);
    } else {
      return _shareInputsEqualAndAmount(
        theme,
        tripDetailController,
        controller,
      );
    }
  }
}

Widget _shareInputsAsParts(
    ThemeData theme,
    TripDetailController tripDetailController,
    TransactionScreenController controller,
    ) {
  final participantNames = Kconstant.participantsRx
      .map((participant) => participant['name'] as String)
      .toList();
  final participantMembers = Kconstant.participantsRx
      .map((participant) => num.tryParse(participant['custom_member_count'].toString()) ?? 1)
      .toList();

  controller.initializeShareFields(participantNames,participantMembers);

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: Kconstant.participantsRx.length,
    itemBuilder: (context, index) {
      final participant = Kconstant.participantsRx[index];
      final name =participant['name'] as String;
      final isSelected = controller.selectedParticipants.contains(name);
      final amount = controller.transactionShares[name] ?? 0.0;
      final parts = controller.customShares[name] ?? 1.0;

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                          parts.toStringAsFixed(2),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          'x',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: 80,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tripDetailController.formatCurrency(amount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 4),

                // Stepper buttons
                _stepperButton(
                  theme: theme,
                  icon: Icons.remove,
                  onPressed:
                  isSelected ? () => controller.decrementParts(name) : null,
                  isEnabled: isSelected,
                ),
                const SizedBox(width: 2),
                _stepperButton(
                  theme: theme,
                  icon: Icons.add,
                  onPressed:
                  isSelected ? () => controller.incrementParts(name) : null,
                  isEnabled: isSelected,
                ),
              ],
            ),
          ),
          Kconstant.participantsRx.length - 1 == index
              ? SizedBox.shrink()
              : Divider(
            height: 1,
            color: theme.dividerColor.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ],
      );
    },
  );
}

Widget _stepperButton({
  required ThemeData theme,
  required IconData icon,
  required VoidCallback? onPressed,
  required bool isEnabled,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      height:48,
      width: 48,
      decoration: BoxDecoration(
        color:
        isEnabled
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.05,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 16,
        color:
        isEnabled
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

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: Kconstant.participantsRx.length,
    itemBuilder: (context, index) {
      final participant = Kconstant.participantsRx[index];
      final name = participant['name'] as String;
      final isSelected = controller.selectedParticipants.contains(name);
      final amount = controller.transactionShares[name] ?? 0.0;
      final textController = controller.shareControllers[name];
      final focusNode = controller.shareFocusNodes[name];

      final selectedCurrency = Kconstant.currencyModelList.firstWhere(
            (currency) =>
        currency.id == tripDetailController.trip['default_currency'],
        orElse:
            () => Kconstant.currencyModelList.firstWhere(
              (currency) => currency.id == 15,
        ),
      );

      print(
        'Building TextFormField for $name: isEqual=$isEqual, isSelected=$isSelected, amount=$amount',
      );

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    if (value == true) {
                      controller.selectedParticipants.add(name);
                      if (!isEqual) {
                        controller.customShares[name] =
                            controller.transactionShares[name] ?? 0.0;
                        controller.fixedAmounts[name] =
                        false; // New participant is not fixed
                        textController!.text = controller.customShares[name]!
                            .toStringAsFixed(2);
                      }
                    } else {
                      controller.selectedParticipants.remove(name);
                      controller.customShares[name] = 0.0;
                      controller.transactionShares[name] = 0.0;
                      controller.fixedAmounts[name] = false;
                      textController!.text = '0.00';
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
                Text(
                  selectedCurrency.symbol,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    key: ValueKey('$name-amount'),
                    controller: textController,
                    focusNode: focusNode,
                    enabled: !isEqual && isSelected,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.isEmpty || newValue.text == '.') {
                          return newValue;
                        }
                        if (double.tryParse(newValue.text) != null) {
                          return newValue;
                        }
                        return oldValue;
                      }),
                    ],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: amount.toStringAsFixed(2),
                      filled: true,
                      fillColor: theme.primaryColor.withValues(alpha: 0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      print('Input changed for $name: $val');
                      final parsed = double.tryParse(val) ?? 0.0;
                      controller.updateCustomShare(name, parsed);
                    },
                    onFieldSubmitted: (val) {
                      print('Input submitted for $name: $val');
                      final parsed = double.tryParse(val) ?? 0.0;
                      controller.updateCustomShare(name, parsed);
                    },
                  ),
                ),
              ],
            ),
          ),
          Kconstant.participantsRx.length - 1 == index
              ? SizedBox.shrink()
              : Divider(
            height: 1,
            color: theme.dividerColor.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ],
      );
    },
  );
}
