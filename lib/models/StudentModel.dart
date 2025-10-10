class Student {
  final int id;
  final String lrn;
  String? path;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? sex;
  final String? birthDate;
  final String? disabilityType;
  final String? supportNeed;
  final String? createdAt;
  final String? updatedAt;
  final int isSynced;

  final String? fullName;

  Student({
    required this.id,
    required this.lrn,
    this.path,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.sex,
    this.birthDate,
    this.disabilityType,
    this.supportNeed,
    this.createdAt,
    this.updatedAt,
    this.fullName,
    this.isSynced = 1,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      lrn: json['lrn'],
      path: json['path'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      fullName: json['fullname'],
      sex: json['sex'],
      birthDate: json['birth_date'],
      disabilityType: json['disability_type'],
      supportNeed: json['support_need'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lrn': lrn,
      'path': path,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'sex': sex,
      'birth_date': birthDate,
      'disability_type': disabilityType,
      'support_need': supportNeed,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced,
    };
  }
}
