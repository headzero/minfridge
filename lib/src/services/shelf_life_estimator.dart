import '../models/food_item.dart';

/// 재료명/유형을 기반으로 예상 보관 가능 일수를 추정한다.
///
/// 사용자가 유통기한을 직접 입력하지 않아도 합리적인 기본값을 제공하기 위한
/// v1 정적 테이블이다. 추후 LLM 기반 추정으로 교체할 수 있다.
class ShelfLifeEstimator {
  const ShelfLifeEstimator();

  /// 키워드가 이름에 포함되면 해당 일수를 사용한다. 위에서부터 먼저 매칭된다.
  static const List<MapEntry<String, int>> _keywordDays = <MapEntry<String, int>>[
    MapEntry('생선', 2),
    MapEntry('회', 2),
    MapEntry('해물', 2),
    MapEntry('조개', 2),
    MapEntry('새우', 3),
    MapEntry('소고기', 3),
    MapEntry('돼지', 3),
    MapEntry('닭', 3),
    MapEntry('고기', 3),
    MapEntry('밥', 3),
    MapEntry('나물', 4),
    MapEntry('바나나', 5),
    MapEntry('상추', 5),
    MapEntry('시금치', 5),
    MapEntry('채소', 5),
    MapEntry('야채', 5),
    MapEntry('빵', 5),
    MapEntry('두부', 7),
    MapEntry('버섯', 7),
    MapEntry('우유', 10),
    MapEntry('토마토', 10),
    MapEntry('요거트', 14),
    MapEntry('요구르트', 14),
    MapEntry('당근', 21),
    MapEntry('사과', 21),
    MapEntry('계란', 21),
    MapEntry('달걀', 21),
    MapEntry('양파', 30),
    MapEntry('감자', 30),
    MapEntry('치즈', 30),
    MapEntry('마늘', 60),
    MapEntry('김치', 60),
    MapEntry('잼', 90),
    MapEntry('소스', 90),
    MapEntry('케첩', 90),
    MapEntry('된장', 180),
    MapEntry('고추장', 180),
    MapEntry('간장', 180),
    MapEntry('장', 180),
  ];

  static const int _defaultIngredientDays = 7;
  static const int _defaultSideDishDays = 5;

  /// 냉동 보관 시 최소 보장 일수(장기 보관). 키워드 추정값보다 길면 그대로 사용.
  static const int _frozenMinDays = 90;

  int estimateDays({
    required String name,
    required FoodType type,
    StoreType store = StoreType.cold,
  }) {
    final trimmed = name.trim();
    var days = type == FoodType.sideDish
        ? _defaultSideDishDays
        : _defaultIngredientDays;
    for (final entry in _keywordDays) {
      if (trimmed.contains(entry.key)) {
        days = entry.value;
        break;
      }
    }
    if (store == StoreType.frozen) {
      days = days > _frozenMinDays ? days : _frozenMinDays;
    }
    return days;
  }

  DateTime estimate({
    required String name,
    required FoodType type,
    required DateTime startedAt,
    StoreType store = StoreType.cold,
  }) {
    final days = estimateDays(name: name, type: type, store: store);
    return DateTime(
      startedAt.year,
      startedAt.month,
      startedAt.day,
    ).add(Duration(days: days));
  }
}
