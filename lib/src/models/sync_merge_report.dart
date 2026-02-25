class SyncMergeReport {
  SyncMergeReport({
    required this.fridgeFromLocal,
    required this.fridgeFromCloud,
    required this.itemFromLocal,
    required this.itemFromCloud,
    required this.resultUpdatedAt,
  });

  final int fridgeFromLocal;
  final int fridgeFromCloud;
  final int itemFromLocal;
  final int itemFromCloud;
  final DateTime resultUpdatedAt;
}
