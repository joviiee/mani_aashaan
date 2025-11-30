import 'package:isar/isar.dart';
import 'category.dart';

part 'expense.g.dart';

@Collection()
class Expense {
  Id id = Isar.autoIncrement;

  late double amount;
  late String title;

  /// Link to Category
  final category = IsarLink<Category>();

  late DateTime timestamp;
  String? notes;

  /// Stores extra data for dynamic category fields
  /// Each field corresponds to one of category.extraParams
  late List<ExpenseExtraValue> extraValues;

  Expense();

  Expense.create({
    required this.amount,
    required this.title,
    required Category category,
    DateTime? timestamp,
    this.notes,
    this.extraValues = const [],
  }) : timestamp = timestamp ?? DateTime.now() {
    this.category.value = category;
  }
}

/// Represents one extra field value stored in an Expense
@embedded
class ExpenseExtraValue {
  String fieldName = '';
  String type = '';  // "string", "number", "date", etc.
  String? value;

  ExpenseExtraValue({
    this.fieldName = '',
    this.type = '',
    this.value,
  });
}
