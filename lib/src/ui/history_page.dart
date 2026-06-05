import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recommendation.dart';
import '../state/app_state.dart';
import 'widgets/common.dart';

const List<String> _weekdayKo = <String>['월', '화', '수', '목', '금', '토', '일'];

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final rows = state.recommendationHistory.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const ScreenTitle(title: '추천 히스토리', subtitle: '지난 1년 · 최신순'),
          Expanded(
            child: rows.isEmpty
                ? const _HistoryEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    itemCount: rows.length,
                    itemBuilder: (_, i) => _HistoryRow(
                      dateKey: rows[i].key,
                      rec: rows[i].value,
                      liked: state.likedOn(rows[i].key),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.dateKey, required this.rec, required this.liked});

  final String dateKey;
  final DailyRecommendation rec;
  final bool? liked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    final date = DateTime.tryParse(dateKey);
    final now = DateTime.now();
    final isToday = date != null && date.year == now.year && date.month == now.month && date.day == now.day;
    final dayLabel = date == null ? '' : (isToday ? '오늘' : _weekdayKo[date.weekday - 1]);
    final dayNum = date == null ? dateKey : '${date.day}';
    final ok = rec.status == RecommendationStatus.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mf.lineSoft),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 44,
            child: Column(
              children: <Widget>[
                Text(dayNum, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                Text(dayLabel, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: isToday ? scheme.primary : scheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: mf.lineSoft),
          const SizedBox(width: 12),
          Expanded(
            child: ok
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('아침 ${rec.breakfast.length} · 점심 ${rec.lunch.length} · 저녁 ${rec.dinner.length}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: scheme.onSurface)),
                      Text('추천 ${rec.breakfast.length + rec.lunch.length + rec.dinner.length}개 생성됨',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: mf.urgent.tint, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.error, size: 13, color: mf.urgent.main),
                        const SizedBox(width: 5),
                        Text('생성 실패', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: mf.urgent.ink)),
                      ],
                    ),
                  ),
          ),
          if (liked != null)
            Icon(
              liked! ? Icons.thumb_up : Icons.thumb_down,
              size: 17,
              color: liked! ? mf.fresh.main : scheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: mf.sunken, borderRadius: BorderRadius.circular(26)),
              child: Icon(Icons.history, size: 42, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            Text('아직 추천 기록이 없어요', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: scheme.onSurface)),
            const SizedBox(height: 7),
            Text(
              '오늘의 추천을 한 번 받아보면\n여기에 차곡차곡 쌓여요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.5, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
