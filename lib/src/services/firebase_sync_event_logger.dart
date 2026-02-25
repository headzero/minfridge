import 'package:firebase_analytics/firebase_analytics.dart';

import '../models/sync_merge_report.dart';
import 'sync_event_logger.dart';

class FirebaseSyncEventLogger implements SyncEventLogger {
  FirebaseSyncEventLogger({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logAppStartSync({
    required String uid,
    required String action,
    int retryCount = 0,
  }) async {
    await _analytics.logEvent(
      name: 'sync_app_start',
      parameters: <String, Object>{
        'action': action,
        'retry_count': retryCount,
      },
    );
  }

  @override
  Future<void> logMergeResult({
    required String uid,
    required String source,
    required SyncMergeReport report,
  }) async {
    await _analytics.logEvent(
      name: 'sync_merge_latest',
      parameters: <String, Object>{
        'source': source,
        'fridge_local': report.fridgeFromLocal,
        'fridge_cloud': report.fridgeFromCloud,
        'item_local': report.itemFromLocal,
        'item_cloud': report.itemFromCloud,
      },
    );
  }

  @override
  Future<void> logSyncError({
    required String uid,
    required String stage,
    required String error,
  }) async {
    await _analytics.logEvent(
      name: 'sync_error',
      parameters: <String, Object>{
        'stage': stage,
        'error': error.length > 80 ? error.substring(0, 80) : error,
      },
    );
  }
}
