import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants.dart';
import '../models/product.dart';
import '../cubit/fridge_cubit.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({
    super.key,
    required this.productId,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _notesController;
  late String _selectedCategory;
  late String _selectedUnit;
  late DateTime? _selectedExpiryDate;
  Product? _product;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _caloriesController = TextEditingController();
    _notesController = TextEditingController();
    _selectedCategory = AppConstants.categories.first;
    _selectedUnit = AppConstants.units.first;
    _selectedExpiryDate = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProduct();
  }

  void _loadProduct() {
    final products = context.read<FridgeCubit>().state.products;
    final product = products.firstWhere(
          (p) => p.id == widget.productId,
      orElse: () => null as Product, // Изменено здесь
    );

    if (product != null) {
      setState(() {
        _product = product;
        _nameController.text = product.name;
        _quantityController.text = product.quantity.toString();
        _caloriesController.text = product.calories.toString();
        _selectedCategory = product.category;
        _selectedUnit = product.unit;
        _selectedExpiryDate = product.expiryDate;
        _notesController.text = product.notes ?? '';
      });
    }
  }

  void _saveChanges() {
    if (_product == null) return;

    final name = _nameController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final calories = double.tryParse(_caloriesController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();

    if (name.isEmpty || quantity <= 0) {
      _showErrorDialog('Пожалуйста, заполните все обязательные поля');
      return;
    }

    final updatedProduct = _product!.copyWith(
      name: name,
      category: _selectedCategory,
      quantity: quantity,
      unit: _selectedUnit,
      calories: calories,
      expiryDate: _selectedExpiryDate,
      notes: notes.isNotEmpty ? notes : null,
    );

    context.read<FridgeCubit>().updateProduct(updatedProduct);
    context.go('/fridge');
  }

  void _deleteProduct() {
    if (_product == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить продукт'),
        content: Text('Вы уверены, что хотите удалить ${_product!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<FridgeCubit>().deleteProduct(_product!.id);
              Navigator.pop(context);
              context.go('/fridge');
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _selectedExpiryDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/fridge'),
          ),
          title: const Text('Продукт не найден'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Продукт не найден',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go('/fridge'),
                child: const Text('Вернуться в холодильник'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать продукт'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/fridge'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteProduct,
            tooltip: 'Удалить продукт',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название продукта *',
                prefixIcon: Icon(Icons.shopping_basket),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Количество *',
                      prefixIcon: Icon(Icons.scale),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedUnit,
                  items: AppConstants.units
                      .map((unit) => DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedUnit = value!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Калорийность на 100г/мл',
                prefixIcon: Icon(Icons.local_fire_department),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Категория',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: AppConstants.categories
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Примечания',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _selectedExpiryDate == null
                    ? 'Выберите срок годности'
                    : 'Срок годности: ${DateFormat('dd.MM.yyyy').format(_selectedExpiryDate!)}',
              ),
              trailing: _selectedExpiryDate == null
                  ? null
                  : TextButton(
                onPressed: () => setState(() => _selectedExpiryDate = null),
                child: const Text('Убрать'),
              ),
              onTap: _selectExpiryDate,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/fridge'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}