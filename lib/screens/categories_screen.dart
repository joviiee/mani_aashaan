import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../main.dart';
import 'package:isar/isar.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../utils/string_extensions.dart';
import 'edit_category_screen.dart'; // We'll create this next

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catsAsync = ref.watch(categoriesProvider);

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
        title: Text('Categories', style: theme.appBarTheme.titleTextStyle),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 110),
          Expanded(
            child: catsAsync.when(
              data: (cats) => _buildCategoriesList(cats),
              loading: () => Center(
                child: CircularProgressIndicator(color: theme.progressIndicatorTheme.color),
              ),
              error: (e, s) => Center(
                child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.violetPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Category',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _navigateToAddCategory(context),
      ),
    );
  }

  Widget _buildCategoriesList(List<Category> cats) {
    final theme = Theme.of(context);

    if (cats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No categories available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a category using the button below',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: cats.length,
      itemBuilder: (context, i) {
        final c = cats[i];
        final isClosable = c.isClosable ?? false;

        return GestureDetector(
          onTap: () => _navigateToEditCategory(context, c.id!),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isClosable
                    ? [const Color(0xFFFFFFFF), const Color(0xFFF3E5F5)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFFFF9E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isClosable ? AppGradients.investment : AppGradients.consumption,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isClosable
                              ? AppColors.investmentStart
                              : AppColors.consumptionStart)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isClosable ? Icons.lock_clock_rounded : Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: Text(
                c.name,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isClosable
                                ? AppColors.investmentStart
                                : AppColors.consumptionStart)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isClosable ? 'Closable' : 'Consumption',
                        style: TextStyle(
                          color: isClosable
                              ? AppColors.investmentStart
                              : AppColors.consumptionStart,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(Icons.delete_rounded, color: Colors.red.shade700),
                  onPressed: () => _showDeleteConfirmation(context, c.id!),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Id id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Delete Category'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this category? This action cannot be undone.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(expenseRepoProvider);
      await repo.deleteCategory(id);
      ref.invalidate(categoriesProvider);
    }
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditCategoryScreen()),
    ).then((_) => ref.invalidate(categoriesProvider));
  }

  void _navigateToEditCategory(BuildContext context, Id categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditCategoryScreen(categoryId: categoryId)),
    ).then((_) => ref.invalidate(categoriesProvider));
  }
}
