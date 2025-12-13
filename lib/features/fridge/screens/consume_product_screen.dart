import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/app_colors.dart';
import '../cubit/fridge_cubit.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/shopping_cubit.dart';
import '../models/product.dart';

class ConsumeProductScreen extends StatefulWidget {
  const ConsumeProductScreen({super.key});

  @override
  State<ConsumeProductScreen> createState() => _ConsumeProductScreenState();
}

class _ConsumeProductScreenState extends State<ConsumeProductScreen> {
  Product? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController();
  double _calculatedCalories = 0.0;

  void _calculateCalories() {
    if (_selectedProduct == null || _quantityController.text.isEmpty) {
      setState(() => _calculatedCalories = 0.0);
      return;
    }

    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    if (quantity <= 0) {
      setState(() => _calculatedCalories = 0.0);
      return;
    }

    final calories = (quantity / 100) * _selectedProduct!.calories;
    setState(() => _calculatedCalories = calories);
  }

  void _consumeProduct() {
    if (_selectedProduct == null || _quantityController.text.isEmpty) {
      _showErrorDialog('Выберите продукт и введите количество');
      return;
    }

    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    if (quantity <= 0 || quantity > _selectedProduct!.quantity) {
      _showErrorDialog('Введите корректное количество (0-${_selectedProduct!.quantity})');
      return;
    }

    final fridgeCubit = context.read<FridgeCubit>();
    final settingsState = context.read<SettingsCubit>().state;

    // Потребляем продукт
    fridgeCubit.consumeProduct(_selectedProduct!.id, quantity);

    // Проверяем, нужно ли добавить в список покупок
    final consumedAll = quantity >= _selectedProduct!.quantity;
    if (consumedAll && !settingsState.isLoading && settingsState.autoGenerateShoppingList) {
      context.read<ShoppingCubit>().addOrIncreaseItem(
        name: _selectedProduct!.name,
        category: _selectedProduct!.category,
        unit: _selectedProduct!.unit,
        quantity: _selectedProduct!.quantity,
      );
    }

    // Показываем подтверждение
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Потреблено $quantity ${_selectedProduct!.unit} ${_selectedProduct!.name} '
              '(${_calculatedCalories.toStringAsFixed(0)} ккал)',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Возвращаемся на главный экран
    context.go('/fridge');
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

  @override
  Widget build(BuildContext context) {
    final products = context.select<FridgeCubit, List<Product>>(
          (cubit) => cubit.state.products,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Учет потребления'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/fridge'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите продукт для учета потребления',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Выбор продукта
            DropdownButtonFormField<Product>(
              value: _selectedProduct,
              decoration: const InputDecoration(
                labelText: 'Продукт *',
                prefixIcon: Icon(Icons.shopping_basket),
                border: OutlineInputBorder(),
              ),
              items: products
                  .where((product) => product.quantity > 0)
                  .map((product) {
                return DropdownMenuItem<Product>(
                  value: product,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.categoryColors[product.category] ?? Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          _getCategoryIcon(product.category),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${product.quantity} ${product.unit}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (product) {
                setState(() {
                  _selectedProduct = product;
                  _quantityController.text = '';
                  _calculatedCalories = 0.0;
                });
              },
            ),

            const SizedBox(height: 24),

            // Ввод количества
            if (_selectedProduct != null) ...[
              Text(
                'Введите количество для потребления (${_selectedProduct!.unit}):',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Количество',
                  hintText: 'Доступно: ${_selectedProduct!.quantity}',
                  prefixIcon: const Icon(Icons.scale),
                  suffixText: _selectedProduct!.unit,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => _calculateCalories(),
              ),
              const SizedBox(height: 16),
              Text(
                'Калорийность: ${_selectedProduct!.calories} ккал/100${_selectedProduct!.unit == 'г' || _selectedProduct!.unit == 'кг' ? 'г' : 'мл'}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],

            const SizedBox(height: 24),

            // Расчет калорий
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Расчет калорийности',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_calculatedCalories ккал',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedProduct == null
                          ? 'Выберите продукт и введите количество'
                          : '${_quantityController.text.isEmpty ? 0.0 : double.tryParse(_quantityController.text) ?? 0.0} ${_selectedProduct!.unit} × ${_selectedProduct!.calories} ккал/100${_selectedProduct!.unit == 'г' || _selectedProduct!.unit == 'кг' ? 'г' : 'мл'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Кнопки действий
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
                    onPressed: _consumeProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Подтвердить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Молочные продукты':
        return Icons.local_drink;
      case 'Овощи':
        return Icons.eco;
      case 'Фрукты':
        return Icons.apple;
      case 'Мясо':
        return Icons.set_meal;
      case 'Рыба':
        return Icons.set_meal;
      case 'Бакалея':
        return Icons.bakery_dining;
      case 'Напитки':
        return Icons.local_cafe;
      default:
        return Icons.shopping_basket;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}