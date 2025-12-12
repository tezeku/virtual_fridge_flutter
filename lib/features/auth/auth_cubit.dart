import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.initial());

  Future<void> login(String username, String password) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Демо-логика: любой непустой логин/пароль
      if (username.isNotEmpty && password.isNotEmpty) {
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
}