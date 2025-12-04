import 'package:flutter/material.dart';
import 'package:kajjafisioapp/screens/startpage.dart';
import 'package:kajjafisioapp/utils/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToStart();
  }

  Future<void> _navigateToStart() async {
    // Simulasi waktu loading untuk splash screen
    await Future.delayed(const Duration(seconds: 3), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StartPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Warna latar belakang dari desain Anda
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menggunakan gambar Logo.jpg dari folder assets/images
            Image.asset(
              'assets/images/Logo_KJ.png', // Pastikan jalur ini benar
              height: 150, // Sesuaikan ukuran sesuai kebutuhan
            ),
            const SizedBox(height: 16),
            // Jika teks "KajjaFisio" adalah bagian dari gambar, Anda bisa menghapus Text widget ini
            // Jika tidak, biarkan saja atau sesuaikan warnanya agar kontras
            const Text(
              'KajjaFisio',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.black, // Sesuaikan warna teks agar terlihat jelas
              ),
            ),
          ],
        ),
      ),
    );
  }
}