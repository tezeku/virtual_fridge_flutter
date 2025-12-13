import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/auth_cubit.dart';
import 'features/fridge/fridge_container.dart';
import 'features/fridge/screens/stats_screen.dart';
import 'features/fridge/screens/shopping_screen.dart';
import 'features/fridge/screens/settings_screen.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: '/auth',
      redirect: (context, state) {
        final authCubit = context.read<AuthCubit>();
        final isAuthenticated = authCubit.state.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/auth';

        if (!isAuthenticated && !isAuthRoute) {
          return '/auth';
        }

        if (isAuthenticated && isAuthRoute) {
          return '/fridge';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/auth',
          name: 'auth',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AuthScreen(),
          ),
        ),
        GoRoute(
          path: '/fridge',
          name: 'fridge',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const FridgeContainer(),
          ),
          routes: [
            GoRoute(
              path: 'stats',
              name: 'stats',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: const StatsScreen(),
              ),
            ),
            GoRoute(
              path: 'shopping',
              name: 'shopping',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: const ShoppingScreen(),
              ),
            ),
            GoRoute(
              path: 'settings',
              name: 'settings',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: const SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Страница не найдена', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/fridge'),
                child: const Text('Вернуться в холодильник'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}