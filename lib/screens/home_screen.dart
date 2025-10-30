import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mani_aashaan/screens/analytics_screen.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../main.dart';
import 'add_expense_screen.dart';
import 'categories_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime? _start;
  DateTime? _end;
  Category? _selectedCategory;

  late FilterParams _filterParams;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, now.day);
    _end = now;

    _filterParams = FilterParams(
      start: _start!,
      end: _end!,
      categoryId: _selectedCategory?.id,
    );
  }

  void _updateFilterParams({String source = "creation"}) {
    setState(() {
      if (source == "creation") {
        final now = DateTime.now();
        _end = now;
      }
      _filterParams = FilterParams(
        start: _start!,
        end: _end!,
        categoryId: _selectedCategory?.id,
      );
    });
    ref.invalidate(categoriesProvider);
    ref.invalidate(expensesProvider(_filterParams));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final expensesAsync = ref.watch(expensesProvider(_filterParams));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        title: Text('My Expenses', style: theme.appBarTheme.titleTextStyle),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.category_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              ).then((_) {
                ref.invalidate(categoriesProvider);
                ref.invalidate(expensesProvider(_filterParams));
              }),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 110),
          _buildFilterSection(context, categoriesAsync),
          const SizedBox(height: 8),
          Expanded(
            child: expensesAsync.when(
              data: (list) => _buildList(list),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: theme.progressIndicatorTheme.color,
                ),
              ),
              error: (e, s) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "analytics",
            backgroundColor: AppColors.violetPrimary.withValues(alpha: .9),
            icon: const Icon(Icons.analytics_rounded),
            label: const Text('Analytics'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
            ).then((shouldRefresh) {
              if (shouldRefresh == true) {
                _updateFilterParams();
              }
            }),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: "addExpense",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            ).then((shouldRefresh) {
              if (shouldRefresh == true) {
                _updateFilterParams();
              }
            }),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
      BuildContext context, AsyncValue<List<Category>> categoriesAsync) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('MMM d, yyyy');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.violetPrimary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: theme.iconTheme.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Filter Expenses', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickRange,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.violetPrimary.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.violetPrimary.withValues(alpha: .3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: theme.iconTheme.color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${dateFmt.format(_start!)} → ${dateFmt.format(_end!)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.iconTheme.color,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: theme.iconTheme.color,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            data: (cats) {
              final allOptions = [null, ...cats];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  hint: Row(
                    children: [
                      Icon(Icons.category_outlined,
                          size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        'All categories',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: allOptions
                      .map((cat) => DropdownMenuItem<Category>(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(
                                  cat == null
                                      ? Icons.apps_rounded
                                      : Icons.label_rounded,
                                  size: 18,
                                  color: theme.iconTheme.color,
                                ),
                                const SizedBox(width: 8),
                                Text(cat?.name ?? 'All'),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedCategory = val);
                    _updateFilterParams();
                    ref.invalidate(expensesProvider(_filterParams));
                  },
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, s) => const Text(
              'Error loading categories',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Expense> list) {
    final theme = Theme.of(context);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses recorded',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first expense',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final e = list[i];
        final dt = DateFormat.yMMMd().add_jm().format(e.timestamp);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppGradients.accent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yellowAccent.withValues(alpha: .3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              e.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    dt,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.violetPrimary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '₹${e.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _start!, end: _end!),
    );

    if (range != null) {
      final now = DateTime.now();

      _start = DateTime(range.start.year, range.start.month, range.start.day);

      _end = (range.end.year == now.year &&
              range.end.month == now.month &&
              range.end.day == now.day)
          ? now
          : DateTime(
              range.end.year, range.end.month, range.end.day, 23, 59, 59, 999);

      _updateFilterParams(source: "filter");
    }
  }
}
