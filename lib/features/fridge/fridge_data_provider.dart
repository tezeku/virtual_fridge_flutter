import 'package:flutter/material.dart';
import 'models/product.dart';

class FridgeDataProvider extends ChangeNotifier {
  List<Product> _products = [];
  double _dailyCalories = 0.0;

  List<Product> get products => List.unmodifiable(_products);
  double get dailyCalories => _dailyCalories;

  static FridgeDataProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedFridgeData>()
        ?.data;
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    final product = _products.firstWhere((p) => p.id == id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void consumeProduct(String id, double quantity) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final product = _products[index];
      final caloriesConsumed = (quantity / 100) * product.calories;
      _dailyCalories += caloriesConsumed;

      if (product.quantity <= quantity) {
        _products.removeAt(index);
      } else {
        _products[index] = product.copyWith(
          quantity: product.quantity - quantity,
        );
      }
      notifyListeners();
    }
  }

  void loadDemoData() {
    _products.addAll([
      Product(
        id: '1',
        name: 'Молоко',
        category: 'Молочные продукты',
        quantity: 1000,
        unit: 'мл',
        calories: 42,
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: '2',
        name: 'Яблоки',
        category: 'Фрукты',
        quantity: 500,
        unit: 'г',
        calories: 52,
        expiryDate: DateTime.now().add(const Duration(days: 14)),
        addedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Product(
        id: '3',
        name: 'Куриное филе',
        category: 'Мясо',
        quantity: 300,
        unit: 'г',
        calories: 165,
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
    notifyListeners();
  }
}

class _InheritedFridgeData extends InheritedWidget {
  final FridgeDataProvider data;

  const _InheritedFridgeData({
    required super.child,
    required this.data,
  });

  @override
  bool updateShouldNotify(_InheritedFridgeData oldWidget) {
    return data != oldWidget.data;
  }
}

class FridgeDataScope extends StatefulWidget {
  final Widget child;

  const FridgeDataScope({super.key, required this.child});

  @override
  State<FridgeDataScope> createState() => _FridgeDataScopeState();
}

class _FridgeDataScopeState extends State<FridgeDataScope> {
  final FridgeDataProvider _provider = FridgeDataProvider();

  @override
  void initState() {
    super.initState();
    _provider.loadDemoData();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedFridgeData(
      data: _provider,
      child: widget.child,
    );
  }
}