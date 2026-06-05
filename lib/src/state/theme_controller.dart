import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 테마 모드(시스템/라이트/다크)를 보관·영속화한다.
class ThemeController extends ChangeNotifier {
  ThemeController({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _prefsKey = 'mf_theme_mode';

  SharedPreferences? _prefs;
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  /// 저장된 테마 모드를 불러온다. 앱 시작 시 1회 호출.
  Future<void> load() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    _mode = _parse(prefs.getString(_prefsKey));
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) {
      return;
    }
    _mode = mode;
    notifyListeners();
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  ThemeMode _parse(String? raw) {
    for (final mode in ThemeMode.values) {
      if (mode.name == raw) {
        return mode;
      }
    }
    return ThemeMode.light;
  }
}
