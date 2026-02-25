import 'package:firebase_database/firebase_database.dart';

import '../models/app_state_snapshot.dart';
import '../models/food_item.dart';
import 'sync_repository.dart';

class FirebaseSyncRepository implements SyncRepository {
  FirebaseSyncRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference _userRef(String uid) => _database.ref('users/$uid');

  @override
  Future<bool> hasCloudData(String uid) async {
    final snapshot = await _userRef(uid).child('meta/localUpdatedAt').get();
    return snapshot.exists;
  }

  @override
  Future<DateTime?> getCloudLastUpdatedAt(String uid) async {
    final server = await _userRef(uid).child('meta/serverUpdatedAt').get();
    if (server.value is num) {
      return DateTime.fromMillisecondsSinceEpoch((server.value as num).toInt());
    }

    final local = await _userRef(uid).child('meta/localUpdatedAt').get();
    if (local.value is num) {
      return DateTime.fromMillisecondsSinceEpoch((local.value as num).toInt());
    }
    return null;
  }

  @override
  Future<void> uploadLocalSnapshot(
    String uid,
    AppStateSnapshot snapshot, {
    bool overwrite = true,
  }) async {
    if (!overwrite && await hasCloudData(uid)) {
      return;
    }

    final ref = _userRef(uid);
    await ref.child('fridges').set(_encodeFridges(snapshot.fridges));
    await ref.child('items').set(_encodeItems(snapshot.items));
    await ref.child('meta').update(<String, Object?>{
      'localUpdatedAt': snapshot.updatedAt.millisecondsSinceEpoch,
      'serverUpdatedAt': ServerValue.timestamp,
    });
  }

  @override
  Future<AppStateSnapshot?> downloadSnapshot(String uid) async {
    final root = await _userRef(uid).get();
    if (!root.exists) {
      return null;
    }

    final map = _asMap(root.value);
    final fridgesMap = _asMap(map['fridges']);
    final itemsMap = _asMap(map['items']);
    final meta = _asMap(map['meta']);

    final updatedAt = _toDateTime(
      meta['localUpdatedAt'],
      fallback: DateTime.fromMillisecondsSinceEpoch(0),
    );

    final fridges = fridgesMap.values
        .map((v) => _fridgeFromMap(_asMap(v)))
        .whereType<FridgeSnapshot>()
        .toList();

    final items = itemsMap.values
        .map((v) => _itemFromMap(_asMap(v)))
        .whereType<FoodItemSnapshot>()
        .toList();

    return AppStateSnapshot(
      updatedAt: updatedAt,
      fridges: fridges,
      items: items,
    );
  }

  @override
  Future<void> mergeByLatest(String uid, AppStateSnapshot localSnapshot) async {
    final cloud = await downloadSnapshot(uid);
    if (cloud == null) {
      await uploadLocalSnapshot(uid, localSnapshot, overwrite: true);
      return;
    }

    final mergedFridges = <String, FridgeSnapshot>{
      for (final f in cloud.fridges) f.id: f,
    };
    for (final local in localSnapshot.fridges) {
      final remote = mergedFridges[local.id];
      if (remote == null || local.updatedAt.isAfter(remote.updatedAt)) {
        mergedFridges[local.id] = local;
      }
    }

    final mergedItems = <String, FoodItemSnapshot>{
      for (final i in cloud.items) i.id: i,
    };
    for (final local in localSnapshot.items) {
      final remote = mergedItems[local.id];
      if (remote == null || local.updatedAt.isAfter(remote.updatedAt)) {
        mergedItems[local.id] = local;
      }
    }

    final merged = AppStateSnapshot(
      updatedAt: localSnapshot.updatedAt.isAfter(cloud.updatedAt)
          ? localSnapshot.updatedAt
          : cloud.updatedAt,
      fridges: mergedFridges.values.toList(),
      items: mergedItems.values.toList(),
    );

    await uploadLocalSnapshot(uid, merged, overwrite: true);
  }

  Map<String, Object?> _encodeFridges(List<FridgeSnapshot> fridges) {
    return <String, Object?>{
      for (final f in fridges)
        f.id: <String, Object?>{
          'id': f.id,
          'name': f.name,
          'createdAt': f.createdAt.millisecondsSinceEpoch,
          'updatedAt': f.updatedAt.millisecondsSinceEpoch,
          'isDefault': f.isDefault,
        },
    };
  }

  Map<String, Object?> _encodeItems(List<FoodItemSnapshot> items) {
    return <String, Object?>{
      for (final i in items)
        i.id: <String, Object?>{
          'id': i.id,
          'fridgeId': i.fridgeId,
          'name': i.name,
          'type': i.type.name,
          'startedAt': i.startedAt.millisecondsSinceEpoch,
          'createdAt': i.createdAt.millisecondsSinceEpoch,
          'updatedAt': i.updatedAt.millisecondsSinceEpoch,
          'isActive': i.isActive,
        },
    };
  }

  FridgeSnapshot? _fridgeFromMap(Map<String, dynamic> map) {
    final id = map['id']?.toString();
    final name = map['name']?.toString();
    if (id == null || name == null) {
      return null;
    }

    final createdAt = _toDateTime(map['createdAt']);
    final updatedAt = _toDateTime(map['updatedAt'], fallback: createdAt);

    return FridgeSnapshot(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDefault: map['isDefault'] == true,
    );
  }

  FoodItemSnapshot? _itemFromMap(Map<String, dynamic> map) {
    final id = map['id']?.toString();
    final fridgeId = map['fridgeId']?.toString();
    final name = map['name']?.toString();
    final typeName = map['type']?.toString();

    if (id == null || fridgeId == null || name == null || typeName == null) {
      return null;
    }

    final type = typeName == FoodType.sideDish.name
        ? FoodType.sideDish
        : FoodType.ingredient;

    return FoodItemSnapshot(
      id: id,
      fridgeId: fridgeId,
      name: name,
      type: type,
      startedAt: _toDateTime(map['startedAt']),
      createdAt: _toDateTime(map['createdAt']),
      updatedAt: _toDateTime(map['updatedAt']),
      isActive: map['isActive'] != false,
    );
  }

  DateTime _toDateTime(Object? value, {DateTime? fallback}) {
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }
}
