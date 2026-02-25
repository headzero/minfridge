import '../models/app_state_snapshot.dart';

abstract class SyncRepository {
  Future<bool> hasCloudData(String uid);

  Future<DateTime?> getCloudLastUpdatedAt(String uid);

  Future<void> uploadLocalSnapshot(
    String uid,
    AppStateSnapshot snapshot, {
    bool overwrite = true,
  });

  Future<AppStateSnapshot?> downloadSnapshot(String uid);

  Future<void> mergeByLatest(String uid, AppStateSnapshot localSnapshot);
}
