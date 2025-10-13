class GameActivityLesson {
  final int id;
  final int? lessonId;
  final int gameActivityId;
  final String? createdAt;
  final String? updatedAt;
  final int isSynced;

  GameActivityLesson({
    required this.id,
    this.lessonId,
    required this.gameActivityId,
    this.createdAt,
    this.updatedAt,
    this.isSynced = 1,
  });

  factory GameActivityLesson.fromJson(Map<String, dynamic> json) {
    return GameActivityLesson(
      id: json['id'],
      lessonId: json['lesson_id'],
      gameActivityId: json['game_activity_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isSynced: json['is_synced'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'lesson_id': lessonId,
    'game_activity_id': gameActivityId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'is_synced': isSynced,
  };
}
