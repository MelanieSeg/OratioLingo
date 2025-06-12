import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_services.dart';

class VerificacionScreen extends StatefulWidget {
  const VerificacionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VerificacionScreenState createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  final FirestoreServices _services = FirestoreServices();
  Timer? _timer;
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  int _remainingTime = 0;

  @override
  void initState() {
    super.initState();
    
    // Verificar si el usuario ya ha verificado el correo
    _checkEmailVerified();
    
    // Iniciar el temporizador que verifica periódicamente si el correo ha sido verificado
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    try {
      bool isVerified = await _services.verificarEstadoCorreo();
      
      if (isVerified && mounted) {
        setState(() => _isEmailVerified = true);
        _timer?.cancel();
        
        // Navegar a la pantalla principal después de un breve retraso
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
      }
    } catch (e) {
      print('Error al verificar correo: $e');
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail) return;
    
    try {
      await _services.reenviarCorreoVerificacion();
      
      setState(() {
        _canResendEmail = false;
        _remainingTime = 60; // 60 segundos de espera
      });
      
      // Temporizador para habilitar el reenvío después de 60 segundos
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTime > 0) {
          setState(() {
            _remainingTime--;
          });
        } else {
          setState(() {
            _canResendEmail = true;
          });
          timer.cancel();
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Correo de verificación reenviado'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al reenviar correo: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de correo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isEmailVerified ? Icons.verified : Icons.mark_email_unread,
                size: 80,
                color: _isEmailVerified ? Colors.green : theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                _isEmailVerified 
                  ? '¡Correo verificado exitosamente!' 
                  : 'Hemos enviado un correo de verificación a tu dirección de email.',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (!_isEmailVerified) ...[
                const Text(
                  'Por favor, revisa tu bandeja de entrada y haz clic en el enlace de verificación.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _canResendEmail ? _resendVerificationEmail : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_canResendEmail 
                    ? 'Reenviar correo de verificación' 
                    : 'Reenviar en $_remainingTime segundos'
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    _services.cerrarSesion();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Volver al inicio de sesión'),
                ),
              ],
              if (_isEmailVerified) ...[
                const SizedBox(height: 20),
                const Text(
                  'Serás redirigido a la aplicación automáticamente...',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}