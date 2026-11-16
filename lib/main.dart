import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GlobioExamReadyApp());
}

class GlobioExamReadyApp extends StatelessWidget {
  const GlobioExamReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Am I exam-ready? · Globio',
      debugShowCheckedModeBanner: false,
      theme: GlobioTheme.light,
      home: const SplashScreen(),
    );
  }
}
