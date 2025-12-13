import '../models/product.dart';

class FridgeState {
  final List<Product> products;
  final double dailyCalories;
  final bool isLoading;
  final String? error;

  const FridgeState({
    required this.products,
    required this.dailyCalories,
    required this.isLoading,
    required this.error,
  });

  factory FridgeState.initial() {
    return const FridgeState(
      products: [],
      dailyCalories: 0.0,
      isLoading: true,
      error: null,
    );
  }

  FridgeState copyWith({
    List<Product>? products,
    double? dailyCalories,
    bool? isLoading,
    String? error,
  }) {
    return FridgeState(
      products: products ?? this.products,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}