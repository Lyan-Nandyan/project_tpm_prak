import 'package:flutter/material.dart';
import 'package:project_tpm_prak/pages/splash_screen.dart'; 
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_tpm_prak/models/boxes.dart';
import 'package:project_tpm_prak/models/favorite.dart';
import 'package:project_tpm_prak/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(FavoriteAdapter());
  }

  await Hive.openBox<Favorite>(HiveBoxes.favorites);
  await Hive.openBox<User>(HiveBoxes.user);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.blueGrey,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueGrey.withOpacity(0.7),
            foregroundColor: Colors.white,
            elevation: 4,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          cardColor: Colors.white.withOpacity(0.1),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
            titleLarge:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(color: Colors.white70),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[850],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            hintStyle: TextStyle(color: Colors.grey[600]),
            labelStyle: const TextStyle(color: Colors.white70),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
            foregroundColor: Colors.blueGrey[200],
          )),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Colors.white,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.grey[900]?.withOpacity(0.85),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          )),
      home: const SplashScreen(),
    );
  }
}
