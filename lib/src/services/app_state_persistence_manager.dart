import 'dart:async';

import '../repositories/local_recommendation_store.dart';
import '../repositories/local_snapshot_repository.dart';
import '../state/app_state.dart';

class AppStatePersistenceManager {
  AppStatePersistenceManager({
    required LocalSnapshotRepository repository,
    required LocalRecommendationStore recommendationStore,
  })  : _repository = repository,
        _recommendationStore = recommendationStore;

  final LocalSnapshotRepository _repository;
  final LocalRecommendationStore _recommendationStore;
  Timer? _saveDebounce;
  bool _isSaving = false;

  Future<void> hydrate(AppState appState) async {
    final snapshot = await _repository.loadSnapshot();
    if (snapshot != null) {
      appState.replaceFromSnapshot(snapshot);
    }
    final session = await _recommendationStore.load();
    if (session != null) {
      appState.importSessionState(session);
    }
  }

  void bindAutoSave(AppState appState) {
    appState.addListener(() {
      _saveDebounce?.cancel();
      _saveDebounce = Timer(const Duration(milliseconds: 700), () async {
        if (_isSaving) {
          return;
        }
        _isSaving = true;
        try {
          await _repository.saveSnapshot(appState.exportSnapshot());
          await _recommendationStore.save(appState.exportSessionState());
        } finally {
          _isSaving = false;
        }
      });
    });
  }
}
