import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_item.dart';
import '../services/date_key.dart';
import '../state/app_state.dart';
import 'theme/minfridge_colors.dart';
import 'widgets/common.dart';

/// 공통 바텀시트 래퍼 (둥근 상단 + 핸들).
Future<T?> _showSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: builder,
  );
}

Widget _grabber(BuildContext context) => Center(
  child: Container(
    width: 38,
    height: 4,
    margin: const EdgeInsets.only(top: 10, bottom: 14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.outlineVariant,
      borderRadius: BorderRadius.circular(4),
    ),
  ),
);

// ─────────────────────────────────────────────────────────
//  아이템 상세 시트 (탭 → 정보 + 소진/수정/폐기)
// ─────────────────────────────────────────────────────────
Future<void> showItemDetailSheet(BuildContext context, FoodItem item) {
  return _showSheet<void>(
    context,
    (ctx) => _ItemDetailSheet(item: item),
  );
}

class _ItemDetailSheet extends StatelessWidget {
  const _ItemDetailSheet({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    final f = freshnessOf(item);
    final tone = mf.freshnessTone(f);
    final d = item.daysUntilExpiry;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).viewPadding.bottom +
            22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _grabber(context),
          Row(
            children: <Widget>[
              FreshDot(freshness: f, size: 11),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: scheme.onSurface),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 유통기한 정보 블록
          if (d != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: tone.tint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('유통기한까지', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tone.ink)),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        ddayLabel(d),
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: scheme.onSurface),
                      ),
                      const SizedBox(width: 8),
                      if (item.isExpiryEstimated)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(8)),
                          child: Text('예상값', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tone.ink)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.isExpiryEstimated
                        ? '이름·유형·보관방식으로 자동 추정 · 정확한 날짜는 ‘수정’에서'
                        : '직접 입력한 날짜예요.',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          _detailRow(
            context,
            '수량',
            _QuantityStepper(
              value: item.quantity,
              onChanged: (v) => state.setItemQuantity(item, v),
            ),
            top: d != null,
          ),
          _detailRow(
            context,
            '유형',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(typeIcon(item.type), size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(item.type == FoodType.sideDish ? '반찬' : '식재료',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: scheme.onSurface)),
              ],
            ),
            top: true,
          ),
          _detailRow(
            context,
            '보관',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(storeIcon(item.store), size: 16, color: item.store == StoreType.frozen ? mf.frost.main : scheme.onSurfaceVariant),
                const SizedBox(width: 5),
                Text('${storeLabel(item.store)} · ${item.storageDays}일째',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: scheme.onSurface)),
              ],
            ),
            top: true,
          ),
          const SizedBox(height: 16),
          MfButtons.primary(
            label: '다 먹었어요 · 소진',
            icon: Icons.check,
            onPressed: () {
              state.deleteItem(item, reason: 'consumed');
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              MfButtons.outline(
                label: '수정',
                icon: Icons.edit_outlined,
                expanded: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  showItemEditorSheet(context, editing: item);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    state.deleteItem(item, reason: 'discarded');
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.delete_outline, size: 19, color: tone.main),
                  label: Text('폐기', style: TextStyle(color: tone.ink)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, Widget trailing, {bool top = false}) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: top ? Border(top: BorderSide(color: mf.lineSoft)) : null,
      ),
      child: Row(
        children: <Widget>[
          Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    return Container(
      decoration: BoxDecoration(color: mf.sunken, borderRadius: BorderRadius.circular(11)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: Icon(Icons.remove, size: 18, color: scheme.onSurfaceVariant),
          ),
          SizedBox(
            width: 34,
            child: Text('$value개', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: scheme.onSurface)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(value + 1),
            icon: Icon(Icons.add, size: 18, color: scheme.primary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  추가 / 수정 시트
// ─────────────────────────────────────────────────────────
Future<void> showItemEditorSheet(BuildContext context, {FoodItem? editing}) {
  return _showSheet<void>(context, (ctx) => _ItemEditorSheet(editing: editing));
}

class _ItemEditorSheet extends StatefulWidget {
  const _ItemEditorSheet({this.editing});

  final FoodItem? editing;

  @override
  State<_ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<_ItemEditorSheet> {
  late final TextEditingController _name;
  late int _quantity;
  late FoodType _type;
  late StoreType _store;
  late DateTime _startedAt;
  DateTime? _manualExpiry;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _name = TextEditingController(text: e?.name ?? '');
    _quantity = e?.quantity ?? 1;
    _type = e?.type ?? FoodType.ingredient;
    _store = e?.store ?? StoreType.cold;
    _startedAt = e?.startedAt ?? DateTime.now();
    _manualExpiry = e?.expirySource == ExpirySource.manual ? e?.expiresAt : null;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = context.read<AppState>();
    final effectiveExpiry = _manualExpiry ??
        state.estimateExpiry(
          name: _name.text.trim(),
          type: _type,
          startedAt: _startedAt,
          store: _store,
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).viewPadding.bottom +
            20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _grabber(context),
            Text(
              widget.editing == null ? '식재료 추가' : '식재료 수정',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: scheme.onSurface),
            ),
            const SizedBox(height: 16),
            _label('이름'),
            TextField(
              controller: _name,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: '예: 손두부'),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _label('수량'),
                    _QuantityStepper(value: _quantity, onChanged: (v) => setState(() => _quantity = v)),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('유형'),
                      _segmented<FoodType>(
                        value: _type,
                        options: const <FoodType, String>{
                          FoodType.ingredient: '식재료',
                          FoodType.sideDish: '반찬',
                        },
                        onChanged: (v) => setState(() => _type = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _label('보관 방식'),
            _segmented<StoreType>(
              value: _store,
              options: const <StoreType, String>{
                StoreType.cold: '냉장',
                StoreType.frozen: '냉동',
                StoreType.room: '실온',
              },
              onChanged: (v) => setState(() => _store = v),
            ),
            const SizedBox(height: 12),
            _label('보관 시작일'),
            _fieldBox(
              child: Row(
                children: <Widget>[
                  Text(toDateKey(_startedAt), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: scheme.onSurface)),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 18, color: scheme.onSurfaceVariant),
                ],
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDate: _startedAt,
                );
                if (picked != null) setState(() => _startedAt = picked);
              },
            ),
            const SizedBox(height: 12),
            _label('유통기한 (선택)'),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scheme.primary, width: 1.5),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(toDateKey(effectiveExpiry),
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                _manualExpiry == null ? '예상·선택' : '직접 입력',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: scheme.onPrimaryContainer),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _manualExpiry == null ? '자동 추정값이에요. 비워둬도 괜찮아요.' : '직접 지정한 날짜예요.',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: scheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            initialDate: effectiveExpiry,
                          );
                          if (picked != null) setState(() => _manualExpiry = picked);
                        },
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('직접 입력'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (_manualExpiry != null)
                        TextButton(
                          onPressed: () => setState(() => _manualExpiry = null),
                          child: const Text('예상값으로'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            MfButtons.primary(
              label: '저장',
              icon: Icons.check,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty || _quantity < 1) {
      return;
    }
    final state = context.read<AppState>();
    if (widget.editing == null) {
      state.addItem(
        name: name,
        type: _type,
        quantity: _quantity,
        store: _store,
        startedAt: _startedAt,
        expiresAt: _manualExpiry,
      );
    } else {
      state.updateItem(
        widget.editing!,
        name: name,
        quantity: _quantity,
        store: _store,
        startedAt: _startedAt,
        expiresAt: _manualExpiry,
      );
    }
    Navigator.of(context).pop();
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurfaceVariant)),
  );

  Widget _fieldBox({required Widget child, VoidCallback? onTap}) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline, width: 1.5),
        ),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }

  Widget _segmented<E>({
    required E value,
    required Map<E, String> options,
    required ValueChanged<E> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: mf.sunken, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: options.entries.map((e) {
          final on = e.key == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: on ? scheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: on ? <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 3, offset: const Offset(0, 1))] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: on ? scheme.onSurface : scheme.onSurfaceVariant),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  냉장고 관리 시트
// ─────────────────────────────────────────────────────────
Future<void> showFridgeManagerSheet(BuildContext context) {
  return _showSheet<void>(context, (ctx) => const _FridgeManagerSheet());
}

class _FridgeManagerSheet extends StatefulWidget {
  const _FridgeManagerSheet();

  @override
  State<_FridgeManagerSheet> createState() => _FridgeManagerSheetState();
}

class _FridgeManagerSheetState extends State<_FridgeManagerSheet> {
  final TextEditingController _newName = TextEditingController();

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    final fridges = state.fridges;

    final canReorder = fridges.length > 1;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).viewPadding.bottom +
            22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _grabber(context),
          Row(
            children: <Widget>[
              Text('냉장고 관리', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: scheme.onSurface)),
              if (canReorder) ...<Widget>[
                const SizedBox(width: 8),
                Text('· 끌어서 순서 변경', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            buildDefaultDragHandles: false,
            itemCount: fridges.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              context.read<AppState>().reorderFridges(oldIndex, newIndex);
            },
            itemBuilder: (context, i) {
              final fridge = fridges[i];
              return Padding(
                key: ValueKey<String>(fridge.id),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: <Widget>[
                    if (canReorder)
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.drag_handle, size: 20, color: scheme.onSurfaceVariant),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(fridge.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: scheme.onSurface)),
                          if (fridge.id == state.selectedFridgeId)
                            Text('현재 선택됨', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: scheme.primary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.drive_file_rename_outline, size: 19, color: scheme.onSurfaceVariant),
                      onPressed: () => _rename(context, fridge.id, fridge.name),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 19, color: scheme.onSurfaceVariant),
                      onPressed: () {
                        if (fridges.length <= 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('마지막 1개 냉장고는 삭제할 수 없어요.')),
                          );
                          return;
                        }
                        final moveTarget = fridges.firstWhere((f) => f.id != fridge.id).id;
                        state.deleteFridge(fridge.id, moveToFridgeId: moveTarget);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Divider(color: mf.lineSoft, height: 24),
          _label(context, '새 냉장고 추가'),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _newName,
                  decoration: const InputDecoration(hintText: '예: 베란다 냉장고'),
                ),
              ),
              const SizedBox(width: 8),
              MfButtons.primary(
                label: '추가',
                icon: Icons.add,
                onPressed: () {
                  final name = _newName.text.trim();
                  if (name.isEmpty) return;
                  state.addFridge(name);
                  _newName.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Icon(Icons.info_outline, size: 13, color: scheme.onSurfaceVariant),
              const SizedBox(width: 5),
              Text('마지막 1개 냉장고는 삭제할 수 없어요.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, String id, String current) async {
    final controller = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('냉장고 이름 변경'),
        content: TextField(controller: controller, autofocus: true),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('저장')),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && context.mounted) {
      context.read<AppState>().renameFridge(id, newName);
    }
  }

  Widget _label(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurfaceVariant)),
  );
}
