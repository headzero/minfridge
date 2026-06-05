enum FoodType { ingredient, sideDish }

class FoodItem {
  FoodItem({
    required this.id,
    required this.fridgeId,
    required this.name,
    required this.type,
    this.quantity = 1,
    required this.startedAt,
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
  DateTime createdAt;
  DateTime updatedAt;
  bool isActive;

  int get storageDays => DateTime.now().difference(startedAt).inDays;
}
