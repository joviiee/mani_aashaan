import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../utils/time_utils.dart';
import '../models/expense.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/category.dart';
import '../main.dart';

// ---------------- Scoped Provider ----------------
final filterParamsProvider = StateProvider<FilterParams>((ref) {
  final now = DateTime.now();
  return FilterParams(start: now, end: now);
});

// ---------------- Screen Entry -------------------
class AnalyticsDetailScreen extends StatelessWidget {
  final String period;
  const AnalyticsDetailScreen({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        filterParamsProvider.overrideWith((ref) {
          final now = DateTime.now();
          late DateTime start, end;

          if (period == 'daily') {
            start = DateTime(now.year, now.month, now.day);
            end = start.add(const Duration(days: 1));     // exclusive
          } else if (period == 'weekly') {
            final today = DateTime(now.year, now.month, now.day);
            start = today.subtract(Duration(days: now.weekday - 1));
            end = start.add(const Duration(days: 7));      // exclusive
          } else {
            start = DateTime(now.year, now.month, 1);
            end = DateTime(now.year, now.month + 1, 1);    // NEXT month start
          }

          return FilterParams(start: start, end: end);
        }),
      ],
      child: _AnalyticsDetailBody(period: period),
    );
  }
}

// ---------------- Stateful Logic -------------------
class _AnalyticsDetailBody extends ConsumerStatefulWidget {
  final String period;
  const _AnalyticsDetailBody({required this.period});

  @override
  ConsumerState<_AnalyticsDetailBody> createState() =>
      _AnalyticsDetailBodyState();
}

class _AnalyticsDetailBodyState extends ConsumerState<_AnalyticsDetailBody> {
  Category? selectedCategory;
  DateTime selectedDate = DateTime.now();

  // Central filter update method
  void _updateFilter({DateTime? date, Category? category}) {
    if (date != null) selectedDate = date;
    if (category != null) selectedCategory = category;

    late DateTime start, end;

    if (widget.period == 'daily') {
      start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      end = start.add(const Duration(days: 1));  // exclusive
    }

    else if (widget.period == 'weekly') {
      final normalized = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      start = normalized.subtract(Duration(days: normalized.weekday - 1));
      end = start.add(const Duration(days: 7));  // exclusive
    }

    else {
      start = DateTime(selectedDate.year, selectedDate.month, 1);
      end = DateTime(selectedDate.year, selectedDate.month + 1, 1);  // exclusive
    }

    ref.read(filterParamsProvider.notifier).state = FilterParams(
      start: start,
      end: end,
      categoryId: selectedCategory?.id,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(filterParamsProvider);
    final expensesAsync = ref.watch(expensesProvider(params));
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
        ),
        title: Text(
          '${widget.period[0].toUpperCase()}${widget.period.substring(1)} Analysis',
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Column(
        children: [
          _buildFilters(categoriesAsync),
          Expanded(
            child: expensesAsync.when(
              data: (expenses) =>
                  _buildBody(context, expenses, params),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Filters UI -------------------
  Widget _buildFilters(AsyncValue<List<Category>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            gradient: AppGradients.cardBackground,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Category>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("All")),
                    ...categories.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (c) => _updateFilter(category: c),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text("Pick"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violetPrimary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) _updateFilter(date: picked);
                },
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  }

  // ---------------- Content -------------------
  Widget _buildBody(
      BuildContext context, List<Expense> expenses, FilterParams params) {
    final theme = Theme.of(context);
    final total = expenses.fold<double>(0, (s, e) => s + e.amount);

    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              formatDateRange(params, widget.period),
              style: theme.textTheme.titleMedium,
            ),
            Text(
              'Total: ₹${total.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(child: _buildList(expenses)),
      ],
    );
  }

  Widget _buildList(List<Expense> expenses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (_, i) {
        final e = expenses[i];
        final date = DateFormat.yMMMd().format(e.timestamp);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: AppGradients.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(e.title, style: const TextStyle(color: AppColors.violetPrimary)),
            subtitle:
                Text('${e.category.value?.name ?? "No category"} • $date'),
            trailing: Text(
              '₹${e.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.violetPrimary),
            ),
          ),
        );
      },
    );
  }
}
