import 'package:flutter/material.dart';
import '../../../shared/constants.dart';
import '../fridge_container.dart';
import '../widgets/shopping_item_card.dart';
import '../fridge_data_provider.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class ShoppingItem {
  final String name;
  final String category;
  final double neededQuantity;
  final String unit;
  bool isBought;

  ShoppingItem({
    required this.name,
    required this.category,
    required this.neededQuantity,
    required this.unit,
    this.isBought = false,
  });
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final List<ShoppingItem> _shoppingList = [];
  final List<ShoppingItem> _manualList = [];

  @override
  void initState() {
    super.initState();
    _generateShoppingList();
  }

  void _generateShoppingList() {
    final provider = FridgeDataProvider.of(context);
    final products = provider?.products ?? [];

    setState(() {
      _shoppingList.clear();

      // Автоматически добавляем продукты с малым количеством
      for (final product in products) {
        if (product.quantity < 100) { // Порог 100 грамм/мл
          _shoppingList.add(ShoppingItem(
            name: product.name,
            category: product.category,
            neededQuantity: 500, // Стандартное количество для покупки
            unit: product.unit,
          ));
        }
      }

      // Если список пустой, предлагаем базовые продукты
      if (_shoppingList.isEmpty && products.isEmpty) {
        _shoppingList.addAll([
          ShoppingItem(
            name: 'Молоко',
            category: 'Молочные продукты',
            neededQuantity: 1000,
            unit: 'мл',
          ),
          ShoppingItem(
            name: 'Хлеб',
            category: 'Бакалея',
            neededQuantity: 1,
            unit: 'шт',
          ),
          ShoppingItem(
            name: 'Яйца',
            category: 'Прочее',
            neededQuantity: 10,
            unit: 'шт',
          ),
        ]);
      }
    });
  }

  void _addManualItem() {
    showDialog(
      context: context,
      builder: (context) => _AddManualItemDialog(
        onAdd: (item) {
          setState(() => _manualList.add(item));
        },
      ),
    );
  }

  void _toggleBought(int index, bool isAutoList) {
    setState(() {
      if (isAutoList) {
        final item = _shoppingList[index];
        _shoppingList[index] = ShoppingItem(
          name: item.name,
          category: item.category,
          neededQuantity: item.neededQuantity,
          unit: item.unit,
          isBought: !item.isBought,
        );
      } else {
        final item = _manualList[index];
        _manualList[index] = ShoppingItem(
          name: item.name,
          category: item.category,
          neededQuantity: item.neededQuantity,
          unit: item.unit,
          isBought: !item.isBought,
        );
      }
    });
  }

  void _deleteItem(int index, bool isAutoList) {
    setState(() {
      if (isAutoList) {
        _shoppingList.removeAt(index);
      } else {
        _manualList.removeAt(index);
      }
    });
  }

  int get _boughtCount {
    return _shoppingList.where((item) => item.isBought).length +
        _manualList.where((item) => item.isBought).length;
  }

  int get _totalCount {
    return _shoppingList.length + _manualList.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Список покупок'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateShoppingList,
            tooltip: 'Обновить список',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addManualItem,
            tooltip: 'Добавить вручную',
          ),
        ],
      ),
      body: Column(
        children: [
          // Прогресс
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_boughtCount/$_totalCount куплено',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${((_boughtCount / _totalCount) * 100).toStringAsFixed(0)}% завершено',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    '$_boughtCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Автоматический список
                if (_shoppingList.isNotEmpty) ...[
                  const Text(
                    'Рекомендуемые покупки',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._shoppingList.asMap().entries.map((entry) =>
                      _ShoppingListItem(
                        item: entry.value,
                        index: entry.key,
                        isAutoList: true,
                        onToggleBought: _toggleBought,
                        onDelete: _deleteItem,
                      )),
                  const SizedBox(height: 20),
                ],

                // Ручной список
                if (_manualList.isNotEmpty) ...[
                  const Text(
                    'Добавленные вручную',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._manualList.asMap().entries.map((entry) =>
                      _ShoppingListItem(
                        item: entry.value,
                        index: entry.key,
                        isAutoList: false,
                        onToggleBought: _toggleBought,
                        onDelete: _deleteItem,
                      )),
                ],

                if (_shoppingList.isEmpty && _manualList.isEmpty) ...[
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Список покупок пуст'),
                        Text('Добавьте продукты для покупки'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingListItem extends StatelessWidget {
  final ShoppingItem item;
  final int index;
  final bool isAutoList;
  final Function(int, bool) onToggleBought;
  final Function(int, bool) onDelete;

  const _ShoppingListItem({
    required this.item,
    required this.index,
    required this.isAutoList,
    required this.onToggleBought,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ShoppingItemCard(
      name: item.name,
      category: item.category,
      quantity: item.neededQuantity,
      unit: item.unit,
      isBought: item.isBought,
      onToggleBought: () => onToggleBought(index, isAutoList),
      onDelete: () => onDelete(index, isAutoList),
    );
  }
}

class _AddManualItemDialog extends StatefulWidget {
  final Function(ShoppingItem) onAdd;

  const _AddManualItemDialog({required this.onAdd});

  @override
  State<_AddManualItemDialog> createState() => _AddManualItemDialogState();
}

class _AddManualItemDialogState extends State<_AddManualItemDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _selectedCategory = AppConstants.categories.first;
  String _selectedUnit = AppConstants.units.first;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить продукт'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Название продукта'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Количество'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 12),
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _quantityController.text.isNotEmpty) {
              final quantity = double.tryParse(_quantityController.text) ?? 1;
              widget.onAdd(ShoppingItem(
                name: _nameController.text,
                category: _selectedCategory,
                neededQuantity: quantity,
                unit: _selectedUnit,
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}