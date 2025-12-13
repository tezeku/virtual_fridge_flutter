import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_project/features/fridge/screens/add_product_screen.dart';
import 'package:my_flutter_project/features/fridge/screens/fridge_screen.dart';

import 'fridge_data_provider.dart';
import 'models/product.dart';

enum FridgeScreenType { fridge, addProduct, editProduct }

class FridgeContainer extends StatefulWidget {
  const FridgeContainer({super.key});

  @override
  State<FridgeContainer> createState() => _FridgeContainerState();
}

class _FridgeContainerState extends State<FridgeContainer> {
  FridgeScreenType _currentScreen = FridgeScreenType.fridge;
  Product? _productToEdit;

  void _showFridge() {
    setState(() {
      _currentScreen = FridgeScreenType.fridge;
      _productToEdit = null;
    });
  }

  void _showAddProduct() {
    setState(() => _currentScreen = FridgeScreenType.addProduct);
  }

  void _editProduct(Product product) {
    setState(() {
      _currentScreen = FridgeScreenType.editProduct;
      _productToEdit = product;
    });
  }

  void _addProduct(Product product) {
    final provider = FridgeDataProvider.of(context);
    provider?.addProduct(product);
    _showFridge();
  }

  void _updateProduct(Product product) {
    final provider = FridgeDataProvider.of(context);
    provider?.updateProduct(product);
    _showFridge();
  }

  void _consumeProduct(String productId, double quantity) {
    final provider = FridgeDataProvider.of(context);
    provider?.consumeProduct(productId, quantity);
  }

  void _deleteProduct(String productId) {
    final provider = FridgeDataProvider.of(context);
    provider?.deleteProduct(productId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = FridgeDataProvider.of(context);

    switch (_currentScreen) {
      case FridgeScreenType.fridge:
        return FridgeScreen(
          products: provider?.products ?? [],
          onAddProduct: _showAddProduct,
          onConsumeProduct: _consumeProduct,
          onDeleteProduct: _deleteProduct,
          onEditProduct: _editProduct,
          onShowStats: () => context.go('/fridge/stats'),
          onShowShopping: () => context.go('/fridge/shopping'),
          onShowSettings: () => context.go('/fridge/settings'),
          totalCalories: provider?.dailyCalories ?? 0.0,
        );
      case FridgeScreenType.addProduct:
        return AddProductScreen(
          onSave: _addProduct,
          onCancel: _showFridge,
        );
      case FridgeScreenType.editProduct:
        return AddProductScreen(
          product: _productToEdit,
          onSave: _updateProduct,
          onCancel: _showFridge,
        );
    }
  }
}