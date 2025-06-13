import 'package:OratioLingo/screens/verificacion.dart';
import 'package:flutter/material.dart';
import 'package:OratioLingo/screens/juegos.dart';
import 'package:OratioLingo/screens/login.dart';
import 'package:OratioLingo/screens/perfil.dart';
import 'package:OratioLingo/screens/registrarme.dart';
import 'package:OratioLingo/screens/niveles.dart';
import 'package:OratioLingo/screens/videos.dart';
import 'package:OratioLingo/screens/theme_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:OratioLingo/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Request permissions on app start
  await Permission.storage.request();
  await Permission.camera.request();
  await Permission.photos.request();

  runApp(
    MaterialApp(
      home: FutureBuilder(
        future: Future.delayed(Duration.zero),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return const MyApp();
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Material App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Color(0xFF6A4C93),
            colorScheme: ColorScheme.light(primary: Color(0xFF6A4C93)),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Color(0xFF6A4C93),
            colorScheme: ColorScheme.dark(primary: Color(0xFF6A4C93)),
            scaffoldBackgroundColor: const Color(0xFF181818),
          ),
          themeMode: mode,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/registrarme': (context) => const RegistrarmeScreen(),
            '/verificacion': (context) => const VerificacionScreen(),
            '/niveles': (context) => const PantallaNiveles(),
            '/juegos': (context) => const PantallaJuegos(),
            '/videos': (context) => const PantallaVideos(),
            '/progreso': (context) => const PantallaProgreso(),
            '/perfil': (context) => const PantallaPerfil(),
          },
        );
      },
    );
  }
}
