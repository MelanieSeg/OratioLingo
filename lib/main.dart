import 'package:OratioLingo/screens/levels/nivel1.dart';
import 'package:OratioLingo/screens/levels/nivel2.dart';
import 'package:OratioLingo/screens/levels/nivel3.dart';
import 'package:OratioLingo/screens/sesion/change-password.dart';
import 'package:OratioLingo/screens/sesion/verificacion.dart';
import 'package:flutter/material.dart';
import 'package:OratioLingo/screens/juegos.dart';
import 'package:OratioLingo/screens/sesion/login.dart';
import 'package:OratioLingo/screens/perfil.dart';
import 'package:OratioLingo/screens/sesion/registrarme.dart';
import 'package:OratioLingo/screens/niveles.dart';
import 'package:OratioLingo/screens/videos.dart';
import 'package:OratioLingo/screens/theme_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:OratioLingo/screens/progreso.dart';
import 'package:OratioLingo/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:OratioLingo/screens/sesion/forgot-password.dart';
//pantallas de admin
import 'package:OratioLingo/screens/admin/dashboard.dart';
import 'package:OratioLingo/screens/admin/gestionar_admins.dart';
import 'package:OratioLingo/screens/admin/gestionar_videos.dart';
import 'package:OratioLingo/screens/admin/estadisticas.dart';
import 'package:OratioLingo/screens/admin/configuracion.dart';

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
          title: 'OratioLingo',
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
            '/forgot-password': (context) => const ForgotPasswordScreen(),

            // Rutas de usuario
            '/niveles': (context) => const PantallaNiveles(),
            '/nivel1': (context) => const Nivel1Screen(),
            '/nivel2': (context) => const Nivel2Screen(),
            '/nivel3': (context) => const Nivel3Screen(),
            '/juegos': (context) => const PantallaJuegos(),
            '/videos': (context) => const PantallaVideos(),
            '/perfil': (context) => const PantallaPerfil(),
            '/progreso': (context) => const PantallaProgreso(),

            // Rutas de administrador
            '/admin': (context) => const AdminDashboard(),
            '/admin/gestionar-admins':
                (context) => const GestionarAdminsScreen(),
            '/admin/gestionar-videos':
                (context) => const GestionarVideosScreen(),
            '/admin/estadisticas': (context) => const EstadisticasScreen(),
            '/admin/configuracion': (context) => const ConfiguracionScreen(),
          },

          // Manejar rutas con argumentos
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/change-password':
                final email = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => ChangePasswordScreen(email: email),
                );
              default:
                return null;
            }
          },
        );
      },
    );
  }
}
