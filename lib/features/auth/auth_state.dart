import '../../shared/constants.dart';

class AuthState {
  final bool isAuthenticated;
  final String? username;
  final bool isLoading;
  final String errorMessage;
  final DateTime? authExpiryTime;

  const AuthState({
    required this.isAuthenticated,
    this.username,
    required this.isLoading,
    required this.errorMessage,
    this.authExpiryTime,
  });

  bool get isSessionValid {
    if (!isAuthenticated || authExpiryTime == null) return false;
    return DateTime.now().isBefore(authExpiryTime!);
  }

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      username: null,
      isLoading: false,
      errorMessage: '',
      authExpiryTime: null,
    );
  }

  factory AuthState.authenticated({
    required String username,
    Duration sessionDuration = AppConstants.defaultSessionDuration,
  }) {
    return AuthState(
      isAuthenticated: true,
      username: username,
      isLoading: false,
      errorMessage: '',
      authExpiryTime: DateTime.now().add(sessionDuration),
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    String? username,
    bool? isLoading,
    String? errorMessage,
    DateTime? authExpiryTime,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      authExpiryTime: authExpiryTime ?? this.authExpiryTime,
    );
  }

  @override
  String toString() {
    return 'AuthState{isAuthenticated: $isAuthenticated, username: $username, isLoading: $isLoading}';
  }
}