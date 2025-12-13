import '../models/shopping_item.dart';

class ShoppingState {
  final List<ShoppingItem> items;
  final bool isLoading;
  final String? error;

  const ShoppingState({
    required this.items,
    required this.isLoading,
    required this.error,
  });

  factory ShoppingState.initial() {
    return const ShoppingState(items: [], isLoading: true, error: null);
  }

  int get boughtCount => items.where((i) => i.isBought).length;
  int get totalCount => items.length;

  ShoppingState copyWith({
    List<ShoppingItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return ShoppingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
