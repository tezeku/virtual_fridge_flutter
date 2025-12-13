import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/constants.dart';
import '../cubit/shopping_cubit.dart';
import '../cubit/shopping_state.dart';
import '../models/shopping_item.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  void _addManualItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddManualItemDialog(
        onAdd: (item) => context.read<ShoppingCubit>().addItem(item),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
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
              context.read<ShoppingCubit>().clearAll();
              Navigator.pop(context);
            },
            child: const Text('Очистить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, ShoppingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить из списка'),
        content: Text('Удалить "${item.name}" из списка покупок?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ShoppingCubit>().deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingCubit, ShoppingState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.error != null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Список покупок'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(state.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<ShoppingCubit>().init(),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final notBoughtItems = state.items.where((i) => !i.isBought).toList();
        final boughtItems = state.items.where((i) => i.isBought).toList();

        final totalCount = state.totalCount;
        final boughtCount = state.boughtCount;
        final completionPercentage =
            totalCount > 0 ? (boughtCount / totalCount) * 100 : 0;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Список покупок'),
            centerTitle: true,
            actions: [
              if (boughtCount > 0)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => context.read<ShoppingCubit>().clearBought(),
                  tooltip: 'Очистить купленное',
                ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () => _confirmClearAll(context),
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
                            '$boughtCount/$totalCount куплено',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: completionPercentage / 100,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.blue,
                            minHeight: 6,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${completionPercentage.toStringAsFixed(0)}% завершено',
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
                        '$boughtCount',
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
                child: state.items.isEmpty
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
                            ...notBoughtItems.map(
                              (item) => _ShoppingListItem(
                                item: item,
                                onToggleBought: () => context
                                    .read<ShoppingCubit>()
                                    .toggleBought(item.id),
                                onDelete: () => _confirmDeleteItem(context, item),
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
                            ...boughtItems.map(
                              (item) => _ShoppingListItem(
                                item: item,
                                onToggleBought: () => context
                                    .read<ShoppingCubit>()
                                    .toggleBought(item.id),
                                onDelete: () => _confirmDeleteItem(context, item),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addManualItem(context),
            tooltip: 'Добавить продукт',
            icon: const Icon(Icons.add),
            label: const Text('Добавить'),
          ),
        );
      },
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
        onTap: onToggleBought,
      ),
    );
  }
}

class _AddManualItemDialog extends StatefulWidget {
  final ValueChanged<ShoppingItem> onAdd;

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
              initialValue: _selectedCategory,
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
            final name = _nameController.text.trim();
            if (name.isEmpty) return;

            final quantity = double.tryParse(_quantityController.text.trim()) ?? 1;
            widget.onAdd(
              ShoppingItem(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: name,
                category: _selectedCategory,
                neededQuantity: quantity,
                unit: _selectedUnit,
                isBought: false,
                addedDate: DateTime.now(),
              ),
            );
            Navigator.pop(context);
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
