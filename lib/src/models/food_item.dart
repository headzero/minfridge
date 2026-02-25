enum FoodType { ingredient, sideDish }

class FoodItem {
  FoodItem({
    required this.id,
    required this.fridgeId,
    required this.name,
    required this.type,
    required this.startedAt,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  final String id;
  String fridgeId;
  String name;
  FoodType type;
  DateTime startedAt;
  DateTime createdAt;
  DateTime updatedAt;
  bool isActive;

  int get storageDays => DateTime.now().difference(startedAt).inDays;
}
