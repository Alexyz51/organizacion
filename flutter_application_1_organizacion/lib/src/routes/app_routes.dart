import 'package:flutter/material.dart';
import '../pages/splash_screen.dart';
import '../pages/home_screen.dart';
import '../pages/login_screen.dart';
import '../pages/register_screen.dart';
import '../pages/common_user/common_user_home_screen.dart';
import '../pages/admin_user/admin_user_home_screen.dart';
import '../pages/admin_user/edit_list_screen/edit_list_screen.dart';
import '../pages/admin_user/edit_list_screen/csv_import_widget.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    "splash": (context) => const SplashScreen(),
    "home": (context) => const HomeScreen(),
    "login": (context) => const LoginScreen(),
    "register": (context) => const RegisterScreen(),
    "user_home": (context) => const CommonUserHomeScreen(),
    "admin_home": (context) => const AdminUserHomeScreen(),
    "edit_list": (context) => const EditListScreen(),
    "csv_import": (context) => const CsvImportWidget(),
  };
}
