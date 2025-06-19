import 'package:flutter/material.dart';
import 'package:OratioLingo/services/auth_service.dart';

class AdminAccessControl extends StatefulWidget {
  final Widget adminScreen;
  final Widget redirectScreen;

  const AdminAccessControl({
    super.key,
    required this.adminScreen,
    required this.redirectScreen,
  });

  @override
  State<AdminAccessControl> createState() => _AdminAccessControlState();
}

class _AdminAccessControlState extends State<AdminAccessControl> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await _authService.esAdministrador();

      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
          _isLoading = false;
        });

        // Si no es administrador, redirigir inmediatamente
        if (!isAdmin) {
          // Usando un pequeño delay para permitir que el widget se monte completamente
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => widget.redirectScreen),
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAdmin = false;
          _isLoading = false;
        });

        // En caso de error, también redirigir
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => widget.redirectScreen),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Solo muestra la pantalla de admin si tiene permisos
    return widget.adminScreen;
  }
}
