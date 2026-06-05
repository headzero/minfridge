import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_item.dart';
import '../state/app_state.dart';
import 'sheets.dart';
import 'theme/minfridge_colors.dart';
import 'widgets/common.dart';

enum _GroupMode { urgency, type }

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onOpenToday});

  final VoidCallback onOpenToday;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _prefsKey = 'mf_group_mode';
  _GroupMode _mode = _GroupMode.urgency;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == 'type' && mounted) {
      setState(() => _mode = _GroupMode.type);
    }
  }

  Future<void> _setMode(_GroupMode mode) async {
    setState(() => _mode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode == _GroupMode.type ? 'type' : 'urgency');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final items = state.activeItemsInSelectedFridge;
    final totalQty = items.fold<int>(0, (s, i) => s + i.quantity);

    final sorted = [...items]..sort((a, b) {
      final ra = freshnessRank(freshnessOf(a));
      final rb = freshnessRank(freshnessOf(b));
      if (ra != rb) return ra - rb;
      return (a.daysUntilExpiry ?? 9999).compareTo(b.daysUntilExpiry ?? 9999);
    });

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MfHeader(
            title: '하루한칸',
            actionIcon: Icons.tune,
            onAction: () => showFridgeManagerSheet(context),
          ),
          const SizedBox(height: 6),
          _FridgeChips(
            fridges: state.fridges.map((f) => (id: f.id, name: f.name)).toList(),
            selectedId: state.selectedFridgeId,
            onSelect: state.selectFridge,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: GaugeBar(progress: state.fridgeGaugeProgress, totalQty: totalQty),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: <Widget>[
                MfButtons.primary(
                  label: '식재료 추가',
                  icon: Icons.add,
                  expanded: true,
                  onPressed: () => showItemEditorSheet(context),
                ),
                const SizedBox(width: 8),
                MfButtons.outline(
                  label: '오늘 추천',
                  icon: Icons.restaurant_menu,
                  expanded: true,
                  onPressed: widget.onOpenToday,
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            Expanded(child: _EmptyInventory(onAdd: () => showItemEditorSheet(context)))
          else ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
              child: Row(
                children: <Widget>[
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        const TextSpan(text: '재고 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        TextSpan(text: '$totalQty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: scheme.primary)),
                      ],
                    ),
                    style: TextStyle(color: scheme.onSurface),
                  ),
                  const Spacer(),
                  _GroupToggle(mode: _mode, onChanged: _setMode),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _mode == _GroupMode.urgency
                    ? _UrgencyZones(items: sorted, onTapItem: _openDetail)
                    : _StorageShelves(items: sorted, onTapItem: _openDetail),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openDetail(FoodItem item) => showItemDetailSheet(context, item);
}

class _FridgeChips extends StatelessWidget {
  const _FridgeChips({required this.fridges, required this.selectedId, required this.onSelect});

  final List<({String id, String name})> fridges;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: fridges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = fridges[i];
          final on = f.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(f.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: on ? scheme.primary : scheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: on ? null : Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: <Widget>[
                  if (on) ...<Widget>[
                    Icon(Icons.kitchen, size: 16, color: scheme.onPrimary),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    f.name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: on ? scheme.onPrimary : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupToggle extends StatelessWidget {
  const _GroupToggle({required this.mode, required this.onChanged});

  final _GroupMode mode;
  final ValueChanged<_GroupMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);

    Widget seg(_GroupMode m, String label) {
      final on = m == mode;
      return GestureDetector(
        onTap: () => onChanged(m),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: on ? scheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: on ? <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 2, offset: const Offset(0, 1))] : null,
          ),
          child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: on ? scheme.onSurface : scheme.onSurfaceVariant)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: mf.sunken, borderRadius: BorderRadius.circular(9)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          seg(_GroupMode.urgency, '임박순'),
          const SizedBox(width: 2),
          seg(_GroupMode.type, '칸별'),
        ],
      ),
    );
  }
}

class _UrgencyZones extends StatelessWidget {
  const _UrgencyZones({required this.items, required this.onTapItem});

  final List<FoodItem> items;
  final ValueChanged<FoodItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    final z1 = items.where((i) {
      final f = freshnessOf(i);
      return f == Freshness.urgent || f == Freshness.soon;
    }).toList();
    final z2 = items.where((i) => freshnessOf(i) == Freshness.caution).toList();
    final z3 = items.where((i) => freshnessOf(i) == Freshness.fresh).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Zone(freshness: Freshness.urgent, title: '지금 먹어요', items: z1, onTapItem: onTapItem),
        _Zone(freshness: Freshness.caution, title: '이번 주 안에', items: z2, onTapItem: onTapItem),
        _Zone(freshness: Freshness.fresh, title: '여유 있어요', items: z3, onTapItem: onTapItem),
      ],
    );
  }
}

class _Zone extends StatelessWidget {
  const _Zone({required this.freshness, required this.title, required this.items, required this.onTapItem});

  final Freshness freshness;
  final String title;
  final List<FoodItem> items;
  final ValueChanged<FoodItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final tone = mfColors(context).freshnessTone(freshness);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: <Widget>[
                FreshDot(freshness: freshness, size: 9),
                const SizedBox(width: 7),
                Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(color: tone.tint, borderRadius: BorderRadius.circular(9)),
                  child: Text('${items.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: tone.ink)),
                ),
              ],
            ),
          ),
          TileGrid(items: items, onTapItem: onTapItem),
        ],
      ),
    );
  }
}

class _StorageShelves extends StatelessWidget {
  const _StorageShelves({required this.items, required this.onTapItem});

  final List<FoodItem> items;
  final ValueChanged<FoodItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    final cold = items.where((i) => i.store == StoreType.cold).toList();
    final frozen = items.where((i) => i.store == StoreType.frozen).toList();
    final room = items.where((i) => i.store == StoreType.room).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (cold.isNotEmpty) _Shelf(store: StoreType.cold, items: cold, onTapItem: onTapItem),
        if (frozen.isNotEmpty) _Shelf(store: StoreType.frozen, items: frozen, onTapItem: onTapItem),
        if (room.isNotEmpty) _Shelf(store: StoreType.room, items: room, onTapItem: onTapItem),
      ],
    );
  }
}

class _Shelf extends StatelessWidget {
  const _Shelf({required this.store, required this.items, required this.onTapItem});

  final StoreType store;
  final List<FoodItem> items;
  final ValueChanged<FoodItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    final frozen = store == StoreType.frozen;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: <Widget>[
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: frozen ? mf.frost.tint : mf.sunken,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(storeIcon(store), size: 16, color: frozen ? mf.frost.main : scheme.onSurfaceVariant),
                ),
                const SizedBox(width: 7),
                Text('${storeLabel(store)}칸', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: frozen ? mf.frost.tint : mf.sunken,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text('${items.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: frozen ? mf.frost.ink : scheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          TileGrid(items: items, onTapItem: onTapItem),
        ],
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(26)),
              child: Icon(Icons.kitchen, size: 44, color: scheme.primary),
            ),
            const SizedBox(height: 18),
            Text('냉장고가 비어 있어요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: scheme.onSurface)),
            const SizedBox(height: 7),
            Text(
              '첫 재료를 추가하면 유통기한을 자동으로\n챙겨주고, 오늘 끼니도 추천해 드려요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.5, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            MfButtons.primary(label: '첫 재료 추가하기', icon: Icons.add, onPressed: onAdd),
          ],
        ),
      ),
    );
  }
}
