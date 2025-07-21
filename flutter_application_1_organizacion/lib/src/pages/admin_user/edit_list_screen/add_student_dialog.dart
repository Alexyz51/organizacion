import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool?> showAddStudentDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();

  String nombre = '';
  String apellido = '';
  String grado = '';
  String seccion = '';
  String nivel = '';
  int numeroLista = 0;
  int anio = 0;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Agregar alumno'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                onSaved: (v) => nombre = v!.trim(),
              ),
              // Repite para otros campos: apellido, grado, seccion, nivel, etc...
              // ...
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              await FirebaseFirestore.instance.collection('alumnos').add({
                'nombre': nombre,
                'apellido': apellido,
                'grado': grado,
                'seccion': seccion,
                'nivel': nivel,
                'numero_lista': numeroLista,
                'anio': anio,
              });

              Navigator.of(context).pop(true);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
