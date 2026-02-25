class RecommendationScheduler {
  static const int pregenWindowMinutes = 7 * 60; // 23:00~06:00

  int pregenSlotMinute({required String uid, required String dateKey}) {
    final seed = '$uid-$dateKey'.codeUnits.fold<int>(0, (a, b) => a + b);
    return seed % pregenWindowMinutes;
  }

  DateTime pregenTime({
    required String uid,
    required DateTime targetDate,
  }) {
    final dateKey =
        '${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
    final slot = pregenSlotMinute(uid: uid, dateKey: dateKey);
    final start = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    ).subtract(const Duration(hours: 1)); // D-1 23:00
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

  bool isAfterMorningReadOnlyTime(DateTime now) {
    final seven = DateTime(now.year, now.month, now.day, 7);
    return now.isAfter(seven) || now.isAtSameMomentAs(seven);
  }
}
