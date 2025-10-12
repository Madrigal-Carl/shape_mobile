class StudentActivity {
  final int id;
  final int studentId;
  final int activityLessonId;
  final String activityLessonType;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final int isSynced;

  StudentActivity({
    required this.id,
    required this.studentId,
    required this.activityLessonId,
    required this.activityLessonType,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.isSynced = 1,
  });

  factory StudentActivity.fromJson(Map<String, dynamic> json) {
    return StudentActivity(
      id: json['id'],
      studentId: json['student_id'],
      activityLessonId: json['activity_lesson_id'],
      activityLessonType: json['activity_lesson_type'],
      status: json['status'] ?? 'unfinished',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isSynced: json['is_synced'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'student_id': studentId,
    'activity_lesson_id': activityLessonId,
    'activity_lesson_type': activityLessonType,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'is_synced': isSynced,
  };
}
