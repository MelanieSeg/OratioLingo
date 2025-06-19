import 'package:OratioLingo/utils/password_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ChangePasswordScreen extends StatefulWidget {
  final String email;

  const ChangePasswordScreen({super.key, required this.email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Confirmar el código de reset y cambiar la contraseña
      await FirebaseAuth.instance.confirmPasswordReset(
        code: _codeController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      _mostrarDialogoExito();
    } catch (e) {
      String errorMessage = 'Error al cambiar la contraseña';

      if (e.toString().contains('invalid-action-code')) {
        errorMessage = 'El código de verificación no es válido o ha expirado';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'La contraseña es muy débil';
      }

      _mostrarError(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reenviarCodigo() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      _mostrarMensaje('Código reenviado a ${widget.email}', Colors.green);
    } catch (e) {
      _mostrarError('Error al reenviar el código');
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
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              const Text('¡Contraseña cambiada!'),
            ],
          ),
          content: const Text(
            'Tu contraseña ha sido actualizada exitosamente. Ahora puedes iniciar sesión con tu nueva contraseña.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text('Ir al inicio de sesión'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarError(String mensaje) {
    _mostrarMensaje(mensaje, Colors.red);
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colores que se adaptan al tema
    final Color textFieldFillColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.grey[50]!
            : Colors.grey[800]!;

    final Color counterBgColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.blue[50]!
            : Colors.blue[900]!.withAlpha(77);

    final Color counterBorderColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.blue[200]!
            : Colors.blue[700]!;

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
                                  ? Colors.white.withAlpha(77)
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
                        "Cambiar contraseña",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Ingresa el código de verificación que enviamos a ${widget.email} y tu nueva contraseña.",
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

                const SizedBox(height: 40),

                // Formulario
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Código de verificación
                      Text(
                        'Código de verificación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeController,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                hintText: 'Ingresa el código de 6 dígitos',
                                prefixIcon: const Icon(Icons.security),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
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
                                  return 'Ingresa el código de verificación';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: _reenviarCodigo,
                            child: const Text('Reenviar'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Nueva contraseña
                      Text(
                        'Nueva contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscurePassword,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu nueva contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
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
                          helperText: PasswordValidator.helperText,
                        ),
                        validator: PasswordValidator.validate,
                      ),

                      const SizedBox(height: 20),

                      // Confirmar contraseña
                      Text(
                        'Confirmar contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Confirma tu nueva contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
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
                            return 'Por favor confirma tu contraseña';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Botón de cambiar contraseña
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
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
                              'Cambiar contraseña',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),

                // Contador de redirección
                if (_isLoading)
                  Center(
                    child: _ContadorRedireccion(
                      counterBgColor: counterBgColor,
                      counterBorderColor: counterBorderColor,
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

// Widget para mostrar el contador de redirección
class _ContadorRedireccion extends StatefulWidget {
  final Color counterBgColor;
  final Color counterBorderColor;

  const _ContadorRedireccion({
    required this.counterBgColor,
    required this.counterBorderColor,
  });

  @override
  State<_ContadorRedireccion> createState() => _ContadorRedireccionState();
}

class _ContadorRedireccionState extends State<_ContadorRedireccion> {
  int _segundosRestantes = 4;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarContador();
  }

  void _iniciarContador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _segundosRestantes--;
      });

      if (_segundosRestantes <= 0) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.blue[700]
            : Colors.blue[300];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.counterBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.counterBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: (_segundosRestantes / 4),
              backgroundColor:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.blue[100]
                      : Colors.blue[700],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).brightness == Brightness.light
                    ? Colors.blue[600]!
                    : Colors.blue[300]!,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Redirigiendo en $_segundosRestantes segundos...',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
