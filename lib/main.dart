import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Supabase!
import 'package:supabase_flutter/supabase_flutter.dart';

// Import semua halaman aplikasi
import 'screens/splash_page.dart';
import 'screens/startpage.dart';
import 'screens/register_page.dart';
import 'screens/login_page.dart';
import 'screens/pasien/home_pasien.dart' as home_pasien;
import 'screens/pasien/order_fisio_pasien.dart' as order_fisio_pasien;
import 'screens/pasien/order_detail_pasien.dart' as order_detail_pasien;
import 'screens/pasien/my_orders_pasien.dart' as my_orders_pasien;
import 'screens/pasien/profil_pasien.dart' as pasien_profile;
import 'screens/admin/my_orders_admin.dart' as my_orders_admin;
import 'screens/admin/order_detail_admin.dart' as order_detail_admin;
import 'screens/admin/profil_admin.dart' as admin_profile;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://jarjxsbkzqparjqjswyi.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imphcmp4c2JrenFwYXJqcWpzd3lpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3NDc0MjIsImV4cCI6MjA2OTMyMzQyMn0.GZ8JdT2SRVA6IsoL6qee6QGp9PYEoFMnI_IP_TgiuAU',
    );

    // Initialize Google Fonts
    GoogleFonts.config.allowRuntimeFetching = true;
    runApp(const KajjaFisioApp());
  } catch (e, s) {
    debugPrint("Firebase/Supabase initialization failed: $e");
    debugPrint("Stack trace: $s");
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            "Gagal memulai aplikasi. Cek koneksi internet, konfigurasi Firebase, atau Supabase.",
            style: TextStyle(color: Colors.red, fontFamily: 'Montserrat'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }
}

class KajjaFisioApp extends StatelessWidget {
  const KajjaFisioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KajjaFisio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.montserrat().fontFamily,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF4CAF50),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.montserrat(),
          hintStyle: GoogleFonts.montserrat(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/start': (context) => const StartPage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/home_pasien': (context) => const home_pasien.HomePasienPage(),
        '/order_pasien': (context) => const order_fisio_pasien.OrderFisioPasienPage(),
        '/myorders_pasien': (context) => const my_orders_pasien.MyOrdersPasienPage(),
        '/profile_pasien': (context) => const pasien_profile.ProfilePasienPage(),
        '/myorders_admin': (context) => const my_orders_admin.MyOrdersAdminPage(),
        '/profile_admin': (context) => const admin_profile.ProfileAdminPage(),
      },
      onGenerateRoute: (settings) {
        try {
          switch (settings.name) {
            case '/order_detail_pasien':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              if (args['orderId'] == null) {
                throw Exception('orderId is required for order detail page');
              }
              return MaterialPageRoute(
                builder: (context) => order_detail_pasien.OrderDetailPasienPage(
                  orderId: args['orderId'] as String,
                  orderData: args['orderData'],
                ),
              );
            case '/order_detail_admin':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              if (args['orderId'] == null) {
                throw Exception('orderId is required for admin order detail page');
              }
              return MaterialPageRoute(
                builder: (context) => order_detail_admin.OrderDetailAdminPage(
                  orderId: args['orderId'] as String,
                  orderData: args['orderData'],
                ),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Halaman tidak ditemukan',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${settings.name} tidak tersedia',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Kembali'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
          }
        } catch (e) {
          debugPrint('Error in route generation: $e');
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Text(
                  'Terjadi kesalahan: ${e.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
