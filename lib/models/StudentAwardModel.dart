class StudentAward {
  final int id;
  final int schoolYearId;
  final int studentId;
  final int awardId;
  final String? createdAt;
  final String? updatedAt;
  final int isSynced;

  StudentAward({
    required this.id,
    required this.schoolYearId,
    required this.studentId,
    required this.awardId,
    this.createdAt,
    this.updatedAt,
    this.isSynced = 1,
  });

  factory StudentAward.fromJson(Map<String, dynamic> json) {
    return StudentAward(
      id: json['id'],
      schoolYearId: json['school_year_id'],
      studentId: json['student_id'],
      awardId: json['award_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_year_id': schoolYearId,
      'student_id': studentId,
      'award_id': awardId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }
}
