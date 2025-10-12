class Feed {
  final int id;
  final int? notifiableId;
  final String group;
  final String title;
  final String message;
  final String? createdAt;
  final String? updatedAt;
  final int isSynced;

  Feed({
    required this.id,
    this.notifiableId,
    required this.group,
    required this.title,
    required this.message,
    this.createdAt,
    this.updatedAt,
    this.isSynced = 1,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'],
      notifiableId: json['notifiable_id'],
      group: json['group_name'] ?? json['group'],
      title: json['title'],
      message: json['message'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notifiable_id': notifiableId,
      'group_name': group,
      'title': title,
      'message': message,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }
}
