import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../main.dart';
import 'add_expense_screen.dart';
import 'categories_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _dateScrollController = ScrollController();

  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;

  late FilterParams _filterParams;

  @override
  void initState() {
    super.initState();
    _filterParams = _getFilterParams();

    // Scroll to the latest date (rightmost)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dateScrollController.hasClients) {
        _dateScrollController.jumpTo(
          _dateScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  FilterParams _getFilterParams() {
    final start =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final end = start.add(const Duration(days: 1));
    return FilterParams(
      start: start,
      end: end,
      categoryId: _selectedCategory?.id,
    );
  }

  void _updateFilter() {
    setState(() {
      _filterParams = _getFilterParams();
    });
    ref.invalidate(expensesProvider(_filterParams));
  }

  List<DateTime> getLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) => now.subtract(Duration(days: i)))
        .reversed
        .toList();
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
                _updateFilter();
              }),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
          _buildDateSelector(context),
          const SizedBox(height: 4),
          _buildFilterRow(context),
          const SizedBox(height: 4),
          Expanded(
            child: expensesAsync.when(
              data: (list) => _buildList(list),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: theme.progressIndicatorTheme.color,
                ),
              ),
              error: (e, s) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.red)),
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
              if (shouldRefresh == true) _updateFilter();
            }),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: "addExpense",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            ).then((shouldRefresh) {
              if (shouldRefresh == true) _updateFilter();
            }),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        ],
      ),
    );
  }

  // 🟣 Horizontal Date Selector (Daily View)
  Widget _buildDateSelector(BuildContext context) {
    final days = getLast7Days();
    final theme = Theme.of(context);

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _dateScrollController, // ✅ attach controller
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final dayName = DateFormat('E').format(date);
          final dayNum = DateFormat('d').format(date);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              _updateFilter();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                gradient: isSelected ? AppGradients.primary : null,
                color: isSelected ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🟣 Category Filter Dropdown
  // 🟣 Compact Filter Row (Category + Total)
  Widget _buildFilterRow(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final expensesAsync = ref.watch(expensesProvider(_filterParams));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🟢 Total Spend Text
          expensesAsync.when(
            data: (list) {
              final total = list.fold<double>(0, (sum, e) => sum + e.amount);
              return Text(
                'Total: ₹${total.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.violetPrimary,
                ),
              );
            },
            loading: () =>
                const Text('Total: ₹...', style: TextStyle(fontSize: 14)),
            error: (_, __) =>
                const Text('Error', style: TextStyle(color: Colors.red)),
          ),

          // 🟣 Category Dropdown - minimal style
          categoriesAsync.when(
            data: (cats) {
              final allOptions = [null, ...cats];
              return DropdownButtonHideUnderline(
                child: DropdownButton<Category>(
                  value: _selectedCategory,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey, size: 20),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade800,
                    fontSize: 13,
                  ),
                  items: allOptions
                      .map((cat) => DropdownMenuItem<Category>(
                            value: cat,
                            child: Text(
                              cat?.name ?? 'All',
                              style: TextStyle(
                                fontSize: 13,
                                color: cat == _selectedCategory
                                    ? AppColors.violetPrimary
                                    : Colors.grey.shade700,
                                fontWeight: cat == _selectedCategory
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedCategory = val);
                    _updateFilter();
                  },
                ),
              );
            },
            loading: () => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const SizedBox(),
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
            Icon(Icons.receipt_long_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No expenses for this day',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final e = list[i];
        final dt = DateFormat.jm().format(e.timestamp);
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
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 24),
            ),
            title: Text(
              e.title,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(dt,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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
                    color: theme.colorScheme.primary),
              ),
            ),
          ),
        );
      },
    );
  }
}
