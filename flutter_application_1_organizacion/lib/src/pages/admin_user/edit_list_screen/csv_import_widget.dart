import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CsvImportWidget extends StatelessWidget {
  final VoidCallback? onImportComplete;

  const CsvImportWidget({super.key, this.onImportComplete});

  Future<void> importCsv(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final csvData = const Utf8Decoder().convert(bytes);

      // Convertir CSV con delimitador punto y coma
      final rows = const CsvToListConverter(
        fieldDelimiter: ';',
      ).convert(csvData, eol: '\n');

      final batch = FirebaseFirestore.instance.batch();

      for (final row in rows.skip(1)) {
        // saltar encabezados
        if (row.length < 7) continue; // filas incompletas se ignoran

        final docRef = FirebaseFirestore.instance.collection('students').doc();

        batch.set(docRef, {
          'nombre': row[0],
          'apellido': row[1],
          'grado': row[2],
          'seccion': row[3],
          'anio': int.tryParse(row[4].toString()) ?? 0,
          'numero_lista': int.tryParse(row[5].toString()) ?? 0,
          'nivel': row[6],
        });
      }

      try {
        await batch.commit();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Importación completada')));
        if (onImportComplete != null) onImportComplete!();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al importar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => importCsv(context),
      icon: const Icon(Icons.upload_file),
      label: const Text('Importar CSV'),
    );
  }
}
