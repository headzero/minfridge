import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_recommendation';
  static const String _channelName = '오늘의 추천 알림';
  static const String _channelDescription = '오전 7시 추천 알림';
  static const int _dailyReminderId = 7100;

  bool _timezoneReady = false;

  Future<void> initialize() async {
    await _initTimezone();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _initTimezone() async {
    if (_timezoneReady) {
      return;
    }
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // 타임존 조회 실패 시 UTC로 폴백한다.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _timezoneReady = true;
  }

  /// 매일 [hour]:[minute]에 OS 레벨로 반복 발송되는 추천 리마인더를 예약한다.
  /// 앱이 완전히 종료된 상태에서도 동작한다(Timer 기반과 달리).
  Future<void> scheduleDailyReminder({int hour = 7, int minute = 0}) async {
    await _initTimezone();
    final scheduled = _nextInstanceOf(hour, minute);

    await _plugin.zonedSchedule(
      _dailyReminderId,
      '오늘의 추천이 준비됐어요',
      '오늘 끼니 추천과 유통기한 임박 재료를 확인해보세요.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() => _plugin.cancel(_dailyReminderId);

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> showDailyRecommendationReady({int expiringSoon = 0}) async {
    final body = StringBuffer('아침/점심/저녁 추천 9개를 확인해보세요.');
    if (expiringSoon > 0) {
      body.write(' 유통기한 임박 재료 $expiringSoon개도 챙겨보세요.');
    }
    await _plugin.show(
      7001,
      '오늘의 추천이 준비됐어요',
      body.toString(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showDailyRecommendationFailed({int expiringSoon = 0}) async {
    final body = StringBuffer('앱에서 새로고침으로 다시 시도해 주세요.');
    if (expiringSoon > 0) {
      body.write(' 유통기한 임박 재료 $expiringSoon개를 먼저 확인해보세요.');
    }
    await _plugin.show(
      7002,
      '오늘의 추천 생성이 지연됐어요',
      body.toString(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
