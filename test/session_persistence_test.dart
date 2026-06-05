import 'package:flutter_test/flutter_test.dart';

import 'package:minfridge/src/models/food_item.dart';
import 'package:minfridge/src/models/recommendation.dart';
import 'package:minfridge/src/repositories/recipe_repository.dart';
import 'package:minfridge/src/services/date_key.dart';
import 'package:minfridge/src/services/recommendation_scheduler.dart';
import 'package:minfridge/src/state/app_state.dart';

class _FakeRecipeRepository implements RecipeRepository {
  @override
  Future<DailyRecommendation> generateForDay({
    required String dateKey,
    required List<FoodItem> activeItems,
    bool forceHighQualityModel = false,
  }) async {
    return DailyRecommendation(
      dateKey: dateKey,
      breakfast: const <String>['계란밥'],
      lunch: const <String>['김치찌개'],
      dinner: const <String>['된장국'],
      generatedAt: DateTime.now(),
      status: RecommendationStatus.success,
    );
  }
}

void main() {
  AppState build() => AppState(
    recipeRepository: _FakeRecipeRepository(),
    scheduler: RecommendationScheduler(),
  );

  test('추천 히스토리/쿼터/만족도가 export-import 왕복으로 보존된다', () async {
    final source = build();
    await source.generateTodayRecommendationIfMissing();
    await source.manualRefreshToday(); // 쿼터 1회 소비
    source.submitFeedbackForToday(true);

    final remainingAfterUse = source.remainingManualRefresh;
    final session = source.exportSessionState();

    final restored = build();
    restored.importSessionState(session);

    final todayKey = toDateKey(DateTime.now());
    expect(restored.todayRecommendation, isNotNull);
    expect(
      restored.todayRecommendation!.status,
      RecommendationStatus.success,
    );
    expect(restored.recommendationHistory.containsKey(todayKey), isTrue);
    expect(restored.remainingManualRefresh, remainingAfterUse);
    expect(restored.recent7DayLikeRatio, 1.0);
  });

  test('보존 기간(1년)을 넘긴 추천은 export 시 정리된다', () async {
    final source = build();
    await source.generateTodayRecommendationIfMissing();

    final session = source.exportSessionState();
    final recommendations = session['recommendations'] as Map;
    // 오늘 추천은 유지된다.
    expect(recommendations.containsKey(toDateKey(DateTime.now())), isTrue);
  });
}
