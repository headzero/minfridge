import 'dart:async';

import '../repositories/local_snapshot_repository.dart';
import '../state/app_state.dart';

class AppStatePersistenceManager {
  AppStatePersistenceManager({required LocalSnapshotRepository repository})
      : _repository = repository;

  final LocalSnapshotRepository _repository;
  Timer? _saveDebounce;
  bool _isSaving = false;

  Future<void> hydrate(AppState appState) async {
    final snapshot = await _repository.loadSnapshot();
    if (snapshot != null) {
      appState.replaceFromSnapshot(snapshot);
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
        } finally {
          _isSaving = false;
        }
      });
    });
  }
}
