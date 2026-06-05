import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 추천 히스토리/새로고침 쿼터/만족도 등 기기 로컬 전용 세션 상태를 영속화한다.
///
/// 클라우드 동기화 대상(`AppStateSnapshot`: 냉장고/재고)과 분리되어 있어,
/// 클라우드 pull(`replaceFromSnapshot`)이 히스토리를 덮어쓰지 않는다.
class LocalRecommendationStore {
  static const String _storageKey = 'recommendation_session_v1';

  Future<void> save(Map<String, Object?> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }
}
