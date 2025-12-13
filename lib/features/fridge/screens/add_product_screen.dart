import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants.dart';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final Function(Product) onSave;
  final VoidCallback onCancel;
  final Product? product;

  const AddProductScreen({
    super.key,
    required this.onSave,
    required this.onCancel,
    this.product,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  String _selectedCategory = AppConstants.categories.first;
  String _selectedUnit = AppConstants.units.first;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _quantityController.text = widget.product!.quantity.toString();
      _caloriesController.text = widget.product!.calories.toString();
      _selectedCategory = widget.product!.category;
      _selectedUnit = widget.product!.unit;
      _selectedExpiryDate = widget.product!.expiryDate;
      _notesController.text = widget.product!.notes ?? '';
    } else {
      _selectedExpiryDate = DateTime.now().add(AppConstants.defaultProductExpiry);
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final calories = double.tryParse(_caloriesController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();

    if (name.isEmpty) {
      _showErrorDialog('Пожалуйста, введите название продукта');
      return;
    }

    if (quantity <= 0) {
      _showErrorDialog('Пожалуйста, введите корректное количество');
      return;
    }

    final product = Product(
      id: widget.product?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      category: _selectedCategory,
      quantity: quantity,
      unit: _selectedUnit,
      calories: calories,
      expiryDate: _selectedExpiryDate,
      addedDate: widget.product?.addedDate ?? DateTime.now(),
      notes: notes.isNotEmpty ? notes : null,
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
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Выберите срок годности',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
    );

    if (pickedDate != null) {
      setState(() => _selectedExpiryDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Добавить продукт' : 'Редактировать продукт'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
          tooltip: 'Назад',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product == null ? 'Новый продукт' : 'Редактирование',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название продукта *',
                hintText: 'Например: Молоко, Яблоки, Курица',
                prefixIcon: Icon(Icons.shopping_basket),
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
                      hintText: '500',
                      prefixIcon: Icon(Icons.scale),
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
                hintText: 'Например: 42 для яблок',
                prefixIcon: Icon(Icons.local_fire_department),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Категория',
                prefixIcon: Icon(Icons.category),
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
                labelText: 'Примечания (опционально)',
                hintText: 'Дополнительная информация о продукте',
                prefixIcon: Icon(Icons.note),
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
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.product == null ? 'Добавить' : 'Сохранить'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.product != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Информация о продукте:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Добавлен: ${DateFormat('dd.MM.yyyy').format(widget.product!.addedDate)}'),
            ],
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