import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_row.dart';

class ProductsList extends StatelessWidget {
  final List<Product> products;
  final Function(String, double) onConsume;
  final Function(String) onDelete;

  const ProductsList({
    super.key,
    required this.products,
    required this.onConsume,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Холодильник пуст', style: TextStyle(fontSize: 18)),
            Text('Добавьте первые продукты!', style: TextStyle(fontSize: 14)),
          ],
        ),
      );
    }

    final sortedProducts = List.of(products)
      ..sort((a, b) {
        if (a.isExpired && !b.isExpired) return -1;
        if (!a.isExpired && b.isExpired) return 1;
        if (a.isExpiringSoon && !b.isExpiringSoon) return -1;
        if (!a.isExpiringSoon && b.isExpiringSoon) return 1;
        return a.name.compareTo(b.name);
      });

    return ListView.builder(
      itemCount: sortedProducts.length,
      itemBuilder: (context, index) {
        final product = sortedProducts[index];
        return ProductRow(
          product: product,
          onConsume: (quantity) => onConsume(product.id, quantity),
          onDelete: () => onDelete(product.id),
        );
      },
    );
  }
}