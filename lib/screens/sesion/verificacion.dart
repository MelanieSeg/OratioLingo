import 'dart:async';
import 'package:OratioLingo/screens/sesion/login.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_services.dart';

class VerificacionScreen extends StatefulWidget {
  const VerificacionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VerificacionScreenState createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  final FirestoreServices _services = FirestoreServices();
  Timer? _timer;
  Timer? _redirectTimer;
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  int _remainingTime = 0;
  int _redirectCountdown = 4; // Contador para la redirección

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
    _redirectTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    try {
      bool isVerified = await _services.verificarEstadoCorreo();

      if (isVerified && mounted) {
        setState(() => _isEmailVerified = true);
        _timer?.cancel();

        // Iniciar contador de redirección de 4 segundos
        _startRedirectCountdown();
      }
    } catch (e) {
      print('Error al verificar correo: $e');
    }
  }

  void _startRedirectCountdown() {
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_redirectCountdown > 0) {
        setState(() {
          _redirectCountdown--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });
  }

  void _redirectNow() {
    _redirectTimer?.cancel();
    Navigator.pop(context); // Cerrar el diálogo si está abierto
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo de verificación reenviado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reenviar correo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verificación de correo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isEmailVerified ? Icons.verified : Icons.mark_email_unread,
                size: 80,
                color:
                    _isEmailVerified ? Colors.green : theme.colorScheme.primary,
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
                  child: Text(
                    _canResendEmail
                        ? 'Reenviar correo de verificación'
                        : 'Reenviar en $_remainingTime segundos',
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
                // Contador visual de redirección
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: (_redirectCountdown / 4),
                              backgroundColor: Colors.green[100],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green[600]!,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Redirigiendo al login en $_redirectCountdown segundos...',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _redirectNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Ir al login ahora'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
