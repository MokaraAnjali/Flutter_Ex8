import 'package:cloud_firestore/cloud_firestore.dart';
import 'grade.dart';

class DatabaseHelper {
  static final CollectionReference grades =
      FirebaseFirestore.instance.collection('grades');

  Future<void> insertGrade(Grade grade) async {
    await grades.add(grade.toMap());
  }

  Stream<List<Grade>> getAllGrades() {
    return grades.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Grade.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> updateGrade(Grade grade) async {
    if (grade.id != null) {
      await grades.doc(grade.id).update(grade.toMap());
    }
  }

  Future<void> deleteGrade(String id) async {
    await grades.doc(id).delete();
  }
}