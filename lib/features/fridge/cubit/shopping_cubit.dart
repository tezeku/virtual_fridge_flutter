import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/shopping_item.dart';
import 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  static const _kItemsKey = 'shopping_items_v1';

  ShoppingCubit() : super(ShoppingState.initial());

  Future<void> init() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final prefs = await SharedPreferences.getInstance();

      final jsonStr = prefs.getString(_kItemsKey);
      final items = jsonStr == null
          ? <ShoppingItem>[]
          : (jsonDecode(jsonStr) as List<dynamic>)
              .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
              .toList(growable: false);

      emit(state.copyWith(items: items, isLoading: false, error: null));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Не удалось загрузить список покупок: $e',
      ));
    }
  }

  Future<void> addItem(ShoppingItem item) async {
    final updated = [...state.items, item];
    emit(state.copyWith(items: updated, error: null));
    await _saveCurrent();
  }

  /// Adds an item or increases quantity on an existing not-bought item
  /// with the same (name, category, unit).
  Future<void> addOrIncreaseItem({
    required String name,
    required String category,
    required String unit,
    required double quantity,
  }) async {
    if (quantity <= 0) return;

    final idx = state.items.indexWhere(
      (i) =>
          !i.isBought &&
          i.name == name &&
          i.category == category &&
          i.unit == unit,
    );

    if (idx == -1) {
      await addItem(
        ShoppingItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          category: category,
          neededQuantity: quantity,
          unit: unit,
          isBought: false,
          addedDate: DateTime.now(),
        ),
      );
      return;
    }

    final existing = state.items[idx];
    final updatedItem = existing.copyWith(
      neededQuantity: existing.neededQuantity + quantity,
    );

    final updated = [...state.items];
    updated[idx] = updatedItem;

    emit(state.copyWith(items: updated, error: null));
    await _saveCurrent();
  }

  Future<void> toggleBought(String id) async {
    final updated = state.items
        .map((i) => i.id == id ? i.copyWith(isBought: !i.isBought) : i)
        .toList(growable: false);

    emit(state.copyWith(items: updated, error: null));
    await _saveCurrent();
  }

  Future<void> deleteItem(String id) async {
    final updated = state.items.where((i) => i.id != id).toList(growable: false);
    emit(state.copyWith(items: updated, error: null));
    await _saveCurrent();
  }

  Future<void> clearBought() async {
    final updated = state.items.where((i) => !i.isBought).toList(growable: false);
    emit(state.copyWith(items: updated, error: null));
    await _saveCurrent();
  }

  Future<void> clearAll() async {
    emit(state.copyWith(items: const [], error: null));
    await _saveCurrent();
  }

  Future<void> _saveCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.items.map((i) => i.toJson()).toList());
    await prefs.setString(_kItemsKey, jsonStr);
  }
}