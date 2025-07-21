import 'package:flutter/material.dart';

class StudentListView extends StatelessWidget {
  final Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> data;
  final void Function(String docId) onDelete;

  const StudentListView({
    super.key,
    required this.data,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: data.entries.map((levelEntry) {
        final level = levelEntry.key; // Ej: "Escolar Básica", "Nivel Medio"
        final grades = levelEntry.value;

        return ExpansionTile(
          key: PageStorageKey(level),
          title: Text(
            level,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          children: grades.entries.map((gradeEntry) {
            final grade = gradeEntry.key; // Ej: "Séptimo", "Primer curso"
            final sections = gradeEntry.value;

            return ExpansionTile(
              key: PageStorageKey('$level-$grade'),
              title: Text(
                grade,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: sections.entries.map((sectionEntry) {
                final section = sectionEntry.key; // Ej: "A", "Informática"
                final students = sectionEntry.value;

                return ExpansionTile(
                  key: PageStorageKey('$level-$grade-$section'),
                  title: Text(
                    'Sección $section',
                    style: const TextStyle(fontSize: 16),
                  ),
                  children: students.map((student) {
                    final fullName =
                        '${student['nombre']} ${student['apellido']}';
                    final listNumber = student['numero_lista'] ?? '-';
                    final docId = student['id'] ?? '';

                    return ListTile(
                      title: Text('$listNumber. $fullName'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (docId.isNotEmpty) onDelete(docId);
                        },
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
