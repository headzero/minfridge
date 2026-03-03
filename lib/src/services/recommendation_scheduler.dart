class RecommendationScheduler {
  static const int pregenWindowMinutes = 6 * 60; // 00:00~06:00

  int pregenSlotMinute({required String uid, required String dateKey}) {
    final seed = '$uid-$dateKey'.codeUnits.fold<int>(0, (a, b) => a + b);
    return seed % pregenWindowMinutes;
  }

  DateTime pregenTime({required String uid, required DateTime targetDate}) {
    final dateKey =
        '${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
    final slot = pregenSlotMinute(uid: uid, dateKey: dateKey);
    final start = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      0,
      0,
    );
    return start.add(Duration(minutes: slot));
  }

  bool shouldRunPregen({
    required String uid,
    required DateTime now,
    required DateTime targetDate,
  }) {
    final scheduled = pregenTime(uid: uid, targetDate: targetDate);
    return now.isAfter(scheduled) || now.isAtSameMomentAs(scheduled);
  }

  bool isInPregenWindow(DateTime now) {
    final start = DateTime(now.year, now.month, now.day, 0, 0);
    final end = DateTime(now.year, now.month, now.day, 6, 0);
    return (now.isAfter(start) || now.isAtSameMomentAs(start)) &&
        now.isBefore(end);
  }

  bool isAfterMorningReadOnlyTime(DateTime now) {
    final seven = DateTime(now.year, now.month, now.day, 7);
    return now.isAfter(seven) || now.isAtSameMomentAs(seven);
  }

  DateTime nextMorningNotification(DateTime now) {
    final todaySeven = DateTime(now.year, now.month, now.day, 7);
    if (now.isBefore(todaySeven)) {
      return todaySeven;
    }
    return todaySeven.add(const Duration(days: 1));
  }

  DateTime nextPregenTrigger({required String uid, required DateTime now}) {
    final today = DateTime(now.year, now.month, now.day);
    final todaySlot = pregenTime(uid: uid, targetDate: today);
    if (now.isBefore(todaySlot)) {
      return todaySlot;
    }
    final tomorrow = today.add(const Duration(days: 1));
    return pregenTime(uid: uid, targetDate: tomorrow);
  }
}
