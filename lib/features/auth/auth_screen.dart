import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'auth_cubit.dart';
import 'auth_state.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          context.go('/fridge');
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: _AuthForm(),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends StatefulWidget {
  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'demo');
  final _passwordController = TextEditingController(text: 'demo123');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const CircularProgressIndicator();
        }

        return Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Виртуальный холодильник',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Логин',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите логин';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  return null;
                },
              ),
              if (state.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthCubit>().login(
                        _usernameController.text,
                        _passwordController.text,
                      );
                    }
                  },
                  child: const Text('Войти'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Демо-доступ: логин: demo, пароль: demo123',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}