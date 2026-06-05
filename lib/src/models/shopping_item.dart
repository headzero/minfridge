/// 장보기 항목의 출처. 사용자가 직접 추가했는지, 소진 재료에서 자동 제안됐는지.
enum ShoppingSource { manual, consumed }

class ShoppingItem {
  ShoppingItem({
    required this.id,
    required this.name,
    this.checked = false,
    required this.createdAt,
    this.source = ShoppingSource.manual,
  });

  final String id;
  String name;
  bool checked;
  final DateTime createdAt;
  final ShoppingSource source;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'checked': checked,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'source': source.name,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['createdAt'];
    final source = ShoppingSource.values.firstWhere(
      (e) => e.name == json['source'],
      orElse: () => ShoppingSource.manual,
    );
    return ShoppingItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      checked: json['checked'] == true,
      createdAt: createdRaw is num
          ? DateTime.fromMillisecondsSinceEpoch(createdRaw.toInt())
          : DateTime.fromMillisecondsSinceEpoch(0),
      source: source,
    );
  }
}
