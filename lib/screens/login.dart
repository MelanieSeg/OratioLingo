import 'dart:io';

import 'package:flutter/material.dart';
import '../services/firestore_services.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              SizedBox(height: 40),
              // Encabezado del login
              LoginHeader(),
              SizedBox(height: 40),
              // Formulario de login
              LoginForm(),
              SizedBox(height: 20),
              // Footer del login
              LoginFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para la parte superior del login
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo de la aplicación
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            image: DecorationImage(
              image: AssetImage('lib/assets/images/logo.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Título de la aplicación
        Text(
          'OratioLingo',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        // Subtítulo o slogan
        Text(
          'Aprende idiomas de forma natural',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Widget para el formulario de login
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreServices = FirestoreServices();
      await firestoreServices.iniciarSesion(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Si llegamos aquí, el inicio de sesión fue exitoso
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/niveles');
      }
    } catch (e) {
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título del formulario
          Text(
            'Iniciar sesión',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 24),

          // Campo de email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa tu correo electrónico';
              }
              if (!RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$',
              ).hasMatch(value)) {
                return 'Ingresa un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Campo de contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingresa tu contraseña';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Olvidé mi contraseña
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navegar a la pantalla de recuperación de contraseña
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          const SizedBox(height: 24),

          // Botón de iniciar sesión
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
                      'Iniciar sesión',
                      style: TextStyle(fontSize: 16),
                    ),
          ),
        ],
      ),
    );
  }
}

// Widget para el footer del login
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Separador
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('O', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        // Opción para registro
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No tienes una cuenta?',
              style: TextStyle(color: Colors.grey[700]),
            ),
            TextButton(
              onPressed: () {
                // Navegar a la pantalla de registro
                Navigator.pushNamed(context, '/registrarme');
              },
              child: const Text('Regístrate'),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
