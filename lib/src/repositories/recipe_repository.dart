import '../models/food_item.dart';
import '../models/recommendation.dart';

abstract class RecipeRepository {
  Future<DailyRecommendation> generateForDay({
    required String dateKey,
    required List<FoodItem> activeItems,
    bool forceHighQualityModel = false,
  });
}
