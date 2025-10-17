import 'package:flutter/material.dart';

import 'features/fridge/fridge_container.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Виртуальный холодильник',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const FridgeContainer(),
        debugShowCheckedModeBanner: false
    );
  }
}