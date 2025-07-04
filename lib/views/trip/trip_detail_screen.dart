import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/data/constants.dart';

import '../../controller/trip/trip_detail_controller.dart';

class TripPage extends StatelessWidget {
  const TripPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TripDetailController controller = Get.put(TripDetailController());

    return Obx(() {
      if (controller.isLoading.value) {
        controller.fetchTripData(); // Fetch once
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final theme = Theme.of(context);
      final trip = controller.trip;
      final summary = controller.summary;
      final todayExpenses = controller.todayTransactions;

      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(trip['emoji'], style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                trip['name'],
                style: theme.textTheme.headlineSmall?.copyWith(
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
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTab(context, controller, 'Expenses', 0, 0),
                    _buildTab(
                      context,
                      controller,
                      'Balances',
                      1,
                      controller.tabs['balances_notification'],
                    ),
                    _buildTab(
                      context,
                      controller,
                      'Photos',
                      2,
                      controller.tabs['photos_notification'],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Obx(() {
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
                  if (todayExpenses.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Today', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...todayExpenses.map(
                      (expense) =>
                          _buildExpenseCard(context, controller, expense),
                    ),
                  ],
                ],
              );
          }
        }),
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          onPressed: () {
            final tab = controller.selectedTabIndex.value;
            if (tab == 0) {
              Get.toNamed(
                PageConstant.AddTransactionScreen,
                arguments: {'type': 'Expense'},
              );
            } else if (tab == 1) {
              Get.snackbar("Balances", "Balances screen coming soon");
            } else {
              Get.snackbar("Photos", "Photos screen coming soon");
            }
          },
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Icon(Icons.add, color: Colors.white)),
          ),
        ),
      );
    });
  }

  Widget _buildTab(
    BuildContext context,
    TripDetailController controller,
    String title,
    int index,
    int? badgeCount,
  ) {
    final theme = Theme.of(context);
    final isActive = controller.selectedTabIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                    isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
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
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
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

  Widget _buildSummaryCard(
    BuildContext context,
    TripDetailController controller,
  ) {
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
          _buildSummaryRow(
            context,
            'Total Expenses',
            controller.formatCurrency(controller.summary['total_expenses']),
          ),
          const Divider(),
          _buildSummaryRow(
            context,
            'My Expenses',
            controller.formatCurrency(controller.summary['my_expenses']),
          ),
          const Divider(),
          _buildSummaryRow(
            context,
            'You are owed',
            controller.formatCurrency(controller.summary['amount_owed']),
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

  Widget _buildExpenseCard(
    BuildContext context,
    TripDetailController controller,
    Map<String, dynamic> expense,
  ) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.orange,
              child: Icon(Icons.local_drink, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense['category'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "paid by ${expense['paid_by']}",
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
                  controller.formatCurrency(expense['amount']),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.formatCurrency(expense['user_share']),
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
