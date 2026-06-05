enum FoodType { ingredient, sideDish }

/// 유통기한 값의 출처. 사용자가 직접 입력했는지, 자동 추정했는지 구분한다.
enum ExpirySource { manual, estimated }

class FoodItem {
  FoodItem({
    required this.id,
    required this.fridgeId,
    required this.name,
    required this.type,
    this.quantity = 1,
    required this.startedAt,
    this.expiresAt,
    this.expirySource,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  final String id;
  String fridgeId;
  String name;
  FoodType type;
  int quantity;
  DateTime startedAt;
  DateTime? expiresAt;
  ExpirySource? expirySource;
  DateTime createdAt;
  DateTime updatedAt;
  bool isActive;

  int get storageDays => DateTime.now().difference(startedAt).inDays;

  /// 오늘 기준 유통기한까지 남은 일수(날짜 기준). 음수면 이미 지난 것.
  /// 유통기한이 없으면 null.
  int? get daysUntilExpiry {
    final expiry = expiresAt;
    if (expiry == null) {
      return null;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(expiry.year, expiry.month, expiry.day);
    return due.difference(today).inDays;
  }

  bool get isExpiryEstimated => expirySource == ExpirySource.estimated;
}
