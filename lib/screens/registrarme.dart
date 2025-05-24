import 'package:flutter/material.dart';

void main() => runApp(const RegistrarmeScreen());

class RegistrarmeScreen extends StatelessWidget {
  const RegistrarmeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Icon(
                Icons.fingerprint,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "Registrarme",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email, color: theme.iconTheme.color),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock, color: theme.iconTheme.color),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar Contraseña',
                prefixIcon: Icon(Icons.lock, color: theme.iconTheme.color),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Registrarme'),
            ),
          ],
        ),
      ),
    );
  }
}
