import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/food_item.dart';
import '../models/recommendation.dart';
import 'recipe_repository.dart';

class MockRecipeRepository implements RecipeRepository {
  @override
  Future<DailyRecommendation> generateForDay({
    required String dateKey,
    required List<FoodItem> activeItems,
    bool forceHighQualityModel = false,
  }) async {
    final jsonString = await rootBundle.loadString('assets/mocks/recipes.json');
    final map = json.decode(jsonString) as Map<String, dynamic>;
    final tag = activeItems.isEmpty ? '기본' : activeItems.first.name;

    List<String> enrich(List<dynamic> src) {
      return src.map((e) => '$e ($tag 활용)').toList();
    }

    return DailyRecommendation(
      dateKey: dateKey,
      breakfast: enrich(map['breakfast'] as List<dynamic>),
      lunch: enrich(map['lunch'] as List<dynamic>),
      dinner: enrich(map['dinner'] as List<dynamic>),
      generatedAt: DateTime.now(),
      status: RecommendationStatus.success,
    );
  }
}
