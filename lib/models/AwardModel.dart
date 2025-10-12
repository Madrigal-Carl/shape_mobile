class Award {
  final int id;
  final String name;
  final String description;
  final String path;
  final String? createdAt;
  final String? updatedAt;
  final int isSynced;

  Award({
    required this.id,
    required this.name,
    required this.description,
    required this.path,
    this.createdAt,
    this.updatedAt,
    this.isSynced = 1,
  });

  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      path: json['path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'path': path,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }
}
