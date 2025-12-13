import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_row.dart';

class ProductsList extends StatelessWidget {
  final List<Product> products;
  final Function(String, double) onConsume;
  final Function(String) onDelete;
  final Function(Product) onEdit;

  const ProductsList({
    super.key,
    required this.products,
    required this.onConsume,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Холодильник пуст',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте первые продукты!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final expiredProducts = products.where((p) => p.isExpired).toList();
    final expiringProducts = products.where((p) => p.isExpiringSoon).toList();
    final freshProducts = products
        .where((p) => !p.isExpired && !p.isExpiringSoon)
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (expiredProducts.isNotEmpty) ...[
          _buildSectionHeader('Просроченные продукты', Colors.red),
          ...expiredProducts.map((product) => ProductRow(
            product: product,
            onConsume: (quantity) => onConsume(product.id, quantity),
            onDelete: () => onDelete(product.id),
            onEdit: () => onEdit(product),
          )),
        ],
        if (expiringProducts.isNotEmpty) ...[
          _buildSectionHeader('Скоро истекают', Colors.orange),
          ...expiringProducts.map((product) => ProductRow(
            product: product,
            onConsume: (quantity) => onConsume(product.id, quantity),
            onDelete: () => onDelete(product.id),
            onEdit: () => onEdit(product),
          )),
        ],
        if (freshProducts.isNotEmpty) ...[
          _buildSectionHeader('Свежие продукты', Colors.green),
          ...freshProducts.map((product) => ProductRow(
            product: product,
            onConsume: (quantity) => onConsume(product.id, quantity),
            onDelete: () => onDelete(product.id),
            onEdit: () => onEdit(product),
          )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}