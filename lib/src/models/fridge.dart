class Fridge {
  Fridge({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
    this.isDefault = false,
  });

  final String id;
  String name;
  final DateTime createdAt;
  DateTime? updatedAt;
  bool isDefault;
}
