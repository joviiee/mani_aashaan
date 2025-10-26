import 'package:isar/isar.dart';
import 'category.dart';

part 'expense.g.dart';

@Collection()
class Expense {
  Id id = Isar.autoIncrement;

  late double amount;
  late String title;

  /// link to Category object
  final category = IsarLink<Category>();

  late DateTime timestamp;
  String? notes;

  Expense();

  Expense.create({
    required this.amount,
    required this.title,
    required Category category,
    DateTime? timestamp,
    this.notes,
  }) : timestamp = timestamp ?? DateTime.now() {
    this.category.value = category;
  }
}
