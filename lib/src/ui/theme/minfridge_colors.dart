import 'package:flutter/material.dart';

import '../../models/food_item.dart';

/// 신선도 단계 (의미 고정 — 톤과 무관).
enum Freshness { fresh, caution, soon, urgent }

/// 신선도/끼니용 3색 묶음.
@immutable
class ToneSet {
  const ToneSet({required this.main, required this.tint, required this.ink});

  final Color main;
  final Color tint;
  final Color ink;

  static ToneSet lerp(ToneSet a, ToneSet b, double t) {
    return ToneSet(
      main: Color.lerp(a.main, b.main, t)!,
      tint: Color.lerp(a.tint, b.tint, t)!,
      ink: Color.lerp(a.ink, b.ink, t)!,
    );
  }
}

/// 디자인 토큰 중 `ColorScheme`에 없는 색(신선도·보관·끼니·게이지)을 담는 테마 확장.
/// 위젯에서는 `Theme.of(context).extension<MinfridgeColors>()!` 로 읽는다.
@immutable
class MinfridgeColors extends ThemeExtension<MinfridgeColors> {
  const MinfridgeColors({
    required this.fresh,
    required this.caution,
    required this.soon,
    required this.urgent,
    required this.frost,
    required this.gaugeOk,
    required this.gaugeOver,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.sunken,
    required this.lineSoft,
  });

  final ToneSet fresh;
  final ToneSet caution;
  final ToneSet soon;
  final ToneSet urgent;
  final ToneSet frost;
  final Color gaugeOk;
  final Color gaugeOver;
  final ToneSet breakfast;
  final ToneSet lunch;
  final ToneSet dinner;
  final Color sunken;
  final Color lineSoft;

  ToneSet freshnessTone(Freshness f) {
    switch (f) {
      case Freshness.fresh:
        return fresh;
      case Freshness.caution:
        return caution;
      case Freshness.soon:
        return soon;
      case Freshness.urgent:
        return urgent;
    }
  }

  ToneSet mealTone(String meal) {
    switch (meal) {
      case 'lunch':
        return lunch;
      case 'dinner':
        return dinner;
      default:
        return breakfast;
    }
  }

  static const MinfridgeColors light = MinfridgeColors(
    fresh: ToneSet(main: Color(0xFF3F9163), tint: Color(0xFFE7F1EA), ink: Color(0xFF2C6B45)),
    caution: ToneSet(main: Color(0xFFCD9A1C), tint: Color(0xFFFAF0D2), ink: Color(0xFF856212)),
    soon: ToneSet(main: Color(0xFFE97E2B), tint: Color(0xFFFCE8D5), ink: Color(0xFF9C4F12)),
    urgent: ToneSet(main: Color(0xFFD6453A), tint: Color(0xFFFBE1DD), ink: Color(0xFF9C2A22)),
    frost: ToneSet(main: Color(0xFF3E7CC2), tint: Color(0xFFE6EFF8), ink: Color(0xFF2A5A94)),
    gaugeOk: Color(0xFF5DA72C),
    gaugeOver: Color(0xFFE97E2B),
    breakfast: ToneSet(main: Color(0xFFE59A3C), tint: Color(0xFFFCEFE0), ink: Color(0xFF9C6A2A)),
    lunch: ToneSet(main: Color(0xFF5BA46B), tint: Color(0xFFE9F1E7), ink: Color(0xFF3E7A4E)),
    dinner: ToneSet(main: Color(0xFF7E6FB8), tint: Color(0xFFECE8F3), ink: Color(0xFF5A4E86)),
    sunken: Color(0xFFEDF4DF),
    lineSoft: Color(0xFFECF2E1),
  );

  static const MinfridgeColors dark = MinfridgeColors(
    fresh: ToneSet(main: Color(0xFF5FB985), tint: Color(0xFF1E3326), ink: Color(0xFFB7E0C6)),
    caution: ToneSet(main: Color(0xFFE0B43A), tint: Color(0xFF352B12), ink: Color(0xFFE8CE7E)),
    soon: ToneSet(main: Color(0xFFF0913F), tint: Color(0xFF3A2613), ink: Color(0xFFF3BE8C)),
    urgent: ToneSet(main: Color(0xFFE85F52), tint: Color(0xFF3A1E1A), ink: Color(0xFFF0A79E)),
    frost: ToneSet(main: Color(0xFF6BA6E0), tint: Color(0xFF16263A), ink: Color(0xFFA9CCEC)),
    gaugeOk: Color(0xFF9BD15E),
    gaugeOver: Color(0xFFF0913F),
    breakfast: ToneSet(main: Color(0xFFE59A3C), tint: Color(0xFF332714), ink: Color(0xFFE8C290)),
    lunch: ToneSet(main: Color(0xFF5BA46B), tint: Color(0xFF1E2E20), ink: Color(0xFFA9D2B2)),
    dinner: ToneSet(main: Color(0xFF7E6FB8), tint: Color(0xFF272238), ink: Color(0xFFC4BAE2)),
    sunken: Color(0xFF272E1E),
    lineSoft: Color(0xFF2C3422),
  );

  @override
  MinfridgeColors copyWith({
    ToneSet? fresh,
    ToneSet? caution,
    ToneSet? soon,
    ToneSet? urgent,
    ToneSet? frost,
    Color? gaugeOk,
    Color? gaugeOver,
    ToneSet? breakfast,
    ToneSet? lunch,
    ToneSet? dinner,
    Color? sunken,
    Color? lineSoft,
  }) {
    return MinfridgeColors(
      fresh: fresh ?? this.fresh,
      caution: caution ?? this.caution,
      soon: soon ?? this.soon,
      urgent: urgent ?? this.urgent,
      frost: frost ?? this.frost,
      gaugeOk: gaugeOk ?? this.gaugeOk,
      gaugeOver: gaugeOver ?? this.gaugeOver,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      sunken: sunken ?? this.sunken,
      lineSoft: lineSoft ?? this.lineSoft,
    );
  }

  @override
  MinfridgeColors lerp(ThemeExtension<MinfridgeColors>? other, double t) {
    if (other is! MinfridgeColors) {
      return this;
    }
    return MinfridgeColors(
      fresh: ToneSet.lerp(fresh, other.fresh, t),
      caution: ToneSet.lerp(caution, other.caution, t),
      soon: ToneSet.lerp(soon, other.soon, t),
      urgent: ToneSet.lerp(urgent, other.urgent, t),
      frost: ToneSet.lerp(frost, other.frost, t),
      gaugeOk: Color.lerp(gaugeOk, other.gaugeOk, t)!,
      gaugeOver: Color.lerp(gaugeOver, other.gaugeOver, t)!,
      breakfast: ToneSet.lerp(breakfast, other.breakfast, t),
      lunch: ToneSet.lerp(lunch, other.lunch, t),
      dinner: ToneSet.lerp(dinner, other.dinner, t),
      sunken: Color.lerp(sunken, other.sunken, t)!,
      lineSoft: Color.lerp(lineSoft, other.lineSoft, t)!,
    );
  }
}

/// 신선도 판정 (DESIGN_SPEC §4). 유통기한 우선, 없으면 보관일수 기반.
Freshness freshnessOf(FoodItem item) {
  final d = item.daysUntilExpiry;
  if (d != null) {
    if (d <= 1) return Freshness.urgent;
    if (d <= 3) return Freshness.soon;
    if (d <= 7) return Freshness.caution;
    return Freshness.fresh;
  }
  final s = item.storageDays;
  if (s <= 3) return Freshness.fresh;
  if (s <= 14) return Freshness.caution;
  if (s <= 28) return Freshness.soon;
  return Freshness.urgent;
}

String ddayLabel(int d) {
  if (d < 0) return '지남';
  if (d == 0) return 'D-day';
  return 'D-$d';
}

/// 급한 순 정렬 가중치 (위급=0 … 여유=3).
int freshnessRank(Freshness f) {
  switch (f) {
    case Freshness.urgent:
      return 0;
    case Freshness.soon:
      return 1;
    case Freshness.caution:
      return 2;
    case Freshness.fresh:
      return 3;
  }
}
