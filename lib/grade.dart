class Grade {
  String? id;
  String studentName;
  String subject;
  double marks;
  String grade;

  Grade({
    this.id,
    required this.studentName,
    required this.subject,
    required this.marks,
    required this.grade,
  });

  factory Grade.fromMap(Map<String, dynamic> map, [String? id]) {
    return Grade(
      id: id,
      studentName: map['studentName'] ?? '',
      subject: map['subject'] ?? '',
      marks: (map['marks'] is int)
          ? (map['marks'] as int).toDouble()
          : map['marks'] ?? 0.0,
      grade: map['grade'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'subject': subject,
      'marks': marks,
      'grade': grade,
    };
  }
}