import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/app_colors.dart';
import '../models/product.dart';

class ProductRow extends StatelessWidget {
  final Product product;
  final Function(double) onConsume;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ProductRow({
    super.key,
    required this.product,
    required this.onConsume,
    required this.onDelete,
    required this.onEdit,
  });

  void _showConsumeDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Съесть ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Введите количество для потребления (${product.unit}):'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Доступно: ${product.quantity}',
                border: const OutlineInputBorder(),
              ),
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
              final quantity = double.tryParse(controller.text) ?? 0.0;
              if (quantity > 0 && quantity <= product.quantity) {
                onConsume(quantity);
                Navigator.pop(context);
                _showSuccessSnackbar(context, product.name, quantity);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Введите корректное количество (0-${product.quantity})',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(
      BuildContext context, String productName, double quantity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Потреблено $quantity ${product.unit} $productName'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить продукт'),
        content: Text('Вы уверены, что хотите удалить ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              onDelete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} удален'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppColors.normal;
    if (product.isExpired) {
      statusColor = AppColors.expired;
    } else if (product.isExpiringSoon) {
      statusColor = AppColors.expiringSoon;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: statusColor, width: 4),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.categoryColors[product.category] ?? Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(product.category),
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${product.quantity} ${product.unit} • ${product.category}',
                style: const TextStyle(fontSize: 14),
              ),
              if (product.expiryDate != null)
                Text(
                  'Годен до: ${DateFormat('dd.MM.yyyy').format(product.expiryDate!)}',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (product.calories > 0)
                Text(
                  '${product.calories} ккал/100${product.unit == 'г' || product.unit == 'кг' ? 'г' : 'мл'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.restaurant, color: Colors.blue),
                onPressed: () => _showConsumeDialog(context),
                tooltip: 'Съесть',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => context.go('/fridge/edit/${product.id}'),
                tooltip: 'Редактировать',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteDialog(context),
                tooltip: 'Удалить',
              ),
            ],
          ),
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
}