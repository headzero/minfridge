import 'food_item.dart';
import 'fridge.dart';

class AppStateSnapshot {
  AppStateSnapshot({
    required this.updatedAt,
    required this.fridges,
    required this.items,
  });

  final DateTime updatedAt;
  final List<FridgeSnapshot> fridges;
  final List<FoodItemSnapshot> items;
}

class FridgeSnapshot {
  FridgeSnapshot({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isDefault,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;

  Fridge toModel() {
    return Fridge(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDefault: isDefault,
    );
  }
}

class FoodItemSnapshot {
  FoodItemSnapshot({
    required this.id,
    required this.fridgeId,
    required this.name,
    required this.type,
    required this.quantity,
    this.store = StoreType.cold,
    required this.startedAt,
    this.expiresAt,
    this.expirySource,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  final String id;
  final String fridgeId;
  final String name;
  final FoodType type;
  final int quantity;
  final StoreType store;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final ExpirySource? expirySource;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  FoodItem toModel() {
    return FoodItem(
      id: id,
      fridgeId: fridgeId,
      name: name,
      type: type,
      quantity: quantity,
      store: store,
      startedAt: startedAt,
      expiresAt: expiresAt,
      expirySource: expirySource,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }
}
