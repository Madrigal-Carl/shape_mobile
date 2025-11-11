class Lesson {
  final int id;
  final int schoolYearId;
  final String? subjectName;
  final String title;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
  final int isSynced;

  Lesson({
    required this.id,
    required this.schoolYearId,
    this.subjectName,
    required this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.isSynced = 1,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      schoolYearId: json['school_year_id'],
      subjectName: json['subject_name'],
      title: json['title'] ?? '',
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_year_id': schoolYearId,
      'subject_name': subjectName,
      'title': title,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }
}
