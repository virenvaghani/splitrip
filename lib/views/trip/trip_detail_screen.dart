import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // For currency formatting

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  // Mock API call (replace with actual API call)
  Future<Map<String, dynamic>> fetchTripData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock API response
    const mockResponse = '''
    {
      "trip": {
        "name": "Goa Trip",
        "emoji": "✌️",
        "currency": "INR"
      },
      "summary": {
        "total_expenses": 5000.00,
        "my_expenses": 2500.00,
        "amount_owed": 2500.00
      },
      "expenses": [
        {
          "id": "1",
          "category": "Drinks",
          "icon": "local_drink",
          "amount": 5000.00,
          "paid_by": "Viren (me)",
          "user_share": 2500.00,
          "date": "2025-06-04"
        }
      ],
      "tabs": {
        "balances_notification": 1,
        "photos_notification": 1
      }
    }
    ''';

    return jsonDecode(mockResponse);
  }

  // Format currency based on API currency code
  String formatCurrency(double amount, String currency) {
    final format = NumberFormat.currency(
      locale: 'en_IN', // Adjust locale based on currency if needed
      symbol: currency == 'INR' ? '₹' : '\$',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  // Map API icon string to Flutter Icons
  IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'local_drink':
        return Icons.local_drink;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchTripData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error loading trip data',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final trip = data['trip'];
        final summary = data['summary'];
        final expenses = (data['expenses'] as List<dynamic>).cast<Map<String, dynamic>>();
        final tabs = data['tabs'];

        // Group expenses by date
        final today = DateTime.now();
        final todayString = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        final todayExpenses = expenses.where((expense) => expense['date'] == todayString).toList();

        return Scaffold(
          appBar: AppBar(
            title: Stack(
              children: [

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trip['emoji'],
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trip['name'],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.3),
                        ],
                      ),
                    ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTab(context, 'Expenses', true),
                    _buildTab(context, 'Balances', false),
                    _buildTab(context, 'Photos', false),
                  ],
                ),
              ),
            ),
          ),
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Section
                      Container(
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
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.onSurface.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              context,
                              'Total Expenses',
                              formatCurrency(summary['total_expenses'], trip['currency']),
                            ),
                            const Divider(),
                            _buildSummaryRow(
                              context,
                              'My Expenses',
                              formatCurrency(summary['my_expenses'], trip['currency']),
                            ),
                            const Divider(),
                            _buildSummaryRow(
                              context,
                              'You are owed',
                              formatCurrency(summary['amount_owed'], trip['currency']),
                              isHighlighted: true,
                            ),
                          ],
                        ),
                      ),
                      if (todayExpenses.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Today',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
              if (todayExpenses.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final expense = todayExpenses[index];
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            color: theme.colorScheme.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.orange,
                                    child: Icon(
                                      getIconFromString(expense['icon']),
                                      color: Colors.white,
                                      size: 24,
                                    ),
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
                                          'paid by ${expense['paid_by']}',
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
                                        formatCurrency(expense['amount'], trip['currency']),
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        formatCurrency(expense['user_share'], trip['currency']),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: todayExpenses.length,
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)
            ),
            onPressed: () {
              // Add expense functionality
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
              child: const Center(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(BuildContext context, String title, bool isActive, [int badgeCount = 0]) {
    final theme = Theme.of(context);
    return Stack(
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
        if (badgeCount > 0)
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget   _buildSummaryRow(BuildContext context, String label, String value, {bool isHighlighted = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}