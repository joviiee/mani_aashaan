import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../main.dart';
import 'edit_category_screen.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Category? _selectedCategory;

  final Map<String, TextEditingController> _customFieldControllers = {};
  final Map<String, bool> _customFieldBoolValues = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    for (final c in _customFieldControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        title: Text('Add Expense', style: theme.appBarTheme.titleTextStyle),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 70),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppGradients.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Expense Details',
                                  style: theme.textTheme.titleLarge),
                              const SizedBox(height: 24),

                              /// 🟪 CATEGORY DROPDOWN
                              categoriesAsync.when(
                                data: (cats) {
                                  if (cats.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.orange.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded,
                                              color: Colors.orange.shade700),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'No categories. Create one first.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          TextButton(
                                             onPressed: () => _navigateToAddCategory(context),
                                            child: const Text('Go'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  if (_selectedCategory != null) {
                                    final existing = cats.firstWhere(
                                      (c) => c.id == _selectedCategory!.id,
                                      orElse: () => cats.first,
                                    );
                                    _selectedCategory = existing;
                                  }

                                  return DropdownButtonFormField<Category>(
                                    value: _selectedCategory,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                      prefixIcon:
                                          Icon(Icons.category_rounded),
                                    ),
                                    items: cats
                                        .map((c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(c.name),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedCategory = val;
                                          _setupCustomFields(val);
                                        });
                                      }
                                    },
                                    validator: (val) => val == null
                                        ? 'Select category'
                                        : null,
                                  );
                                },
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (e, s) => Text(
                                  'Error: $e',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              const SizedBox(height: 16),

                              /// TITLE
                              TextFormField(
                                controller: _titleCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  hintText: 'e.g., Groceries, Fuel, etc.',
                                  prefixIcon: Icon(Icons.title_rounded),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Enter title'
                                        : null,
                              ),
                              const SizedBox(height: 16),

                              /// AMOUNT
                              TextFormField(
                                controller: _amountCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  hintText: '0.00',
                                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Enter amount';
                                  final val = double.tryParse(v);
                                  if (val == null || val <= 0) return 'Enter valid amount';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              /// NOTES
                              TextFormField(
                                controller: _notesCtrl,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Notes (optional)',
                                  hintText: 'Add additional details...',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(bottom: 40),
                                    child: Icon(Icons.notes_rounded),
                                  ),
                                ),
                              ),

                              /// 🔹 DYNAMIC CUSTOM FIELDS
                              if (_selectedCategory?.extraParams.isNotEmpty == true)
                                ..._selectedCategory!.extraParams.map((field) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _buildCustomField(field),
                                  );
                                }),

                              const SizedBox(height: 32),

                              /// SAVE BUTTON
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppGradients.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.violetPrimary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save_rounded, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save Expense',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🔧 Initialize controllers for selected category’s custom fields
  void _setupCustomFields(Category category) {
    _customFieldControllers.clear();
    _customFieldBoolValues.clear();

    for (final f in category.extraParams) {
      switch (f.type.toLowerCase()) {
        case 'boolean':
          _customFieldBoolValues[f.name] = false;
          break;
        default:
          _customFieldControllers[f.name] = TextEditingController();
      }
    }
  }

  /// 🧩 Build dynamic widgets for each field type
  Widget _buildCustomField(CategoryField field) {
    switch (field.type.toLowerCase()) {
      case 'number':
        final ctrl = _customFieldControllers[field.name]!;
        return TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: field.name,
            prefixIcon: const Icon(Icons.numbers_rounded),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Enter ${field.name}' : null,
        );

      case 'boolean':
        final value = _customFieldBoolValues[field.name] ?? false;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(field.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Center(
              child: Switch.adaptive(

                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: value,
                onChanged: (val) {
                  setState(() => _customFieldBoolValues[field.name] = val);
                },
              ),
            ),
          ],
        );

      case 'date':
        final ctrl = _customFieldControllers[field.name]!;
        return TextFormField(
          controller: ctrl,
          readOnly: true,
          decoration: InputDecoration(
            labelText: field.name,
            prefixIcon: const Icon(Icons.calendar_today_rounded),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              ctrl.text = '${picked.year}-${picked.month}-${picked.day}';
            }
          },
        );

      case 'string':
      default:
        final ctrl = _customFieldControllers[field.name]!;
        return TextFormField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: field.name,
            prefixIcon: const Icon(Icons.text_fields_rounded),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Enter ${field.name}' : null,
        );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select category')),
      );
      return;
    }

    final repo = ref.read(expenseRepoProvider);

    /// Collect dynamic custom field values
    final extraValues = <ExpenseExtraValue>[];
    for (final field in _selectedCategory!.extraParams) {
      switch (field.type.toLowerCase()) {
        case 'boolean':
          extraValues.add(ExpenseExtraValue(
            fieldName: field.name,
            type: field.type,
            value: _customFieldBoolValues[field.name].toString(),
          ));
          break;
        default:
          extraValues.add(ExpenseExtraValue(
            fieldName: field.name,
            type: field.type,
            value: _customFieldControllers[field.name]?.text.trim() ?? '',
          ));
      }
    }

    final expense = Expense.create(
      amount: double.parse(_amountCtrl.text.trim()),
      title: _titleCtrl.text.trim(),
      category: _selectedCategory!,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      extraValues: extraValues,
    );

    await repo.createExpense(expense);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditCategoryScreen()),
    ).then((_) => ref.invalidate(categoriesProvider));
  }
}
