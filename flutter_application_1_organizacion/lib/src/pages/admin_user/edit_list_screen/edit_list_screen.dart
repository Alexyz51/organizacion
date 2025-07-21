// 📄 edit_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'csv_import_widget.dart';
import 'student_list_view.dart';
import 'add_student_dialog.dart';

class EditListScreen extends StatefulWidget {
  const EditListScreen({super.key});

  @override
  State<EditListScreen> createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {
  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>
  studentsByLevel = {};

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .get();
    final docs = snapshot.docs;

    final tempData =
        <String, Map<String, Map<String, List<Map<String, dynamic>>>>>{};

    for (var doc in docs) {
      final data = doc.data();
      final level = (data['nivel'] ?? '').toString().trim();
      final grade = (data['grado'] ?? '').toString().trim();
      final section = (data['seccion'] ?? '').toString().trim();
      final mapData = {...data, 'id': doc.id};

      tempData.putIfAbsent(level, () => {});
      tempData[level]!.putIfAbsent(grade, () => {});
      tempData[level]![grade]!.putIfAbsent(section, () => []);
      tempData[level]![grade]![section]!.add(mapData);
    }

    setState(() {
      studentsByLevel = tempData;
    });
  }

  void _deleteStudent(String docId) async {
    await FirebaseFirestore.instance.collection('students').doc(docId).delete();
    fetchStudents();
  }

  void _showAddDialog() async {
    final added = await showAddStudentDialog(context);
    if (added == true) fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Lista de Alumnos')),
      body: Column(
        children: [
          CsvImportWidget(onImportComplete: fetchStudents),
          Expanded(
            child: StudentListView(
              data: studentsByLevel,
              onDelete: _deleteStudent,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
