import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';

class TransactionFormWidgets {
  static Widget buildSection({
    required ThemeData theme,
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
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
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

  static Widget textField({
    required ThemeData theme,
    required String hint,
    required TextEditingController controller,
    required Function(String) onChanged,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
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

  static Widget currencyBox(TripDetailController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        controller.tripController.tripModel?.tripCurrency == 'INR' ? '₹' : '\$',
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  static Widget extras(TripDetailController controller, ThemeData theme, RxBool hasChanges) {
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

  static Widget submitButton({
    required ThemeData theme,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
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

  static Widget actionButton({
    required ThemeData theme,
    required String text,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        foregroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        splashFactory: NoSplash.splashFactory,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  static Widget amountValidation({
    required TripDetailController controller,
    required ThemeData theme,
    bool isRecipient = false,
  }) {
    return Obx(() {
      final total = isRecipient
          ? controller.recipientAmounts.values.fold(0.0, (sum, amt) => sum + amt)
          : controller.payerAmounts.values.fold(0.0, (sum, amt) => sum + amt);
      final expected = double.tryParse(controller.transactionAmount.value) ?? 0.0;
      final diff = expected - total;
      final hasError = diff != 0 || total == 0;

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (hasError)
            Icon(Icons.warning, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 4),
          Text(
            hasError
                ? (diff > 0
                ? 'Remaining: ${controller.formatCurrency(diff)}'
                : 'Over by: ${controller.formatCurrency(-diff)}')
                : 'Total matches',
            style: TextStyle(
              color: hasError ? theme.colorScheme.error : theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    });
  }

  static Widget buildTab({
    required BuildContext context,
    required TripDetailController controller,
    required String title,
    required int index,
    required int? badgeCount,
  }) {
    final theme = Theme.of(context);
    final isActive = controller.selectedTabIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if ((badgeCount ?? 0) > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget buildSummaryCard({
    required BuildContext context,
    required TripDetailController controller,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          buildSummaryRow(
            context: context,
            label: 'Total Expenses',
            value: controller.formatCurrency(controller.summary['total_expenses'] ?? 0.0),
          ),
          const Divider(),
          buildSummaryRow(
            context: context,
            label: 'My Expenses',
            value: controller.formatCurrency(controller.summary['my_expenses'] ?? 0.0),
          ),
          const Divider(),
          buildSummaryRow(
            context: context,
            label: 'You are owed',
            value: controller.formatCurrency(controller.summary['amount_owed'] ?? 0.0),
            highlight: true,
          ),
        ],
      ),
    );
  }

  static Widget buildSummaryRow({
    required BuildContext context,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildExpenseCard({
    required BuildContext context,
    required TripDetailController controller,
    required Map<String, dynamic> expense,
  }) {
    final theme = Theme.of(context);
    final categoryIcons = {
      'Food': Icons.local_dining,
      'Transport': Icons.directions_car,
      'Accommodation': Icons.hotel,
      'Entertainment': Icons.theater_comedy,
      'Other': Icons.category,
    };
    final categoryColors = {
      'Food': Colors.orange,
      'Transport': Colors.blue,
      'Accommodation': Colors.green,
      'Entertainment': Colors.purple,
      'Other': Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: categoryColors[expense['category']] ?? Colors.grey,
              child: Icon(
                categoryIcons[expense['category']] ?? Icons.category,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense['category'] ?? 'Unknown',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Paid by ${expense['paid_by'] ?? 'Unknown'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.formatCurrency((expense['amount'] as num?)?.toDouble() ?? 0.0),
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  controller.formatCurrency((expense['user_share'] as num?)?.toDouble() ?? 0.0),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}