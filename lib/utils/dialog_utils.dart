import 'package:flutter/material.dart';
import 'package:OratioLingo/services/firestore_services.dart';

class DialogUtils {
  static Future<void> mostrarDialogoCerrarSesion(
    BuildContext context,
    FirestoreServices firestoreServices,
  ) async {
    final ThemeData themeData = Theme.of(context);
    final isDarkMode = themeData.brightness == Brightness.dark;

    // Mostrar diálogo de confirmación
    bool confirmar =
        await showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
              title: Text(
                '¿Cerrar sesión?',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              content: Text(
                '¿Estás seguro de que deseas cerrar sesión?',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: const Color(0xFF6A4C93)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4C93),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            );
          },
        ) ??
        false;

    // Si el usuario confirma, proceder con el cierre de sesión
    if (confirmar) {
      try {
        await firestoreServices.cerrarSesion();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al cerrar sesión: $e',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
