import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Раздел уведомлений
          _SettingsSection(
            title: 'Уведомления',
            children: [
              SwitchListTile(
                title: const Text('Напоминания о сроке годности'),
                subtitle: const Text('Уведомлять за 3 дня до истечения срока'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Ежедневные отчеты'),
                subtitle: const Text('Отправлять отчет о потребленных калориях'),
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),

          // Раздел единиц измерения
          _SettingsSection(
            title: 'Единицы измерения',
            children: [
              RadioListTile<String>(
                title: const Text('Метрическая система'),
                subtitle: const Text('г, кг, мл, л'),
                value: 'metric',
                groupValue: 'metric',
                onChanged: (value) {},
              ),
              RadioListTile<String>(
                title: const Text('Имперская система'),
                subtitle: const Text('oz, lb, fl oz, pt'),
                value: 'imperial',
                groupValue: 'metric',
                onChanged: (value) {},
              ),
            ],
          ),

          // Раздел темы
          _SettingsSection(
            title: 'Внешний вид',
            children: [
              RadioListTile<String>(
                title: const Text('Светлая тема'),
                value: 'light',
                groupValue: 'light',
                onChanged: (value) {},
              ),
              RadioListTile<String>(
                title: const Text('Темная тема'),
                value: 'dark',
                groupValue: 'light',
                onChanged: (value) {},
              ),
              RadioListTile<String>(
                title: const Text('Системная тема'),
                subtitle: const Text('Следовать настройкам системы'),
                value: 'system',
                groupValue: 'light',
                onChanged: (value) {},
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
                onTap: () {},
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
                onTap: () {
                  _showClearDataDialog(context);
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
                subtitle: const Text('Версия 1.0.0'),
                onTap: () {
                  _showAboutDialog(context);
                },
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
            ],
          ),

          // Кнопка выхода
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                _showLogoutDialog(context);
              },
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
        content: const Text('Это действие удалит все продукты и настройки. '
            'Действие необратимо.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Здесь будет логика очистки данных
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
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Виртуальный холодильник'),
            SizedBox(height: 8),
            Text('Версия: 1.0.0'),
            Text('Разработчик: Кузюхин А.В.'),
            SizedBox(height: 8),
            Text('Приложение для учета продуктов, контроля сроков '
                'годности и отслеживания калорийности.'),
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