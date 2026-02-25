class DailyRecommendation {
  DailyRecommendation({
    required this.dateKey,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.generatedAt,
    this.status = RecommendationStatus.success,
    this.refreshCount = 0,
    this.failureCount = 0,
    this.successCount = 1,
  });

  final String dateKey;
  final List<String> breakfast;
  final List<String> lunch;
  final List<String> dinner;
  final DateTime generatedAt;
  RecommendationStatus status;
  int refreshCount;
  int failureCount;
  int successCount;
}

enum RecommendationStatus { scheduled, success, failed }
