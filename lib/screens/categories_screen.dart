import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/category.dart';
import '../utils/string_extensions.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _nameCtrl = TextEditingController();
  ExpenseType _type = ExpenseType.consumption;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        elevation: 2,
        backgroundColor: Colors.teal[600],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // First row: Name TextField
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                // Second row: Dropdown + Add button
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<ExpenseType>(
                          value: _type,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                                value: ExpenseType.consumption,
                                child: Text('Consumption')),
                            DropdownMenuItem(
                                value: ExpenseType.investment,
                                child: Text('Investment')),
                          ],
                          onChanged: (v) => setState(
                              () => _type = v ?? ExpenseType.consumption),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _create,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Categories List
          Expanded(
            child: catsAsync.when(
              data: (cats) {
                if (cats.isEmpty) {
                  return const Center(child: Text('No categories available'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cats.length,
                  itemBuilder: (context, i) {
                    final c = cats[i];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(
                          c.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          c.type.name.capitalize(),
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(c.id!),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final repo = ref.read(expenseRepoProvider);
    final cat = Category.create(name: name, type: _type);

    await repo.createCategory(cat);

    _nameCtrl.clear();
    ref.invalidate(categoriesProvider);
  }

  Future<void> _delete(Id id) async {
    final repo = ref.read(expenseRepoProvider);
    await repo.deleteCategory(id);
    ref.invalidate(categoriesProvider);
  }
}
