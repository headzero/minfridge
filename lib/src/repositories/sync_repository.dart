import '../models/app_state_snapshot.dart';
import '../models/sync_merge_report.dart';

abstract class SyncRepository {
  Future<bool> hasCloudData(String uid);

  Future<DateTime?> getCloudLastUpdatedAt(String uid);

  Future<void> uploadLocalSnapshot(
    String uid,
    AppStateSnapshot snapshot, {
    bool overwrite = true,
  });

  Future<AppStateSnapshot?> downloadSnapshot(String uid);

  Future<SyncMergeReport> mergeByLatest(
    String uid,
    AppStateSnapshot localSnapshot,
  );
}
