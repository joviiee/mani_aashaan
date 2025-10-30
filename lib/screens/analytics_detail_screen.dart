import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../viewmodels/expense_viewmodel.dart';

class AnalyticsDetailScreen extends ConsumerStatefulWidget {
  final String period;
  const AnalyticsDetailScreen({super.key, required this.period});

  @override
  ConsumerState<AnalyticsDetailScreen> createState() => _AnalyticsDetailScreenState();
}

class _AnalyticsDetailScreenState extends ConsumerState<AnalyticsDetailScreen> {
  late final FilterParams params;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    DateTime start;

    if (widget.period == 'daily') {
      start = DateTime(now.year, now.month, now.day);
    } else if (widget.period == 'weekly') {
      start = now.subtract(Duration(days: now.weekday - 1));
    } else {
      start = DateTime(now.year, now.month, 1);
    }

    // ✅ Compute once — stable value
    params = FilterParams(start: start, end: now);
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.period[0].toUpperCase()}${widget.period.substring(1)} Expenses'),
      ),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(
              child: Text('No expenses found for this period.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final e = expenses[index];
              final formattedDate = DateFormat.yMMMd().format(e.timestamp);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(e.title),
                  subtitle: Text(
                    '${e.category.value?.name ?? 'No category'} • $formattedDate',
                  ),
                  trailing: Text(
                    '₹${e.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
