// lib/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:project_tpm_prak/bottomNavBar.dart';
import 'package:project_tpm_prak/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Fungsi untuk mengecek status login dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId'); // Ambil userId yang tersimpan

    // Tambahkan sedikit jeda agar splash screen terlihat
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return; // Pastikan widget masih ada di tree

    if (userId != null && userId.isNotEmpty) {
      // Jika ada userId (pengguna sudah login), navigasi ke halaman utama
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BottomNavbar()),
      );
    } else {
      // Jika tidak ada userId, navigasi ke halaman login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan sederhana untuk splash screen
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Memuat Aplikasi...'),
          ],
        ),
      ),
    );
  }
}
