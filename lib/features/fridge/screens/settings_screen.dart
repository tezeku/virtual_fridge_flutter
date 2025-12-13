import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants.dart';
import '../../auth/auth_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _expiryNotifications = true;
  bool _dailyReports = false;
  String _measurementSystem = 'metric';
  String _themeMode = 'system';
  bool _autoGenerateShoppingList = true;

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
            'Это действие удалит все продукты и настройки. Действие необратимо.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // Здесь будет логика очистки данных
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

  @override
  Widget build(BuildContext context) {
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
                value: _expiryNotifications,
                onChanged: (value) =>
                    setState(() => _expiryNotifications = value),
              ),
              SwitchListTile(
                title: const Text('Ежедневные отчеты'),
                subtitle: const Text('Отправлять отчет о потребленных калориях'),
                value: _dailyReports,
                onChanged: (value) => setState(() => _dailyReports = value),
              ),
            ],
          ),

          // Раздел приложения
          _SettingsSection(
            title: 'Приложение',
            children: [
              SwitchListTile(
                title: const Text('Автоматический список покупок'),
                subtitle: const Text('Автоматически добавлять недостающие продукты'),
                value: _autoGenerateShoppingList,
                onChanged: (value) =>
                    setState(() => _autoGenerateShoppingList = value),
              ),
              ListTile(
                title: const Text('Единицы измерения'),
                subtitle: Text(_measurementSystem == 'metric'
                    ? 'Метрическая система'
                    : 'Имперская система'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Единицы измерения'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<String>(
                            title: const Text('Метрическая система'),
                            subtitle: const Text('г, кг, мл, л'),
                            value: 'metric',
                            groupValue: _measurementSystem,
                            onChanged: (value) {
                              setState(() => _measurementSystem = value!);
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Имперская система'),
                            subtitle: const Text('oz, lb, fl oz, pt'),
                            value: 'imperial',
                            groupValue: _measurementSystem,
                            onChanged: (value) {
                              setState(() => _measurementSystem = value!);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Тема приложения'),
                subtitle: Text(_getThemeModeText(_themeMode)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Тема приложения'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<String>(
                            title: const Text('Светлая тема'),
                            value: 'light',
                            groupValue: _themeMode,
                            onChanged: (value) {
                              setState(() => _themeMode = value!);
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Темная тема'),
                            value: 'dark',
                            groupValue: _themeMode,
                            onChanged: (value) {
                              setState(() => _themeMode = value!);
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Системная тема'),
                            subtitle: const Text('Следовать настройкам системы'),
                            value: 'system',
                            groupValue: _themeMode,
                            onChanged: (value) {
                              setState(() => _themeMode = value!);
                              Navigator.pop(context);
                            },
                          ),
                        ],
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
  }

  String _getThemeModeText(String mode) {
    switch (mode) {
      case 'light':
        return 'Светлая тема';
      case 'dark':
        return 'Темная тема';
      case 'system':
        return 'Системная тема';
      default:
        return 'Системная тема';
    }
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