class Video {
  final int id;
  final int lessonId;
  final String url;
  final String title;
  final String? thumbnail;
  final String? createdAt;
  final String? updatedAt;
  final int isSynced;

  Video({
    required this.id,
    required this.lessonId,
    required this.url,
    required this.title,
    this.thumbnail,
    this.createdAt,
    this.updatedAt,
    this.isSynced = 1,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      lessonId: json['lesson_id'],
      url: json['url'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isSynced: json['is_synced'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'url': url,
      'title': title,
      'thumbnail': thumbnail,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }
}
