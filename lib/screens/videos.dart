import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Descomentar cuando se implemente Firebase

class PantallaVideos extends StatefulWidget {
  const PantallaVideos({super.key});

  @override
  State<PantallaVideos> createState() => _PantallaVideosState();
}

class _PantallaVideosState extends State<PantallaVideos> {
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Descomentar cuando se implemente Firebase

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior
            _buildTopBar(),
            
            // Contenido principal - Por ahora vacío, aquí irán los videos
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[50],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library,
                        size: 80,
                        color: Color(0xFF6a4c93),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Videos de Aprendizaje',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6a4c93),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Próximamente: Contenido de videos\npara mejorar tu aprendizaje',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Barra de navegación inferior
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      color: const Color(0xFF6a4c93),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo centrado
          Expanded(
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school, // Placeholder para el logo
                  color: Color(0xFF6a4c93),
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Botón de perfil
          GestureDetector(
            onTap: _mostrarModalPerfil,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.person,
                  color: Color(0xFF6a4c93),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem('Niveles', Icons.layers, false, _abrirPantallaNiveles),
          _buildNavItem('Videos', Icons.play_circle_outline, true, null), // Pantalla actual
          _buildNavItem('Juegos', Icons.games, false, _abrirPantallaJuegos),
          _buildNavItem('Progreso', Icons.bar_chart, false, _abrirPantallaProgreso),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isActive, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? const Color(0xFF6a4c93) : const Color(0xFF666666),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? const Color(0xFF6a4c93) : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarModalPerfil() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Opciones de Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _abrirEditarPerfil();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6a4c93),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Editar Perfil'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _cerrarSesion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cerrar Sesión'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _cerrarSesion() {
    // TODO: Implementar Firebase Auth cuando esté disponible
    /*
    _auth.signOut().then((_) {
      if (_auth.currentUser == null) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
    */
    
    // Por ahora, navegación temporal
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _abrirPantallaProgreso() {
    Navigator.of(context).pushNamed('/progreso');
  }

  void _abrirPantallaJuegos() {
    Navigator.of(context).pushNamed('/juegos');
  }

  void _abrirPantallaNiveles() {
    Navigator.of(context).pushNamed('/niveles');
  }

  void _abrirEditarPerfil() {
    Navigator.of(context).pushNamed('/perfil');
  }
}