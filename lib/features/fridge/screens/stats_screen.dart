import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/constants.dart';
import '../models/product.dart';
import '../widgets/calories_chart.dart';
import '../fridge_data_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = FridgeDataProvider.of(context);

    if (provider == null) {
      return const Scaffold(
        body: Center(child: Text('Провайдер данных не найден')),
      );
    }

    final products = provider.products;
    final dailyCalories = provider.dailyCalories;

    if (products.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Статистика'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Нет данных для статистики'),
              Text('Добавьте продукты в холодильник'),
            ],
          ),
        ),
      );
    }

    final categoryStats = _calculateCategoryStats(products);
    final expiredCount = products.where((p) => p.isExpired).length;
    final expiringCount = products.where((p) => p.isExpiringSoon).length;
    final freshCount = products.length - expiredCount - expiringCount;
    final weeklyCalories = _getWeeklyCaloriesData(products);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Статистика'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Общая статистика
          Card(
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
                        value: products.length.toString(),
                        icon: Icons.shopping_basket,
                      ),
                      _StatItem(
                        label: 'Сегодня калорий',
                        value: dailyCalories.toStringAsFixed(0),
                        icon: Icons.local_fire_department,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatItem(
                        label: 'Свежих',
                        value: freshCount.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      _StatItem(
                        label: 'Истекают',
                        value: expiringCount.toString(),
                        icon: Icons.warning,
                        color: Colors.orange,
                      ),
                      _StatItem(
                        label: 'Просрочено',
                        value: expiredCount.toString(),
                        icon: Icons.error,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // График калорий
          Card(
            child: CaloriesChart(
              caloriesData: weeklyCalories,
              chartColor: Colors.orange,
            ),
          ),

          const SizedBox(height: 20),

          // Диаграмма категорий
          Card(
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
                        sections: _buildPieChartData(categoryStats, products),
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
                  ...categoryStats.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(entry.key)),
                        Text('${entry.value} продуктов'),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateCategoryStats(List<Product> products) {
    final Map<String, int> stats = {};
    for (final category in AppConstants.categories) {
      stats[category] = 0;
    }

    for (final product in products) {
      stats[product.category] = (stats[product.category] ?? 0) + 1;
    }

    return stats;
  }

  List<PieChartSectionData> _buildPieChartData(Map<String, int> stats, List<Product> products) {
    final total = products.length;
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
    return stats.entries.where((entry) => entry.value > 0).map((entry) {
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

  List<double> _getWeeklyCaloriesData(List<Product> products) {
    // Демо-данные для графика (последние 7 дней)
    return [1200, 1400, 1800, 1600, 2000, 1700, 1560];
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
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