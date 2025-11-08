// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'database_helper.dart';
import 'grade.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const StudentGradeBook());
}

class StudentGradeBook extends StatelessWidget {
  const StudentGradeBook({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Student Grade Book',
      debugShowCheckedModeBanner: false,
      home: GradeBookScreen(),
    );
  }
}

class GradeBookScreen extends StatefulWidget {
  const GradeBookScreen({super.key});

  @override
  State<GradeBookScreen> createState() => _GradeBookScreenState();
}

class _GradeBookScreenState extends State<GradeBookScreen> {
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _marksController = TextEditingController();
  final _gradeController = TextEditingController();
  final _searchController = TextEditingController();

  String _searchQuery = '';

  late Stream<List<Grade>> _gradesStream;

  @override
  void initState() {
    super.initState();
    _gradesStream = DatabaseHelper().getAllGrades();
  }

  void _clearFields() {
    _nameController.clear();
    _subjectController.clear();
    _marksController.clear();
    _gradeController.clear();
  }

  void _addGrade() async {
    if (_nameController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _marksController.text.isEmpty ||
        _gradeController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields")),
      );
      return;
    }
    try {
      final newGrade = Grade(
        studentName: _nameController.text.trim(),
        subject: _subjectController.text.trim(),
        marks: double.tryParse(_marksController.text) ?? 0.0,
        grade: _gradeController.text.trim(),
      );
      await DatabaseHelper().insertGrade(newGrade);
      if (!mounted) return;
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Grade added successfully!"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error adding grade: $e")),
      );
    }
  }

  void _deleteGrade(String id) async {
    try {
      await DatabaseHelper().deleteGrade(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🗑️ Grade deleted"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error deleting grade: $e")),
      );
    }
  }

  void _updateGrade(Grade grade) {
    // Fill inputs with current grade data
    _nameController.text = grade.studentName;
    _subjectController.text = grade.subject;
    _marksController.text = grade.marks.toStringAsFixed(1);
    _gradeController.text = grade.grade;

    // Show dialog for updating grade
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Grade"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
              autocorrect: false,
              enableSuggestions: false,
            ),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: "Subject"),
              autocorrect: false,
              enableSuggestions: false,
            ),
            TextField(
              controller: _marksController,
              decoration: const InputDecoration(labelText: "Marks"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _gradeController,
              decoration: const InputDecoration(labelText: "Grade"),
              autocorrect: false,
              enableSuggestions: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final updatedGrade = Grade(
                  id: grade.id,
                  studentName: _nameController.text.trim(),
                  subject: _subjectController.text.trim(),
                  marks: double.tryParse(_marksController.text) ?? 0.0,
                  grade: _gradeController.text.trim(),
                );
                await DatabaseHelper().updateGrade(updatedGrade);
                if (!mounted) return;
                _clearFields();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✏️ Grade updated successfully!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Error updating grade: $e")),
                );
              }
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () {
              _clearFields();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📚 Student Grade Book")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Student Name"),
              autocorrect: false,
              enableSuggestions: false,
            ),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: "Subject"),
              autocorrect: false,
              enableSuggestions: false,
            ),
            TextField(
              controller: _marksController,
              decoration: const InputDecoration(labelText: "Marks"),
              keyboardType: TextInputType.number,
              autocorrect: false,
              enableSuggestions: false,
            ),
            TextField(
              controller: _gradeController,
              decoration: const InputDecoration(labelText: "Grade"),
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addGrade, child: const Text("Add Grade")),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: "Search by Name or Subject",
                      prefixIcon: Icon(Icons.search),
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = _searchController.text.toLowerCase();
                    });
                  },
                  child: const Text("Search"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Grade>>(
                stream: _gradesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final allGrades = snapshot.data!;
                  final grades = _searchQuery.isEmpty
                      ? allGrades
                      : allGrades.where((grade) =>
                          grade.studentName.toLowerCase().contains(_searchQuery) ||
                          grade.subject.toLowerCase().contains(_searchQuery)).toList();
                  double averageMarks = 0.0;
                  if (grades.isNotEmpty) {
                    averageMarks = grades.fold(0.0, (double sum, Grade g) => sum + g.marks) / grades.length;
                  }
                  if (grades.isEmpty) {
                    return const Center(child: Text("No grades found"));
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: grades.length,
                          itemBuilder: (context, index) {
                            final grade = grades[index];
                            return Card(
                              child: ListTile(
                                title: Text("${grade.studentName} - ${grade.subject}"),
                                subtitle: Text(
                                    "Marks: ${grade.marks.toStringAsFixed(1)} | Grade: ${grade.grade}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _updateGrade(grade),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteGrade(grade.id!),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(thickness: 1),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "📊 Average Marks: ${averageMarks.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}