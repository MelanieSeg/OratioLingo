import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Descomentar cuando se implemente Firebase

class PantallaProgreso extends StatefulWidget {
  const PantallaProgreso({super.key});

  @override
  State<PantallaProgreso> createState() => _PantallaProgresoState();
}

class _PantallaProgresoState extends State<PantallaProgreso> {
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Descomentar cuando se implemente Firebase

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior
            _buildTopBar(),
            
            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 100), // Espacio equivalente al marginTop
                      
                      // Título
                      const Text(
                        'Mi Progreso',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tarjeta de progreso general
                      _buildProgresoCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Sección de tiempo de estudio
                      _buildTiempoEstudioSection(),
                      
                      const SizedBox(height: 48),
                      
                      // Imagen y mensaje motivacional
                      _buildMensajeMotivacional(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icono de corazón coreano
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: Color(0xFF6a4c93),
              size: 24,
            ),
          ),
          
          // Botón de perfil
          GestureDetector(
            onTap: _mostrarModalPerfil,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF6a4c93),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgresoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Progreso general',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Barra de progreso
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: 0.1, // 10%
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6a4c93),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '10%',
                  style: TextStyle(
                    color: Color(0xFF6a4c93),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Estadísticas
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '0',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Módulos completados',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '2',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Niveles completados',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTiempoEstudioSection() {
    return Column(
      children: [
        const Text(
          'Tiempo de estudio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6a4c93).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      size: 40,
                      color: Color(0xFF6a4c93),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '5h 30m',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6a4c93),
                    ),
                  ),
                  const Text(
                    'Tiempo total',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6a4c93).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.timer,
                      size: 40,
                      color: Color(0xFF6a4c93),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '15m',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6a4c93),
                    ),
                  ),
                  const Text(
                    'Sesión promedio',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMensajeMotivacional() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF6a4c93).withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.favorite_outline,
            size: 50,
            color: Color(0xFF6a4c93),
          ),
        ),
        
        const SizedBox(height: 28),
        
        const Text(
          '¡Sigue así! ¡Vas por buen camino!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
          _buildNavItem('Videos', Icons.play_circle_outline, false, _abrirPantallaVideos),
          _buildNavItem('Juegos', Icons.games, false, _abrirPantallaJuegos),
          _buildNavItem('Progreso', Icons.bar_chart, true, null), // Pantalla actual
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

  void _abrirPantallaJuegos() {
    Navigator.of(context).pushNamed('/juegos');
  }

  void _abrirPantallaVideos() {
    Navigator.of(context).pushNamed('/videos');
  }

  void _abrirPantallaNiveles() {
    Navigator.of(context).pushNamed('/niveles');
  }

  void _abrirEditarPerfil() {
    Navigator.of(context).pushNamed('/perfil');
  }
}