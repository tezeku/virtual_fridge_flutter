import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';

class StatsState {
  final List<double> weeklyCalories;
  final Map<String, int> categoryStats;
  final int expiredCount;
  final int expiringSoonCount;
  final int freshCount;
  final double totalCalories;
  final double dailyCalories;
  final bool isLoading;
  final String? error;

  const StatsState({
    required this.weeklyCalories,
    required this.categoryStats,
    required this.expiredCount,
    required this.expiringSoonCount,
    required this.freshCount,
    required this.totalCalories,
    required this.dailyCalories,
    required this.isLoading,
    this.error,
  });

  factory StatsState.initial() {
    return const StatsState(
      weeklyCalories: [],
      categoryStats: {},
      expiredCount: 0,
      expiringSoonCount: 0,
      freshCount: 0,
      totalCalories: 0.0,
      dailyCalories: 0.0,
      isLoading: false,
      error: null,
    );
  }

  StatsState copyWith({
    List<double>? weeklyCalories,
    Map<String, int>? categoryStats,
    int? expiredCount,
    int? expiringSoonCount,
    int? freshCount,
    double? totalCalories,
    double? dailyCalories,
    bool? isLoading,
    String? error,
  }) {
    return StatsState(
      weeklyCalories: weeklyCalories ?? this.weeklyCalories,
      categoryStats: categoryStats ?? this.categoryStats,
      expiredCount: expiredCount ?? this.expiredCount,
      expiringSoonCount: expiringSoonCount ?? this.expiringSoonCount,
      freshCount: freshCount ?? this.freshCount,
      totalCalories: totalCalories ?? this.totalCalories,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class StatsCubit extends Cubit<StatsState> {
  final List<Product> _products;
  final double _dailyCalories;

  StatsCubit({
    required List<Product> products,
    required double dailyCalories,
  })  : _products = products,
        _dailyCalories = dailyCalories,
        super(StatsState.initial()) {
    _calculateStats();
  }

  void _calculateStats() {
    emit(state.copyWith(isLoading: true));

    try {
      final categoryStats = <String, int>{};
      for (final product in _products) {
        categoryStats[product.category] =
            (categoryStats[product.category] ?? 0) + 1;
      }

      final expiredCount = _products.where((p) => p.isExpired).length;
      final expiringCount = _products.where((p) => p.isExpiringSoon).length;
      final freshCount = _products.length - expiredCount - expiringCount;

      final totalCalories = _products.fold(
        0.0,
            (sum, product) => sum + product.totalCalories,
      );

      final weeklyCalories = _generateWeeklyData();

      emit(StatsState(
        weeklyCalories: weeklyCalories,
        categoryStats: categoryStats,
        expiredCount: expiredCount,
        expiringSoonCount: expiringCount,
        freshCount: freshCount,
        totalCalories: totalCalories,
        dailyCalories: _dailyCalories,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Ошибка при расчете статистики: $e',
      ));
    }
  }

  List<double> _generateWeeklyData() {
    final List<double> data = [];

    for (int i = 6; i >= 0; i--) {
      if (i == 0) {
        data.add(_dailyCalories);
      } else {
        final baseValue = 1200 + (i * 100);
        final randomVariation = (DateTime.now().day + i) % 300;
        data.add((baseValue + randomVariation).toDouble());
      }
    }

    return data;
  }

  void refreshStats({
    required List<Product> products,
    required double dailyCalories,
  }) {
    _products.clear();
    _products.addAll(products);
    _calculateStats();
  }
}