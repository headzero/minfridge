import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/date_key.dart';
import '../state/app_state.dart';
import '../state/auth_controller.dart';
import 'widgets/common.dart';

// ─────────────────────────────────────────────────────────
//  데이터 병합 다이얼로그
// ─────────────────────────────────────────────────────────
Future<MergeChoice?> showMergeDialog(BuildContext context, MergePromptData prompt) {
  return showDialog<MergeChoice>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      final mf = mfColors(ctx);
      final cloudNewer = prompt.isCloudNewer;

      Widget infoBox(String label, DateTime at, bool newer) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: newer ? scheme.primaryContainer : mf.sunken,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(toDateKey(at), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: scheme.onSurface)),
              if (newer)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('최신', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: scheme.primary)),
                ),
            ],
          ),
        ),
      );

      Widget choice(IconData icon, String title, String sub, MergeChoice value, {bool primary = false}) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Material(
            color: primary ? scheme.primary : scheme.surface,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: () => Navigator.of(ctx).pop(value),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: primary ? null : Border.all(color: scheme.outline, width: 1.5),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(icon, size: 20, color: primary ? scheme.onPrimary : scheme.onSurfaceVariant),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: primary ? scheme.onPrimary : scheme.onSurface)),
                          Text(sub, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: primary ? scheme.onPrimary.withValues(alpha: 0.85) : scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('데이터 병합 방식', style: TextStyle(fontWeight: FontWeight.w800)),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                infoBox('이 기기', prompt.localUpdatedAt, !cloudNewer),
                const SizedBox(width: 8),
                infoBox('클라우드', prompt.cloudUpdatedAt, cloudNewer),
              ],
            ),
            const SizedBox(height: 8),
            choice(Icons.merge, '최신 기준 병합', '항목별로 더 최신 데이터를 사용 (추천)', MergeChoice.mergeByLatest, primary: true),
            choice(Icons.cloud_download_outlined, '클라우드 사용', '클라우드 데이터를 내려받아 사용', MergeChoice.useCloud),
            choice(Icons.cloud_upload_outlined, '로컬 업로드', '이 기기 데이터를 클라우드로 올림', MergeChoice.keepLocal),
          ],
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────
//  만족도 다이얼로그 (홈 백버튼 종료 시). returns true=종료
// ─────────────────────────────────────────────────────────
Future<bool> showSatisfactionDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;

      Widget faceButton({
        required IconData icon,
        required String label,
        required bool liked,
        required bool primary,
      }) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              ctx.read<AppState>().submitFeedbackForToday(liked);
              Navigator.of(ctx).pop(true);
            },
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                color: primary ? scheme.primaryContainer : scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: primary ? null : Border.all(color: scheme.outline, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 28, color: primary ? scheme.primary : scheme.onSurfaceVariant),
                  const SizedBox(height: 6),
                  Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: primary ? scheme.onPrimaryContainer : scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        );
      }

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('오늘 추천 어땠어요?', style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.w800, color: scheme.onSurface)),
            const SizedBox(height: 6),
            Text('만족도는 다음 추천 품질에 반영돼요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                faceButton(icon: Icons.sentiment_dissatisfied, label: '싫어요', liked: false, primary: false),
                const SizedBox(width: 10),
                faceButton(icon: Icons.sentiment_very_satisfied, label: '좋아요', liked: true, primary: true),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('건너뛰기'),
            ),
          ],
        ),
      );
    },
  );
  return result ?? true;
}
