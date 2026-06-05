import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/theme_controller.dart';
import 'home_shell.dart';
import 'theme/minfridge_theme.dart';

class MinFridgeApp extends StatelessWidget {
  const MinFridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeController?>()?.mode ?? ThemeMode.light;
    return MaterialApp(
      title: 'MINFRIDGE',
      debugShowCheckedModeBanner: false,
      theme: MinfridgeTheme.light(),
      darkTheme: MinfridgeTheme.dark(),
      themeMode: themeMode,
      home: const HomeShell(),
    );
  }
}
