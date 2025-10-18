import 'package:flutter/material.dart';
import 'package:my_flutter_project/features/fridge/screens/add_product_screen.dart';
import 'package:my_flutter_project/features/fridge/screens/fridge_screen.dart';
import 'models/product.dart';

enum FridgeScreenType { fridge, addProduct }

class FridgeContainer extends StatefulWidget {
  const FridgeContainer({super.key});

  @override
  State<FridgeContainer> createState() => _FridgeContainerState();
}

class _FridgeContainerState extends State<FridgeContainer> {
  final List<Product> _products = [];
  final List<double> _dailyCalories = [0.0];
  FridgeScreenType _currentScreen = FridgeScreenType.fridge;

  Product? _recentlyRemovedProduct;
  int? _recentlyRemovedIndex;

  void _showFridge() {
    setState(() => _currentScreen = FridgeScreenType.fridge);
  }

  void _showAddProduct() {
    setState(() => _currentScreen = FridgeScreenType.addProduct);
  }

  void _addProduct(Product product) {
    setState(() {
      _products.add(product);
    });
    _showFridge();
  }

  void _consumeProduct(String productId, double quantity) {
    setState(() {
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        final product = _products[productIndex];

        final caloriesConsumed = (quantity / 100) * product.calories;
        _dailyCalories[0] += caloriesConsumed;

        if (product.quantity <= quantity) {
          _products.removeAt(productIndex);
        } else {
          _products[productIndex] = product.copyWith(
            quantity: product.quantity - quantity,
          );
        }
      }
    });
  }

  void _deleteProduct(String productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    _recentlyRemovedProduct = _products[index];
    _recentlyRemovedIndex = index;

    setState(() {
      _products.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Продукт "${_recentlyRemovedProduct!.name}" удален'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: _undoDelete,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _undoDelete() {
    if (_recentlyRemovedProduct != null && _recentlyRemovedIndex != null) {
      setState(() {
        _products.insert(_recentlyRemovedIndex!, _recentlyRemovedProduct!);
      });

      _recentlyRemovedProduct = null;
      _recentlyRemovedIndex = null;
    }
  }

  void _resetDailyCalories() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    Future.delayed(durationUntilMidnight, () {
      if (mounted) {
        setState(() {
          _dailyCalories[0] = 0.0;
        });
        _resetDailyCalories();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _resetDailyCalories();
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case FridgeScreenType.fridge:
        return FridgeScreen(
          products: _products,
          onAddProduct: _showAddProduct,
          onConsumeProduct: _consumeProduct,
          onDeleteProduct: _deleteProduct,
          totalCalories: _dailyCalories[0],
        );
      case FridgeScreenType.addProduct:
        return AddProductScreen(onSave: _addProduct);
    }
  }
}