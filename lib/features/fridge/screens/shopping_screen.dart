import 'package:flutter/material.dart';

import '../../../shared/constants.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class ShoppingItem {
  final String id;
  final String name;
  final String category;
  final double neededQuantity;
  final String unit;
  bool isBought;
  final DateTime addedDate;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.neededQuantity,
    required this.unit,
    this.isBought = false,
    required this.addedDate,
  });

  ShoppingItem copyWith({
    String? name,
    String? category,
    double? neededQuantity,
    String? unit,
    bool? isBought,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      neededQuantity: neededQuantity ?? this.neededQuantity,
      unit: unit ?? this.unit,
      isBought: isBought ?? this.isBought,
      addedDate: addedDate,
    );
  }
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final List<ShoppingItem> _shoppingList = [];

  @override
  void initState() {
    super.initState();
    _loadDemoData();
  }

  void _loadDemoData() {
    setState(() {
      _shoppingList.addAll([
        ShoppingItem(
          id: '1',
          name: 'Молоко',
          category: 'Молочные продукты',
          neededQuantity: 1000,
          unit: 'мл',
          isBought: false,
          addedDate: DateTime.now(),
        ),
        ShoppingItem(
          id: '2',
          name: 'Хлеб',
          category: 'Бакалея',
          neededQuantity: 1,
          unit: 'шт',
          isBought: true,
          addedDate: DateTime.now(),
        ),
        ShoppingItem(
          id: '3',
          name: 'Яйца',
          category: 'Другое',
          neededQuantity: 10,
          unit: 'шт',
          isBought: false,
          addedDate: DateTime.now(),
        ),
        ShoppingItem(
          id: '4',
          name: 'Яблоки',
          category: 'Фрукты',
          neededQuantity: 500,
          unit: 'г',
          isBought: false,
          addedDate: DateTime.now(),
        ),
      ]);
    });
  }

  void _addManualItem() {
    showDialog(
      context: context,
      builder: (context) => _AddManualItemDialog(
        onAdd: (item) {
          setState(() => _shoppingList.add(item));
        },
      ),
    );
  }

  void _toggleBought(int index) {
    setState(() {
      final item = _shoppingList[index];
      _shoppingList[index] = item.copyWith(isBought: !item.isBought);
    });
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить из списка'),
        content: Text('Удалить "${_shoppingList[index].name}" из списка покупок?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _shoppingList.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearBoughtItems() {
    setState(() {
      _shoppingList.removeWhere((item) => item.isBought);
    });
  }

  void _clearAllItems() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить список'),
        content: const Text('Вы уверены, что хотите очистить весь список покупок?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _shoppingList.clear());
              Navigator.pop(context);
            },
            child: const Text('Очистить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  int get _boughtCount => _shoppingList.where((item) => item.isBought).length;
  int get _totalCount => _shoppingList.length;
  double get _completionPercentage =>
      _totalCount > 0 ? (_boughtCount / _totalCount) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    final notBoughtItems = _shoppingList.where((item) => !item.isBought).toList();
    final boughtItems = _shoppingList.where((item) => item.isBought).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Список покупок'),
        centerTitle: true,
        actions: [
          if (_boughtCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearBoughtItems,
              tooltip: 'Очистить купленное',
            ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearAllItems,
            tooltip: 'Очистить все',
          ),
        ],
      ),
      body: Column(
        children: [
          // Прогресс
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_boughtCount/$_totalCount куплено',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: _completionPercentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.blue,
                        minHeight: 6,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_completionPercentage.toStringAsFixed(0)}% завершено',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 24,
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
            child: _shoppingList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Список покупок пуст',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте продукты для покупки',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (notBoughtItems.isNotEmpty) ...[
                  const Text(
                    'Требуется купить',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...notBoughtItems.asMap().entries.map(
                        (entry) => _ShoppingListItem(
                      item: entry.value,
                      onToggleBought: () => _toggleBought(
                        _shoppingList.indexOf(entry.value),
                      ),
                      onDelete: () => _deleteItem(
                        _shoppingList.indexOf(entry.value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (boughtItems.isNotEmpty) ...[
                  const Text(
                    'Уже куплено',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...boughtItems.asMap().entries.map(
                        (entry) => _ShoppingListItem(
                      item: entry.value,
                      onToggleBought: () => _toggleBought(
                        _shoppingList.indexOf(entry.value),
                      ),
                      onDelete: () => _deleteItem(
                        _shoppingList.indexOf(entry.value),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addManualItem,
        tooltip: 'Добавить продукт',
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}

class _ShoppingListItem extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggleBought;
  final VoidCallback onDelete;

  const _ShoppingListItem({
    required this.item,
    required this.onToggleBought,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: item.isBought ? Colors.grey.shade100 : Colors.white,
      child: ListTile(
        leading: Checkbox(
          value: item.isBought,
          onChanged: (value) => onToggleBought(),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration:
            item.isBought ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.category),
            Text('${item.neededQuantity} ${item.unit}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название продукта *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Количество *',
                      border: OutlineInputBorder(),
                    ),
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
                  onChanged: (value) => setState(() => _selectedUnit = value!),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Категория',
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
          ],
        ),
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
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: _nameController.text,
                category: _selectedCategory,
                neededQuantity: quantity,
                unit: _selectedUnit,
                addedDate: DateTime.now(),
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