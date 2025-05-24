import 'package:flutter/material.dart';
import 'package:gestos/screens/juegos.dart';
import 'package:gestos/screens/login.dart';
import 'package:gestos/screens/perfil.dart';
import 'package:gestos/screens/registrarme.dart';
import 'package:gestos/screens/niveles.dart';
import 'package:gestos/screens/videos.dart';
import 'package:gestos/screens/theme_notifier.dart'; // <-- Importa el notifier

void main() => runApp(const MyApp());

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
