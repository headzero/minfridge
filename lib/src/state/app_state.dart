import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/app_state_snapshot.dart';
import '../models/food_item.dart';
import '../models/fridge.dart';
import '../models/recommendation.dart';
import '../repositories/recipe_repository.dart';
import '../services/date_key.dart';
import '../services/recommendation_scheduler.dart';

class AppState extends ChangeNotifier {
  AppState({
    required RecipeRepository recipeRepository,
    required RecommendationScheduler scheduler,
  })  : _recipeRepository = recipeRepository,
        _scheduler = scheduler {
    _seedInitialData();
  }

  final RecipeRepository _recipeRepository;
  final RecommendationScheduler _scheduler;

  final List<Fridge> _fridges = <Fridge>[];
  final Map<String, List<FoodItem>> _itemsByFridge = <String, List<FoodItem>>{};
  final Map<String, DailyRecommendation> _recommendations =
      <String, DailyRecommendation>{};
  final Map<String, _RefreshQuota> _quotaByDate = <String, _RefreshQuota>{};
  final Map<String, bool> _feedbackByDate = <String, bool>{};

  String _uid = 'guest-local-user';
  String? _selectedFridgeId;
  DateTime _localUpdatedAt = DateTime.now();

  String get uid => _uid;
  DateTime get localUpdatedAt => _localUpdatedAt;
  UnmodifiableListView<Fridge> get fridges => UnmodifiableListView(_fridges);
  String? get selectedFridgeId => _selectedFridgeId;

  List<FoodItem> get activeItemsInSelectedFridge {
    final id = _selectedFridgeId;
    if (id == null) {
      return const <FoodItem>[];
    }
    final items = _itemsByFridge[id] ?? <FoodItem>[];
    return items.where((e) => e.isActive).toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  }

  Map<String, DailyRecommendation> get recommendationHistory =>
      Map<String, DailyRecommendation>.unmodifiable(_recommendations);

  double get fridgeGaugeProgress {
    final count = activeItemsInSelectedFridge.length;
    const capacity = 30.0;
    return (count / capacity).clamp(0.0, 1.0);
  }

  int get remainingManualRefresh {
    final key = toDateKey(DateTime.now());
    final quota = _quotaByDate.putIfAbsent(key, _RefreshQuota.new);
    return quota.remaining;
  }

  DailyRecommendation? get todayRecommendation {
    return _recommendations[toDateKey(DateTime.now())];
  }

  double get recent7DayLikeRatio {
    final now = DateTime.now();
    final recent = _feedbackByDate.entries.where((entry) {
      final date = DateTime.tryParse(entry.key);
      if (date == null) {
        return false;
      }
      return now.difference(date).inDays < 7;
    }).toList();

    if (recent.isEmpty) {
      return 1.0;
    }
    final likes = recent.where((e) => e.value).length;
    return likes / recent.length;
  }

  Future<void> bootstrap() async {
    await _ensurePregeneratedForToday();
    notifyListeners();
  }

  AppStateSnapshot exportSnapshot() {
    final fridgeSnapshots = _fridges
        .map(
          (f) => FridgeSnapshot(
            id: f.id,
            name: f.name,
            createdAt: f.createdAt,
            updatedAt: f.updatedAt ?? f.createdAt,
            isDefault: f.isDefault,
          ),
        )
        .toList();

    final itemSnapshots = _itemsByFridge.values
        .expand((list) => list)
        .map(
          (item) => FoodItemSnapshot(
            id: item.id,
            fridgeId: item.fridgeId,
            name: item.name,
            type: item.type,
            startedAt: item.startedAt,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
            isActive: item.isActive,
          ),
        )
        .toList();

    return AppStateSnapshot(
      updatedAt: _localUpdatedAt,
      fridges: fridgeSnapshots,
      items: itemSnapshots,
    );
  }

  void replaceFromSnapshot(AppStateSnapshot snapshot) {
    _fridges
      ..clear()
      ..addAll(snapshot.fridges.map((e) => e.toModel()));

    _itemsByFridge.clear();
    for (final itemSnapshot in snapshot.items) {
      final item = itemSnapshot.toModel();
      _itemsByFridge.putIfAbsent(item.fridgeId, () => <FoodItem>[]).add(item);
    }

    _selectedFridgeId = _fridges.isEmpty ? null : _fridges.first.id;
    _localUpdatedAt = snapshot.updatedAt;
    notifyListeners();
  }

  void setUid(String value) {
    _uid = value;
    notifyListeners();
  }

  void selectFridge(String fridgeId) {
    _selectedFridgeId = fridgeId;
    notifyListeners();
  }

  void addFridge(String name) {
    final now = DateTime.now();
    final fridge = Fridge(
      id: _id('fridge'),
      name: name,
      createdAt: now,
      updatedAt: now,
      isDefault: _fridges.isEmpty,
    );
    _fridges.add(fridge);
    _itemsByFridge[fridge.id] = <FoodItem>[];
    _selectedFridgeId ??= fridge.id;
    _touch();
    notifyListeners();
  }

  void renameFridge(String id, String name) {
    final fridge = _fridges.firstWhere((f) => f.id == id);
    fridge.name = name;
    fridge.updatedAt = DateTime.now();
    _touch();
    notifyListeners();
  }

  bool deleteFridge(String id, {String? moveToFridgeId}) {
    if (_fridges.length == 1) {
      return false;
    }
    final target = moveToFridgeId;
    final items = _itemsByFridge[id] ?? <FoodItem>[];
    if (items.isNotEmpty && target != null) {
      final targetList = _itemsByFridge[target] ?? <FoodItem>[];
      for (final item in items) {
        item.fridgeId = target;
        item.updatedAt = DateTime.now();
        targetList.add(item);
      }
      _itemsByFridge[target] = targetList;
    }
    _itemsByFridge.remove(id);
    _fridges.removeWhere((f) => f.id == id);
    if (_selectedFridgeId == id) {
      _selectedFridgeId = _fridges.first.id;
    }
    _touch();
    notifyListeners();
    return true;
  }

  void addItem({
    required String name,
    required FoodType type,
    required DateTime startedAt,
  }) {
    final fridgeId = _selectedFridgeId;
    if (fridgeId == null) {
      return;
    }
    final item = FoodItem(
      id: _id('item'),
      fridgeId: fridgeId,
      name: name,
      type: type,
      startedAt: startedAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _itemsByFridge.putIfAbsent(fridgeId, () => <FoodItem>[]).add(item);
    _touch();
    notifyListeners();
  }

  void updateItem(FoodItem item, {required String name, required DateTime startedAt}) {
    item.name = name;
    item.startedAt = startedAt;
    item.updatedAt = DateTime.now();
    _touch();
    notifyListeners();
  }

  void deleteItem(FoodItem item, {required String reason}) {
    item.isActive = false;
    item.updatedAt = DateTime.now();
    _touch();
    notifyListeners();
  }

  Future<void> generateTodayRecommendationIfMissing() async {
    final now = DateTime.now();
    final key = toDateKey(now);
    if (_recommendations[key]?.status == RecommendationStatus.success) {
      return;
    }

    final rec = await _recipeRepository.generateForDay(
      dateKey: key,
      activeItems: activeItemsInSelectedFridge,
      forceHighQualityModel: _shouldUseHighQualityModel(),
    );

    _recommendations[key] = rec;
    final quota = _quotaByDate.putIfAbsent(key, _RefreshQuota.new);
    quota.successCount += 1;
    notifyListeners();
  }

  Future<bool> manualRefreshToday() async {
    final now = DateTime.now();
    final key = toDateKey(now);
    final quota = _quotaByDate.putIfAbsent(key, _RefreshQuota.new);
    quota.resetIfNeeded(now);

    if (!quota.canTryRefresh) {
      return false;
    }

    quota.consumeTry();
    try {
      final rec = await _recipeRepository.generateForDay(
        dateKey: key,
        activeItems: activeItemsInSelectedFridge,
        forceHighQualityModel: _shouldUseHighQualityModel(),
      );
      rec.refreshCount = quota.used;
      rec.successCount = quota.successCount + 1;
      rec.failureCount = quota.failureCount;
      _recommendations[key] = rec;
      quota.successCount += 1;
      notifyListeners();
      return true;
    } catch (_) {
      quota.failureCount += 1;
      quota.markFailureWindowIfNeeded();
      final failed = DailyRecommendation(
        dateKey: key,
        breakfast: const <String>[],
        lunch: const <String>[],
        dinner: const <String>[],
        generatedAt: DateTime.now(),
        status: RecommendationStatus.failed,
        refreshCount: quota.used,
        failureCount: quota.failureCount,
        successCount: quota.successCount,
      );
      _recommendations[key] = failed;
      notifyListeners();
      return false;
    }
  }

  void submitFeedbackForToday(bool liked) {
    _feedbackByDate[toDateKey(DateTime.now())] = liked;
    notifyListeners();
  }

  Future<void> _ensurePregeneratedForToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateKey = toDateKey(today);
    final existing = _recommendations[dateKey];

    if (existing?.status == RecommendationStatus.success) {
      return;
    }

    final shouldRun = _scheduler.shouldRunPregen(
      uid: _uid,
      now: now,
      targetDate: today,
    );

    if (shouldRun && !_scheduler.isAfterMorningReadOnlyTime(now)) {
      await generateTodayRecommendationIfMissing();
      return;
    }

    if (_scheduler.isAfterMorningReadOnlyTime(now) && existing == null) {
      _recommendations[dateKey] = DailyRecommendation(
        dateKey: dateKey,
        breakfast: const <String>[],
        lunch: const <String>[],
        dinner: const <String>[],
        generatedAt: now,
        status: RecommendationStatus.failed,
      );
    }
  }

  bool _shouldUseHighQualityModel() {
    final lowLikeRatio = recent7DayLikeRatio < 0.4;
    final today = todayRecommendation;
    final lowCoverage = today == null
        ? true
        : (today.breakfast.length + today.lunch.length + today.dinner.length) < 3;
    return lowLikeRatio && lowCoverage;
  }

  void _seedInitialData() {
    addFridge('기본 냉장고');
    addFridge('서브 냉장고');
    selectFridge(fridges.first.id);
    addItem(
      name: '계란',
      type: FoodType.ingredient,
      startedAt: DateTime.now().subtract(const Duration(days: 2)),
    );
    addItem(
      name: '김치',
      type: FoodType.sideDish,
      startedAt: DateTime.now().subtract(const Duration(days: 8)),
    );
  }

  void _touch() {
    _localUpdatedAt = DateTime.now();
  }

  String _id(String prefix) {
    final now = DateTime.now().microsecondsSinceEpoch;
    return '$prefix-$now';
  }
}

class _RefreshQuota {
  _RefreshQuota();

  int used = 0;
  int successCount = 0;
  int failureCount = 0;
  DateTime? blockedUntil;
  DateTime _day = DateTime.now();

  int get remaining => (3 - used).clamp(0, 3);

  bool get canTryRefresh {
    final now = DateTime.now();
    if (remaining > 0) {
      return true;
    }
    if (blockedUntil == null) {
      return false;
    }
    return now.isAfter(blockedUntil!);
  }

  void consumeTry() {
    if (used < 3) {
      used += 1;
      return;
    }
    if (blockedUntil != null && DateTime.now().isAfter(blockedUntil!)) {
      used = 2;
      blockedUntil = null;
      used += 1;
    }
  }

  void markFailureWindowIfNeeded() {
    if (used >= 3 && failureCount >= 3 && successCount == 0) {
      blockedUntil = DateTime.now().add(const Duration(minutes: 10));
    }
  }

  void resetIfNeeded(DateTime now) {
    final newDay = DateTime(now.year, now.month, now.day);
    final day = DateTime(_day.year, _day.month, _day.day);
    if (day != newDay) {
      used = 0;
      successCount = 0;
      failureCount = 0;
      blockedUntil = null;
      _day = now;
    }
  }
}
