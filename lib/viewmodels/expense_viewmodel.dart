import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../repository/expense_repository.dart';
import '../models/expense.dart';
import '../models/category.dart';

final expenseRepoProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(expenseRepoProvider);
  return repo.getAllCategories();
});

final expensesProvider =
    FutureProvider.family<List<Expense>, FilterParams>((ref, params) async {
  final repo = ref.read(expenseRepoProvider);
  return repo.getExpenses(
    start: params.start,
    end: params.end,
    category: params.categoryId,
  );
});

final todayTotalProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(expenseRepoProvider);
  return repo.getTodayTotal();
});

final weekTotalProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(expenseRepoProvider);
  return repo.getWeekTotal();
});

final monthTotalProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(expenseRepoProvider);
  return repo.getMonthTotal();
});


class FilterParams extends Equatable {
  final DateTime start;
  final DateTime end;
  final int? categoryId; // store only the ID

  const FilterParams({
    required this.start,
    required this.end,
    this.categoryId,
  });

  @override
  List<Object?> get props => [start, end, categoryId];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterParams &&
          start == other.start &&
          end == other.end &&
          categoryId == other.categoryId;

  @override
  int get hashCode => Object.hash(start, end, categoryId);
}

