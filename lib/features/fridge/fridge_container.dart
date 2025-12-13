import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_project/features/fridge/screens/add_product_screen.dart';
import 'package:my_flutter_project/features/fridge/screens/fridge_screen.dart';
import 'cubit/fridge_cubit.dart';
import 'cubit/fridge_state.dart';
import 'cubit/settings_cubit.dart';
import 'cubit/shopping_cubit.dart';

enum FridgeScreenType { fridge, addProduct, editProduct, consume }

class FridgeContainer extends StatefulWidget {
  const FridgeContainer({super.key});

  @override
  State<FridgeContainer> createState() => _FridgeContainerState();
}

class _FridgeContainerState extends State<FridgeContainer> {
  FridgeScreenType _currentScreen = FridgeScreenType.fridge;

  void _showFridge() {
    setState(() {
      _currentScreen = FridgeScreenType.fridge;
    });
  }

  void _showAddProduct() {
    setState(() => _currentScreen = FridgeScreenType.addProduct);
  }

  void _showConsumeProduct() {
    setState(() => _currentScreen = FridgeScreenType.consume);
  }

  void _consumeProduct(String productId, double quantity) {
    final fridgeCubit = context.read<FridgeCubit>();
    final settingsState = context.read<SettingsCubit>().state;

    // Capture the product state before consuming.
    final productIndex = fridgeCubit.state.products.indexWhere((p) => p.id == productId);
    final product = productIndex == -1 ? null : fridgeCubit.state.products[productIndex];

    fridgeCubit.consumeProduct(productId, quantity);

    // If enabled, and the product is fully consumed, add it to the shopping list.
    if (product == null) return;
    if (settingsState.isLoading || !settingsState.autoGenerateShoppingList) return;

    final consumedAll = quantity >= product.quantity;
    if (!consumedAll) return;

    final buyQuantity = product.quantity;
    context.read<ShoppingCubit>().addOrIncreaseItem(
      name: product.name,
      category: product.category,
      unit: product.unit,
      quantity: buyQuantity,
    );
  }

  void _deleteProduct(String productId) {
    context.read<FridgeCubit>().deleteProduct(productId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FridgeCubit, FridgeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.error != null) {
          return Scaffold(
            body: Center(
              child: Text(state.error!, textAlign: TextAlign.center),
            ),
          );
        }

        switch (_currentScreen) {
          case FridgeScreenType.fridge:
            return FridgeScreen(
              products: state.products,
              onAddProduct: () => context.go('/fridge/add'),
              onConsumeProduct: _consumeProduct,
              onDeleteProduct: _deleteProduct,
              onEditProduct: (product) => context.go('/fridge/edit/${product.id}'),
              onShowStats: () => context.go('/fridge/stats'),
              onShowShopping: () => context.go('/fridge/shopping'),
              onShowSettings: () => context.go('/fridge/settings'),
              totalCalories: state.dailyCalories,
            );
          case FridgeScreenType.addProduct:
            return const AddProductScreen();
          case FridgeScreenType.editProduct:
            return const SizedBox.shrink();
          case FridgeScreenType.consume:
            return const SizedBox.shrink();
        }
      },
    );
  }
}