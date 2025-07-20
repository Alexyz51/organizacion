import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CsvImportScreen extends StatefulWidget {
  const CsvImportScreen({super.key});

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  bool _isLoading = false;
  String? _message;

  Future<void> _pickAndUploadCsv() async {
    print('>>> _pickAndUploadCsv llamado'); // <-- Mensaje para consola

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        setState(() {
          _isLoading = false;
          _message = 'No se seleccionó ningún archivo.';
        });
        return;
      }

      File file = File(result.files.single.path!);
      final input = file.openRead();

      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(fieldDelimiter: ';'))
          .toList();

      print('Datos CSV leídos:');
      for (var row in fields) {
        print(row);
      }

      if (fields.isEmpty) {
        setState(() {
          _isLoading = false;
          _message = 'El archivo está vacío.';
        });
        return;
      }

      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];

        if (row.length < 7) continue;

        final nivel = row[6].toString();
        final grado = row[2].toString();
        final seccion = row[3].toString();
        final nombre = row[0].toString();
        final apellido = row[1].toString();
        final numeroLista = int.tryParse(row[5].toString()) ?? 0;
        final anio = int.tryParse(row[4].toString()) ?? 0;

        print(
          'Subiendo alumno: $nombre $apellido, Nivel: $nivel, Grado: $grado, Sección: $seccion, Año: $anio, NúmeroLista: $numeroLista',
        );

        await FirebaseFirestore.instance.collection('students').add({
          'nivel': nivel,
          'grado': grado,
          'seccion': seccion,
          'nombre': nombre,
          'apellido': apellido,
          'numero_lista': numeroLista,
          'anio': anio,
        });
      }

      setState(() {
        _isLoading = false;
        _message = 'Importación finalizada correctamente.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error durante la importación: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar alumnos desde CSV')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _pickAndUploadCsv,
              child: const Text('Seleccionar archivo CSV'),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_message != null) Text(_message!),
          ],
        ),
      ),
    );
  }
}
