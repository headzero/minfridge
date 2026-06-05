import 'package:flutter/material.dart';

import 'minfridge_colors.dart';

/// 하루한칸 디자인 시스템 테마. (DESIGN_SPEC §1, §3)
///
/// 폰트는 Pretendard 권장이나, 폰트 파일이 레포에 포함되어 있지 않아 현재는
/// 시스템 기본 폰트로 폴백한다. `assets/fonts/`에 Pretendard를 추가하고
/// `pubspec.yaml`에 등록한 뒤 아래 `_fontFamily`를 'Pretendard'로 바꾸면 적용된다.
class MinfridgeTheme {
  static const String? _fontFamily = null;

  static ThemeData light() => _build(
    brightness: Brightness.light,
    ext: MinfridgeColors.light,
    scheme: const ColorScheme.light(
      primary: Color(0xFF6BA830),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE9F3D6),
      onPrimaryContainer: Color(0xFF46751A),
      secondary: Color(0xFF6BA830),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF27301C),
      onSurfaceVariant: Color(0xFF8A9479),
      surfaceContainerLowest: Color(0xFFF6FAEE),
      surfaceContainerHigh: Color(0xFFEDF4DF),
      outline: Color(0xFFCBD7B4),
      outlineVariant: Color(0xFFE3ECD2),
      error: Color(0xFFD6453A),
    ),
    scaffold: const Color(0xFFF6FAEE),
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    ext: MinfridgeColors.dark,
    scheme: const ColorScheme.dark(
      primary: Color(0xFF9BD15E),
      onPrimary: Color(0xFF14180F),
      primaryContainer: Color(0xFF2A3A16),
      onPrimaryContainer: Color(0xFFC7E89A),
      secondary: Color(0xFF9BD15E),
      onSecondary: Color(0xFF14180F),
      surface: Color(0xFF1D2316),
      onSurface: Color(0xFFECF1E2),
      onSurfaceVariant: Color(0xFF8E997E),
      surfaceContainerLowest: Color(0xFF14180F),
      surfaceContainerHigh: Color(0xFF272E1E),
      outline: Color(0xFF333B27),
      outlineVariant: Color(0xFF333B27),
      error: Color(0xFFE85F52),
    ),
    scaffold: const Color(0xFF14180F),
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required MinfridgeColors ext,
    required Color scaffold,
  }) {
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: scaffold,
    );
    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[ext],
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),
      dividerTheme: DividerThemeData(color: ext.lineSoft, thickness: 1, space: 1),
    );
  }
}
