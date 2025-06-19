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
import 'package:OratioLingo/screens/diccionario.dart';
import 'package:OratioLingo/screens/theme_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:OratioLingo/screens/splash.dart';
import 'package:OratioLingo/widgets/admin_access_control.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
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
            scaffoldBackgroundColor: const Color.fromARGB(70, 0, 0, 0),
            cardColor: const Color(
              0xFF2C2C2C,
            ), // Color oscuro para las tarjetas
          ),
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/registrarme': (context) => const RegistrarmeScreen(),
            '/verificacion': (context) => const VerificacionScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),

            // Rutas de usuario
            '/niveles': (context) => const PantallaNiveles(),
            '/nivel1': (context) => const Nivel1Screen(),
            '/nivel2': (context) => const Nivel2Screen(),
            '/nivel3': (context) => const Nivel3Screen(),
            '/diccionario': (context) => const PantallaDiccionario(),
            '/juegos': (context) => const PantallaJuegos(),
            '/videos': (context) => const PantallaVideos(),
            '/perfil': (context) => const PantallaPerfil(),
            '/progreso': (context) => const PantallaProgreso(),

            // Rutas de administrador con control de acceso
            '/admin':
                (context) => AdminAccessControl(
                  adminScreen: const AdminDashboard(),
                  redirectScreen: const PantallaNiveles(),
                ),
            '/admin/gestionar-admins':
                (context) => AdminAccessControl(
                  adminScreen: const GestionarAdminsScreen(),
                  redirectScreen: const PantallaNiveles(),
                ),
            '/admin/gestionar-videos':
                (context) => AdminAccessControl(
                  adminScreen: const GestionarVideosScreen(),
                  redirectScreen: const PantallaNiveles(),
                ),
            '/admin/estadisticas':
                (context) => AdminAccessControl(
                  adminScreen: const EstadisticasScreen(),
                  redirectScreen: const PantallaNiveles(),
                ),
            '/admin/configuracion':
                (context) => AdminAccessControl(
                  adminScreen: const ConfiguracionScreen(),
                  redirectScreen: const PantallaNiveles(),
                ),
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
