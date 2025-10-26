import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/expense.dart';
import '../models/category.dart';
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
    final categoriesAsync = ref.watch(categoriesProvider);
    final expensesAsync = ref.watch(expensesProvider(_filterParams));

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Expenses',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        elevation: 2,
        backgroundColor: Colors.teal[600],
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 22.0),
            child: IconButton(
              icon: const Icon(
                Icons.category,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              ).then((_) {
                // Refresh categories and expenses after returning
                ref.invalidate(categoriesProvider);
                ref.invalidate(expensesProvider(_filterParams));
              }),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(context, categoriesAsync),
          const Divider(),
          Expanded(
            child: expensesAsync.when(
              data: (list) => _buildList(list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        ).then((shouldRefresh) {
          if (shouldRefresh == true) {
            _updateFilterParams();
            print("refreshed items ...................................");
          }
        }),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection(
      BuildContext context, AsyncValue<List<Category>> categoriesAsync) {
    final dateFmt = DateFormat('MMM d, yyyy');
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter by:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: _pickRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                    child: Center(
                      child: Text(
                        '${dateFmt.format(_start!)} → ${dateFmt.format(_end!)}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: categoriesAsync.when(
                  data: (cats) {
                    // Prepend a null option for "All"
                    final allOptions = [null, ...cats];
                    return DropdownButtonFormField<Category>(
                      initialValue: _selectedCategory,
                      hint: const Text(
                        'All categories',
                        style: TextStyle(fontSize: 10),
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      items: allOptions
                          .map((cat) => DropdownMenuItem<Category>(
                                value: cat,
                                child: Text(cat?.name ?? 'All'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedCategory = val);
                        _updateFilterParams();
                        ref.invalidate(expensesProvider(_filterParams));
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => const Text('Error loading categories'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Expense> list){
    if (list.isEmpty) {
      return const Center(child: Text('No expenses recorded.'));
    }

    return Expanded(
  child: ListView.builder(
    itemCount: list.length,
    itemBuilder: (context, i) {
      final e = list[i];
      final dt = DateFormat.yMMMd().add_jm().format(e.timestamp);

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 1.5,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // spacing between cards
        child: ListTile(
          leading: Icon(
            Icons.money
          ),
          title: Text(
            e.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(dt),
          trailing: Text(
            '₹ ${e.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
      );
    },
  ),
)
;
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
