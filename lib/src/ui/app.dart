import 'package:flutter/material.dart';

import 'home_shell.dart';
import 'theme/minfridge_theme.dart';

class MinFridgeApp extends StatelessWidget {
  const MinFridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MINFRIDGE',
      debugShowCheckedModeBanner: false,
      theme: MinfridgeTheme.light(),
      darkTheme: MinfridgeTheme.dark(),
      themeMode: ThemeMode.light,
      home: const HomeShell(),
    );
  }
}
