import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants.dart';
import '../../auth/auth_cubit.dart';
import '../cubit/fridge_cubit.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/shopping_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              context.go('/auth');
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистка данных'),
        content: const Text(
          'Это действие удалит все продукты, список покупок и сбросит настройки. Действие необратимо.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final fridgeCubit = context.read<FridgeCubit>();
              final shoppingCubit = context.read<ShoppingCubit>();
              final settingsCubit = context.read<SettingsCubit>();

              await fridgeCubit.clearAll();
              await shoppingCubit.clearAll();
              await settingsCubit.resetToDefaults();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Все данные очищены'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Очистить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Виртуальный холодильник',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Версия: ${AppConstants.appVersion}'),
            Text('Разработчик: ${AppConstants.developer}'),
            const SizedBox(height: 8),
            const Text(
              'Приложение для учета продуктов, контроля сроков годности и отслеживания калорийности.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(String mode) {
    switch (mode) {
      case 'light':
        return 'Светлая тема';
      case 'dark':
        return 'Темная тема';
      case 'system':
      default:
        return 'Системная тема';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Настройки'),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              if (state.errorMessage != null) ...[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],

              // Раздел аккаунта
              _SettingsSection(
                title: 'Аккаунт',
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Профиль'),
                    subtitle: const Text('Изменить данные профиля'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Безопасность'),
                    subtitle: const Text('Изменить пароль'),
                    onTap: () {},
                  ),
                ],
              ),

              // Раздел уведомлений
              _SettingsSection(
                title: 'Уведомления',
                children: [
                  SwitchListTile(
                    title: const Text('Напоминания о сроке годности'),
                    subtitle: const Text('Уведомлять за 3 дня до истечения срока'),
                    value: state.expiryNotifications,
                    onChanged: (value) => context
                        .read<SettingsCubit>()
                        .toggleExpiryNotifications(value),
                  ),
                  SwitchListTile(
                    title: const Text('Ежедневные отчеты'),
                    subtitle: const Text('Отправлять отчет о потребленных калориях'),
                    value: state.dailyReports,
                    onChanged: (value) =>
                        context.read<SettingsCubit>().toggleDailyReports(value),
                  ),
                ],
              ),

              // Раздел приложения
              _SettingsSection(
                title: 'Приложение',
                children: [
                  SwitchListTile(
                    title: const Text('Автоматический список покупок'),
                    subtitle:
                        const Text('Автоматически добавлять недостающие продукты'),
                    value: state.autoGenerateShoppingList,
                    onChanged: (value) => context
                        .read<SettingsCubit>()
                        .toggleAutoGenerateShoppingList(value),
                  ),
                  ListTile(
                    title: const Text('Единицы измерения'),
                    subtitle: Text(state.measurementSystem == 'metric'
                        ? 'Метрическая система'
                        : 'Имперская система'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Единицы измерения'),
                          content: RadioGroup<String>(
                            groupValue: state.measurementSystem,
                            onChanged: (value) {
                              if (value == null) return;
                              context.read<SettingsCubit>().setMeasurementSystem(value);
                              Navigator.pop(context);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                RadioListTile<String>(
                                  title: Text('Метрическая система'),
                                  subtitle: Text('г, кг, мл, л'),
                                  value: 'metric',
                                ),
                                RadioListTile<String>(
                                  title: Text('Имперская система'),
                                  subtitle: Text('oz, lb, fl oz, pt'),
                                  value: 'imperial',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Тема приложения'),
                    subtitle: Text(_getThemeModeText(state.themeMode)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Тема приложения'),
                          content: RadioGroup<String>(
                            groupValue: state.themeMode,
                            onChanged: (value) {
                              if (value == null) return;
                              context.read<SettingsCubit>().setThemeMode(value);
                              Navigator.pop(context);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                RadioListTile<String>(
                                  title: Text('Светлая тема'),
                                  value: 'light',
                                ),
                                RadioListTile<String>(
                                  title: Text('Темная тема'),
                                  value: 'dark',
                                ),
                                RadioListTile<String>(
                                  title: Text('Системная тема'),
                                  subtitle: Text('Следовать настройкам системы'),
                                  value: 'system',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Раздел данных
              _SettingsSection(
                title: 'Данные',
                children: [
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Резервное копирование'),
                    subtitle: const Text('Создать резервную копию данных'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Резервная копия создана'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Восстановление'),
                    subtitle: const Text('Восстановить данные из копии'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Очистить все данные'),
                    subtitle: const Text('Удалить все продукты и настройки'),
                    onTap: () => _showClearDataDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.restart_alt),
                    title: const Text('Сбросить дневные калории'),
                    subtitle: const Text('Обнулить счетчик калорий за сегодня'),
                    onTap: () async {
                      await context.read<FridgeCubit>().resetDailyCalories();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Дневные калории сброшены'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              // Раздел информации
              _SettingsSection(
                title: 'Информация',
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('О приложении'),
                    subtitle: Text('Версия ${AppConstants.appVersion}'),
                    onTap: () => _showAboutDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Справка'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.bug_report),
                    title: const Text('Сообщить об ошибке'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.rate_review),
                    title: const Text('Оценить приложение'),
                    onTap: () {},
                  ),
                ],
              ),

              // Кнопка выхода
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Выйти из аккаунта'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}