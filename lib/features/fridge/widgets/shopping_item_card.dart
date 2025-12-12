import 'package:flutter/material.dart';

class ShoppingItemCard extends StatelessWidget {
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final bool isBought;
  final VoidCallback onToggleBought;
  final VoidCallback onDelete;

  const ShoppingItemCard({
    super.key,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.isBought,
    required this.onToggleBought,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      color: isBought ? Colors.grey.shade100 : Colors.white,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getCategoryColor(category),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(category),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: isBought ? TextDecoration.lineThrough : TextDecoration.none,
            color: isBought ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                color: isBought ? Colors.grey : Colors.grey.shade600,
              ),
            ),
            Text(
              '$quantity $unit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isBought ? Colors.grey : Colors.blue,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isBought ? Icons.check_box : Icons.check_box_outline_blank,
                color: isBought ? Colors.green : Colors.grey,
              ),
              onPressed: onToggleBought,
              tooltip: isBought ? 'Отметить как некупленное' : 'Отметить как купленное',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Удалить из списка',
            ),
          ],
        ),
        onTap: onToggleBought,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Молочные продукты': Colors.blue,
      'Овощи': Colors.green,
      'Фрукты': Colors.orange,
      'Мясо': Colors.red,
      'Рыба': Colors.cyan,
      'Бакалея': Colors.brown,
      'Напитки': Colors.purple,
      'Другое': Colors.grey,
    };
    return colors[category] ?? Colors.blue;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Молочные продукты': Icons.local_drink,
      'Овощи': Icons.eco,
      'Фрукты': Icons.apple,
      'Мясо': Icons.set_meal,
      'Рыба': Icons.set_meal,
      'Бакалея': Icons.bakery_dining,
      'Напитки': Icons.local_cafe,
      'Другое': Icons.shopping_basket,
    };
    return icons[category] ?? Icons.shopping_basket;
  }
}