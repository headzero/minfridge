import '../models/sync_merge_report.dart';

abstract class SyncEventLogger {
  Future<void> logAppStartSync({
    required String uid,
    required String action,
    int retryCount = 0,
  });

  Future<void> logMergeResult({
    required String uid,
    required String source,
    required SyncMergeReport report,
  });

  Future<void> logSyncError({
    required String uid,
    required String stage,
    required String error,
  });
}

class NoopSyncEventLogger implements SyncEventLogger {
  @override
  Future<void> logAppStartSync({
    required String uid,
    required String action,
    int retryCount = 0,
  }) async {}

  @override
  Future<void> logMergeResult({
    required String uid,
    required String source,
    required SyncMergeReport report,
  }) async {}

  @override
  Future<void> logSyncError({
    required String uid,
    required String stage,
    required String error,
  }) async {}
}
