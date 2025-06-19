import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:OratioLingo/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      // Pequeña espera para mostrar el splash
      await Future.delayed(const Duration(seconds: 2));

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Recargar el usuario para obtener el estado más reciente
        await user.reload();

        // Usuario ya está autenticado
        final isAdmin = await _authService.esAdministrador();

        if (mounted) {
          if (isAdmin) {
            Navigator.of(context).pushReplacementNamed('/admin');
          } else {
            Navigator.of(context).pushReplacementNamed('/niveles');
          }
        }
      } else {
        // No hay usuario autenticado, ir a login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      // En caso de error, ir a login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A4C93),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'OratioLingo',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
