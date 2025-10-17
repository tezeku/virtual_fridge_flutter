import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/products_list.dart';

class FridgeScreen extends StatelessWidget {
  final List<Product> products;
  final VoidCallback onAddProduct;
  final Function(String, double) onConsumeProduct;
  final Function(String) onDeleteProduct;
  final double totalCalories;

  const FridgeScreen({
    super.key,
    required this.products,
    required this.onAddProduct,
    required this.onConsumeProduct,
    required this.onDeleteProduct,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой холодильник'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAddProduct,
            tooltip: 'Добавить продукт',
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Сегодня съедено',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${totalCalories.toStringAsFixed(0)} ккал',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Продуктов в холодильнике: ${products.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ProductsList(
              products: products,
              onConsume: onConsumeProduct,
              onDelete: onDeleteProduct,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddProduct,
        tooltip: 'Добавить продукт',
        child: const Icon(Icons.add),
      ),
    );
  }
}