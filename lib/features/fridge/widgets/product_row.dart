import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductRow extends StatelessWidget {
  final Product product;
  final Function(double) onConsume;
  final VoidCallback onDelete;

  const ProductRow({
    super.key,
    required this.product,
    required this.onConsume,
    required this.onDelete,
  });

  void _showConsumeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Съесть ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Введите количество для потребления (${product.unit}):'),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Доступно: ${product.quantity}',
              ),
              onSubmitted: (value) {
                final quantity = double.tryParse(value) ?? 0.0;
                if (quantity > 0 && quantity <= product.quantity) {
                  onConsume(quantity);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final quantity = double.tryParse('100') ?? 100.0;
              if (quantity <= product.quantity) {
                onConsume(quantity);
                Navigator.pop(context);
              }
            },
            child: const Text('100 ${''}'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (product.isExpired) {
      statusColor = Colors.red;
    } else if (product.isExpiringSoon) {
      statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 4,
          color: statusColor,
        ),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.quantity} ${product.unit}'),
            if (product.expiryDate != null)
              Text(
                'Годен до: ${_formatDate(product.expiryDate!)}',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                ),
              ),
            if (product.calories > 0)
              Text('${product.calories} ккал/100${product.unit == 'г' ? 'г' : 'мл'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restaurant),
              onPressed: () => _showConsumeDialog(context),
              tooltip: 'Съесть',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Удалить',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}