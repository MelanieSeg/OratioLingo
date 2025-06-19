import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // Simulamos un delay para mostrar el loading
      await Future.delayed(const Duration(seconds: 2));

      _mostrarDialogoExito();

      if (mounted) {
        setState(() {
          _emailController.clear();
        });
      }
    } catch (e) {
      _mostrarError(
        'Error al enviar el correo de recuperación. Inténtalo de nuevo.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.mark_email_read,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Correo enviado'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hemos enviado un enlace de recuperación a tu correo electrónico.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Correo: ${_emailController.text.trim()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Si no encuentras el correo, revisa tu carpeta de spam.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha(153), // ~0.6 opacity
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cambiar aquí'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  '/change-password',
                  arguments: _emailController.text.trim(),
                );
              },
            ),
            TextButton(
              child: const Text('Entendido'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los colores del tema actual para usar en los contenedores
    final Color containerColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.blue[50]!
            : Colors.blue[900]!.withAlpha(77); // ~0.3 opacity

    final Color containerBorderColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.blue[200]!
            : Colors.blue[700]!;

    final Color textFieldFillColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.grey[50]!
            : Colors.grey[800]!;

    return Scaffold(
      // Usar el color de fondo del tema
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón de regreso
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),

                const SizedBox(height: 20),

                // Logo y título
                Center(
                  child: Column(
                    children: [
                      // Logo de OratioLingo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Color adaptado al tema actual
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withAlpha(
                                    77,
                                  ) // 0.2 opacidad en modo oscuro
                                  : Theme.of(context).primaryColor.withAlpha(
                                    25,
                                  ), // 0.1 opacidad en modo claro
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        "¿Olvidaste tu contraseña?",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "No te preocupes, te ayudamos a recuperarla. Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha(179), // ~0.7 opacity
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Formulario
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Correo electrónico',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu correo electrónico',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withAlpha(77), // ~0.3 opacity
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: textFieldFillColor,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo electrónico';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Por favor ingresa un correo válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Botón de enviar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Enviar enlace de recuperación',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 30),

                // Enlace para volver al login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: TextSpan(
                        text: '¿Recordaste tu contraseña? ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha(179), // ~0.7 opacity
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Inicia sesión',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: containerBorderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.blue[700]
                                : Colors.blue[300],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Consejo de seguridad',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.blue[700]
                                        : Colors.blue[300],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'El enlace de recuperación expirará en 24 horas por tu seguridad.',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.blue[600]
                                        : Colors.blue[200],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
