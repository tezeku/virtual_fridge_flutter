import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../shared/app_colors.dart';
import '../cubit/fridge_cubit.dart';
import '../cubit/fridge_state.dart';
import '../models/product.dart';
import '../widgets/calories_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FridgeCubit, FridgeState>(
      builder: (context, fridgeState) {
        if (fridgeState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (fridgeState.error != null) {
          return Scaffold(
            body: Center(child: Text(fridgeState.error!)),
          );
        }

        final products = fridgeState.products;
        if (products.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Статистика'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Нет данных для статистики',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте продукты в холодильник',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        final data = _calculateStats(
          products: products,
          dailyCalories: fridgeState.dailyCalories,
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Статистика'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<FridgeCubit>().reload(),
                tooltip: 'Обновить',
              ),
            ],
          ),
          body: _StatsContent(data: data),
        );
      },
    );
  }
}

class _StatsData {
  final List<double> weeklyCalories;
  final Map<String, int> categoryStats;
  final int expiredCount;
  final int expiringSoonCount;
  final int freshCount;
  final double totalCalories;
  final double dailyCalories;

  const _StatsData({
    required this.weeklyCalories,
    required this.categoryStats,
    required this.expiredCount,
    required this.expiringSoonCount,
    required this.freshCount,
    required this.totalCalories,
    required this.dailyCalories,
  });
}

_StatsData _calculateStats({
  required List<Product> products,
  required double dailyCalories,
}) {
  final categoryStats = <String, int>{};
  for (final product in products) {
    categoryStats[product.category] = (categoryStats[product.category] ?? 0) + 1;
  }

  final expiredCount = products.where((p) => p.isExpired).length;
  final expiringCount = products.where((p) => p.isExpiringSoon).length;
  final freshCount = products.length - expiredCount - expiringCount;

  final totalCalories = products.fold(
    0.0,
    (sum, product) => sum + product.totalCalories,
  );

  return _StatsData(
    weeklyCalories: _generateWeeklyData(dailyCalories),
    categoryStats: categoryStats,
    expiredCount: expiredCount,
    expiringSoonCount: expiringCount,
    freshCount: freshCount,
    totalCalories: totalCalories,
    dailyCalories: dailyCalories,
  );
}

List<double> _generateWeeklyData(double todayCalories) {
  final List<double> data = [];

  for (int i = 6; i >= 0; i--) {
    if (i == 0) {
      data.add(todayCalories);
    } else {
      final baseValue = 1200 + (i * 100);
      final randomVariation = (DateTime.now().day + i) % 300;
      data.add((baseValue + randomVariation).toDouble());
    }
  }

  return data;
}

class _StatsContent extends StatelessWidget {
  final _StatsData data;

  const _StatsContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Общая статистика
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Общая статистика',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      label: 'Всего продуктов',
                      value: (data.expiredCount +
                              data.expiringSoonCount +
                              data.freshCount)
                          .toString(),
                      icon: Icons.shopping_basket,
                    ),
                    _StatItem(
                      label: 'Сегодня калорий',
                      value: data.dailyCalories.toStringAsFixed(0),
                      icon: Icons.local_fire_department,
                    ),
                    _StatItem(
                      label: 'Общие калории',
                      value: data.totalCalories.toStringAsFixed(0),
                      icon: Icons.calculate,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // График калорий
        CaloriesChart(
          caloriesData: data.weeklyCalories,
          chartColor: Colors.orange,
        ),

        const SizedBox(height: 20),

        // Статус продуктов
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Статус продуктов',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatusIndicator(
                      count: data.freshCount,
                      total: data.expiredCount +
                          data.expiringSoonCount +
                          data.freshCount,
                      label: 'Свежие',
                      color: AppColors.normal,
                    ),
                    _StatusIndicator(
                      count: data.expiringSoonCount,
                      total: data.expiredCount +
                          data.expiringSoonCount +
                          data.freshCount,
                      label: 'Истекают',
                      color: AppColors.expiringSoon,
                    ),
                    _StatusIndicator(
                      count: data.expiredCount,
                      total: data.expiredCount +
                          data.expiringSoonCount +
                          data.freshCount,
                      label: 'Просрочены',
                      color: AppColors.expired,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Диаграмма категорий
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Распределение по категориям',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartData(data.categoryStats),
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Список категорий
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Детали по категориям',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...data.categoryStats.entries.map(
                      (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.categoryColors[entry.key] ??
                                Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.key)),
                        Text(
                          '${entry.value} продуктов',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartData(Map<String, int> stats) {
    final total = stats.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return [];

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.amber,
      Colors.cyan,
      Colors.grey,
    ];

    int colorIndex = 0;
    return stats.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: colors[colorIndex++ % colors.length],
        value: percentage,
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 30),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final int count;
  final int total;
  final String label;
  final Color color;

  const _StatusIndicator({
    required this.count,
    required this.total,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100).toInt() : 0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: total > 0 ? count / total : 0,
                strokeWidth: 8,
                color: color,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}