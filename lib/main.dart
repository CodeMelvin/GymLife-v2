import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/admin/admin_page.dart';
import 'screens/auth/auth_slider_page.dart';
import 'screens/auth/forgot_password_page.dart';
import 'screens/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  runApp(const GymLifeApp());
}

class GymLifeApp extends StatelessWidget {
  const GymLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymLife',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthSliderPage(),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/home': (_) => const HomePage(),
        '/admin': (_) => const AdminPage(),
      },
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4C7FFF),
        useMaterial3: true,
      ),
    );
  }
}
