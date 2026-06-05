import 'dart:async';

import '../state/app_state.dart';
import 'local_notification_service.dart';
import 'recommendation_scheduler.dart';

class RecommendationAutomationService {
  RecommendationAutomationService({
    required AppState appState,
    required RecommendationScheduler scheduler,
    required LocalNotificationService notificationService,
  }) : _appState = appState,
       _scheduler = scheduler,
       _notificationService = notificationService;

  final AppState _appState;
  final RecommendationScheduler _scheduler;
  final LocalNotificationService _notificationService;

  Timer? _pregenTimer;
  String _lastUid = '';

  Future<void> start() async {
    _lastUid = _appState.uid;
    _appState.addListener(_onAppStateChanged);
    await _runCatchUpIfNeeded();
    _scheduleNextPregen();
    // 오전 7시 추천 리마인더를 OS 레벨로 예약(앱 종료 상태에서도 발송).
    try {
      await _notificationService.scheduleDailyReminder(hour: 7);
    } catch (_) {
      // 예약 실패가 앱 구동을 막지 않는다.
    }
  }

  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    _pregenTimer?.cancel();
  }

  void _onAppStateChanged() {
    final nextUid = _appState.uid;
    if (nextUid == _lastUid) {
      return;
    }
    _lastUid = nextUid;
    _scheduleNextPregen();
  }

  Future<void> _runCatchUpIfNeeded() async {
    final now = DateTime.now();
    if (_scheduler.isInPregenWindow(now)) {
      final today = DateTime(now.year, now.month, now.day);
      final shouldRun = _scheduler.shouldRunPregen(
        uid: _appState.uid,
        now: now,
        targetDate: today,
      );
      if (shouldRun) {
        await _appState.generateTodayRecommendationIfMissing();
      }
    }
  }

  void _scheduleNextPregen() {
    _pregenTimer?.cancel();
    final now = DateTime.now();
    final next = _scheduler.nextPregenTrigger(uid: _appState.uid, now: now);
    final delay = next.difference(now);

    _pregenTimer = Timer(delay, () async {
      try {
        await _appState.generateTodayRecommendationIfMissing();
      } catch (_) {
        // Ignore and keep next schedule alive.
      }
      _scheduleNextPregen();
    });
  }
}
