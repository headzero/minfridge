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

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'dateKey': dateKey,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'generatedAt': generatedAt.millisecondsSinceEpoch,
      'status': status.name,
      'refreshCount': refreshCount,
      'failureCount': failureCount,
      'successCount': successCount,
    };
  }

  factory DailyRecommendation.fromJson(Map<String, dynamic> json) {
    List<String> stringList(Object? value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return const <String>[];
    }

    int toInt(Object? value, {int fallback = 0}) {
      return value is num ? value.toInt() : fallback;
    }

    final statusName = json['status']?.toString();
    final status = RecommendationStatus.values.firstWhere(
      (e) => e.name == statusName,
      orElse: () => RecommendationStatus.success,
    );

    final generatedAtRaw = json['generatedAt'];
    final generatedAt =
        generatedAtRaw is num
            ? DateTime.fromMillisecondsSinceEpoch(generatedAtRaw.toInt())
            : DateTime.fromMillisecondsSinceEpoch(0);

    return DailyRecommendation(
      dateKey: json['dateKey']?.toString() ?? '',
      breakfast: stringList(json['breakfast']),
      lunch: stringList(json['lunch']),
      dinner: stringList(json['dinner']),
      generatedAt: generatedAt,
      status: status,
      refreshCount: toInt(json['refreshCount']),
      failureCount: toInt(json['failureCount']),
      successCount: toInt(json['successCount'], fallback: 1),
    );
  }
}

enum RecommendationStatus { scheduled, success, failed }
