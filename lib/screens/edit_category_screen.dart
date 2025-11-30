import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/category.dart';
import '../main.dart';
import '../viewmodels/expense_viewmodel.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  final Id? categoryId;

  const EditCategoryScreen({super.key, this.categoryId});

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  final _nameCtrl = TextEditingController();
  bool _isClosable = false;
  bool _isRecurring = false;

  // Controllers for custom parameter inputs
  final _paramNameCtrl = TextEditingController();
  String _paramType = 'string';
  bool _paramRequired = false;

  // Local temporary storage for CategoryField objects
  final List<CategoryField> _extraParams = [];

  bool _isLoading = false;

  final List<String> _availableTypes = ['string', 'number', 'date', 'boolean'];

  @override
  void initState() {
    super.initState();
    _loadCategoryIfNeeded();
  }

  Future<void> _loadCategoryIfNeeded() async {
    if (widget.categoryId == null) return;

    setState(() => _isLoading = true);
    final repo = ref.read(expenseRepoProvider);
    final cat = await repo.getCategoryById(widget.categoryId!);

    if (cat != null) {
      _nameCtrl.text = cat.name;
      _isClosable = cat.isClosable;
      _isRecurring = cat.isRecurring;
      _extraParams.clear();
      _extraParams.addAll(cat.extraParams);
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _paramNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = widget.categoryId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Category' : 'Create Category'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBasicForm(theme),
                      const SizedBox(height: 16),
                      _buildExtraParamsHeader(),
                      const SizedBox(height: 8),
                      _buildExtraParamsList(),
                      const SizedBox(height: 12),
                      _buildParamInputCard(theme),
                      const SizedBox(height: 16),
                      _buildActionButtons(theme),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBasicForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            prefixIcon: Icon(Icons.category_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
              Text(
                'Closable',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Center(
                child: Switch.adaptive(
                  value: _isClosable,
                  activeThumbColor:AppColors.violetPrimary,
                  onChanged: (v) => setState(() => _isClosable = v),
                ),
              ),
            ]),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
              Text(
                'Recurring',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Center(
                child: Switch.adaptive(
                  value: _isRecurring,
                  activeThumbColor:AppColors.violetPrimary,
                  onChanged: (v) => setState(() => _isRecurring = v),
                ),
              ),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildExtraParamsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Custom Parameters',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('${_extraParams.length}',
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildExtraParamsList() {
    if (_extraParams.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          'No custom parameters added',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 180),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _extraParams.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final p = _extraParams[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.tune_rounded, color: Colors.deepPurple),
              title: Text(p.name.isEmpty ? '(unnamed)' : p.name),
              subtitle: Text(
                  'Type: ${p.type}  •  Required: ${p.required ? "Yes" : "No"}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editParam(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: () =>
                        setState(() => _extraParams.removeAt(index)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParamInputCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppGradients.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add / Edit Parameter',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _paramNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Parameter Name',
              hintText: 'e.g., vehicle, litres, store',
              prefixIcon: Icon(Icons.edit_road_rounded),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _paramType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: _availableTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _paramType = v ?? 'string'),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Required'),
                  Switch(
                    value: _paramRequired,
                    onChanged: (v) => setState(() => _paramRequired = v),
                    activeColor: AppColors.violetPrimary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Parameter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violetPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: _addParameter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Clear'),
            onPressed: _clearForm,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save Category'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violetPrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: _saveCategory,
          ),
        ),
      ],
    );
  }

  void _addParameter() {
    final name = _paramNameCtrl.text.trim();
    if (name.isEmpty) {
      // simple validation
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter parameter name')));
      return;
    }

    setState(() {
      _extraParams.add(CategoryField(
          name: name, type: _paramType, required: _paramRequired));
      _paramNameCtrl.clear();
      _paramType = 'string';
      _paramRequired = false;
    });
  }

  void _editParam(int index) {
    final p = _extraParams[index];
    _paramNameCtrl.text = p.name;
    _paramType = p.type;
    _paramRequired = p.required;

    // remove existing param — user will re-add (simpler UI)
    setState(() => _extraParams.removeAt(index));
  }

  void _clearForm() {
    setState(() {
      _nameCtrl.clear();
      _isClosable = false;
      _isRecurring = false;
      _paramNameCtrl.clear();
      _paramType = 'string';
      _paramRequired = false;
      _extraParams.clear();
    });
  }

  Future<void> _saveCategory() async {
    final repo = ref.read(expenseRepoProvider);
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a category name')));
      return;
    }

    final category = Category.create(
      name: name,
      colorHex: null,
      icon: null,
      isClosable: _isClosable,
      isRecurring: _isRecurring,
      extraParams: List<CategoryField>.from(_extraParams),
    );

    if (widget.categoryId != null) {
      // set id so update works (repo.updateCategory should handle put)
      category.id = widget.categoryId;
      await repo.updateCategory(category);
    } else {
      await repo.createCategory(category);
    }

    if (mounted) Navigator.pop(context, true);
  }
}
