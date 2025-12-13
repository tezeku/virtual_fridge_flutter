import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/app_colors.dart';
import '../widgets/calories_chart.dart';
import '../fridge_data_provider.dart';
import '../cubit/stats_cubit.dart';

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

    return BlocProvider(
      create: (context) => StatsCubit(
        products: provider.products,
        dailyCalories: provider.dailyCalories,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Статистика'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final cubit = context.read<StatsCubit>();
                cubit.refreshStats(
                  products: provider.products,
                  dailyCalories: provider.dailyCalories,
                );
              },
              tooltip: 'Обновить статистику',
            ),
          ],
        ),
        body: BlocBuilder<StatsCubit, StatsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (provider.products.isEmpty) {
              return Center(
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
              );
            }

            return _StatsContent(state: state);
          },
        ),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final StatsState state;

  const _StatsContent({required this.state});

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
                      value: (state.expiredCount +
                          state.expiringSoonCount +
                          state.freshCount)
                          .toString(),
                      icon: Icons.shopping_basket,
                    ),
                    _StatItem(
                      label: 'Сегодня калорий',
                      value: state.dailyCalories.toStringAsFixed(0),
                      icon: Icons.local_fire_department,
                    ),
                    _StatItem(
                      label: 'Общие калории',
                      value: state.totalCalories.toStringAsFixed(0),
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
          caloriesData: state.weeklyCalories,
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
                      count: state.freshCount,
                      total: state.expiredCount +
                          state.expiringSoonCount +
                          state.freshCount,
                      label: 'Свежие',
                      color: AppColors.normal,
                    ),
                    _StatusIndicator(
                      count: state.expiringSoonCount,
                      total: state.expiredCount +
                          state.expiringSoonCount +
                          state.freshCount,
                      label: 'Истекают',
                      color: AppColors.expiringSoon,
                    ),
                    _StatusIndicator(
                      count: state.expiredCount,
                      total: state.expiredCount +
                          state.expiringSoonCount +
                          state.freshCount,
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
                      sections: _buildPieChartData(state.categoryStats),
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
                ...state.categoryStats.entries.map(
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