import 'package:flutter/material.dart';
import 'package:gestos/screens/juegos.dart';
import 'package:gestos/screens/login.dart';
import 'package:gestos/screens/perfil.dart';
import 'package:gestos/screens/registrarme.dart';
import 'package:gestos/screens/niveles.dart';
import 'package:gestos/screens/videos.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
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
  }
}