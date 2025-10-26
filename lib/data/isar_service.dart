// lib/data/isar_service.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> open() async {
    if (Isar.instanceNames.isNotEmpty) {
      // Return the already open instance
      return Isar.getInstance()!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ExpenseSchema, CategorySchema],
      directory: dir.path,
      inspector: true,
    );

    return _isar!;
  }

  static Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close(deleteFromDisk: false);
      _isar = null;
    }
  }
}
