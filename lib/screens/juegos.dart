import 'package:flutter/material.dart';
import 'package:gestos/screens/niveles.dart';
import 'package:gestos/screens/perfil.dart';
import 'package:gestos/screens/videos.dart';

class PantallaJuegos extends StatefulWidget {
  const PantallaJuegos({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PantallaJuegosState createState() => _PantallaJuegosState();
}

class _PantallaJuegosState extends State<PantallaJuegos> {
  bool _isModalVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf5f5f5),
      body: Column(
        children: [
          // Barra superior
          _buildTopBar(),
          // Contenido principal (área vacía para juegos)
          Expanded(
            child: _buildGamesContent(),
          ),
          // Barra de navegación inferior
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60 + MediaQuery.of(context).padding.top,
      color: Color(0xFF6a4c93),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    color: Color(0xFF6a4c93),
                    size: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _toggleModal,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
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
      ),
    );
  }

  Widget _buildGamesContent() {
    // ignore: sized_box_for_whitespace
    return Container(
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.games,
              size: 80,
              color: Color(0xFF6a4c93),
            ),
            SizedBox(height: 20),
            Text(
              "Juegos",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6a4c93),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Próximamente aquí encontrarás\njuegos divertidos para aprender",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
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
          _buildNavItem(Icons.layers, "Niveles", false),
          _buildNavItem(Icons.play_circle_outline, "Videos", false),
          _buildNavItem(Icons.games, "Juegos", true), // Esta pantalla está activa
          _buildNavItem(Icons.trending_up, "Progreso", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTap(label),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Color(0xFF6a4c93) : Color(0xFF666666),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Color(0xFF6a4c93) : Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleModal() {
    setState(() {
      _isModalVisible = !_isModalVisible;
    });
    
    if (_isModalVisible) {
      _showProfileModal();
    }
  }

  void _showProfileModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(20),
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
                    backgroundColor: Color(0xFF6a4c93),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Editar Perfil"),
                ),
              ),
              SizedBox(height: 12),
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
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Cerrar Sesión"),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        _isModalVisible = false;
      });
    });
  }

  void _onNavItemTap(String label) {
    switch (label) {
      case "Niveles":
        _abrirPantallaNiveles();
        break;
      case "Videos":
        _abrirPantallaVideos();
        break;
      case "Progreso":
        _abrirPantallaProgreso();
        break;
      case "Juegos":
        // Ya estamos en juegos
        break;
    }
  }

  void _cerrarSesion() {
    // TODO: Implementar Firebase auth.signOut()
    print("Cerrando sesión...");
    // Navegar a pantalla de login
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _abrirPantallaProgreso() {
    print("Abriendo pantalla de progreso...");
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => PantallaProgreso())
    );
  }

  void _abrirPantallaVideos() {
    print("Abriendo pantalla de videos...");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaVideos()));
  }

  void _abrirPantallaNiveles() {
    print("Abriendo pantalla de niveles...");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaNiveles()));
  }

  void _abrirEditarPerfil() {
    print("Abriendo editar perfil...");
    Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaPerfil()));
  }
}

// Placeholder para las otras pantallas (puedes eliminar esto cuando tengas las pantallas reales)
class PantallaProgreso extends StatelessWidget {
  const PantallaProgreso({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Progreso")),
      body: Center(child: Text("Pantalla de Progreso")),
    );
  }
}