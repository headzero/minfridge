import 'package:flutter/material.dart';

import 'home_shell.dart';

class MinFridgeApp extends StatelessWidget {
  const MinFridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MINFRIDGE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}
