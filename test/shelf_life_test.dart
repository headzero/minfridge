import 'package:flutter_test/flutter_test.dart';

import 'package:minfridge/src/models/food_item.dart';
import 'package:minfridge/src/repositories/mock_recipe_repository.dart';
import 'package:minfridge/src/services/recommendation_scheduler.dart';
import 'package:minfridge/src/services/shelf_life_estimator.dart';
import 'package:minfridge/src/state/app_state.dart';

void main() {
  group('ShelfLifeEstimator', () {
    const estimator = ShelfLifeEstimator();

    test('키워드가 매칭되면 해당 보관일수를 사용한다', () {
      expect(
        estimator.estimateDays(name: '계란 한 판', type: FoodType.ingredient),
        21,
      );
      expect(estimator.estimateDays(name: '김치', type: FoodType.sideDish), 60);
    });

    test('매칭이 없으면 유형별 기본값을 사용한다', () {
      expect(
        estimator.estimateDays(name: '알수없는재료', type: FoodType.ingredient),
        7,
      );
      expect(
        estimator.estimateDays(name: '알수없는반찬', type: FoodType.sideDish),
        5,
      );
    });

    test('estimate는 보관 시작일 기준으로 날짜를 더한다', () {
      final started = DateTime(2026, 1, 1);
      final expiry = estimator.estimate(
        name: '우유',
        type: FoodType.ingredient,
        startedAt: started,
      );
      expect(expiry, DateTime(2026, 1, 11)); // 우유 10일
    });
  });

  group('AppState 유통기한', () {
    AppState build() => AppState(
      recipeRepository: MockRecipeRepository(),
      scheduler: RecommendationScheduler(),
    );

    test('유통기한 미입력 시 추정값으로 자동 채운다', () {
      final state = build();
      state.addItem(
        name: '우유',
        type: FoodType.ingredient,
        quantity: 1,
        startedAt: DateTime.now(),
      );
      final item = state.activeItemsInSelectedFridge.firstWhere(
        (e) => e.name == '우유',
      );
      expect(item.expiresAt, isNotNull);
      expect(item.expirySource, ExpirySource.estimated);
      expect(item.isExpiryEstimated, isTrue);
    });

    test('유통기한 직접 입력 시 manual 출처로 보존한다', () {
      final state = build();
      final manual = DateTime.now().add(const Duration(days: 2));
      state.addItem(
        name: '두부',
        type: FoodType.ingredient,
        quantity: 1,
        startedAt: DateTime.now(),
        expiresAt: manual,
      );
      final item = state.activeItemsInSelectedFridge.firstWhere(
        (e) => e.name == '두부',
      );
      expect(item.expirySource, ExpirySource.manual);
      expect(item.expiresAt, manual);
    });

    test('임박 항목 카운트는 활성 항목 중 임박분만 센다', () {
      final state = build();
      state.addItem(
        name: '임박재료',
        type: FoodType.ingredient,
        quantity: 1,
        startedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
      state.addItem(
        name: '여유재료',
        type: FoodType.ingredient,
        quantity: 1,
        startedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(state.expiringSoonCount(), greaterThanOrEqualTo(1));
      expect(
        state.expiringSoonInSelectedFridge().any((e) => e.name == '임박재료'),
        isTrue,
      );
    });
  });
}
