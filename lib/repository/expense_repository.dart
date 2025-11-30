import 'package:isar/isar.dart';
import '../data/isar_service.dart';
import '../models/expense.dart';
import '../models/category.dart';

class ExpenseRepository {
  Future<Isar> _db() => IsarService.open();

  // ─────────────── CATEGORY CRUD ───────────────
  Future<int> createCategory(Category c) async {
    final isar = await _db();
    return await isar.writeTxn<int>(() async {
      return await isar.categorys.put(c);
    });
  }

  Future<List<Category>> getAllCategories() async {
    final isar = await _db();
    return await isar.categorys.where().findAll();
  }

  /// ✅ Get Category by ID
  Future<Category?> getCategoryById(Id id) async {
    final isar = await _db();
    return await isar.categorys.get(id);
  }

  Future<void> deleteCategory(Id id) async {
    final isar = await _db();
    await isar.writeTxn(() async {
      await isar.categorys.delete(id);
    });
  }

  /// ✅ Update existing Category
  Future<void> updateCategory(Category updatedCategory) async {
    final isar = await _db();
    await isar.writeTxn(() async {
      // Fetch the existing category
      final existing = await isar.categorys.get(updatedCategory.id ?? -1);
      if (existing == null) {
        throw Exception('Category with ID ${updatedCategory.id} not found');
      }

      // Update fields (only overwrite if provided)
      existing.name = updatedCategory.name;
      existing.colorHex = updatedCategory.colorHex;
      existing.icon = updatedCategory.icon;
      existing.isClosable = updatedCategory.isClosable;
      existing.isRecurring = updatedCategory.isRecurring;
      existing.extraParams = updatedCategory.extraParams;

      // Save changes
      await isar.categorys.put(existing);
    });
  }

  // ─────────────── EXPENSE CRUD ───────────────
  Future<int> createExpense(Expense e) async {
    final isar = await _db();
    return await isar.writeTxn<int>(() async {
      await isar.expenses.put(e);
      await e.category.save(); // save link
      return e.id;
    });
  }

  Future<List<Expense>> getExpenses({
    DateTime? start,
    DateTime? end,
    int? category,
  }) async {
    final isar = await _db();

    final now = DateTime.now();
    start ??= DateTime(now.year, now.month, now.day);
    end ??= now;

    final q = isar.expenses
        .filter()
        .timestampBetween(start, end)
        .optional(category != null, (q) => q.category((c) => c.idEqualTo(category!)));

    final result = await q.findAll();
    print('Fetched ${result.length} expenses between $start and $end (category: $category)');
    return result;
  }

  Future<void> deleteExpense(int id) async {
    final isar = await _db();
    await isar.writeTxn(() async {
      await isar.expenses.delete(id);
    });
  }

  Future<double> getTotalSpentBetween(DateTime start, DateTime end) async {
    final isar = await _db();
    final expenses =
        await isar.expenses.filter().timestampBetween(start, end).findAll();
    await Future.wait(expenses.map((e) => e.category.load()));
    return expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  Future<double> getTodayTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return await getTotalSpentBetween(start, end);
  }

  Future<double> getWeekTotal() async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final end = start.add(const Duration(days: 7));
    return await getTotalSpentBetween(start, end);
  }

  Future<double> getMonthTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    print('Calculating month total from $start to $end');
    return await getTotalSpentBetween(start, end);
  }
}

extension<T> on FilterQuery<T> {
  FilterQuery<T> optional(
      bool condition, FilterQuery<T> Function(FilterQuery<T>) apply) {
    return condition ? apply(this) : this;
  }
}
