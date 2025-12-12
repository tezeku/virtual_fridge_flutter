class AuthState {
  final bool isAuthenticated;
  final String? username;
  final bool isLoading;
  final String errorMessage;

  const AuthState({
    required this.isAuthenticated,
    this.username,
    required this.isLoading,
    required this.errorMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      username: null,
      isLoading: false,
      errorMessage: '',
    );
  }

  factory AuthState.authenticated({required String username}) {
    return AuthState(
      isAuthenticated: true,
      username: username,
      isLoading: false,
      errorMessage: '',
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    String? username,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}