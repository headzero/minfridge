import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_state_snapshot.dart';
import '../models/food_item.dart';

class LocalSnapshotRepository {
  static const String _storageKey = 'app_state_snapshot_v1';

  Future<void> saveSnapshot(AppStateSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_toMap(snapshot));
    await prefs.setString(_storageKey, encoded);
  }

  Future<AppStateSnapshot?> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return _fromMap(decoded);
  }

  Map<String, Object?> _toMap(AppStateSnapshot snapshot) {
    return <String, Object?>{
      'updatedAt': snapshot.updatedAt.millisecondsSinceEpoch,
      'fridges': snapshot.fridges
          .map(
            (f) => <String, Object?>{
              'id': f.id,
              'name': f.name,
              'createdAt': f.createdAt.millisecondsSinceEpoch,
              'updatedAt': f.updatedAt.millisecondsSinceEpoch,
              'isDefault': f.isDefault,
            },
          )
          .toList(),
      'items': snapshot.items
          .map(
            (i) => <String, Object?>{
              'id': i.id,
              'fridgeId': i.fridgeId,
              'name': i.name,
              'type': i.type.name,
              'startedAt': i.startedAt.millisecondsSinceEpoch,
              'createdAt': i.createdAt.millisecondsSinceEpoch,
              'updatedAt': i.updatedAt.millisecondsSinceEpoch,
              'isActive': i.isActive,
            },
          )
          .toList(),
    };
  }

  AppStateSnapshot _fromMap(Map<String, dynamic> map) {
    final fridgesRaw = map['fridges'];
    final itemsRaw = map['items'];

    final fridges = <FridgeSnapshot>[];
    if (fridgesRaw is List) {
      for (final value in fridgesRaw) {
        if (value is! Map) {
          continue;
        }
        final row = value.map((k, v) => MapEntry(k.toString(), v));
        final id = row['id']?.toString();
        final name = row['name']?.toString();
        if (id == null || name == null) {
          continue;
        }
        fridges.add(
          FridgeSnapshot(
            id: id,
            name: name,
            createdAt: _toDateTime(row['createdAt']),
            updatedAt: _toDateTime(
              row['updatedAt'],
              fallback: _toDateTime(row['createdAt']),
            ),
            isDefault: row['isDefault'] == true,
          ),
        );
      }
    }

    final items = <FoodItemSnapshot>[];
    if (itemsRaw is List) {
      for (final value in itemsRaw) {
        if (value is! Map) {
          continue;
        }
        final row = value.map((k, v) => MapEntry(k.toString(), v));
        final id = row['id']?.toString();
        final fridgeId = row['fridgeId']?.toString();
        final name = row['name']?.toString();
        if (id == null || fridgeId == null || name == null) {
          continue;
        }

        final type = row['type'] == FoodType.sideDish.name
            ? FoodType.sideDish
            : FoodType.ingredient;

        items.add(
          FoodItemSnapshot(
            id: id,
            fridgeId: fridgeId,
            name: name,
            type: type,
            startedAt: _toDateTime(row['startedAt']),
            createdAt: _toDateTime(row['createdAt']),
            updatedAt: _toDateTime(row['updatedAt']),
            isActive: row['isActive'] != false,
          ),
        );
      }
    }

    return AppStateSnapshot(
      updatedAt: _toDateTime(map['updatedAt']),
      fridges: fridges,
      items: items,
    );
  }

  DateTime _toDateTime(Object? value, {DateTime? fallback}) {
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
