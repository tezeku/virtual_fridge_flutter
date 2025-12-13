import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_router.dart';
import 'features/auth/auth_cubit.dart';
import 'features/fridge/cubit/fridge_cubit.dart';
import 'features/fridge/cubit/settings_cubit.dart';
import 'features/fridge/cubit/shopping_cubit.dart';

class VirtualFridgeApp extends StatelessWidget {
  const VirtualFridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => FridgeCubit()..init()),
        BlocProvider(create: (_) => ShoppingCubit()..init()),
        BlocProvider(create: (_) => SettingsCubit()..init()),
      ],
      child: MaterialApp.router(
        title: 'Виртуальный холодильник',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
        ),
        routerConfig: AppRouter().router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
