import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/shopping_item.dart';
import '../state/app_state.dart';
import 'widgets/common.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add() {
    final name = _input.text.trim();
    if (name.isEmpty) return;
    context.read<AppState>().addShoppingItem(name);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final items = state.shoppingList.toList()
      ..sort((a, b) {
        if (a.checked != b.checked) return a.checked ? 1 : -1; // 미체크 먼저
        return a.createdAt.compareTo(b.createdAt);
      });
    final hasChecked = items.any((e) => e.checked);

    return Scaffold(
      appBar: AppBar(
        title: const Text('장보기'),
        actions: <Widget>[
          if (hasChecked)
            TextButton(
              onPressed: state.clearCheckedShoppingItems,
              child: const Text('담은 항목 비우기'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _add(),
                      decoration: const InputDecoration(hintText: '살 것을 입력하세요 (예: 우유)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MfButtons.primary(label: '추가', icon: Icons.add, onPressed: _add),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? _Empty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _ShoppingRow(item: items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingRow extends StatelessWidget {
  const _ShoppingRow({required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    final checked = item.checked;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => state.toggleShoppingItem(item),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: mf.lineSoft),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                checked ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 22,
                color: checked ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: checked ? scheme.onSurfaceVariant : scheme.onSurface,
                    decoration: checked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (item.source == ShoppingSource.consumed && !checked)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: mf.sunken, borderRadius: BorderRadius.circular(9)),
                  child: Text('소진', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close, size: 18, color: scheme.onSurfaceVariant),
                onPressed: () => state.removeShoppingItem(item),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
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
              child: Icon(Icons.shopping_cart_outlined, size: 42, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            Text('장보기 목록이 비어 있어요', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: scheme.onSurface)),
            const SizedBox(height: 7),
            Text(
              '살 것을 추가하거나, 재료를 다 먹고 소진하면\n여기에 다시 살 후보로 담겨요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.5, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
