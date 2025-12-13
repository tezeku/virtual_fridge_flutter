class AppConstants {
  static const String appName = 'Виртуальный холодильник';
  static const String appVersion = '1.1.0';
  static const String developer = 'Кузюхин А.В.';

  static const List<String> categories = [
    'Молочные продукты',
    'Овощи',
    'Фрукты',
    'Мясо',
    'Рыба',
    'Бакалея',
    'Напитки',
    'Другое'
  ];

  static const List<String> units = ['г', 'кг', 'мл', 'л', 'шт'];

  static const List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  static const int expiryWarningDays = 3;
  static const Duration defaultSessionDuration = Duration(hours: 1);
  static const Duration defaultProductExpiry = Duration(days: 7);
}