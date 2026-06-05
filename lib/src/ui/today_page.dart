import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recommendation.dart';
import '../state/app_state.dart';
import 'widgets/common.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  bool _busy = false;

  Future<void> _refresh() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await context.read<AppState>().manualRefreshToday();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '추천을 새로 생성했어요.' : '재시도 제한에 도달했어요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final rec = state.todayRecommendation;
    final failed = rec == null || rec.status == RecommendationStatus.failed;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('오늘의 추천', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: scheme.onSurface)),
                const SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Icon(Icons.autorenew, size: 15, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          const TextSpan(text: '수동 새로고침 남은 횟수 '),
                          TextSpan(text: '${state.remainingManualRefresh}회', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800)),
                          const TextSpan(text: ' · 하루 최대 3회'),
                        ],
                      ),
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: <Widget>[
                MfButtons.primary(
                  label: _busy ? '생성 중…' : '수동 새로고침',
                  icon: _busy ? Icons.hourglass_top : Icons.refresh,
                  expanded: true,
                  onPressed: _busy ? null : _refresh,
                ),
                const SizedBox(width: 8),
                MfButtons.outline(
                  label: '오늘 조회',
                  icon: Icons.event_available,
                  expanded: true,
                  onPressed: _busy ? null : () => context.read<AppState>().generateTodayRecommendationIfMissing(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _busy
                ? const _LoadingBody()
                : failed
                    ? _FailureBody(failureCount: rec?.failureCount ?? 0, onRetry: _refresh)
                    : _SuccessBody(rec: rec),
          ),
        ],
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.rec});

  final DailyRecommendation rec;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      children: <Widget>[
        _MealCard(meal: 'breakfast', label: '아침', items: rec.breakfast),
        _MealCard(meal: 'lunch', label: '점심', items: rec.lunch),
        _MealCard(meal: 'dinner', label: '저녁', items: rec.dinner),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.label, required this.items});

  final String meal;
  final String label;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    final tone = mf.mealTone(meal);
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mf.lineSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: tone.tint,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: <Widget>[
                Container(width: 9, height: 9, decoration: BoxDecoration(color: tone.main, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: tone.ink)),
                const SizedBox(width: 6),
                Text('· 보유 재료로', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tone.ink.withValues(alpha: 0.7))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
            child: Column(
              children: <Widget>[
                for (var i = 0; i < items.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: i == 0 ? null : Border(top: BorderSide(color: mf.lineSoft)),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 16, child: Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: tone.main))),
                        const SizedBox(width: 9),
                        Expanded(child: Text(items[i], style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: scheme.onSurface))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
          child: Row(
            children: <Widget>[
              Icon(Icons.auto_awesome, size: 16, color: scheme.primary),
              const SizedBox(width: 8),
              Text('오늘 끼니를 고르는 중이에요…', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            children: const <Widget>[
              _SkeletonCard(meal: 'breakfast', label: '아침'),
              _SkeletonCard(meal: 'lunch', label: '점심'),
              _SkeletonCard(meal: 'dinner', label: '저녁'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.meal, required this.label});

  final String meal;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    final tone = mf.mealTone(meal);
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mf.lineSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: tone.tint,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: tone.ink.withValues(alpha: 0.7))),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: <Widget>[
                for (final w in <double>[0.78, 0.62, 0.70])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: w,
                        child: Container(height: 13, decoration: BoxDecoration(color: mf.sunken, borderRadius: BorderRadius.circular(7))),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FailureBody extends StatelessWidget {
  const _FailureBody({required this.failureCount, required this.onRetry});

  final int failureCount;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: mf.urgent.tint, borderRadius: BorderRadius.circular(24)),
              child: Icon(Icons.sentiment_dissatisfied, size: 42, color: mf.urgent.main),
            ),
            const SizedBox(height: 18),
            Text('추천 생성에 실패했어요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: scheme.onSurface)),
            const SizedBox(height: 7),
            Text(
              '잠시 후 다시 시도해 주세요.\n재료를 더 추가하면 성공률이 올라가요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.5, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(color: mf.urgent.tint, borderRadius: BorderRadius.circular(13)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.error, size: 14, color: mf.urgent.main),
                  const SizedBox(width: 5),
                  Text('실패 횟수 $failureCount / 3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: mf.urgent.ink)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            MfButtons.primary(label: '다시 시도', icon: Icons.refresh, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
