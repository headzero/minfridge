import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/food_item.dart';
import '../models/recommendation.dart';
import '../services/date_key.dart';
import '../state/app_state.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final shouldExit = await _onWillPop();
        if (shouldExit && mounted) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const <Widget>[
            _HomePage(),
            _TodayPage(),
            _HistoryPage(),
            _SettingsPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.kitchen_outlined), label: '홈'),
            NavigationDestination(icon: Icon(Icons.restaurant_menu), label: '오늘 추천'),
            NavigationDestination(icon: Icon(Icons.history), label: '히스토리'),
            NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_index != 0) {
      setState(() => _index = 0);
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오늘 추천 만족도'),
        content: const Text('오늘 추천이 도움이 되었나요? (선택 입력)'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              context.read<AppState>().submitFeedbackForToday(false);
              Navigator.of(context).pop(true);
            },
            child: const Text('싫어요'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().submitFeedbackForToday(true);
              Navigator.of(context).pop(true);
            },
            child: const Text('좋아요'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('건너뛰기'),
          ),
        ],
      ),
    );
    return result ?? true;
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.activeItemsInSelectedFridge;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text('하루한칸', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => _showFridgeManager(context),
                  icon: const Icon(Icons.tune),
                  tooltip: '냉장고 관리',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _FridgeTabs(
              selectedFridgeId: state.selectedFridgeId,
              onSelect: state.selectFridge,
            ),
            const SizedBox(height: 16),
            _GaugeCard(progress: state.fridgeGaugeProgress),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () => _showItemEditor(context),
                  icon: const Icon(Icons.add),
                  label: const Text('식재료 추가'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const _TodayPage()),
                  ),
                  icon: const Icon(Icons.restaurant),
                  label: const Text('오늘 추천 보기'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('재고 (${items.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final item = items[index];
                  return _FoodTile(item: item);
                },
              ),
            ),
            const _AdBannerPlaceholder(),
          ],
        ),
      ),
    );
  }
}

class _TodayPage extends StatelessWidget {
  const _TodayPage();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final recommendation = state.todayRecommendation;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('오늘의 추천', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('수동 새로고침 남은 횟수: ${state.remainingManualRefresh}회'),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () async {
                    final ok = await context.read<AppState>().manualRefreshToday();
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? '추천을 새로 생성했습니다.' : '재시도 제한에 도달했습니다.')),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('수동 새로고침'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => context.read<AppState>().generateTodayRecommendationIfMissing(),
                  child: const Text('오늘 조회'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recommendation == null || recommendation.status == RecommendationStatus.failed)
              _FailureCard(recommendation: recommendation)
            else
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _MealSection(title: '아침', values: recommendation.breakfast),
                    _MealSection(title: '점심', values: recommendation.lunch),
                    _MealSection(title: '저녁', values: recommendation.dinner),
                  ],
                ),
              ),
            const _AdBannerPlaceholder(),
          ],
        ),
      ),
    );
  }
}

class _HistoryPage extends StatelessWidget {
  const _HistoryPage();

  @override
  Widget build(BuildContext context) {
    final recs = context.watch<AppState>().recommendationHistory.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('추천 히스토리 (1년)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: recs.length,
                itemBuilder: (_, index) {
                  final row = recs[index];
                  final rec = row.value;
                  return Card(
                    child: ListTile(
                      title: Text(row.key),
                      subtitle: Text(
                        rec.status == RecommendationStatus.success
                            ? '아침 ${rec.breakfast.length} / 점심 ${rec.lunch.length} / 저녁 ${rec.dinner.length}'
                            : '생성 실패',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('설정', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.notifications_active_outlined),
              title: Text('알림 권한: 사용 (MVP)'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('사용자 식별자 (UID)'),
              subtitle: Text(state.uid),
            ),
            ListTile(
              leading: const Icon(Icons.thumb_up_alt_outlined),
              title: const Text('최근 7일 좋아요 비율'),
              subtitle: Text('${(state.recent7DayLikeRatio * 100).toStringAsFixed(1)}%'),
            ),
            const Spacer(),
            const Text('Firebase 연동 가이드는 lib/src/repositories/firebase_guide.md 참고'),
          ],
        ),
      ),
    );
  }
}

class _FridgeTabs extends StatelessWidget {
  const _FridgeTabs({required this.selectedFridgeId, required this.onSelect});

  final String? selectedFridgeId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final fridges = context.watch<AppState>().fridges;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: fridges
            .map(
              (f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f.name),
                  selected: selectedFridgeId == f.id,
                  onSelected: (_) => onSelect(f.id),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _GaugeCard extends StatelessWidget {
  const _GaugeCard({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final overTarget = progress > 0.66;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '냉장고 점유율 ${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: overTarget ? Colors.deepOrange : Colors.teal,
              backgroundColor: Colors.black12,
            ),
            const SizedBox(height: 8),
            Text(overTarget ? '주의: 목표(2/3) 초과' : '목표 이내'),
          ],
        ),
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _storageColor(item.storageDays),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('보관 ${item.storageDays}일'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showItemEditor(context, editing: item),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteReasonDialog(context, item),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            for (final value in values) Text('• $value'),
          ],
        ),
      ),
    );
  }
}

class _FailureCard extends StatelessWidget {
  const _FailureCard({required this.recommendation});

  final DailyRecommendation? recommendation;

  @override
  Widget build(BuildContext context) {
    final failures = recommendation?.failureCount ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('추천 생성 실패', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('실패 횟수: $failures'),
            const SizedBox(height: 8),
            const Text('새로고침 버튼으로 다시 시도해 주세요.'),
          ],
        ),
      ),
    );
  }
}

class _AdBannerPlaceholder extends StatelessWidget {
  const _AdBannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text('배너 광고 영역 (항상 노출)'),
    );
  }
}

Color _storageColor(int days) {
  if (days <= 3) {
    return const Color(0xFFE8F5E9);
  }
  if (days <= 7) {
    return const Color(0xFFFFFDE7);
  }
  if (days <= 14) {
    return const Color(0xFFFFF3E0);
  }
  if (days <= 28) {
    return const Color(0xFFFFE0B2);
  }
  return const Color(0xFFFFCDD2);
}

Future<void> _showItemEditor(BuildContext context, {FoodItem? editing}) async {
  final state = context.read<AppState>();
  final nameController = TextEditingController(text: editing?.name ?? '');
  FoodType type = editing?.type ?? FoodType.ingredient;
  DateTime startedAt = editing?.startedAt ?? DateTime.now();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(editing == null ? '식재료 추가' : '식재료 수정', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: '이름')),
            const SizedBox(height: 8),
            DropdownButtonFormField<FoodType>(
              value: type,
              items: const <DropdownMenuItem<FoodType>>[
                DropdownMenuItem(value: FoodType.ingredient, child: Text('식재료')),
                DropdownMenuItem(value: FoodType.sideDish, child: Text('반찬')),
              ],
              onChanged: (v) => type = v ?? FoodType.ingredient,
              decoration: const InputDecoration(labelText: '유형'),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Text('보관 시작일: ${toDateKey(startedAt)}'),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDate: startedAt,
                    );
                    if (picked != null) {
                      startedAt = picked;
                    }
                  },
                  child: const Text('날짜 선택'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  return;
                }
                if (editing == null) {
                  state.addItem(name: name, type: type, startedAt: startedAt);
                } else {
                  state.updateItem(editing, name: name, startedAt: startedAt);
                }
                Navigator.of(context).pop();
              },
              child: const Text('저장'),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showDeleteReasonDialog(BuildContext context, FoodItem item) async {
  final reason = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('삭제 사유 선택'),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop('consumed'), child: const Text('소진')),
        TextButton(onPressed: () => Navigator.of(context).pop('discarded'), child: const Text('폐기')),
      ],
    ),
  );

  if (reason != null && context.mounted) {
    context.read<AppState>().deleteItem(item, reason: reason);
  }
}

Future<void> _showFridgeManager(BuildContext context) async {
  final state = context.read<AppState>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      final nameController = TextEditingController();
      return StatefulBuilder(
        builder: (context, setModalState) {
          final fridges = state.fridges;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('냉장고 관리', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final fridge in fridges)
                  ListTile(
                    title: Text(fridge.name),
                    subtitle: Text(fridge.id == state.selectedFridgeId ? '현재 선택됨' : ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.drive_file_rename_outline),
                          onPressed: () async {
                            final controller = TextEditingController(text: fridge.name);
                            final newName = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('냉장고 이름 변경'),
                                content: TextField(controller: controller),
                                actions: <Widget>[
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                                  TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('저장')),
                                ],
                              ),
                            );
                            if (newName != null && newName.isNotEmpty) {
                              state.renameFridge(fridge.id, newName);
                              setModalState(() {});
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            if (fridges.length <= 1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('최소 1개의 냉장고는 유지되어야 합니다.')),
                              );
                              return;
                            }
                            final moveTarget = fridges.firstWhere((f) => f.id != fridge.id).id;
                            state.deleteFridge(fridge.id, moveToFridgeId: moveTarget);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '새 냉장고 이름'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      return;
                    }
                    state.addFridge(name);
                    nameController.clear();
                    setModalState(() {});
                  },
                  child: const Text('냉장고 추가'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
