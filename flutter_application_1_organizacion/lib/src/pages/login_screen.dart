// Importamos los paquetes necesarios
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

// Creamos un widget con estado llamado LoginScreen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Esta es la clase que maneja el estado de LoginScreen
class _LoginScreenState extends State<LoginScreen> {
  // Controladores para obtener el texto del usuario
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // Objeto Logger para imprimir información útil en consola
  final Logger logger = Logger();

  // Función asíncrona para manejar el inicio de sesión
  Future<void> _login() async {
    try {
      // Obtenemos y limpiamos los valores ingresados por el usuario
      final email = emailController.text
          .trim()
          .toLowerCase(); // Email en minúsculas sin espacios
      final password = passwordController.text
          .trim(); // Contraseña sin espacios

      // Intentamos iniciar sesión con Firebase Auth con los datos ingresado tomando en cuenta
      //principalmete el correo como ID y hay se compara la contraseña todo lo hace auth
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si inicia sesión, obtenemos su UID (identificador único de Firebase)
      final uid = credential.user!.uid;
      logger.i("UID obtenido tras login: $uid");

      // Buscamos en Firestore un documento en la colección 'users' que coincida con ese correo
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('correo', isEqualTo: email)
          .limit(1)
          .get();

      logger.i("Documentos encontrados: ${querySnapshot.docs.length}");

      // Si no encuentra el usuario en la base de datos, muestra error
      if (querySnapshot.docs.isEmpty) {
        logger.w("No existe el usuario con correo $email en Firestore.");
        _mostrarDialogo("Error", "No se encontró información del usuario.");
        return;
      }

      // Si encuentra el documento, obtenemos su información de rol
      final data = querySnapshot.docs.first.data();
      final rol = data['rol'];

      // Redirigimos al usuario según su rol
      if (rol == 'usuario') {
        Navigator.pushReplacementNamed(context, 'user_home');
      } else if (rol == 'administrador') {
        Navigator.pushReplacementNamed(context, 'admin_home');
      } else {
        _mostrarDialogo("Error", "Rol no reconocido: $rol");
      }
    } catch (e) {
      // Si ocurre un error (como credenciales inválidas), lo mostramos
      logger.e("Error al iniciar sesión: $e");
      _mostrarDialogo("Error", "Correo o contraseña incorrectos.");
    }
  }

  // Función para mostrar una ventana emergente con un mensaje
  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context), // Cierra el diálogo
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const azulGrisClaro = Color.fromARGB(
      255,
      175,
      183,
      197,
    ); // Color personalizado

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF), // Fondo gris claro no oficial
      appBar: AppBar(
        elevation: 0, // Sin sombra
        backgroundColor: Colors.transparent, // Fondo transparente
        leading: BackButton(color: Colors.black), // Botón para volver atrás
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ), // Espacio lateral
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo de la app
              Image.asset('assets/book.png', height: 100),
              const SizedBox(height: 16), // Espacio vertical
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 350,
                ), // Ancho máximo
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Bordes redondeados
                  ),
                  elevation: 8, // Sombra de la tarjeta
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // Título de la tarjeta
                          'Registro Anecdótico',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: azulGrisClaro,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          // Campo de texto para el correo
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Correo electrónico",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          // Campo de texto para la contraseña
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          // Botón para iniciar sesión
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: azulGrisClaro,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Ingresar"),
                        ),
                        const SizedBox(height: 12),
                        // Botón para ir a la pantalla de registro
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              'register',
                            ); // Navega a "register"
                          },
                          child: Text(
                            "¿No tienes cuenta? Regístrate aquí",
                            style: TextStyle(color: azulGrisClaro),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
