import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsState {
  final bool expiryNotifications;
  final bool dailyReports;
  final String measurementSystem;
  final String themeMode;
  final String? errorMessage;
  final bool isLoading;

  const SettingsState({
    required this.expiryNotifications,
    required this.dailyReports,
    required this.measurementSystem,
    required this.themeMode,
    this.errorMessage,
    required this.isLoading,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      expiryNotifications: true,
      dailyReports: false,
      measurementSystem: 'metric',
      themeMode: 'system',
      errorMessage: null,
      isLoading: false,
    );
  }

  SettingsState copyWith({
    bool? expiryNotifications,
    bool? dailyReports,
    String? measurementSystem,
    String? themeMode,
    String? errorMessage,
    bool? isLoading,
  }) {
    return SettingsState(
      expiryNotifications: expiryNotifications ?? this.expiryNotifications,
      dailyReports: dailyReports ?? this.dailyReports,
      measurementSystem: measurementSystem ?? this.measurementSystem,
      themeMode: themeMode ?? this.themeMode,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState.initial());

  void toggleExpiryNotifications(bool value) {
    emit(state.copyWith(expiryNotifications: value));
  }

  void toggleDailyReports(bool value) {
    emit(state.copyWith(dailyReports: value));
  }

  void setMeasurementSystem(String system) {
    if (system != 'metric' && system != 'imperial') {
      emit(state.copyWith(
        errorMessage: 'Некорректная система измерения',
      ));
      return;
    }
    emit(state.copyWith(measurementSystem: system));
  }

  void setThemeMode(String mode) {
    if (mode != 'light' && mode != 'dark' && mode != 'system') {
      emit(state.copyWith(
        errorMessage: 'Некорректный режим темы',
      ));
      return;
    }
    emit(state.copyWith(themeMode: mode));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void resetToDefaults() {
    emit(SettingsState.initial());
  }
}