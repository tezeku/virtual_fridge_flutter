import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/products_list.dart';

class FridgeScreen extends StatelessWidget {
  final List<Product> products;
  final VoidCallback onAddProduct;
  final Function(String, double) onConsumeProduct;
  final Function(String) onDeleteProduct;
  final Function(Product) onEditProduct;
  final VoidCallback onShowStats;
  final VoidCallback onShowShopping;
  final VoidCallback onShowSettings;
  final double totalCalories;

  const FridgeScreen({
    super.key,
    required this.products,
    required this.onAddProduct,
    required this.onConsumeProduct,
    required this.onDeleteProduct,
    required this.onEditProduct,
    required this.onShowStats,
    required this.onShowShopping,
    required this.onShowSettings,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    final expiredCount = products.where((p) => p.isExpired).length;
    final expiringCount = products.where((p) => p.isExpiringSoon).length;
    final totalItems = products.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой холодильник'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: onShowShopping,
            tooltip: 'Список покупок',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onShowSettings,
            tooltip: 'Настройки',
          ),
        ],
      ),
      body: Column(
        children: [
          // Статистическая панель
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatCard(
                      title: 'Калории',
                      value: '${totalCalories.toStringAsFixed(0)}',
                      unit: 'ккал',
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Продукты',
                      value: totalItems.toString(),
                      unit: 'шт',
                      icon: Icons.shopping_basket,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Истекают',
                      value: '$expiredCount/$expiringCount',
                      unit: 'просроч./истекают',
                      icon: Icons.warning,
                      color: expiredCount > 0 ? Colors.red : Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Быстрый доступ
                Row(
                  children: [
                    Expanded(
                      child: _QuickAccessButton(
                        icon: Icons.bar_chart,
                        label: 'Статистика',
                        onTap: onShowStats,
                      ),
                    ),
                    Expanded(
                      child: _QuickAccessButton(
                        icon: Icons.add,
                        label: 'Добавить',
                        onTap: onAddProduct,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ProductsList(
              products: products,
              onConsume: onConsumeProduct,
              onDelete: onDeleteProduct,
              onEdit: onEditProduct,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddProduct,
        tooltip: 'Добавить продукт',
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
      ),
    );
  }
}