import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.initial());

  static final Map<String, String> _demoUsers = {
    'demo': 'demo123',
    'admin': 'admin123',
    'user': 'user123',
  };

  Future<void> login(String username, String password) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (_demoUsers.containsKey(username) &&
          _demoUsers[username] == password) {
        emit(AuthState.authenticated(username: username));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Неверный логин или пароль',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка соединения',
      ));
    }
  }

  void logout() {
    emit(AuthState.initial());
  }

  void clearError() {
    emit(state.copyWith(errorMessage: ''));
  }

  bool isSessionValid() {
    return state.isSessionValid;
  }
}