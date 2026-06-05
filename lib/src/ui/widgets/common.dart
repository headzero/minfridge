import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../theme/minfridge_colors.dart';

MinfridgeColors mfColors(BuildContext context) =>
    Theme.of(context).extension<MinfridgeColors>()!;

IconData storeIcon(StoreType store) {
  switch (store) {
    case StoreType.frozen:
      return Icons.ac_unit;
    case StoreType.room:
      return Icons.countertops;
    case StoreType.cold:
      return Icons.kitchen;
  }
}

String storeLabel(StoreType store) {
  switch (store) {
    case StoreType.frozen:
      return '냉동';
    case StoreType.room:
      return '실온';
    case StoreType.cold:
      return '냉장';
  }
}

IconData typeIcon(FoodType type) =>
    type == FoodType.sideDish ? Icons.rice_bowl : Icons.eco;

String itemSubLine(FoodItem item) {
  final parts = <String>['수량 ${item.quantity}개', '보관 ${item.storageDays}일'];
  final d = item.daysUntilExpiry;
  if (d != null) {
    parts.add('유통기한 ${ddayLabel(d)}${item.isExpiryEstimated ? ' (예상)' : ''}');
  }
  return parts.join(' · ');
}

/// 화면 상단 헤더 (제목 + 우측 액션 버튼).
class MfHeader extends StatelessWidget {
  const MfHeader({super.key, required this.title, this.actionIcon, this.onAction});

  final String title;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: scheme.onSurface,
            ),
          ),
          const Spacer(),
          if (actionIcon != null)
            InkResponse(
              onTap: onAction,
              radius: 26,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Icon(actionIcon, size: 21, color: scheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

/// 제목 + 보조설명 (히스토리/설정 등).
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: scheme.onSurface,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 배너 광고 영역 (56px, 점선 placeholder).
class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final mf = mfColors(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      height: 56,
      decoration: BoxDecoration(
        color: mf.sunken,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant, style: BorderStyle.solid),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.ad_units_outlined, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 7),
          Text(
            '배너 광고 영역',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class FreshDot extends StatelessWidget {
  const FreshDot({super.key, required this.freshness, this.size = 9});

  final Freshness freshness;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: mfColors(context).freshnessTone(freshness).main,
        shape: BoxShape.circle,
      ),
    );
  }
}

class FreshChip extends StatelessWidget {
  const FreshChip({super.key, required this.freshness, required this.label});

  final Freshness freshness;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tone = mfColors(context).freshnessTone(freshness);
    return Container(
      height: 22,
      padding: const EdgeInsets.fromLTRB(8, 0, 9, 0),
      decoration: BoxDecoration(
        color: tone.tint,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FreshDot(freshness: freshness, size: 7),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tone.ink),
          ),
        ],
      ),
    );
  }
}

/// 점유율 게이지 카드 (가로 막대 + 2/3 마커 + 상태 문구).
class GaugeBar extends StatelessWidget {
  const GaugeBar({super.key, required this.progress, required this.totalQty});

  final double progress;
  final int totalQty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    final over = progress > 0.66;
    final color = over ? mf.gaugeOver : mf.gaugeOk;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '냉장고 점유율',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              Text(
                '$totalQty / 30',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '${(progress * 100).round()}',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1, color: scheme.onSurface, height: 1),
                    ),
                    TextSpan(
                      text: '%',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: scheme.onSurface),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      return Stack(
                        children: <Widget>[
                          Container(
                            height: 10,
                            decoration: BoxDecoration(color: mf.sunken, borderRadius: BorderRadius.circular(6)),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          Positioned(
                            left: c.maxWidth * 0.66,
                            top: -2,
                            bottom: -2,
                            child: Container(width: 2, color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              Icon(over ? Icons.warning_rounded : Icons.check_circle, size: 14, color: over ? mf.soon.main : mf.gaugeOk),
              const SizedBox(width: 5),
              Text(
                over ? '목표(2/3) 초과' : '목표 이내',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: over ? mf.soon.ink : scheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 3열 그리드용 작은 재고 타일. 탭 → 상세 시트.
class SmallTile extends StatelessWidget {
  const SmallTile({super.key, required this.item, this.onTap});

  final FoodItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    final f = freshnessOf(item);
    final tone = mf.freshnessTone(f);
    final d = item.daysUntilExpiry;
    final isFrozen = item.store == StoreType.frozen;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(11),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: mf.lineSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(height: 3, color: tone.main),
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 6, 9, 8),
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  FreshDot(freshness: f, size: 7),
                  const Spacer(),
                  Text(
                    d != null ? ddayLabel(d) : '${item.storageDays}일',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: tone.ink),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.onSurface),
              ),
              const SizedBox(height: 3),
              Row(
                children: <Widget>[
                  Icon(typeIcon(item.type), size: 12, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${item.quantity}개',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  if (isFrozen)
                    Icon(Icons.ac_unit, size: 12, color: mf.frost.main)
                  else if (item.isExpiryEstimated && d != null)
                    Text('예상', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                ],
              ),
            ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3열 타일 그리드.
class TileGrid extends StatelessWidget {
  const TileGrid({super.key, required this.items, required this.onTapItem});

  final List<FoodItem> items;
  final ValueChanged<FoodItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 86,
      ),
      itemBuilder: (_, i) => SmallTile(item: items[i], onTap: () => onTapItem(items[i])),
    );
  }
}

/// Filled / Outline 1줄 버튼 헬퍼.
class MfButtons {
  static Widget primary({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool expanded = false,
  }) {
    final child = FilledButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
      ),
    );
    return expanded ? Expanded(child: child) : child;
  }

  static Widget outline({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool expanded = false,
  }) {
    final child = OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
      ),
    );
    return expanded ? Expanded(child: child) : child;
  }
}
