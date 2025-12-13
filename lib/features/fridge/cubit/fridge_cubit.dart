import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import 'fridge_state.dart';

class FridgeCubit extends Cubit<FridgeState> {
  static const _kInitializedKey = 'fridge_initialized_v1';
  static const _kProductsKey = 'fridge_products_v1';
  static const _kDailyCaloriesKey = 'fridge_daily_calories_v1';

  FridgeCubit() : super(FridgeState.initial());

  Future<void> init() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final prefs = await SharedPreferences.getInstance();

      final initialized = prefs.getBool(_kInitializedKey) ?? false;
      final productsJson = prefs.getString(_kProductsKey);
      final dailyCalories = prefs.getDouble(_kDailyCaloriesKey) ?? 0.0;

      if (!initialized) {
        final demo = _demoProducts();
        emit(state.copyWith(
          products: demo,
          dailyCalories: 0.0,
          isLoading: false,
          error: null,
        ));
        await prefs.setBool(_kInitializedKey, true);
        await _save(prefs, products: demo, dailyCalories: 0.0);
        return;
      }

      final products = productsJson == null
          ? <Product>[]
          : (jsonDecode(productsJson) as List<dynamic>)
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList(growable: false);

      emit(state.copyWith(
        products: products,
        dailyCalories: dailyCalories,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Не удалось загрузить данные холодильника: $e',
      ));
    }
  }

  Future<void> reload() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString(_kProductsKey);
    final dailyCalories = prefs.getDouble(_kDailyCaloriesKey) ?? 0.0;

    final products = productsJson == null
        ? <Product>[]
        : (jsonDecode(productsJson) as List<dynamic>)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);

    emit(state.copyWith(
      products: products,
      dailyCalories: dailyCalories,
      isLoading: false,
      error: null,
    ));
  }

  Future<void> addProduct(Product product) async {
    final updated = [...state.products, product];
    emit(state.copyWith(products: updated, error: null));
    await _saveCurrent();
  }

  Future<void> updateProduct(Product product) async {
    final updated = state.products
        .map((p) => p.id == product.id ? product : p)
        .toList(growable: false);

    emit(state.copyWith(products: updated, error: null));
    await _saveCurrent();
  }

  Future<void> deleteProduct(String id) async {
    final updated = state.products.where((p) => p.id != id).toList(growable: false);
    emit(state.copyWith(products: updated, error: null));
    await _saveCurrent();
  }

  Future<void> consumeProduct(String id, double quantity) async {
    final index = state.products.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final product = state.products[index];
    final caloriesConsumed = (quantity / 100) * product.calories;
    final newDailyCalories = state.dailyCalories + caloriesConsumed;

    final updated = [...state.products];
    if (product.quantity <= quantity) {
      updated.removeAt(index);
    } else {
      updated[index] = product.copyWith(quantity: product.quantity - quantity);
    }

    emit(state.copyWith(
      products: updated,
      dailyCalories: newDailyCalories,
      error: null,
    ));
    await _saveCurrent();
  }

  Future<void> clearAll() async {
    emit(state.copyWith(products: const [], dailyCalories: 0.0, error: null));
    await _saveCurrent();
  }

  Future<void> resetDailyCalories() async {
    emit(state.copyWith(dailyCalories: 0.0, error: null));
    await _saveCurrent();
  }

  Future<void> _saveCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    await _save(prefs, products: state.products, dailyCalories: state.dailyCalories);
  }

  Future<void> _save(
    SharedPreferences prefs, {
    required List<Product> products,
    required double dailyCalories,
  }) async {
    final productsJson = jsonEncode(products.map((p) => p.toJson()).toList());
    await prefs.setString(_kProductsKey, productsJson);
    await prefs.setDouble(_kDailyCaloriesKey, dailyCalories);
  }

  List<Product> _demoProducts() {
    final now = DateTime.now();
    return [
      Product(
        id: '1',
        name: 'Молоко',
        category: 'Молочные продукты',
        quantity: 1000,
        unit: 'мл',
        calories: 42,
        expiryDate: now.add(const Duration(days: 3)),
        addedDate: now.subtract(const Duration(days: 1)),
      ),
      Product(
        id: '2',
        name: 'Яблоки',
        category: 'Фрукты',
        quantity: 500,
        unit: 'г',
        calories: 52,
        expiryDate: now.add(const Duration(days: 14)),
        addedDate: now.subtract(const Duration(days: 2)),
      ),
      Product(
        id: '3',
        name: 'Куриное филе',
        category: 'Мясо',
        quantity: 300,
        unit: 'г',
        calories: 165,
        expiryDate: now.add(const Duration(days: 5)),
        addedDate: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
