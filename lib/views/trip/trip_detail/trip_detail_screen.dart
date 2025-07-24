import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:splitrip/data/constants.dart';

import '../../../controller/trip/trip_detail_controller.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TripDetailController tripDetailController = Get.put(
      TripDetailController(),
    );
    final int tripId = int.tryParse(Get.arguments['tripId'].toString()) ?? 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        statusBarColor: theme.scaffoldBackgroundColor,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: GetX<TripDetailController>(
          initState: (state) {
            tripDetailController.fetchTripDetailById(
              context: context,
              tripId: tripId,
            );
            tripDetailController.loadMockData();
          },
          builder: (_) {
            return Scaffold(
              appBar: _buildAppBar(context, tripDetailController),
              body:
                  tripDetailController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : _buildBodyContent(context, tripDetailController),

              bottomNavigationBar: tripDetailController.isLoading.value ? SizedBox.shrink() :_buildFAB(context, tripDetailController),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    TripDetailController controller,
  ) {
    final theme = Theme.of(context);
    return AppBar(
      actions: [
        Obx(() {
          return controller.isLoading.value
              ? SizedBox.shrink()
              : IconButton(
                onPressed: () {},
                icon: Icon(Bootstrap.three_dots_vertical),
              );
        }),
      ],
      title:
          controller.isLoading.value
              ? SizedBox.shrink()
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.trip['trip_emoji'] ?? '',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.trip['trip_name'] ?? 'Unnamed Trip',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
      centerTitle: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Obx(() {
            return controller.isLoading.value
                ? SizedBox.shrink()
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(3, (index) {
                    final titles = ['Expenses', 'Balances', 'Photos'];
                    return _buildTab(context, controller, titles[index], index);
                  }),
                );
          }),
        ),
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    TripDetailController controller,
  ) {
    // final todayExpenses = controller.todayTransactions;
    switch (controller.selectedTabIndex.value) {
      case 1:
        return const Center(child: Text('Balances coming soon'));
      case 2:
        return const Center(child: Text('Photos coming soon'));
      default:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(context, controller),
            const SizedBox(height: 24),

            if (controller.todayTransactions.isNotEmpty) ...[
              Text('Today', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...controller.todayTransactions.map(
                (expense) => _buildExpenseCard(context, controller, expense),
              ),
              const SizedBox(height: 16),
            ],

            if (controller.yesterdayTransactions.isNotEmpty) ...[
              Text('Yesterday', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...controller.yesterdayTransactions.map(
                (expense) => _buildExpenseCard(context, controller, expense),
              ),
              const SizedBox(height: 16),
            ],

            if (controller.olderTransactions.isNotEmpty) ...[
              Text('Earlier', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...controller.olderTransactions.map(
                (expense) => _buildExpenseCard(context, controller, expense),
              ),
            ],
          ],
        );
    }
  }

  Widget _buildFAB(BuildContext context, TripDetailController controller) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          final tab = controller.selectedTabIndex.value;
          if (tab == 0) {
            Get.toNamed(
              PageConstant.addTransactionScreen,
              arguments: {'type': 'Expense'},

            );
          } else {
            Get.snackbar(
              tab == 1 ? "Balances" : "Photos",
              "Screen coming soon",
            );
          }
        },
        child: Container(
          height: 56, // Match standard navigation bar height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), // Consistent with cards and tabs
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.6),
                theme.colorScheme.secondary.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.6), // Softer shadow
                blurRadius: 8,
                offset: const Offset(0, 2), // Consistent with summary card
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: theme.colorScheme.onPrimary, // Use onPrimary for contrast
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Add Transaction",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600, // Slightly less bold for balance
                  fontSize: 16, // Match tab text size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    TripDetailController controller,
    String title,
    int index,
  ) {
    final theme = Theme.of(context);
    final isActive = controller.selectedTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isActive
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color:
                  isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    TripDetailController controller,
  ) {
    final theme = Theme.of(context);
    final summary = controller.summary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            'Total Expenses',
            controller.formatCurrency(
              (summary['total_expenses'] ?? 0.0) as double,
            ),
          ),
          const Divider(),
          _buildSummaryRow(
            context,
            'My Expenses',
            controller.formatCurrency(
              (summary['my_expenses'] ?? 0.0) as double,
            ),
          ),
          const Divider(),
          _buildSummaryRow(
            context,
            'You are owed',
            controller.formatCurrency(
              (summary['amount_owed'] ?? 0.0) as double,
            ),
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(
    BuildContext context,
    TripDetailController controller,
    Map<String, dynamic> expense,
  ) {
    final theme = Theme.of(context);

    final String category = expense['category'] ?? 'Uncategorized';
    final String paidBy = expense['paid_by'] ?? 'Unknown';
    final double amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
    final double userShare = (expense['user_share'] as num?)?.toDouble() ?? 0.0;
    final String dateString = expense['date'] ?? '';
    final String transactionType = (expense['type'] ?? 'expense').toLowerCase();

    DateTime? date;
    try {
      date = DateTime.parse(dateString);
    } catch (_) {}

    String formattedDate = '';
    if (date != null) {
      final now = DateTime.now();
      if (controller.isSameDate(date, now)) {
        formattedDate = "Today";
      } else if (controller.isSameDate(
        date,
        now.subtract(const Duration(days: 1)),
      )) {
        formattedDate = "Yesterday";
      } else {
        formattedDate = controller.formatDate(date);
      }
    }

    Color categoryColor = theme.colorScheme.primary;
    IconData categoryIcon = Icons.category;

    switch (category.toLowerCase()) {
      case 'food':
        categoryColor = Colors.orange;
        categoryIcon = Icons.restaurant;
        break;
      case 'transport':
        categoryColor = Colors.blue;
        categoryIcon = Icons.directions_car;
        break;
      case 'shopping':
        categoryColor = Colors.purple;
        categoryIcon = Icons.shopping_bag;
        break;
      case 'hotel':
        categoryColor = Colors.green;
        categoryIcon = Icons.hotel;
        break;
      case 'entertainment':
        categoryColor = Colors.red;
        categoryIcon = Icons.movie;
        break;
      case 'salary':
      case 'freelance payment':
      case 'bonus':
        categoryColor = Colors.green;
        categoryIcon = Icons.attach_money;
        break;
      case 'bank transfer':
      case 'payback':
        categoryColor = Colors.orange;
        categoryIcon = Icons.swap_horiz;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: categoryColor.withValues(alpha: 0.2),
              child: Icon(categoryIcon, color: categoryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          category,
                          style: theme.textTheme.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getTypeColor(transactionType, theme),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          transactionType.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    transactionType == 'transfer'
                        ? 'from $paidBy'
                        : 'Paid by $paidBy ',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (formattedDate.isNotEmpty)
                    Text(
                      formattedDate,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.formatCurrency(amount),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.formatCurrency(userShare),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color getTypeColor(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'expense':
        return theme.colorScheme.error.withValues(alpha: 0.5);
      case 'income':
        return Colors.green.withValues(alpha: 0.5);
      case 'transfer':
        return Colors.orange.withValues(alpha: 0.5);
      default:
        return theme.colorScheme.primary.withValues(alpha: 0.5);
    }
  }
}
