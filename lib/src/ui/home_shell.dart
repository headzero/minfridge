import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dialogs.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'today_page.dart';
import 'widgets/common.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _select(int value) => setState(() => _index = value);

  @override
  Widget build(BuildContext context) {
    // 홈/오늘추천에만 배너 노출 (히스토리·설정은 미노출).
    final showBanner = _index == 0 || _index == 1;

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _onWillPop();
        if (shouldExit && mounted) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: IndexedStack(
                index: _index,
                children: <Widget>[
                  HomePage(onOpenToday: () => _select(1)),
                  const TodayPage(),
                  const HistoryPage(),
                  const SettingsPage(),
                ],
              ),
            ),
            if (showBanner) const SafeArea(top: false, child: AdBanner()),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.kitchen_outlined), selectedIcon: Icon(Icons.kitchen), label: '홈'),
            NavigationDestination(icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu), label: '오늘 추천'),
            NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: '히스토리'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '설정'),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_index != 0) {
      _select(0);
      return false;
    }
    return showSatisfactionDialog(context);
  }
}
