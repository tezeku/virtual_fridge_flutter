import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool expiryNotifications;
  final bool dailyReports;
  final String measurementSystem;
  final String themeMode;
  final bool autoGenerateShoppingList;
  final String? errorMessage;
  final bool isLoading;

  const SettingsState({
    required this.expiryNotifications,
    required this.dailyReports,
    required this.measurementSystem,
    required this.themeMode,
    required this.autoGenerateShoppingList,
    required this.isLoading,
    this.errorMessage,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      expiryNotifications: true,
      dailyReports: false,
      measurementSystem: 'metric',
      themeMode: 'system',
      autoGenerateShoppingList: true,
      errorMessage: null,
      isLoading: true,
    );
  }

  SettingsState copyWith({
    bool? expiryNotifications,
    bool? dailyReports,
    String? measurementSystem,
    String? themeMode,
    bool? autoGenerateShoppingList,
    String? errorMessage,
    bool? isLoading,
  }) {
    return SettingsState(
      expiryNotifications: expiryNotifications ?? this.expiryNotifications,
      dailyReports: dailyReports ?? this.dailyReports,
      measurementSystem: measurementSystem ?? this.measurementSystem,
      themeMode: themeMode ?? this.themeMode,
      autoGenerateShoppingList:
          autoGenerateShoppingList ?? this.autoGenerateShoppingList,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  static const _kExpiryNotificationsKey = 'settings_expiry_notifications_v1';
  static const _kDailyReportsKey = 'settings_daily_reports_v1';
  static const _kMeasurementSystemKey = 'settings_measurement_system_v1';
  static const _kThemeModeKey = 'settings_theme_mode_v1';
  static const _kAutoShoppingKey = 'settings_auto_shopping_list_v1';

  SettingsCubit() : super(SettingsState.initial());

  Future<void> init() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final prefs = await SharedPreferences.getInstance();

      emit(SettingsState(
        expiryNotifications:
            prefs.getBool(_kExpiryNotificationsKey) ?? true,
        dailyReports: prefs.getBool(_kDailyReportsKey) ?? false,
        measurementSystem:
            prefs.getString(_kMeasurementSystemKey) ?? 'metric',
        themeMode: prefs.getString(_kThemeModeKey) ?? 'system',
        autoGenerateShoppingList: prefs.getBool(_kAutoShoppingKey) ?? true,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Не удалось загрузить настройки: $e',
      ));
    }
  }

  Future<void> toggleExpiryNotifications(bool value) async {
    emit(state.copyWith(expiryNotifications: value, errorMessage: null));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kExpiryNotificationsKey, value);
  }

  Future<void> toggleDailyReports(bool value) async {
    emit(state.copyWith(dailyReports: value, errorMessage: null));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDailyReportsKey, value);
  }

  Future<void> setMeasurementSystem(String system) async {
    if (system != 'metric' && system != 'imperial') {
      emit(state.copyWith(errorMessage: 'Некорректная система измерения'));
      return;
    }
    emit(state.copyWith(measurementSystem: system, errorMessage: null));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMeasurementSystemKey, system);
  }

  Future<void> setThemeMode(String mode) async {
    if (mode != 'light' && mode != 'dark' && mode != 'system') {
      emit(state.copyWith(errorMessage: 'Некорректный режим темы'));
      return;
    }
    emit(state.copyWith(themeMode: mode, errorMessage: null));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode);
  }

  Future<void> toggleAutoGenerateShoppingList(bool value) async {
    emit(state.copyWith(autoGenerateShoppingList: value, errorMessage: null));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoShoppingKey, value);
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  Future<void> resetToDefaults() async {
    const defaults = SettingsState(
      expiryNotifications: true,
      dailyReports: false,
      measurementSystem: 'metric',
      themeMode: 'system',
      autoGenerateShoppingList: true,
      errorMessage: null,
      isLoading: false,
    );

    emit(defaults);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kExpiryNotificationsKey, defaults.expiryNotifications);
    await prefs.setBool(_kDailyReportsKey, defaults.dailyReports);
    await prefs.setString(_kMeasurementSystemKey, defaults.measurementSystem);
    await prefs.setString(_kThemeModeKey, defaults.themeMode);
    await prefs.setBool(_kAutoShoppingKey, defaults.autoGenerateShoppingList);
  }
}
