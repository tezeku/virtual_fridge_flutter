import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../../shared/constants.dart';

class AddProductScreen extends StatefulWidget {
  final Function(Product) onSave;

  const AddProductScreen({super.key, required this.onSave});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _selectedCategory = AppConstants.categories.first;
  String _selectedUnit = AppConstants.units.first;
  DateTime? _selectedExpiryDate;

  void _submit() {
    final name = _nameController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final calories = double.tryParse(_caloriesController.text.trim()) ?? 0.0;

    if (name.isEmpty || quantity <= 0) {
      _showErrorDialog('Пожалуйста, заполните название и количество продукта');
      return;
    }

    final product = Product(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      category: _selectedCategory,
      quantity: quantity,
      unit: _selectedUnit,
      calories: calories,
      expiryDate: _selectedExpiryDate,
      addedDate: DateTime.now(),
    );

    widget.onSave(product);
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
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _selectedExpiryDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить продукт'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Название продукта',
                  hintText: 'Например: Молоко, Яблоки, Курица'
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                        labelText: 'Количество',
                        hintText: '500'
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
                  onChanged: (value) =>
                      setState(() => _selectedUnit = value!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                  labelText: 'Калорийность на 100г/мл',
                  hintText: 'Например: 42 для яблок'
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Категория'),
              items: AppConstants.categories
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _selectedExpiryDate == null
                    ? 'Выберите срок годности (опционально)'
                    : 'Срок годности: ${DateFormat('dd.MM.yyyy').format(_selectedExpiryDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectExpiryDate,
            ),
            if (_selectedExpiryDate != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _selectedExpiryDate = null),
                child: const Text('Убрать срок годности'),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Добавить в холодильник'),
            ),
          ],
        ),
      ),
    );
  }
}