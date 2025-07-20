import 'package:flutter/material.dart';
import 'package:flutter_application_1_organizacion/src/pages/admin_user/csv_import_screen.dart';
import 'package:flutter_application_1_organizacion/src/pages/admin_user/edit_list_screen.dart';
import 'package:flutter_application_1_organizacion/src/pages/splash_screen.dart';
import 'package:flutter_application_1_organizacion/src/pages/home_screen.dart';
import 'package:flutter_application_1_organizacion/src/pages/login_screen.dart';
import 'package:flutter_application_1_organizacion/src/pages/register_screen.dart';
import 'package:flutter_application_1_organizacion/src/pages/common_user/common_user_home_screen.dart';
import 'package:flutter_application_1_organizacion/src/pages/admin_user/admin_user_home_screen.dart';

// Importaciones de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "splash",
      routes: {
        "splash": (context) => const SplashScreen(),
        "home": (context) => const HomeScreen(),
        "login": (context) => const LoginScreen(),
        "register": (context) => const RegisterScreen(),
        "user_home": (context) => const CommonUserHomeScreen(),
        "admin_home": (context) => const AdminUserHomeScreen(),
        "edit_list": (context) => const EditListScreen(),
        'csv_import': (context) => const CsvImportScreen(),
      },
    );
  }
}
