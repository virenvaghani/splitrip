import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';

class AddTransactionScreen extends StatelessWidget {
  AddTransactionScreen({super.key});
  final controller = Get.find<TripDetailController>();
  final expenseFormKey = GlobalKey<FormState>(); // Separate key for Expense form
  final incomeFormKey = GlobalKey<FormState>(); // Separate key for Income form
  final transferFormKey = GlobalKey<FormState>(); // Separate key for Transfer form
  final hasChanges = false.obs;
  final tabController = TabController(length: 3, vsync: _TickerProvider());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ever(controller.transactionTitle, (_) => hasChanges.value = true);
    ever(controller.transactionAmount, (_) => hasChanges.value = true);
    ever(controller.transactionPayers, (_) => hasChanges.value = true);
    ever(controller.payerAmounts, (_) => hasChanges.value = true);
    ever(controller.transactionSplitType, (_) => hasChanges.value = true);
    ever(controller.customShares, (_) => hasChanges.value = true);
    ever(controller.selectedCategory, (_) => hasChanges.value = true);
    ever(controller.transactionRecipient, (_) => hasChanges.value = true);

    return Obx(() => WillPopScope(
      onWillPop: () async {
        if (hasChanges.value && !controller.isTransactionSubmitted.value) {
          final shouldDiscard = await _showDiscardDialog(context);
          if (shouldDiscard) {
            controller.discardTransaction();
            return true;
          }
          return false;
        }
        controller.discardTransaction();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            "${controller.trip['emoji'] ?? '✌️'} ${controller.trip['name']}",
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () async {
              if (hasChanges.value &&
                  !controller.isTransactionSubmitted.value) {
                final shouldDiscard = await _showDiscardDialog(context);
                if (shouldDiscard) {
                  controller.discardTransaction();
                  Get.back();
                }
              } else {
                controller.discardTransaction();
                Get.back();
              }
            },
          ),
          bottom: TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
              Tab(text: 'Transfer'),
            ],
            onTap: (index) {
              controller.transactionType(
                  ['expense', 'income', 'transfer'][index]);
              hasChanges.value = true;
            },
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            _buildExpenseForm(theme, expenseFormKey),
            _buildIncomeForm(theme, incomeFormKey),
            _buildTransferForm(theme, transferFormKey),
          ],
        ),
      ),
    ));
  }

  Widget _buildExpenseForm(ThemeData theme, GlobalKey<FormState> formKey) {
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
                      Expanded(child: _textField("Title", controller.updateTitle)),
                      const SizedBox(width: 12),
                      Expanded(child: _categoryDropdown(theme)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _currencyBox(theme),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _textField(
                          "0.00",
                          controller.updateAmount,
                          inputType: TextInputType.numberWithOptions(decimal: true),
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
              icon: Icons.payments_outlined,
              title: "Paid By",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _payerDropdown(theme),
                  Obx(() {
                    if (controller.transactionPayers.isNotEmpty) {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildPayerAmountInputs(theme),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildAmountValidation(theme),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              theme,
              icon: Icons.groups_2_outlined,
              title: "Split Between",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _splitOptions(theme),
                  const SizedBox(height: 12),
                  _buildShareInputs(theme),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Remaining: ${controller.remainingShareString()}",
                      style: theme.textTheme.bodySmall,
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
              child: _buildExtras(theme),
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(theme, 'Add Expense'),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeForm(ThemeData theme, GlobalKey<FormState> formKey) {
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
                      Expanded(child: _textField("Title", controller.updateTitle)),
                      const SizedBox(width: 12),
                      Expanded(child: _categoryDropdown(theme)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _currencyBox(theme),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _textField(
                          "0.00",
                          controller.updateAmount,
                          inputType: TextInputType.numberWithOptions(decimal: true),
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
              icon: Icons.payments_outlined,
              title: "Received By",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _payerDropdown(theme),
                  Obx(() {
                    if (controller.transactionPayers.isNotEmpty) {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildPayerAmountInputs(theme),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildAmountValidation(theme),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              theme,
              icon: Icons.groups_2_outlined,
              title: "Split Between",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _splitOptions(theme),
                  const SizedBox(height: 12),
                  _buildShareInputs(theme),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Remaining: ${controller.remainingShareString()}",
                      style: theme.textTheme.bodySmall,
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
              child: _buildExtras(theme),
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(theme, 'Add Income'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferForm(ThemeData theme, GlobalKey<FormState> formKey) {
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
              title: "Transfer Details",
              child: Column(
                children: [
                  _textField("Title", controller.updateTitle),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _currencyBox(theme),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _textField(
                          "0.00",
                          controller.updateAmount,
                          inputType: TextInputType.numberWithOptions(decimal: true),
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
              icon: Icons.payments_outlined,
              title: "Paid By",
              child: _payerDropdown(theme),
            ),
            const SizedBox(height: 20),
            _buildSection(
              theme,
              icon: Icons.person_outline,
              title: "Transferred To",
              child: _recipientDropdown(theme),
            ),
            const SizedBox(height: 20),
            _buildSection(
              theme,
              icon: Icons.more_horiz_outlined,
              title: "Extras",
              child: _buildExtras(theme),
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(theme, 'Add Transfer'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme,
      {required IconData icon, required String title, required Widget child}) {
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
          )
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
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<bool> _showDiscardDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Discard them anyway?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Widget _textField(String hint, Function(String) onChanged,
      {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      onChanged: onChanged,
      keyboardType: inputType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (hint == "Title" && (value == null || value.isEmpty)) {
          return 'Please enter a title';
        }
        if (hint == "0.00" &&
            (value == null ||
                double.tryParse(value) == null ||
                double.parse(value) <= 0)) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _currencyBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        controller.trip['currency'] == 'INR' ? '₹' : '\$',
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _categoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: controller.selectedCategory.value,
      onChanged: (value) {
        controller.updateCategory(value);
        hasChanges.value = true;
      },
      items: controller.categories
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      decoration: InputDecoration(
        hintText: 'Category',
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _payerDropdown(ThemeData theme) {
    return DropdownButtonFormField2<String>(
      value: null,
      onChanged: null,
      items: [],
      decoration: InputDecoration(
        hintText: controller.transactionPayers.isEmpty
            ? 'Select payers'
            : controller.transactionType.value == 'transfer'
            ? 'Paid by ${controller.transactionPayers.length} person'
            : 'Paid by ${controller.transactionPayers.length} people',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainer,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        offset: const Offset(0, -8),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: WidgetStateProperty.all(6),
        ),
      ),
      iconStyleData: IconStyleData(
        icon: Builder(
          builder: (context) => PopupMenuButton<String>(
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onSelected: (value) {
              controller.togglePayer(value);
              hasChanges.value = true;
            },
            itemBuilder: (_) => controller.participants.map((name) {
              return PopupMenuItem<String>(
                value: name,
                child: Obx(
                      () => Row(
                    children: [
                      Checkbox(
                        value: controller.transactionPayers.contains(name),
                        onChanged: (_) {
                          controller.togglePayer(name);
                          hasChanges.value = true;
                        },
                        activeColor: theme.colorScheme.primary,
                        checkColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        name == "Viren" ? "$name (me)" : name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _recipientDropdown(ThemeData theme) {
    return DropdownButtonFormField2<String>(
      value: controller.transactionRecipient.value,
      onChanged: (value) {
        controller.updateRecipient(value);
        hasChanges.value = true;
      },
      items: controller.participants
          .map((name) => DropdownMenuItem<String>(
        value: name,
        child: Text(
          name == "Viren" ? "$name (me)" : name,
          style: theme.textTheme.bodyMedium,
        ),
      ))
          .toList(),
      decoration: InputDecoration(
        hintText: 'Select recipient',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainer,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        offset: const Offset(0, -8),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: WidgetStateProperty.all(6),
        ),
      ),
      validator: (value) => value == null ? 'Please select a recipient' : null,
    );
  }

  Widget _buildPayerAmountInputs(ThemeData theme) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: controller.transactionPayers.map((name) {
            final amount = controller.payerAmounts[name] ?? 0.0;
            final textController = controller.getPayerTextController(name);

            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: textController,
                        onChanged: (val) {
                          final amount =
                              double.tryParse(val.replaceAll(RegExp(r'[^\d.]'), '')) ??
                                  0.0;
                          controller.updatePayerAmount(name, amount);
                        },
                        keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                            prefixText:
                            controller.trip['currency'] == 'INR' ? '₹ ' : '\$ ',
                            prefixStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest,
                            hintText: "0.00"),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ));
  }

  Widget _splitOptions(ThemeData theme) {
    return Row(
      children: controller.splitTypes.map((type) {
        final selected = controller.transactionSplitType.value == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                controller.updateSplitType(type);
                hasChanges.value = true;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selected
                    ? theme.colorScheme.primary.withOpacity(0.12)
                    : theme.colorScheme.surfaceVariant,
                foregroundColor: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(type, style: theme.textTheme.labelMedium),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShareInputs(ThemeData theme) {
    final isEqual = controller.transactionSplitType.value == 'Equally';

    return Column(
      children: controller.participants.map((name) {
        final amount = controller.transactionShares[name] ?? 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(name, style: theme.textTheme.bodyLarge)),
              SizedBox(
                width: 100,
                child: TextFormField(
                  enabled: !isEqual,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: isEqual ? controller.formatCurrency(amount) : 'Enter',
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) {
                    controller.updateCustomShare(
                        name,
                        double.tryParse(val.replaceAll(RegExp(r'[^\d.]'), '')) ??
                            0.0);
                    hasChanges.value = true;
                  },
                  validator: (value) {
                    if (!isEqual &&
                        (value == null ||
                            double.tryParse(value) == null ||
                            double.parse(value) <= 0)) {
                      return 'Enter a valid share';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountValidation(ThemeData theme) {
    final totalPaid = controller.payerAmounts.values.fold(0.0, (sum, amt) => sum + amt);
    final expected = double.tryParse(controller.transactionAmount.value) ?? 0.0;
    final diff = expected - totalPaid;
    final hasError = diff != 0 || totalPaid == 0;

    return Text(
      hasError
          ? (diff > 0
          ? 'Remaining: ${controller.formatCurrency(diff)}'
          : 'Over by: ${controller.formatCurrency(-diff)}')
          : 'Total matches: ${controller.formatCurrency(totalPaid)}',
      style: TextStyle(
        color: hasError ? theme.colorScheme.error : theme.colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildExtras(ThemeData theme) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: controller.pickImage,
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
            final picked = await showDatePicker(
              context: Get.context!,
              initialDate: controller.transactionDate.value,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.updateDate(picked);
              hasChanges.value = true;
            }
          },
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(
            controller.formatDate(controller.transactionDate.value),
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme, String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (controller.transactionPayers.isEmpty &&
            controller.transactionRecipient.value == null) ||
            (controller.transactionType.value == 'transfer' &&
                controller.transactionPayers.length > 1)
            ? null
            : () {
          if (controller.transactionType.value == 'transfer') {
            if (transferFormKey.currentState!.validate()) {
              controller.submitTransaction();
            }
          } else if (controller.transactionType.value == 'income') {
            if (incomeFormKey.currentState!.validate()) {
              controller.submitTransaction();
            }
          } else {
            if (expenseFormKey.currentState!.validate()) {
              controller.submitTransaction();
            }
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
        ),
      ),
    );
  }
}

class _TickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}