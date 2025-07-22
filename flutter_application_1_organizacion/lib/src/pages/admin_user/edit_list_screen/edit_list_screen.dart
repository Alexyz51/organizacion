import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

class EditListScreen extends StatefulWidget {
  const EditListScreen({super.key});

  @override
  State<EditListScreen> createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {
  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> data = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .get();

    final tempData =
        <String, Map<String, Map<String, List<Map<String, dynamic>>>>>{};

    for (var doc in snapshot.docs) {
      final d = doc.data();
      final nivel = d['nivel'] ?? 'Sin nivel';
      final grado = d['grado'] ?? 'Sin grado';
      final seccion = d['seccion'] ?? 'Sin sección';

      tempData.putIfAbsent(nivel, () => {});
      tempData[nivel]!.putIfAbsent(grado, () => {});
      tempData[nivel]![grado]!.putIfAbsent(seccion, () => []);

      Map<String, dynamic> alumnoConId = Map<String, dynamic>.from(d);
      alumnoConId['docId'] = doc.id;

      tempData[nivel]![grado]![seccion]!.add(alumnoConId);
    }

    // Ordenar niveles, grados y secciones
    tempData.forEach((nivel, grados) {
      var gradosList = grados.keys.toList();
      if (nivel == 'Nivel Medio') {
        gradosList.sort((a, b) {
          int? aNum = int.tryParse(a);
          int? bNum = int.tryParse(b);
          if (aNum != null && bNum != null) {
            return aNum.compareTo(bNum);
          }
          return a.compareTo(b);
        });
      } else {
        gradosList.sort();
      }

      final gradosOrdenadosMap =
          <String, Map<String, List<Map<String, dynamic>>>>{};
      for (var grado in gradosList) {
        final secciones = grados[grado]!;

        List<String> seccionesOrdenadas = secciones.keys.toList();
        if (nivel == 'Nivel Medio') {
          seccionesOrdenadas.sort((a, b) {
            if (a == 'A') return -1;
            if (b == 'A') return 1;
            return a.compareTo(b);
          });
        } else {
          seccionesOrdenadas.sort();
        }

        final seccionesOrdenadasMap = <String, List<Map<String, dynamic>>>{};
        for (var sec in seccionesOrdenadas) {
          final alumnos = secciones[sec]!;
          alumnos.sort(
            (a, b) =>
                (a['numero_lista'] as int).compareTo(b['numero_lista'] as int),
          );
          seccionesOrdenadasMap[sec] = alumnos;
        }

        gradosOrdenadosMap[grado] = seccionesOrdenadasMap;
      }

      tempData[nivel] = gradosOrdenadosMap;
    });

    setState(() {
      data = tempData;
      loading = false;
    });
  }

  Future<void> _deleteAllStudents() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: const Text('¿Seguro quieres borrar toda la lista de alumnos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirm) {
      final batch = FirebaseFirestore.instance.batch();
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      _loadData();
    }
  }

  Future<void> _importCsvDirectamente() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      final bytes = result.files.single.bytes;
      if (bytes == null) throw 'No se pudieron obtener los datos del archivo.';
      final content = utf8.decode(bytes);

      final fields = const CsvToListConverter(
        fieldDelimiter: ';',
      ).convert(content);

      if (fields.isEmpty) {
        setState(() {
          loading = false;
        });
        return;
      }

      // Borrar toda la colección students
      final batch = FirebaseFirestore.instance.batch();
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Agregar todos los alumnos del CSV
      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length < 7) continue;

        final data = {
          'nombre': row[0].toString(),
          'apellido': row[1].toString(),
          'grado': row[2].toString(),
          'seccion': row[3].toString(),
          'anio': int.tryParse(row[4].toString()) ?? 0,
          'numero_lista': int.tryParse(row[5].toString()) ?? 0,
          'nivel': row[6].toString(),
        };

        await FirebaseFirestore.instance.collection('students').add(data);
      }

      await _loadData();
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _confirmAndImportCsv() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar importación'),
        content: const Text(
          'Esta acción borrará la lista actual y cargará los datos del archivo CSV. ¿Querés continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );

    if (confirm) {
      await _importCsvDirectamente();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar lista'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.file_upload),
                label: const Text('Importar CSV'),
                onPressed: _confirmAndImportCsv,
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: const Text('Borrar todo'),
                onPressed: _deleteAllStudents,
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: data.entries.map((nivelEntry) {
                final nivel = nivelEntry.key;
                final grados = nivelEntry.value;

                return ExpansionTile(
                  title: Text(nivel),
                  children: grados.entries.map((gradoEntry) {
                    final grado = gradoEntry.key;
                    final secciones = gradoEntry.value;

                    return ExpansionTile(
                      title: Text(
                        nivel == 'Nivel Medio'
                            ? '$grado curso'
                            : 'Grado: $grado',
                      ),
                      children: secciones.entries.map((seccionEntry) {
                        final seccion = seccionEntry.key;
                        final alumnos = seccionEntry.value;

                        return ExpansionTile(
                          title: Text('Sección: $seccion'),
                          children: alumnos.map((alumno) {
                            return ListTile(
                              title: Text(
                                '${alumno['numero_lista']}  ${alumno['nombre']} ${alumno['apellido']}',
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
