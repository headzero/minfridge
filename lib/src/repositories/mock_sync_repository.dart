import '../models/app_state_snapshot.dart';
import 'sync_repository.dart';

class MockSyncRepository implements SyncRepository {
  static final Map<String, AppStateSnapshot> _cloud =
      <String, AppStateSnapshot>{};

  @override
  Future<bool> hasCloudData(String uid) async => _cloud.containsKey(uid);

  @override
  Future<DateTime?> getCloudLastUpdatedAt(String uid) async {
    return _cloud[uid]?.updatedAt;
  }

  @override
  Future<void> uploadLocalSnapshot(
    String uid,
    AppStateSnapshot snapshot, {
    bool overwrite = true,
  }) async {
    if (!overwrite && _cloud.containsKey(uid)) {
      return;
    }
    _cloud[uid] = snapshot;
  }

  @override
  Future<AppStateSnapshot?> downloadSnapshot(String uid) async {
    return _cloud[uid];
  }

  @override
  Future<void> mergeByLatest(String uid, AppStateSnapshot localSnapshot) async {
    final cloud = _cloud[uid];
    if (cloud == null || localSnapshot.updatedAt.isAfter(cloud.updatedAt)) {
      _cloud[uid] = localSnapshot;
    }
  }
}
