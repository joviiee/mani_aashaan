import 'package:isar/isar.dart';

part 'category.g.dart';

enum ExpenseType { consumption, investment }

@Collection()
class Category {
  Id? id = Isar.autoIncrement;

  late String name;
  int? colorHex;
  String? icon;

  @enumerated
  late ExpenseType type;

  Category({
    required this.name,
    required this.type,
    this.colorHex,
    this.icon,
  });

  Category.create({
    required this.name,
    required this.type,
    this.colorHex,
    this.icon,
  });

  // Equality check without extending Equatable
  @ignore
  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @ignore
  @override
  int get hashCode => id.hashCode;
}