class GameActivity {
  final int id;
  final String name;
  final String? createdAt;
  final String? updatedAt;
  final int isSynced;

  GameActivity({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.isSynced = 1,
  });

  factory GameActivity.fromJson(Map<String, dynamic> json) {
    return GameActivity(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isSynced: json['is_synced'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'is_synced': isSynced,
  };
}
