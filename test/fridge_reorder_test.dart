import 'package:flutter_test/flutter_test.dart';

import 'package:minfridge/src/repositories/mock_recipe_repository.dart';
import 'package:minfridge/src/services/recommendation_scheduler.dart';
import 'package:minfridge/src/state/app_state.dart';

void main() {
  AppState build() => AppState(
    recipeRepository: MockRecipeRepository(),
    scheduler: RecommendationScheduler(),
  );

  test('냉장고 순서 변경: 첫 번째를 마지막으로 이동', () {
    final state = build();
    final before = state.fridges.map((f) => f.name).toList();
    expect(before.length, greaterThanOrEqualTo(2));

    state.reorderFridges(0, before.length - 1);

    final after = state.fridges.map((f) => f.name).toList();
    expect(after.first, before[1]);
    expect(after.last, before.first);
    expect(after.toSet(), before.toSet()); // 항목 유실 없음
  });

  test('범위를 벗어난 인덱스는 무시', () {
    final state = build();
    final before = state.fridges.map((f) => f.name).toList();
    state.reorderFridges(99, 0);
    expect(state.fridges.map((f) => f.name).toList(), before);
  });
}
