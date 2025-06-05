import 'package:flutter/material.dart';
import 'package:project_tpm_prak/bottomNavBar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.blueGrey,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueGrey.withOpacity(0.5),
            foregroundColor: Colors.white,
            elevation: 4,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          cardColor: Colors.white.withOpacity(0.08),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Colors.white,
          ),
        ),
        home: BottomNavbar());
  }
}
