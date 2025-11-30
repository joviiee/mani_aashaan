import 'package:isar/isar.dart';

part 'category.g.dart';

@Collection()
class Category {
  Id? id = Isar.autoIncrement;

  late String name;
  int? colorHex;
  String? icon;

  /// Determines whether expenses in this category can be "closed"
  late bool isClosable;

  /// Whether expenses in this category are recurring (e.g., rent, subscription)
  late bool isRecurring;

  /// Dynamic extra parameters to customize expense fields
  /// Example:
  /// [
  ///   {"name": "vehicle", "type": "string"},
  ///   {"name": "litres", "type": "number"}
  /// ]
  late List<CategoryField> extraParams;

  Category({
    required this.name,
    this.colorHex,
    this.icon,
    this.isClosable = false,
    this.isRecurring = false,
    this.extraParams = const [],
  });

  Category.create({
    required this.name,
    this.colorHex,
    this.icon,
    this.isClosable = false,
    this.isRecurring = false,
    this.extraParams = const [],
  });

  @ignore
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @ignore
  @override
  int get hashCode => id.hashCode;
}

/// Represents one custom field for expenses under this category.
@embedded
class CategoryField {
  String name = '';
  String type = ''; // e.g. "string", "number", "boolean", "date"
  bool required = false;

  CategoryField({
    this.name = '',
    this.type = '',
    this.required = false,
  });
}
